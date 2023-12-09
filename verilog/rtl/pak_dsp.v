module pak_dsp (
	clk,
	arst_n,
	addr,
	ack_out,
	write_en,
	wdata,
	rdata,
	src_data_in,
	src_valid_in,
	src_ready_out,
	dst_data_out,
	dst_valid_out,
	dst_ready_in
);
	parameter DATA_WIDTH = 16;
	parameter COEFF_WIDTH = 16;
	parameter N = 8;
	localparam NUM_GPR_REGS = 1;
	localparam NUM_COEFFS_REGS = 30;
	localparam NUM_FFT_REGS = 32;
	localparam TOTAL_REGS = 63;
	input wire clk;
	input wire arst_n;
	input wire [5:0] addr;
	output wire ack_out;
	input wire write_en;
	input wire signed [DATA_WIDTH - 1:0] wdata;
	output wire signed [DATA_WIDTH - 1:0] rdata;
	input wire signed [DATA_WIDTH - 1:0] src_data_in;
	input wire src_valid_in;
	output wire src_ready_out;
	output wire signed [DATA_WIDTH - 1:0] dst_data_out;
	output wire dst_valid_out;
	input wire dst_ready_in;
	localparam OUTPUT_WORD_SIZE_FIR = (2 * DATA_WIDTH) + 5;
	wire [DATA_WIDTH - 1:0] gpr;
	wire signed [(30 * DATA_WIDTH) - 1:0] coeffs_fir;
	wire signed [DATA_WIDTH - 1:0] dst_data_out_interp;
	wire dst_valid_out_interp;
	wire dst_ready_in_interp;
	wire signed [DATA_WIDTH - 1:0] dst_data_out_decim;
	wire dst_valid_out_decim;
	wire dst_ready_in_decim;
	reg signed [DATA_WIDTH - 1:0] src_data_in_fir;
	reg src_valid_in_fir;
	wire src_ready_out_fir;
	wire signed [OUTPUT_WORD_SIZE_FIR - 1:0] dst_data_out_fir;
	wire signed [(N * DATA_WIDTH) - 1:0] fft_x_real;
	wire signed [(N * DATA_WIDTH) - 1:0] fft_x_imag;
	wire signed [(N * DATA_WIDTH) - 1:0] fft_X_real;
	wire signed [(N * DATA_WIDTH) - 1:0] fft_X_imag;
	wire src_ready_out_ddc;
	wire src_ready_out_duc;
	wire done_fft;
	assign src_ready_out = src_ready_out_ddc | src_ready_out_duc;
	duc #(
		.DATA_WIDTH(DATA_WIDTH),
		.COEFF_WIDTH(COEFF_WIDTH)
	) i_duc(
		.clk(clk),
		.arst_n(arst_n),
		.bypass(gpr[4-:3]),
		.src_data_in(src_data_in),
		.src_valid_in(src_valid_in),
		.src_ready_out(src_ready_out_duc),
		.dst_data_out(dst_data_out_interp),
		.dst_valid_out(dst_valid_out_interp),
		.dst_ready_in(src_ready_out_fir)
	);
	ddc #(
		.DATA_WIDTH(DATA_WIDTH),
		.COEFF_WIDTH(COEFF_WIDTH),
		.N_COEFFS_0(1),
		.N_COEFFS_1(1)
	) i_ddc(
		.clk(clk),
		.arst_n(arst_n),
		.bypass(gpr[4-:3]),
		.src_data_in(src_data_in),
		.src_valid_in(src_valid_in),
		.src_ready_out(src_ready_out_ddc),
		.dst_data_out(dst_data_out_decim),
		.dst_valid_out(dst_valid_out_decim),
		.dst_ready_in(src_ready_out_fir)
	);
	always @(*)
		case ({gpr[1], gpr[0]})
			2'b00: begin
				src_data_in_fir  = 0;
				src_valid_in_fir = 0;
			end
			2'b01: begin
				src_data_in_fir  = dst_data_out_interp;
				src_valid_in_fir = dst_valid_out_interp;
			end
			2'b10: begin
				src_data_in_fir  = dst_data_out_decim;
				src_valid_in_fir = dst_valid_out_decim;
			end
			default:
			begin
				src_data_in_fir  = 0;
				src_valid_in_fir = 0;
			end

		endcase
	fir_filter #(
		.INPUT_WORD_SIZE(DATA_WIDTH),
		.COEFF_WORD_SIZE(DATA_WIDTH),
		.N_COEFFS(NUM_COEFFS_REGS)
	) i_fir_filter(
		.clk(clk),
		.arst_n(arst_n),
		.bypass(gpr[5]),
		.coeff(coeffs_fir),
		.data_in(src_data_in_fir),
		.valid_in(src_valid_in_fir),
		.src_ready_out(src_ready_out_fir),
		.data_out(dst_data_out_fir),
		.valid_out(dst_valid_out),
		.dst_ready_in(dst_ready_in)
	);
	fft_8p #(
		.DATA_WIDTH(DATA_WIDTH),
		.N(N)
	) i_fft_8p(
		.clk(clk),
		.arst_n(arst_n),
		.start(gpr[6]),
		.done(done_fft),
		.x_real(fft_x_real),
		.x_imag(fft_x_imag),
		.X_real(fft_X_real),
		.X_imag(fft_X_imag)
	);
	memory_map #(
		.DATA_WIDTH(DATA_WIDTH),
		.NUM_GPR_REGS(NUM_GPR_REGS),
		.NUM_COEFFS_REGS(NUM_COEFFS_REGS),
		.NUM_FFT_REGS(NUM_FFT_REGS)
	) i_memory_map(
		.clk(clk),
		.arst_n(arst_n),
		.fft_done(done_fft),
		.addr(addr),
		.ack_out(ack_out),
		.write_en(write_en),
		.wdata(wdata),
		.rdata(rdata),
		.gpr(gpr),
		.coeffs(coeffs_fir),
		.fft_real_input_regs(fft_x_real),
		.fft_imag_input_regs(fft_x_imag),
		.fft_real_output_regs(fft_X_real),
		.fft_imag_output_regs(fft_X_imag)
	);
endmodule
