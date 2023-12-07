module fft_np (
	clk,
	arst_n,
	data_in,
	data_out
);
	parameter N = 4;
	parameter SAMPLE_WIDTH = 16;
	parameter PHASE_WIDTH = 2;
	parameter DATA_WIDTH = 16;
	input wire clk;
	input wire arst_n;
	input wire [(N * SAMPLE_WIDTH) - 1:0] data_in;
	output reg [(N * SAMPLE_WIDTH) - 1:0] data_out;
	localparam NUM_STAGES = $clog2(N);
	reg [(2 * SAMPLE_WIDTH) - 1:0] twiddle_factors = 32'h0001ff00;
	reg [((NUM_STAGES * N) * SAMPLE_WIDTH) - 1:0] data_bfly_in;
	wire [((NUM_STAGES * N) * SAMPLE_WIDTH) - 1:0] data_bfly_out;
	genvar k;
	generate
		for (k = 0; k < NUM_STAGES; k = k + 1) begin : stage
			genvar j;
			for (j = 0; j < (k + 1); j = j + 1) begin : block
				genvar i;
				for (i = 0; i < (N / (2 ** (k + 1))); i = i + 1) begin : butterfly
					wire [(SAMPLE_WIDTH / 2) - 1:0] bfly_in_1_real;
					wire [(SAMPLE_WIDTH / 2) - 1:0] bfly_in_1_imag;
					wire [(SAMPLE_WIDTH / 2) - 1:0] bfly_in_2_real;
					wire [(SAMPLE_WIDTH / 2) - 1:0] bfly_in_2_imag;
					wire [(SAMPLE_WIDTH / 2) - 1:0] bfly_out_1_real;
					wire [(SAMPLE_WIDTH / 2) - 1:0] bfly_out_1_imag;
					wire [(SAMPLE_WIDTH / 2) - 1:0] bfly_out_2_real;
					wire [(SAMPLE_WIDTH / 2) - 1:0] bfly_out_2_imag;
					wire [(SAMPLE_WIDTH / 2) - 1:0] twiddle_real;
					wire [(SAMPLE_WIDTH / 2) - 1:0] twiddle_imag;
					wire [(SAMPLE_WIDTH / 2) - 1:0] bfly_out_2_real_scaled;
					wire [(SAMPLE_WIDTH / 2) - 1:0] bfly_out_2_imag_scaled;
					assign bfly_in_1_real = data_bfly_in[(((k * N) + ((j * (N / (2 ** k))) + i)) * SAMPLE_WIDTH) + 7-:8];
					assign bfly_in_1_imag = data_bfly_in[(((k * N) + ((j * (N / (2 ** k))) + i)) * SAMPLE_WIDTH) + 15-:8];
					assign bfly_in_2_real = data_bfly_in[(((k * N) + (((j * (N / (2 ** k))) + (N / (2 ** (k + 1)))) + i)) * SAMPLE_WIDTH) + 7-:8];
					assign bfly_in_2_imag = data_bfly_in[(((k * N) + (((j * (N / (2 ** k))) + (N / (2 ** (k + 1)))) + i)) * SAMPLE_WIDTH) + 15-:8];
					butterfly #(.DATAWIDTH(SAMPLE_WIDTH / 2)) butterfly_i(
						.data_1_in_real(bfly_in_1_real),
						.data_1_in_imag(bfly_in_1_imag),
						.data_2_in_real(bfly_in_2_real),
						.data_2_in_imag(bfly_in_2_imag),
						.data_1_out_real(bfly_out_1_real),
						.data_1_out_imag(bfly_out_1_imag),
						.data_2_out_real(bfly_out_2_real),
						.data_2_out_imag(bfly_out_2_imag)
					);
					assign twiddle_real = twiddle_factors[((1 - (i * (2 ** k))) * SAMPLE_WIDTH) + 7-:8];
					assign twiddle_imag = twiddle_factors[((1 - (i * (2 ** k))) * SAMPLE_WIDTH) + 15-:8];
					cmul #(.DATA_WIDTH(SAMPLE_WIDTH / 2)) cmul_i(
						.A_real(bfly_out_2_real),
						.A_imag(bfly_out_2_imag),
						.B_real(twiddle_real),
						.B_imag(twiddle_imag),
						.Y_real(bfly_out_2_real_scaled),
						.Y_imag(bfly_out_2_imag_scaled)
					);
					assign data_bfly_out[(((k * N) + ((j * (N / (2 ** k))) + i)) * SAMPLE_WIDTH) + 7-:8] = bfly_out_1_real;
					assign data_bfly_out[(((k * N) + ((j * (N / (2 ** k))) + i)) * SAMPLE_WIDTH) + 15-:8] = bfly_out_1_imag;
					assign data_bfly_out[(((k * N) + (((j * (N / (2 ** k))) + (N / (2 ** (k + 1)))) + i)) * SAMPLE_WIDTH) + 7-:8] = bfly_out_2_real_scaled;
					assign data_bfly_out[(((k * N) + (((j * (N / (2 ** k))) + (N / (2 ** (k + 1)))) + i)) * SAMPLE_WIDTH) + 15-:8] = bfly_out_2_imag_scaled;
				end
			end
		end
	endgenerate
	always @(*) begin
		data_bfly_in[0+:SAMPLE_WIDTH * N] = data_in;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < (NUM_STAGES - 1); i = i + 1)
				data_bfly_in[SAMPLE_WIDTH * ((i + 1) * N)+:SAMPLE_WIDTH * N] = data_bfly_out[SAMPLE_WIDTH * (i * N)+:SAMPLE_WIDTH * N];
		end
		data_out = data_bfly_out[SAMPLE_WIDTH * ((NUM_STAGES - 1) * N)+:SAMPLE_WIDTH * N];
	end
endmodule
