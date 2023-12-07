module sym_odd_fir_filter (
	clk,
	arst_n,
	data_in,
	valid_in,
	data_out,
	valid_out
);
	parameter INPUT_WORD_SIZE = 16;
	parameter COEFF_WORD_SIZE = 5;
	parameter N_COEFFS = 5;
	parameter signed [(N_COEFFS * COEFF_WORD_SIZE) - 1:0] COEFFS = 10'h0c1;
	localparam OUTPUT_WORD_SIZE = ((INPUT_WORD_SIZE + COEFF_WORD_SIZE) + $clog2(N_COEFFS)) + 1;
	input wire clk;
	input wire arst_n;
	input wire signed [INPUT_WORD_SIZE - 1:0] data_in;
	input wire valid_in;
	output wire signed [OUTPUT_WORD_SIZE - 1:0] data_out;
	output wire valid_out;
	reg signed [INPUT_WORD_SIZE - 1:0] delay_line [(2 * N_COEFFS) - 3:0];
	wire signed [INPUT_WORD_SIZE:0] pre_adder [N_COEFFS - 1:0];
	wire signed [OUTPUT_WORD_SIZE - 1:0] product_out [N_COEFFS - 1:0];
	wire signed [OUTPUT_WORD_SIZE - 1:0] adder_out [N_COEFFS - 2:0];
	wire signed [OUTPUT_WORD_SIZE - 1:0] adder [N_COEFFS - 2:0];
	generate
		if (N_COEFFS <= 1) begin : genblk1
			assign pre_adder[0] = {data_in[INPUT_WORD_SIZE - 1], data_in};
		end
		else begin : genblk1
			genvar i;
			for (i = 0; i < (N_COEFFS - 2); i = i + 1) begin : genblk1
				assign pre_adder[i + 1] = delay_line[i] + delay_line[((2 * N_COEFFS) - 4) - i];
			end
			assign pre_adder[N_COEFFS - 1] = {delay_line[N_COEFFS - 2][INPUT_WORD_SIZE - 1], delay_line[N_COEFFS - 2]};
			assign pre_adder[0] = data_in + delay_line[(2 * N_COEFFS) - 3];
		end
	endgenerate
	genvar i;
	generate
		for (i = 0; i < N_COEFFS; i = i + 1) begin : genblk2
			assign product_out[i] = $signed(pre_adder[i]) * $signed(COEFFS[i * COEFF_WORD_SIZE+:COEFF_WORD_SIZE]);
		end
	endgenerate
	assign adder[0] = product_out[0] + product_out[1];
	genvar I;
	generate
		for (I = 1; I < (N_COEFFS - 1); I = I + 1) begin : genblk3
			assign adder[I] = adder_out[I - 1] + product_out[I + 1];
		end
		if (N_COEFFS <= 1) begin : genblk4
			assign data_out = product_out[0];
			assign valid_out = valid_in;
		end
		else begin : genblk4
			assign data_out = adder[N_COEFFS - 2];
			assign valid_out = valid_in;
		end
	endgenerate
	always @(posedge clk or negedge arst_n)
		if (~arst_n) begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i <= ((2 * N_COEFFS) - 3); i = i + 1)
				delay_line[i] <= 0;
		end
		else if (valid_in) begin
			begin : sv2v_autoblock_2
				reg signed [31:0] i;
				for (i = 0; i <= ((2 * N_COEFFS) - 3); i = i + 1)
					delay_line[i + 1] <= delay_line[i];
			end
			delay_line[0] <= data_in;
		end
endmodule
