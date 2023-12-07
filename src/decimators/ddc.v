module ddc (
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
	parameter COEFF_WIDTH = 5;
	parameter N_COEFFS_0 = 20;
	parameter N_COEFFS_1 = 20;
	input wire clk;
	input wire arst_n;
	input wire [2:0] bypass;
	input wire [DATA_WIDTH - 1:0] src_data_in;
	input wire src_valid_in;
	output wire src_ready_out;
	output wire [15:0] dst_data_out;
	output wire dst_valid_out;
	input wire dst_ready_in;
	localparam OUTPUT_WIDTH_1 = ((DATA_WIDTH + COEFF_WIDTH) + $clog2(N_COEFFS_0)) + 1;
	localparam OUTPUT_WIDTH_2 = (((DATA_WIDTH + 2) + COEFF_WIDTH) + $clog2(N_COEFFS_0)) + 1;
	localparam OUTPUT_WIDTH_3 = (((DATA_WIDTH + 4) + COEFF_WIDTH) + $clog2(N_COEFFS_0)) + 1;
	localparam OUTPUT_WIDTH = OUTPUT_WIDTH_1;
	wire [OUTPUT_WIDTH_1 - 1:0] data_out_decim_1;
	wire valid_out_decim_1;
	wire ready_out_decim_1;
	wire [OUTPUT_WIDTH_2 - 1:0] data_out_decim_2;
	wire valid_out_decim_2;
	wire ready_out_decim_2;
	wire [OUTPUT_WIDTH_3 - 1:0] data_out_decim_3;
	wire valid_out_decim_3;
	wire ready_out_decim_3;
	wire [17:0] data_out_sat_1;
	wire [19:0] data_out_sat_2;
	wire [15:0] data_out_sat_3;
	assign dst_data_out = data_out_sat_3;
	assign src_ready_out = dst_ready_in;
	assign dst_valid_out = valid_out_decim_3;
	pp_decimator_2 #(
		.DATA_WIDTH(DATA_WIDTH),
		.COEFF_WIDTH(COEFF_WIDTH),
		.DECIM_FACTOR(2),
		.N_COEFFS_0(N_COEFFS_0),
		.N_COEFFS_1(N_COEFFS_1)
	) i_decim_1(
		.clk(clk),
		.arst_n(arst_n),
		.bypass(bypass[0]),
		.data_in(src_data_in),
		.valid_in(src_valid_in),
		.data_out(data_out_decim_1),
		.valid_out(valid_out_decim_1)
	);
	sat_trunc #(
		.M_I(1),
		.N_I(OUTPUT_WIDTH_1 - 1),
		.M_O(1),
		.N_O(17)
	) i_sat_truc_1(
		.sig_i(data_out_decim_1),
		.sig_o(data_out_sat_1)
	);
	wire signed [17:0] data_out_sat_1_q;
	wire valid_out_decim_1_q;
	pipeline #(
		.NUM_STAGES(1),
		.BYPASS(0),
		.DATA_WIDTH(18)
	) i_pipeline_1(
		.clk(clk),
		.arst_n(arst_n),
		.en_in(1),
		.src_data_in(data_out_sat_1),
		.src_valid_in(valid_out_decim_1),
		.dst_data_out(data_out_sat_1_q),
		.dst_valid_out(valid_out_decim_1_q)
	);
	pp_decimator_2 #(
		.DATA_WIDTH(DATA_WIDTH + 2),
		.COEFF_WIDTH(COEFF_WIDTH),
		.DECIM_FACTOR(2),
		.N_COEFFS_0(N_COEFFS_0),
		.N_COEFFS_1(N_COEFFS_1)
	) i_decim_2(
		.clk(clk),
		.arst_n(arst_n),
		.bypass(bypass[1]),
		.data_in(data_out_sat_1_q),
		.valid_in(valid_out_decim_1_q),
		.data_out(data_out_decim_2),
		.valid_out(valid_out_decim_2)
	);
	sat_trunc #(
		.M_I(1),
		.N_I(OUTPUT_WIDTH_2 - 1),
		.M_O(1),
		.N_O(19)
	) i_sat_truc_2(
		.sig_i(data_out_decim_2),
		.sig_o(data_out_sat_2)
	);
	wire signed [19:0] data_out_sat_2_q;
	wire valid_out_decim_2_q;
	pipeline #(
		.NUM_STAGES(1),
		.BYPASS(0),
		.DATA_WIDTH(20)
	) i_pipeline_2(
		.clk(clk),
		.arst_n(arst_n),
		.en_in(1),
		.src_data_in(data_out_sat_2),
		.src_valid_in(valid_out_decim_2),
		.dst_data_out(data_out_sat_2_q),
		.dst_valid_out(valid_out_decim_2_q)
	);
	pp_decimator_2 #(
		.DATA_WIDTH(DATA_WIDTH + 4),
		.COEFF_WIDTH(COEFF_WIDTH),
		.DECIM_FACTOR(2),
		.N_COEFFS_0(N_COEFFS_0),
		.N_COEFFS_1(N_COEFFS_1)
	) i_decim_3(
		.clk(clk),
		.arst_n(arst_n),
		.bypass(bypass[2]),
		.data_in(data_out_sat_2_q),
		.valid_in(valid_out_decim_2_q),
		.data_out(data_out_decim_3),
		.valid_out(valid_out_decim_3)
	);
	sat_trunc #(
		.M_I(1),
		.N_I(OUTPUT_WIDTH_3 - 1),
		.M_O(1),
		.N_O(15)
	) i_sat_truc_3(
		.sig_i(data_out_decim_3),
		.sig_o(data_out_sat_3)
	);
endmodule
