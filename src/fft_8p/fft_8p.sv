// 8 point FFT module

module fft_8p #(
    parameter DATA_WIDTH = 16,    // for each real and imaginary
    parameter N          = 8      // N points
)(
    input  logic                                 clk,
    input  logic                                 arst_n,
    input  logic                                 start,
    output logic                                 done,
    input  logic signed  [N-1:0][DATA_WIDTH-1:0] x_real,
    input  logic signed  [N-1:0][DATA_WIDTH-1:0] x_imag,
    output logic signed  [N-1:0][DATA_WIDTH-1:0] X_real,
    output logic signed  [N-1:0][DATA_WIDTH-1:0] X_imag
);

    logic signed [N/2-1:0][DATA_WIDTH-1:0] W_8_real;
    logic signed [N/2-1:0][DATA_WIDTH-1:0] W_8_imag;


    logic signed [N-1:0][DATA_WIDTH-1:0] stage_1_real;
    logic signed [N-1:0][DATA_WIDTH-1:0] stage_1_imag;
    logic signed [N-1:0][DATA_WIDTH-1:0] stage_1_real_q;
    logic signed [N-1:0][DATA_WIDTH-1:0] stage_1_imag_q;

    logic signed [N-1:0][DATA_WIDTH-1:0] stage_2_real;
    logic signed [N-1:0][DATA_WIDTH-1:0] stage_2_imag;
    logic signed [N-1:0][DATA_WIDTH-1:0] stage_2_real_q;
    logic signed [N-1:0][DATA_WIDTH-1:0] stage_2_imag_q;

    logic signed [N-1:0][DATA_WIDTH-1:0] stage_3_real;
    logic signed [N-1:0][DATA_WIDTH-1:0] stage_3_imag;

    logic                         done_stage_1;
    logic                         done_stage_2;

    // assign W_8_real[0] = 16'h0100;   // 1      - j0
    // assign W_8_imag[0] = 16'h0000;   // 1      - j0
    // assign W_8_real[1] = 16'h00b5;   // 0.707  - j0.707
    // assign W_8_imag[1] = 16'hff4b;   // 0.707  - j0.707
    // assign W_8_real[2] = 16'h0000;   // 0      - j1
    // assign W_8_imag[2] = 16'hff00;   // 0      - j1
    // assign W_8_real[3] = 16'hff4b;   // -0.707 - j0.707
    // assign W_8_imag[3] = 16'hff4b;   // -0.707 - j0.707
    assign W_8_real = {16'hff4b, 16'h0000, 16'h00b5, 16'h0100};
    assign W_8_imag = {16'hff4b, 16'hff00, 16'hff4b, 16'h0000};

    function automatic logic [$clog2(N)-1:0] bit_reversal(
        input [$clog2(N)-1:0] data_in
    );
        logic [$clog2(N)-1:0] data_out;

        for (int i = 0; i < $clog2(N)-1; i++)
        begin
            data_out[i]                 = data_in[$clog2(N) - 1 - i];
            data_out[$clog2(N) - 1 - i] = data_in[i];
        end

        return data_out;
    endfunction

    // stage 1
    generate
        for (genvar i = 0; i < N; i = i + 2)
        begin : stage_1
            bfly_2p #(
                .DATA_WIDTH ( DATA_WIDTH                      )
            ) i_bfly_2p (
                .A_real     ( x_real[bit_reversal(i)]         ),
                .A_imag     ( x_imag[bit_reversal(i)]         ),
                .B_real     ( x_real[bit_reversal(i+1)]       ),
                .B_imag     ( x_imag[bit_reversal(i+1)]       ),
                .W_real     ( W_8_real[0]                     ),
                .W_imag     ( W_8_imag[0]                     ),
                .Y0_real    ( stage_1_real[i]                 ),
                .Y0_imag    ( stage_1_imag[i]                 ),
                .Y1_real    ( stage_1_real[i+1]               ),
                .Y1_imag    ( stage_1_imag[i+1]               )
            );
        end
    endgenerate

    generate
        for (genvar i = 0; i < N; i++)
        begin
            pipeline #(
                .NUM_STAGES   ( 1                                      ),
                .BYPASS       ( 0                                      ),
                .DATA_WIDTH   ( 2*DATA_WIDTH                           )
            ) i_pipeline_1 (
                .clk          ( clk                                    ),
                .arst_n       ( arst_n                                 ),
                .en_in        ( 1                                      ),
                .src_valid_in ( start                                  ),
                .src_data_in  ( {stage_1_imag[i], stage_1_real[i]    } ),
                .dst_data_out ( {stage_1_imag_q[i], stage_1_real_q[i]} ),
                .dst_valid_out( done_stage_1                           )
            );
        end
    endgenerate

    // stage 2
    generate
        for (genvar i = 0; i < N/4; i = i + 1)
        begin : stage_2_0
            bfly_2p #(
                .DATA_WIDTH ( DATA_WIDTH                         )
            ) i_bfly_2p (
                .A_real     ( stage_1_real_q[i]                  ),
                .A_imag     ( stage_1_imag_q[i]                  ),
                .B_real     ( stage_1_real_q[i+2]                ),
                .B_imag     ( stage_1_imag_q[i+2]                ),
                .W_real     ( (i==0) ? W_8_real[0] : W_8_real[2] ),
                .W_imag     ( (i==0) ? W_8_imag[0] : W_8_imag[2] ),
                .Y0_real    ( stage_2_real[i]                    ),
                .Y0_imag    ( stage_2_imag[i]                    ),
                .Y1_real    ( stage_2_real[i+2]                  ),
                .Y1_imag    ( stage_2_imag[i+2]                  )
            );
        end

        for (genvar j = N/2; j < N/2+2; j++)
        begin : stage_2_1
            bfly_2p #(
                .DATA_WIDTH ( DATA_WIDTH                             )
            ) i_bfly_2p (
                .A_real     ( stage_1_real_q[j]                      ),
                .A_imag     ( stage_1_imag_q[j]                      ),
                .B_real     ( stage_1_real_q[j+2]                    ),
                .B_imag     ( stage_1_imag_q[j+2]                    ),
                .W_real     ( (j==(N/2)) ? W_8_real[0] : W_8_real[2] ),
                .W_imag     ( (j==(N/2)) ? W_8_imag[0] : W_8_imag[2] ),
                .Y0_real    ( stage_2_real[j]                        ),
                .Y0_imag    ( stage_2_imag[j]                        ),
                .Y1_real    ( stage_2_real[j+2]                      ),
                .Y1_imag    ( stage_2_imag[j+2]                      )
            );
        end

    endgenerate

    generate
        for (genvar i = 0; i < N; i++)
        begin
            pipeline #(
                .NUM_STAGES   ( 1                                      ),
                .BYPASS       ( 0                                      ),
                .DATA_WIDTH   ( 2*DATA_WIDTH                           )
            ) i_pipeline_1 (
                .clk          ( clk                                    ),
                .arst_n       ( arst_n                                 ),
                .en_in        ( 1                                      ),
                .src_data_in  ( {stage_2_imag[i], stage_2_real[i]    } ),
                .src_valid_in ( done_stage_1                           ),
                .dst_data_out ( {stage_2_imag_q[i], stage_2_real_q[i]} ),
                .dst_valid_out( done_stage_2                           )
            );
        end
    endgenerate

    // stage 3
    generate
        for (genvar i = 0; i < N/2; i = i + 1)
        begin : stage_3
            bfly_2p #(
                .DATA_WIDTH ( DATA_WIDTH          )
            ) i_bfly_2p (
                .A_real     ( stage_2_real_q[i]   ),
                .A_imag     ( stage_2_imag_q[i]   ),
                .B_real     ( stage_2_real_q[i+4] ),
                .B_imag     ( stage_2_imag_q[i+4] ),
                .W_real     ( W_8_real[i]         ),
                .W_imag     ( W_8_imag[i]         ),
                .Y0_real    ( stage_3_real[i]     ),
                .Y0_imag    ( stage_3_imag[i]     ),
                .Y1_real    ( stage_3_real[i+4]   ),
                .Y1_imag    ( stage_3_imag[i+4]   )
            );
        end
    endgenerate

    assign X_real = stage_3_real;
    assign X_imag = stage_3_imag;
    assign done   = done_stage_1 & done_stage_2;
endmodule : fft_8p