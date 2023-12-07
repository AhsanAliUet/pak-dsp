module butterfly (
	data_1_in_real,
	data_1_in_imag,
	data_2_in_real,
	data_2_in_imag,
	data_1_out_real,
	data_1_out_imag,
	data_2_out_real,
	data_2_out_imag
);
	parameter DATAWIDTH = 16;
	input wire signed [DATAWIDTH - 1:0] data_1_in_real;
	input wire signed [DATAWIDTH - 1:0] data_1_in_imag;
	input wire signed [DATAWIDTH - 1:0] data_2_in_real;
	input wire signed [DATAWIDTH - 1:0] data_2_in_imag;
	output wire signed [DATAWIDTH - 1:0] data_1_out_real;
	output wire signed [DATAWIDTH - 1:0] data_1_out_imag;
	output wire signed [DATAWIDTH - 1:0] data_2_out_real;
	output wire signed [DATAWIDTH - 1:0] data_2_out_imag;
	reg signed [DATAWIDTH + 0:0] data_1_real_fp;
	reg signed [DATAWIDTH + 0:0] data_1_imag_fp;
	reg signed [DATAWIDTH + 0:0] data_2_real_fp;
	reg signed [DATAWIDTH + 0:0] data_2_imag_fp;
	always @(*) begin
		data_1_real_fp = data_1_in_real + data_2_in_real;
		data_1_imag_fp = data_1_in_imag + data_2_in_imag;
		data_2_real_fp = data_1_in_real - data_2_in_real;
		data_2_imag_fp = data_1_in_imag - data_2_in_imag;
	end
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
	assign data_1_out_real = sat_pkg_sym_sat_9_8(data_1_real_fp);
	assign data_1_out_imag = sat_pkg_sym_sat_9_8(data_1_imag_fp);
	assign data_2_out_real = sat_pkg_sym_sat_9_8(data_2_real_fp);
	assign data_2_out_imag = sat_pkg_sym_sat_9_8(data_2_imag_fp);
endmodule
