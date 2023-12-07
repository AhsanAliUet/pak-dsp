module duc (
	clk,
	arst_n,
	bypass,
	src_data_in,
	src_valid_in,
	src_ready_out,
	dst_data_out,
	dst_valid_out,
	dst_ready_in
);
	parameter DATA_WIDTH = 16;
	parameter COEFF_WIDTH = 16;
	input wire clk;
	input wire arst_n;
	input wire [2:0] bypass;
	input wire [DATA_WIDTH - 1:0] src_data_in;
	input wire src_valid_in;
	output wire src_ready_out;
	output wire [15:0] dst_data_out;
	output wire dst_valid_out;
	input wire dst_ready_in;
	localparam OUTPUT_WIDTH_1 = (DATA_WIDTH + COEFF_WIDTH) + 5;
	localparam OUTPUT_WIDTH_2 = ((DATA_WIDTH + 2) + COEFF_WIDTH) + 5;
	localparam OUTPUT_WIDTH_3 = ((DATA_WIDTH + 4) + COEFF_WIDTH) + 3;
	wire [OUTPUT_WIDTH_1 - 1:0] data_out_interp_1;
	wire valid_out_interp_1;
	wire ready_out_interp_1;
	wire [OUTPUT_WIDTH_2 - 1:0] data_out_interp_2;
	wire valid_out_interp_2;
	wire ready_out_interp_2;
	wire [OUTPUT_WIDTH_3 - 1:0] data_out_interp_3;
	wire valid_out_interp_3;
	wire ready_out_interp_3;
	wire [17:0] data_out_sat_1;
	wire [19:0] data_out_sat_2;
	wire [15:0] data_out_sat_3;
	assign src_ready_out = ready_out_interp_1;
	assign dst_data_out = data_out_sat_3;
	assign dst_valid_out = valid_out_interp_3;
	interpolator #(
		.DATA_WIDTH(DATA_WIDTH),
		.COEFF_WIDTH(COEFF_WIDTH),
		.COEFFS_0_ODD(0),
		.COEFFS_1_ODD(0),
		.N_COEFFS_0(10),
		.N_COEFFS_1(10),
		.COEFFS_0({16'd20751, -16'd6629, 16'd3649, -16'd2284, 16'd1482, -16'd957, 16'd599, -16'd355, 16'd193, -16'd108}),
		.COEFFS_1(160'h7fff000000000000000000000000000000000000)
	) i_interpolator_1(
		.clk(clk),
		.arst_n(arst_n),
		.bypass(bypass[0]),
		.src_data_in(src_data_in),
		.src_valid_in(src_valid_in),
		.src_ready_out(ready_out_interp_1),
		.dst_data_out(data_out_interp_1),
		.dst_valid_out(valid_out_interp_1),
		.dst_ready_in(ready_out_interp_2)
	);
	sat_trunc #(
		.M_I(1),
		.N_I(OUTPUT_WIDTH_1 - 1),
		.M_O(1),
		.N_O(17)
	) i_sat_truc_1(
		.sig_i(data_out_interp_1),
		.sig_o(data_out_sat_1)
	);
	interpolator #(
		.DATA_WIDTH(DATA_WIDTH + 2),
		.COEFF_WIDTH(COEFF_WIDTH),
		.COEFFS_0_ODD(0),
		.COEFFS_1_ODD(0),
		.N_COEFFS_0(11),
		.N_COEFFS_1(11),
		.COEFFS_0({16'd28, -16'd198, 16'd802, -16'd2526, 32'h2215742e, -16'd5246, 16'd1973, -16'd683, 16'd176, -16'd25}),
		.COEFFS_1({-16'd25, 16'd176, -16'd683, 16'd1973, -16'd5246, 32'h742e2215, -16'd2526, 16'd802, -16'd198, 16'd28})
	) i_interpolator_2(
		.clk(clk),
		.arst_n(arst_n),
		.bypass(bypass[1]),
		.src_data_in(data_out_sat_1),
		.src_valid_in(valid_out_interp_1),
		.src_ready_out(ready_out_interp_2),
		.dst_data_out(data_out_interp_2),
		.dst_valid_out(valid_out_interp_2),
		.dst_ready_in(ready_out_interp_3)
	);
	sat_trunc #(
		.M_I(1),
		.N_I(OUTPUT_WIDTH_2 - 1),
		.M_O(1),
		.N_O(19)
	) i_sat_truc_2(
		.sig_i(data_out_interp_2),
		.sig_o(data_out_sat_2)
	);
	interpolator #(
		.DATA_WIDTH(DATA_WIDTH + 4),
		.COEFF_WIDTH(COEFF_WIDTH),
		.COEFFS_0_ODD(0),
		.COEFFS_1_ODD(0),
		.N_COEFFS_0(3),
		.N_COEFFS_1(3),
		.COEFFS_0({16'd19333, -16'd3406, 16'd458}),
		.COEFFS_1(48'h7fff00000000)
	) i_interpolator_3(
		.clk(clk),
		.arst_n(arst_n),
		.bypass(bypass[2]),
		.src_data_in(data_out_sat_2),
		.src_valid_in(valid_out_interp_2),
		.src_ready_out(ready_out_interp_3),
		.dst_data_out(data_out_interp_3),
		.dst_valid_out(valid_out_interp_3),
		.dst_ready_in(dst_ready_in)
	);
	sat_trunc #(
		.M_I(1),
		.N_I(OUTPUT_WIDTH_3 - 1),
		.M_O(1),
		.N_O(15)
	) i_sat_truc_3(
		.sig_i(data_out_interp_3),
		.sig_o(data_out_sat_3)
	);
endmodule
