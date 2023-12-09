module memory_map (
	clk,
	arst_n,
	fft_done,
	addr,
	ack_out,
	write_en,
	wdata,
	rdata,
	gpr,
	coeffs,
	fft_real_input_regs,
	fft_imag_input_regs,
	fft_real_output_regs,
	fft_imag_output_regs
);
	parameter DATA_WIDTH = 16;
	parameter NUM_GPR_REGS = 1;
	parameter NUM_COEFFS_REGS = 30;
	parameter NUM_FFT_REGS = 32;
	localparam TOTAL_REGS = (NUM_GPR_REGS + NUM_COEFFS_REGS) + NUM_FFT_REGS;
	input wire clk;
	input wire arst_n;
	input wire fft_done;
	input wire [$clog2(TOTAL_REGS) - 1:0] addr;
	output reg ack_out;
	input wire write_en;
	input wire signed [DATA_WIDTH - 1:0] wdata;
	output wire signed [DATA_WIDTH - 1:0] rdata;
	output reg signed [(NUM_GPR_REGS * DATA_WIDTH) - 1:0] gpr;
	output reg signed [(NUM_COEFFS_REGS * DATA_WIDTH) - 1:0] coeffs;
	output reg signed [((NUM_FFT_REGS / 4) * DATA_WIDTH) - 1:0] fft_real_input_regs;
	output reg signed [((NUM_FFT_REGS / 4) * DATA_WIDTH) - 1:0] fft_imag_input_regs;
	input wire signed [((NUM_FFT_REGS / 4) * DATA_WIDTH) - 1:0] fft_real_output_regs;
	input wire signed [((NUM_FFT_REGS / 4) * DATA_WIDTH) - 1:0] fft_imag_output_regs;
	reg [(TOTAL_REGS * DATA_WIDTH) - 1:0] Regs;
	always @(posedge clk or negedge arst_n)
		if (~arst_n) begin : sv2v_autoblock_1
			reg signed [31:0] j;
			for (j = 0; j < NUM_GPR_REGS; j = j + 1)
				gpr <= 0;
		end
		else begin : sv2v_autoblock_2
			reg signed [31:0] j;
			for (j = 0; j < NUM_GPR_REGS; j = j + 1)
				gpr[j * DATA_WIDTH+:DATA_WIDTH] <= Regs[((TOTAL_REGS - 1) - j) * DATA_WIDTH+:DATA_WIDTH];
		end
	always @(posedge clk or negedge arst_n)
		if (~arst_n) begin : sv2v_autoblock_3
			reg signed [31:0] i;
			for (i = 0; i < NUM_COEFFS_REGS; i = i + 1)
				coeffs[i * DATA_WIDTH+:DATA_WIDTH] <= 0;
		end
		else begin : sv2v_autoblock_4
			reg signed [31:0] i;
			for (i = 0; i < NUM_COEFFS_REGS; i = i + 1)
				coeffs[i * DATA_WIDTH+:DATA_WIDTH] <= Regs[((TOTAL_REGS - 1) - (NUM_GPR_REGS + i)) * DATA_WIDTH+:DATA_WIDTH];
		end
	always @(posedge clk or negedge arst_n)
		if (~arst_n) begin : sv2v_autoblock_5
			reg signed [31:0] i;
			for (i = 0; i < (NUM_FFT_REGS / 4); i = i + 1)
				begin
					fft_real_input_regs[i * DATA_WIDTH+:DATA_WIDTH] <= 0;
					fft_imag_input_regs[i * DATA_WIDTH+:DATA_WIDTH] <= 0;
				end
		end
		else begin : sv2v_autoblock_6
			reg signed [31:0] i;
			for (i = 0; i < (NUM_FFT_REGS / 4); i = i + 1)
				begin
					fft_real_input_regs[i * DATA_WIDTH+:DATA_WIDTH] <= Regs[((TOTAL_REGS - 1) - ((NUM_GPR_REGS + NUM_COEFFS_REGS) + i)) * DATA_WIDTH+:DATA_WIDTH];
					fft_imag_input_regs[i * DATA_WIDTH+:DATA_WIDTH] <= Regs[((TOTAL_REGS - 1) - (((NUM_GPR_REGS + NUM_COEFFS_REGS) + (NUM_FFT_REGS / 4)) + i)) * DATA_WIDTH+:DATA_WIDTH];
				end
		end
	assign rdata = (~write_en ? Regs[((TOTAL_REGS - 1) - addr) * DATA_WIDTH+:DATA_WIDTH] : {DATA_WIDTH {1'sb0}});

	always @(posedge clk or negedge arst_n)
		if (~arst_n)
			Regs <= 0;
			ack_out <= 0;
		else if (write_en)
			Regs[((TOTAL_REGS - 1) - addr) * DATA_WIDTH+:DATA_WIDTH] <= wdata;
			ack_out <= 1;
		else if (fft_done) begin : sv2v_autoblock_7
			reg signed [31:0] i;
			for (i = 0; i < (NUM_FFT_REGS / 4); i = i + 1)
				begin
					Regs[((TOTAL_REGS - 1) - (((NUM_GPR_REGS + NUM_COEFFS_REGS) + (NUM_FFT_REGS / 2)) + i)) * DATA_WIDTH+:DATA_WIDTH] <= fft_real_output_regs[i * DATA_WIDTH+:DATA_WIDTH];
					Regs[((TOTAL_REGS - 1) - ((((NUM_GPR_REGS + NUM_COEFFS_REGS) + (NUM_FFT_REGS / 2)) + (NUM_FFT_REGS / 4)) + i)) * DATA_WIDTH+:DATA_WIDTH] <= fft_imag_output_regs[i * DATA_WIDTH+:DATA_WIDTH];
				end
		end
endmodule
