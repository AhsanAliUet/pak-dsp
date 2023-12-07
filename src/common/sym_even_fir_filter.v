module sym_even_fir_filter (
	clk,
	arst_n,
	data_in,
	valid_in,
	data_out,
	valid_out
);
	parameter INPUT_WORD_SIZE = 16;
	parameter COEFF_WORD_SIZE = 16;
	parameter N_COEFFS = 5;
	parameter signed [(N_COEFFS * COEFF_WORD_SIZE) - 1:0] COEFFS = {N_COEFFS {0}};
	localparam OUTPUT_WORD_SIZE = ((INPUT_WORD_SIZE + COEFF_WORD_SIZE) + $clog2(N_COEFFS)) + 1;
	input wire clk;
	input wire arst_n;
	input wire signed [INPUT_WORD_SIZE - 1:0] data_in;
	input wire valid_in;
	output wire signed [OUTPUT_WORD_SIZE - 1:0] data_out;
	output wire valid_out;
	reg signed [INPUT_WORD_SIZE - 1:0] delay_line [(2 * N_COEFFS) - 2:0];
	wire signed [INPUT_WORD_SIZE:0] pre_adder [N_COEFFS - 1:0];
	wire signed [OUTPUT_WORD_SIZE - 1:0] adder_out [N_COEFFS - 2:0];
	wire signed [OUTPUT_WORD_SIZE - 1:0] adder [N_COEFFS - 2:0];
	wire signed [OUTPUT_WORD_SIZE - 1:0] product_out [N_COEFFS - 1:0];
	assign pre_adder[0] = data_in + delay_line[(2 * N_COEFFS) - 2];
	genvar I;
	generate
		for (I = 0; I < (N_COEFFS - 1); I = I + 1) begin : genblk1
			assign pre_adder[I + 1] = delay_line[I] + delay_line[((2 * N_COEFFS) - 3) - I];
		end
	endgenerate
	genvar j;
	generate
		for (j = 0; j < N_COEFFS; j = j + 1) begin : genblk2
			assign product_out[j] = $signed(pre_adder[j]) * $signed(COEFFS[j * COEFF_WORD_SIZE+:COEFF_WORD_SIZE]);
		end
		if (N_COEFFS <= 1) begin : genblk3
			assign adder[0] = product_out[0];
		end
		else begin : genblk3
			assign adder[0] = product_out[0] + product_out[1];
			genvar I;
			for (I = 1; I < (N_COEFFS - 1); I = I + 1) begin : genblk1
				assign adder[I] = adder_out[I - 1] + product_out[I + 1];
			end
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
			for (i = 0; i <= ((2 * N_COEFFS) - 2); i = i + 1)
				delay_line[i] <= 1'sb0;
		end
		else if (valid_in) begin
			begin : sv2v_autoblock_2
				reg signed [31:0] i;
				for (i = 0; i <= ((2 * N_COEFFS) - 2); i = i + 1)
					delay_line[i + 1] <= delay_line[i];
			end
			delay_line[0] <= data_in;
		end
endmodule
