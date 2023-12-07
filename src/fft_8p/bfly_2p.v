module bfly_2p (
	A_real,
	A_imag,
	B_real,
	B_imag,
	W_real,
	W_imag,
	Y0_real,
	Y0_imag,
	Y1_real,
	Y1_imag
);
	parameter DATA_WIDTH = 16;
	input wire signed [DATA_WIDTH - 1:0] A_real;
	input wire signed [DATA_WIDTH - 1:0] A_imag;
	input wire signed [DATA_WIDTH - 1:0] B_real;
	input wire signed [DATA_WIDTH - 1:0] B_imag;
	input wire signed [DATA_WIDTH - 1:0] W_real;
	input wire signed [DATA_WIDTH - 1:0] W_imag;
	output wire signed [DATA_WIDTH - 1:0] Y0_real;
	output wire signed [DATA_WIDTH - 1:0] Y0_imag;
	output wire signed [DATA_WIDTH - 1:0] Y1_real;
	output wire signed [DATA_WIDTH - 1:0] Y1_imag;
	wire signed [DATA_WIDTH - 1:0] mult_res_real;
	wire signed [DATA_WIDTH - 1:0] mult_res_imag;
	cmul #(.DATA_WIDTH(DATA_WIDTH)) i_cmul(
		.A_real(B_real),
		.A_imag(B_imag),
		.B_real(W_real),
		.B_imag(W_imag),
		.Y_real(mult_res_real),
		.Y_imag(mult_res_imag)
	);
	cadd #(.DATA_WIDTH(DATA_WIDTH)) i_cadd_0(
		.A_real(A_real),
		.A_imag(A_imag),
		.B_real(mult_res_real),
		.B_imag(mult_res_imag),
		.Y_real(Y0_real),
		.Y_imag(Y0_imag)
	);
	cadd #(.DATA_WIDTH(DATA_WIDTH)) i_cadd_1(
		.A_real(A_real),
		.A_imag(A_imag),
		.B_real(~mult_res_real + 1),
		.B_imag(~mult_res_imag + 1),
		.Y_real(Y1_real),
		.Y_imag(Y1_imag)
	);
endmodule
