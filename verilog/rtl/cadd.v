module cadd (
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
	assign Y_real = A_real + B_real;
	assign Y_imag = A_imag + B_imag;
endmodule
