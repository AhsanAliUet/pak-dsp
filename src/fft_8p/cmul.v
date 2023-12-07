module cmul (
	A_real,
	A_imag,
	B_real,
	B_imag,
	Y_real,
	Y_imag
);
	parameter DATA_WIDTH = 16;
	input wire signed [DATA_WIDTH - 1:0] A_real;
	input wire signed [DATA_WIDTH - 1:0] A_imag;
	input wire signed [DATA_WIDTH - 1:0] B_real;
	input wire signed [DATA_WIDTH - 1:0] B_imag;
	output wire signed [DATA_WIDTH - 1:0] Y_real;
	output wire signed [DATA_WIDTH - 1:0] Y_imag;
	function automatic signed [15:0] truncator_16_16_8_8;
		input reg signed [31:0] sig_i;
		localparam MSB_I = 31;
		localparam SAT_LO = {{8 {1'b1}}, {8 {1'b0}}};
		localparam SAT_HI = {{8 {1'b0}}, {8 {1'b1}}};
		reg [15:0] data_out;
		begin
			data_out = sig_i[23:8];
			truncator_16_16_8_8 = data_out;
		end
	endfunction
	assign Y_real = truncator_16_16_8_8(A_real * B_real) - truncator_16_16_8_8(A_imag * B_imag);
	assign Y_imag = truncator_16_16_8_8(A_real * B_imag) + truncator_16_16_8_8(A_imag * B_real);
endmodule
