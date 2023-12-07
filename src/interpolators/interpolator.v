module interpolator (
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
	parameter COEFFS_0_ODD = 0;
	parameter COEFFS_1_ODD = 0;
	parameter N_COEFFS_0 = 3;
	parameter N_COEFFS_1 = 3;
	parameter signed [(N_COEFFS_0 * COEFF_WIDTH) - 1:0] COEFFS_0 = {16'd19333, -16'd3406, 16'd458};
	parameter signed [(N_COEFFS_0 * COEFF_WIDTH) - 1:0] COEFFS_1 = 48'h7fff00000000;
	localparam OUTPUT_WIDTH = ((DATA_WIDTH + COEFF_WIDTH) + $clog2(N_COEFFS_0)) + 1;
	input wire clk;
	input wire arst_n;
	input wire bypass;
	input wire signed [DATA_WIDTH - 1:0] src_data_in;
	input wire src_valid_in;
	output wire src_ready_out;
	output wire signed [OUTPUT_WIDTH - 1:0] dst_data_out;
	output wire dst_valid_out;
	input wire dst_ready_in;
	localparam X = DATA_WIDTH - 1;
	localparam Y = COEFF_WIDTH - 1;
	localparam Z = OUTPUT_WIDTH - (X + Y);
	localparam MSB_BP_DATA = DATA_WIDTH - 1;
	wire [1:0] filter_val;
	wire [OUTPUT_WIDTH - 1:0] bp_data_out;
	wire [OUTPUT_WIDTH - 1:0] filter_output;
	wire [OUTPUT_WIDTH - 1:0] filter_output0;
	reg [OUTPUT_WIDTH - 1:0] filter_output0_q;
	wire [OUTPUT_WIDTH - 1:0] filter_output1;
	reg [OUTPUT_WIDTH - 1:0] filter_output1_q;
	wire [OUTPUT_WIDTH - 1:0] dst_bp_data_out;
	wire dm;
	wire en_out;
	wire dst_valid;
	wire src_ready;
	generate
		if (COEFFS_0_ODD == 0) begin : genblk1
			sym_even_fir_filter #(
				.INPUT_WORD_SIZE(DATA_WIDTH),
				.COEFF_WORD_SIZE(COEFF_WIDTH),
				.N_COEFFS(N_COEFFS_0),
				.COEFFS(COEFFS_0)
			) u_sym_even_fir_filter_0(
				.clk(clk),
				.arst_n(arst_n),
				.data_in(src_data_in),
				.valid_in(src_valid_in),
				.data_out(filter_output0),
				.valid_out(filter_val[0])
			);
		end
		else begin : genblk1
			sym_odd_fir_filter #(
				.INPUT_WORD_SIZE(DATA_WIDTH),
				.COEFF_WORD_SIZE(COEFF_WIDTH),
				.N_COEFFS(N_COEFFS_0),
				.COEFFS(COEFFS_0)
			) u_sym_odd_fir_filter_0(
				.clk(clk),
				.arst_n(arst_n),
				.data_in(src_data_in),
				.valid_in(src_valid_in),
				.data_out(filter_output0),
				.valid_out(filter_val[0])
			);
		end
		if (COEFFS_1_ODD == 0) begin : genblk2
			sym_even_fir_filter #(
				.INPUT_WORD_SIZE(DATA_WIDTH),
				.COEFF_WORD_SIZE(COEFF_WIDTH),
				.N_COEFFS(N_COEFFS_1),
				.COEFFS(COEFFS_1)
			) u_sym_even_fir_filter_1(
				.clk(clk),
				.arst_n(arst_n),
				.data_in(src_data_in),
				.valid_in(src_valid_in),
				.data_out(filter_output1),
				.valid_out(filter_val[1])
			);
		end
		else begin : genblk2
			sym_odd_fir_filter #(
				.INPUT_WORD_SIZE(DATA_WIDTH),
				.COEFF_WORD_SIZE(COEFF_WIDTH),
				.N_COEFFS(N_COEFFS_1),
				.COEFFS(COEFFS_1)
			) u_sym_odd_fir_filter_1(
				.clk(clk),
				.arst_n(arst_n),
				.data_in(src_data_in),
				.valid_in(src_valid_in),
				.data_out(filter_output1),
				.valid_out(filter_val[1])
			);
		end
	endgenerate
	assign filter_output = (dm ? filter_output1_q : filter_output0_q);
	function automatic signed [Y - 1:0] sv2v_cast_ADE2E_signed;
		input reg signed [Y - 1:0] inp;
		sv2v_cast_ADE2E_signed = inp;
	endfunction
	assign dst_bp_data_out = {{{Z - 1} {src_data_in[MSB_BP_DATA]}}, src_data_in, sv2v_cast_ADE2E_signed(0)};
	assign dst_data_out = (bypass ? dst_bp_data_out : filter_output);
	assign dst_valid_out = (bypass ? src_valid_in : dst_valid);
	assign src_ready_out = (bypass ? dst_ready_in : src_ready);
	always @(posedge clk or negedge arst_n)
		if (~arst_n) begin
			filter_output0_q <= 1'sb0;
			filter_output1_q <= 1'sb0;
		end
		else if (en_out) begin
			filter_output0_q <= filter_output0;
			filter_output1_q <= filter_output1;
		end
	interpolator_ctrl i_interpolator_ctrl(
		.clk(clk),
		.arst_n(arst_n),
		.dst_ready_in(dst_ready_in),
		.src_valid_in(src_valid_in),
		.src_ready_out(src_ready),
		.dst_valid_out(dst_valid),
		.en_out(en_out),
		.dm_out(dm)
	);
endmodule
