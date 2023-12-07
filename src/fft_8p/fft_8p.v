module fft_8p (
	clk,
	arst_n,
	start,
	done,
	x_real,
	x_imag,
	X_real,
	X_imag
);
	parameter DATA_WIDTH = 16;
	parameter N = 8;
	input wire clk;
	input wire arst_n;
	input wire start;
	output wire done;
	input wire signed [(N * DATA_WIDTH) - 1:0] x_real;
	input wire signed [(N * DATA_WIDTH) - 1:0] x_imag;
	output wire signed [(N * DATA_WIDTH) - 1:0] X_real;
	output wire signed [(N * DATA_WIDTH) - 1:0] X_imag;
	wire signed [((N / 2) * DATA_WIDTH) - 1:0] W_8_real;
	wire signed [((N / 2) * DATA_WIDTH) - 1:0] W_8_imag;
	wire signed [(N * DATA_WIDTH) - 1:0] stage_1_real;
	wire signed [(N * DATA_WIDTH) - 1:0] stage_1_imag;
	wire signed [(N * DATA_WIDTH) - 1:0] stage_1_real_q;
	wire signed [(N * DATA_WIDTH) - 1:0] stage_1_imag_q;
	wire signed [(N * DATA_WIDTH) - 1:0] stage_2_real;
	wire signed [(N * DATA_WIDTH) - 1:0] stage_2_imag;
	wire signed [(N * DATA_WIDTH) - 1:0] stage_2_real_q;
	wire signed [(N * DATA_WIDTH) - 1:0] stage_2_imag_q;
	wire signed [(N * DATA_WIDTH) - 1:0] stage_3_real;
	wire signed [(N * DATA_WIDTH) - 1:0] stage_3_imag;
	wire done_stage_1;
	wire done_stage_2;
	assign W_8_real = 64'hff4b000000b50100;
	assign W_8_imag = 64'hff4bff00ff4b0000;
	function automatic [$clog2(N) - 1:0] bit_reversal;
		input [$clog2(N) - 1:0] data_in;
		reg [$clog2(N) - 1:0] data_out;
		begin
			begin : sv2v_autoblock_1
				reg signed [31:0] i;
				for (i = 0; i < ($clog2(N) - 1); i = i + 1)
					begin
						data_out[i] = data_in[($clog2(N) - 1) - i];
						data_out[($clog2(N) - 1) - i] = data_in[i];
					end
			end
			bit_reversal = data_out;
		end
	endfunction
	genvar i;
	generate
		for (i = 0; i < N; i = i + 2) begin : stage_1
			bfly_2p #(.DATA_WIDTH(DATA_WIDTH)) i_bfly_2p(
				.A_real(x_real[bit_reversal(i) * DATA_WIDTH+:DATA_WIDTH]),
				.A_imag(x_imag[bit_reversal(i) * DATA_WIDTH+:DATA_WIDTH]),
				.B_real(x_real[bit_reversal(i + 1) * DATA_WIDTH+:DATA_WIDTH]),
				.B_imag(x_imag[bit_reversal(i + 1) * DATA_WIDTH+:DATA_WIDTH]),
				.W_real(W_8_real[0+:DATA_WIDTH]),
				.W_imag(W_8_imag[0+:DATA_WIDTH]),
				.Y0_real(stage_1_real[i * DATA_WIDTH+:DATA_WIDTH]),
				.Y0_imag(stage_1_imag[i * DATA_WIDTH+:DATA_WIDTH]),
				.Y1_real(stage_1_real[(i + 1) * DATA_WIDTH+:DATA_WIDTH]),
				.Y1_imag(stage_1_imag[(i + 1) * DATA_WIDTH+:DATA_WIDTH])
			);
		end
		for (i = 0; i < N; i = i + 1) begin : genblk2
			pipeline #(
				.NUM_STAGES(1),
				.BYPASS(0),
				.DATA_WIDTH(2 * DATA_WIDTH)
			) i_pipeline_1(
				.clk(clk),
				.arst_n(arst_n),
				.en_in(1),
				.src_valid_in(start),
				.src_data_in({stage_1_imag[i * DATA_WIDTH+:DATA_WIDTH], stage_1_real[i * DATA_WIDTH+:DATA_WIDTH]}),
				.dst_data_out({stage_1_imag_q[i * DATA_WIDTH+:DATA_WIDTH], stage_1_real_q[i * DATA_WIDTH+:DATA_WIDTH]}),
				.dst_valid_out(done_stage_1)
			);
		end
		for (i = 0; i < (N / 4); i = i + 1) begin : stage_2_0
			bfly_2p #(.DATA_WIDTH(DATA_WIDTH)) i_bfly_2p(
				.A_real(stage_1_real_q[i * DATA_WIDTH+:DATA_WIDTH]),
				.A_imag(stage_1_imag_q[i * DATA_WIDTH+:DATA_WIDTH]),
				.B_real(stage_1_real_q[(i + 2) * DATA_WIDTH+:DATA_WIDTH]),
				.B_imag(stage_1_imag_q[(i + 2) * DATA_WIDTH+:DATA_WIDTH]),
				.W_real((i == 0 ? W_8_real[0+:DATA_WIDTH] : W_8_real[2 * DATA_WIDTH+:DATA_WIDTH])),
				.W_imag((i == 0 ? W_8_imag[0+:DATA_WIDTH] : W_8_imag[2 * DATA_WIDTH+:DATA_WIDTH])),
				.Y0_real(stage_2_real[i * DATA_WIDTH+:DATA_WIDTH]),
				.Y0_imag(stage_2_imag[i * DATA_WIDTH+:DATA_WIDTH]),
				.Y1_real(stage_2_real[(i + 2) * DATA_WIDTH+:DATA_WIDTH]),
				.Y1_imag(stage_2_imag[(i + 2) * DATA_WIDTH+:DATA_WIDTH])
			);
		end
	endgenerate
	genvar j;
	generate
		for (j = N / 2; j < ((N / 2) + 2); j = j + 1) begin : stage_2_1
			bfly_2p #(.DATA_WIDTH(DATA_WIDTH)) i_bfly_2p(
				.A_real(stage_1_real_q[j * DATA_WIDTH+:DATA_WIDTH]),
				.A_imag(stage_1_imag_q[j * DATA_WIDTH+:DATA_WIDTH]),
				.B_real(stage_1_real_q[(j + 2) * DATA_WIDTH+:DATA_WIDTH]),
				.B_imag(stage_1_imag_q[(j + 2) * DATA_WIDTH+:DATA_WIDTH]),
				.W_real((j == (N / 2) ? W_8_real[0+:DATA_WIDTH] : W_8_real[2 * DATA_WIDTH+:DATA_WIDTH])),
				.W_imag((j == (N / 2) ? W_8_imag[0+:DATA_WIDTH] : W_8_imag[2 * DATA_WIDTH+:DATA_WIDTH])),
				.Y0_real(stage_2_real[j * DATA_WIDTH+:DATA_WIDTH]),
				.Y0_imag(stage_2_imag[j * DATA_WIDTH+:DATA_WIDTH]),
				.Y1_real(stage_2_real[(j + 2) * DATA_WIDTH+:DATA_WIDTH]),
				.Y1_imag(stage_2_imag[(j + 2) * DATA_WIDTH+:DATA_WIDTH])
			);
		end
		for (i = 0; i < N; i = i + 1) begin : genblk5
			pipeline #(
				.NUM_STAGES(1),
				.BYPASS(0),
				.DATA_WIDTH(2 * DATA_WIDTH)
			) i_pipeline_1(
				.clk(clk),
				.arst_n(arst_n),
				.en_in(1),
				.src_data_in({stage_2_imag[i * DATA_WIDTH+:DATA_WIDTH], stage_2_real[i * DATA_WIDTH+:DATA_WIDTH]}),
				.src_valid_in(done_stage_1),
				.dst_data_out({stage_2_imag_q[i * DATA_WIDTH+:DATA_WIDTH], stage_2_real_q[i * DATA_WIDTH+:DATA_WIDTH]}),
				.dst_valid_out(done_stage_2)
			);
		end
		for (i = 0; i < (N / 2); i = i + 1) begin : stage_3
			bfly_2p #(.DATA_WIDTH(DATA_WIDTH)) i_bfly_2p(
				.A_real(stage_2_real_q[i * DATA_WIDTH+:DATA_WIDTH]),
				.A_imag(stage_2_imag_q[i * DATA_WIDTH+:DATA_WIDTH]),
				.B_real(stage_2_real_q[(i + 4) * DATA_WIDTH+:DATA_WIDTH]),
				.B_imag(stage_2_imag_q[(i + 4) * DATA_WIDTH+:DATA_WIDTH]),
				.W_real(W_8_real[i * DATA_WIDTH+:DATA_WIDTH]),
				.W_imag(W_8_imag[i * DATA_WIDTH+:DATA_WIDTH]),
				.Y0_real(stage_3_real[i * DATA_WIDTH+:DATA_WIDTH]),
				.Y0_imag(stage_3_imag[i * DATA_WIDTH+:DATA_WIDTH]),
				.Y1_real(stage_3_real[(i + 4) * DATA_WIDTH+:DATA_WIDTH]),
				.Y1_imag(stage_3_imag[(i + 4) * DATA_WIDTH+:DATA_WIDTH])
			);
		end
	endgenerate
	assign X_real = stage_3_real;
	assign X_imag = stage_3_imag;
	assign done = done_stage_1 & done_stage_2;
endmodule
