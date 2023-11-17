// 4-point FFT module

module fft_np
# (
    parameter N            = 4,
    parameter SAMPLE_WIDTH = 16,
    parameter PHASE_WIDTH  = 2,
    parameter DATA_WIDTH   = 16
) (
  	input  logic                           clk,
  	input  logic                           arst_n,
  	input  logic [N-1:0][SAMPLE_WIDTH-1:0] data_in,
    output logic [N-1:0][SAMPLE_WIDTH-1:0] data_out
);

    localparam NUM_STAGES = $clog2(N);

    logic [SAMPLE_WIDTH-1:0] twiddle_factors [2] = '{ 16'h0001, 16'hff00 };

    logic [NUM_STAGES-1:0][N-1:0][SAMPLE_WIDTH-1:0] data_bfly_in;
    logic [NUM_STAGES-1:0][N-1:0][SAMPLE_WIDTH-1:0] data_bfly_out;

    generate

        for(genvar k = 0; k < NUM_STAGES; k++) 
        begin : stage

            for(genvar j = 0; j < k+1; j++) 
            begin : block

                for(genvar i = 0; i < N/(2**(k+1)); i++) 
                begin : butterfly

                    logic [SAMPLE_WIDTH/2-1:0] bfly_in_1_real;
                    logic [SAMPLE_WIDTH/2-1:0] bfly_in_1_imag;

                    logic [SAMPLE_WIDTH/2-1:0] bfly_in_2_real;
                    logic [SAMPLE_WIDTH/2-1:0] bfly_in_2_imag;

                    logic [SAMPLE_WIDTH/2-1:0] bfly_out_1_real;
                    logic [SAMPLE_WIDTH/2-1:0] bfly_out_1_imag;

                    logic [SAMPLE_WIDTH/2-1:0] bfly_out_2_real;
                    logic [SAMPLE_WIDTH/2-1:0] bfly_out_2_imag;
                    
                    logic [SAMPLE_WIDTH/2-1:0] twiddle_real;
                    logic [SAMPLE_WIDTH/2-1:0] twiddle_imag;

                    logic [SAMPLE_WIDTH/2-1:0] bfly_out_2_real_scaled;
                    logic [SAMPLE_WIDTH/2-1:0] bfly_out_2_imag_scaled;

                    assign bfly_in_1_real = data_bfly_in[k][j*(N/(2**k)) + i][ 7:0];
                    assign bfly_in_1_imag = data_bfly_in[k][j*(N/(2**k)) + i][15:8];

                    assign bfly_in_2_real = data_bfly_in[k][j*(N/(2**k)) + N/(2**(k+1))+i][ 7:0];
                    assign bfly_in_2_imag = data_bfly_in[k][j*(N/(2**k)) + N/(2**(k+1))+i][15:8];

                    butterfly # (
                        .DATAWIDTH       ( SAMPLE_WIDTH/2  )
                    ) butterfly_i (

                        .data_1_in_real  ( bfly_in_1_real  ),
                        .data_1_in_imag  ( bfly_in_1_imag  ),

                        .data_2_in_real  ( bfly_in_2_real  ),
                        .data_2_in_imag  ( bfly_in_2_imag  ),

                        .data_1_out_real ( bfly_out_1_real ),
                        .data_1_out_imag ( bfly_out_1_imag ),

                        .data_2_out_real ( bfly_out_2_real ),
                        .data_2_out_imag ( bfly_out_2_imag )
                    );

                    assign twiddle_real = twiddle_factors[i*(2**k)][ 7:0];
                    assign twiddle_imag = twiddle_factors[i*(2**k)][15:8];

                    cmul # (
                        .DATA_WIDTH ( SAMPLE_WIDTH/2         )
                    ) cmul_i (
                        .A_real     ( bfly_out_2_real        ),
                        .A_imag     ( bfly_out_2_imag        ),
                        .B_real     ( twiddle_real           ),
                        .B_imag     ( twiddle_imag           ),
                        .Y_real     ( bfly_out_2_real_scaled ),
                        .Y_imag     ( bfly_out_2_imag_scaled )
                    );

                    assign data_bfly_out[k][j*(N/(2**k)) + i][ 7:0] = bfly_out_1_real;
                    assign data_bfly_out[k][j*(N/(2**k)) + i][15:8] = bfly_out_1_imag;

                    assign data_bfly_out[k][j*(N/(2**k)) + N/(2**(k+1))+i][ 7:0] = bfly_out_2_real_scaled;
                    assign data_bfly_out[k][j*(N/(2**k)) + N/(2**(k+1))+i][15:8] = bfly_out_2_imag_scaled;
                end

            end

        end

    endgenerate

    always_comb 
    begin
        data_bfly_in[0] = data_in;
        for(int i = 0; i < NUM_STAGES-1; i++)
        begin
            data_bfly_in[i+1] = data_bfly_out[i];
        end
        data_out = data_bfly_out[NUM_STAGES-1];
    end

endmodule
