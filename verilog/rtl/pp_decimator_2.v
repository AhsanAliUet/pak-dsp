module pp_decimator_2 (
	clk,
	arst_n,
	bypass,
	data_in,
	valid_in,
	data_out,
	valid_out
);
	parameter DATA_WIDTH = 16;
	parameter COEFF_WIDTH = 5;
	parameter DECIM_FACTOR = 2;
	parameter N_COEFFS_0 = 2;
	parameter N_COEFFS_1 = 1;
	parameter COEFFS_0_ODD = 1;
	parameter COEFFS_1_ODD = 0;
	parameter COEFFS_0 = 10'h0c1;
	parameter COEFFS_1 = 5'd4;
	localparam FIR_OUTPUT_SIZE = ((DATA_WIDTH + COEFF_WIDTH) + $clog2(N_COEFFS_0)) + 1;
	localparam FIR_OUTPUT_SIZE1 = ((DATA_WIDTH + COEFF_WIDTH) + $clog2(N_COEFFS_1)) + 1;
	localparam OUTPUT_WORD_SIZE = FIR_OUTPUT_SIZE;
	input clk;
	input arst_n;
	input bypass;
	input wire signed [DATA_WIDTH - 1:0] data_in;
	input valid_in;
	output wire signed [OUTPUT_WORD_SIZE - 1:0] data_out;
	output wire valid_out;
	localparam X = DATA_WIDTH - 1;
	localparam Y = COEFF_WIDTH - 1;
	localparam Z = OUTPUT_WORD_SIZE - (X + Y);
	localparam MSB_BP_DATA = DATA_WIDTH - 1;
	reg [DECIM_FACTOR - 1:0] pp_turns;
	wire [DECIM_FACTOR - 1:0] pp_valid_in;
	reg [DECIM_FACTOR - 1:0] pp_valid_out_reg;
	reg signed [FIR_OUTPUT_SIZE - 1:0] data_out_reg [DECIM_FACTOR - 1:0];
	wire signed [FIR_OUTPUT_SIZE - 1:0] pp_output0;
	wire signed [FIR_OUTPUT_SIZE1 - 1:0] pp_output1;
	wire [DECIM_FACTOR - 1:0] pp_valid_out;
	wire signed [OUTPUT_WORD_SIZE - 1:0] bp_data;
	assign pp_valid_in = pp_turns & {DECIM_FACTOR {valid_in}};
	function automatic signed [Y - 1:0] sv2v_cast_ADE2E_signed;
		input reg signed [Y - 1:0] inp;
		sv2v_cast_ADE2E_signed = inp;
	endfunction
	assign bp_data = {{{Z - 1} {data_in[MSB_BP_DATA]}}, data_in, sv2v_cast_ADE2E_signed(0)};
	assign data_out = (bypass ? bp_data : data_out_reg[0] + data_out_reg[1]);
	assign valid_out = (bypass ? valid_in : pp_valid_out_reg[0]);
	generate
		if (COEFFS_0_ODD == 0) begin : genblk1
			sym_even_fir_filter #(
				.INPUT_WORD_SIZE(DATA_WIDTH),
				.COEFF_WORD_SIZE(COEFF_WIDTH),
				.N_COEFFS(N_COEFFS_0),
				.COEFFS(COEFFS_0)
			) i_sym_even_fir_filter_0(
				.clk(clk),
				.arst_n(arst_n),
				.data_in(data_in),
				.valid_in(pp_valid_in[0]),
				.data_out(pp_output0),
				.valid_out(pp_valid_out[0])
			);
		end
		else begin : genblk1
			sym_odd_fir_filter #(
				.INPUT_WORD_SIZE(DATA_WIDTH),
				.COEFF_WORD_SIZE(COEFF_WIDTH),
				.N_COEFFS(N_COEFFS_0),
				.COEFFS(COEFFS_0)
			) i_sym_odd_fir_filter_0(
				.clk(clk),
				.arst_n(arst_n),
				.data_in(data_in),
				.valid_in(pp_valid_in[0]),
				.data_out(pp_output0),
				.valid_out(pp_valid_out[0])
			);
		end
		if (COEFFS_1_ODD == 0) begin : genblk2
			sym_even_fir_filter #(
				.INPUT_WORD_SIZE(DATA_WIDTH),
				.COEFF_WORD_SIZE(COEFF_WIDTH),
				.N_COEFFS(N_COEFFS_1),
				.COEFFS(COEFFS_1)
			) i_sym_even_fir_filter_1(
				.clk(clk),
				.arst_n(arst_n),
				.data_in(data_in),
				.valid_in(pp_valid_in[1]),
				.data_out(pp_output1),
				.valid_out(pp_valid_out[1])
			);
		end
		else begin : genblk2
			sym_odd_fir_filter #(
				.INPUT_WORD_SIZE(DATA_WIDTH),
				.COEFF_WORD_SIZE(COEFF_WIDTH),
				.N_COEFFS(N_COEFFS_1),
				.COEFFS(COEFFS_1)
			) i_sym_odd_fir_filter_1(
				.clk(clk),
				.arst_n(arst_n),
				.data_in(data_in),
				.valid_in(pp_valid_in[1]),
				.data_out(pp_output1),
				.valid_out(pp_valid_out[1])
			);
		end
	endgenerate
	always @(posedge clk or negedge arst_n)
		if (~arst_n)
			pp_turns <= 1;
		else if (valid_in)
			pp_turns <= {pp_turns[0], pp_turns[DECIM_FACTOR - 1:1]};
	always @(posedge clk or negedge arst_n)
		if (~arst_n) begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < DECIM_FACTOR; i = i + 1)
				data_out_reg[i] <= 0;
		end
		else begin
			if (pp_valid_out[0])
				data_out_reg[0] <= pp_output0;
			if (pp_valid_out[1])
				data_out_reg[1] <= pp_output1;
		end
	always @(posedge clk or negedge arst_n)
		if (~arst_n)
			pp_valid_out_reg <= 0;
		else
			pp_valid_out_reg <= pp_valid_out;
endmodule
