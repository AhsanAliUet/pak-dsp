module cmul (
	A_real,
	A_imag,
	B_real,
	B_imag,
	Y_real,
	Y_imag
);
	parameter DATA_WIDTH = 8;
	input wire signed [DATA_WIDTH - 1:0] A_real;
	input wire signed [DATA_WIDTH - 1:0] A_imag;
	input wire signed [DATA_WIDTH - 1:0] B_real;
	input wire signed [DATA_WIDTH - 1:0] B_imag;
	output wire signed [DATA_WIDTH - 1:0] Y_real;
	output wire signed [DATA_WIDTH - 1:0] Y_imag;
	wire signed [(2 * DATA_WIDTH) + 0:0] fp_real;
	wire signed [(2 * DATA_WIDTH) + 0:0] fp_imag;
	assign fp_real = (A_real * B_real) - (A_imag * B_imag);
	assign fp_imag = (A_real * B_imag) + (A_imag * B_real);
	function automatic [7:0] sat_pkg_sym_sat_9_8;
		input [8:0] in;
		reg [7:0] out;
		reg [7:0] max_pos;
		reg [7:0] max_neg;
		reg [7:0] max_neg_asym;
		begin
			max_pos = {1'b0, {7 {1'b1}}};
			max_neg = ~max_pos + 1;
			max_neg_asym = {1'b1, {7 {1'b0}}};
			if (&in[8:7] || &(~in[8:7]))
				out = (1 && ($signed(in) == $signed({max_neg_asym[7], max_neg_asym})) ? max_neg : in[7:0]);
			else
				out = (in[8] == 1'b1 ? max_neg : max_pos);
			sat_pkg_sym_sat_9_8 = out;
		end
	endfunction
	assign Y_real = sat_pkg_sym_sat_9_8(fp_real[DATA_WIDTH:0]);
	assign Y_imag = sat_pkg_sym_sat_9_8(fp_imag[DATA_WIDTH:0]);
endmodule
