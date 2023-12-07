module fir_filter (
	clk,
	arst_n,
	bypass,
	coeff,
	data_in,
	valid_in,
	src_ready_out,
	data_out,
	valid_out,
	dst_ready_in
);
	parameter INPUT_WORD_SIZE = 16;
	parameter COEFF_WORD_SIZE = 16;
	parameter N_COEFFS = 5;
	localparam OUTPUT_WORD_SIZE = (INPUT_WORD_SIZE + COEFF_WORD_SIZE) + $clog2(N_COEFFS - 1);
	input wire clk;
	input wire arst_n;
	input wire bypass;
	input wire signed [(N_COEFFS * COEFF_WORD_SIZE) - 1:0] coeff;
	input wire signed [INPUT_WORD_SIZE - 1:0] data_in;
	input wire valid_in;
	output wire src_ready_out;
	output wire signed [OUTPUT_WORD_SIZE - 1:0] data_out;
	output reg valid_out;
	input wire dst_ready_in;
	localparam DELAY_LINE_SIZE = N_COEFFS - 1;
	localparam X = INPUT_WORD_SIZE - 1;
	localparam Y = COEFF_WORD_SIZE - 1;
	localparam Z = OUTPUT_WORD_SIZE - (X + Y);
	localparam MSB_BP_DATA = INPUT_WORD_SIZE - 1;
	reg signed [INPUT_WORD_SIZE - 1:0] delay_line [DELAY_LINE_SIZE - 1:0];
	reg signed [OUTPUT_WORD_SIZE - 1:0] data_out_interm;
	wire signed [OUTPUT_WORD_SIZE - 1:0] bp_data;
	assign src_ready_out = dst_ready_in;
	always @(posedge clk or negedge arst_n)
		if (~arst_n) begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < DELAY_LINE_SIZE; i = i + 1)
				delay_line[i] <= 0;
		end
		else if (valid_in) begin
			begin : sv2v_autoblock_2
				reg signed [31:0] i;
				for (i = 0; i < DELAY_LINE_SIZE; i = i + 1)
					delay_line[i + 1] <= delay_line[i];
			end
			delay_line[0] <= data_in;
		end
	always @(*) begin
		data_out_interm = $signed(data_in) * $signed(coeff[0+:COEFF_WORD_SIZE]);
		begin : sv2v_autoblock_3
			reg signed [31:0] i;
			for (i = 0; i < DELAY_LINE_SIZE; i = i + 1)
				data_out_interm = data_out_interm + ($signed(delay_line[i]) * $signed(coeff[(i + 1) * COEFF_WORD_SIZE+:COEFF_WORD_SIZE]));
		end
		valid_out = valid_in;
	end
	function automatic signed [Y - 1:0] sv2v_cast_ADE2E_signed;
		input reg signed [Y - 1:0] inp;
		sv2v_cast_ADE2E_signed = inp;
	endfunction
	assign bp_data = {{{Z - 1} {data_in[MSB_BP_DATA]}}, data_in, sv2v_cast_ADE2E_signed(0)};
	assign data_out = (bypass ? bp_data : data_out_interm);
endmodule
