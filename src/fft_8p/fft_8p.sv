// 8 point FFT module

module fft_8p #(
    parameter DATA_WIDTH = 16,    // for each real and imaginary
    parameter N          = 8      // N points
)(
    input  logic                         clk,
    input  logic                         arst_n,
    // input  logic signed [DATA_WIDTH-1:0] x_real [N-1:0],
    // input  logic signed [DATA_WIDTH-1:0] x_imag [N-1:0],
    output logic signed [DATA_WIDTH-1:0] X_real [N-1:0],
    output logic signed [DATA_WIDTH-1:0] X_imag [N-1:0]
);

    localparam STAGE1 = 1;
    localparam STAGE2 = 2;
    localparam STAGE3 = 3;

    logic signed [N-1:0][DATA_WIDTH-1:0] x_real;
    logic signed [N-1:0][DATA_WIDTH-1:0] x_imag;

    function shortint float2fix16(real x, shortint fw);
        return shortint'(x*(2**fw));
    endfunction

    shortint ONE_REAL   = float2fix16(1, 8);
    shortint TWO_REAL   = float2fix16(2, 8);
    shortint THREE_REAL = float2fix16(3, 8);
    shortint FOUR_REAL  = float2fix16(4, 8);
    shortint FIVE_REAL  = float2fix16(5, 8);
    shortint SIX_REAL   = float2fix16(6, 8);
    shortint SEVEN_REAL = float2fix16(7, 8);
    shortint EIGHT_REAL = float2fix16(8, 8);

    shortint ONE_IMAG   = float2fix16(1, 8);
    shortint TWO_IMAG   = float2fix16(1, 8);
    shortint THREE_IMAG = float2fix16(1, 8);
    shortint FOUR_IMAG  = float2fix16(1, 8);
    shortint FIVE_IMAG  = float2fix16(1, 8);
    shortint SIX_IMAG   = float2fix16(1, 8);
    shortint SEVEN_IMAG = float2fix16(1, 8);
    shortint EIGHT_IMAG = float2fix16(1, 8);

    assign x_real = {EIGHT_REAL, SEVEN_REAL, SIX_REAL, FIVE_REAL, FOUR_REAL, THREE_REAL, TWO_REAL, ONE_REAL};
    assign x_imag = {EIGHT_IMAG, SEVEN_IMAG, SIX_IMAG, FIVE_IMAG, FOUR_IMAG, THREE_IMAG, TWO_IMAG, ONE_IMAG};

    logic signed [N/2-1:0][DATA_WIDTH-1:0] W_8_real;
    logic signed [N/2-1:0][DATA_WIDTH-1:0] W_8_imag;

    assign W_8_real[0] = float2fix16(1     , 8);   // 1      - j0
    assign W_8_imag[0] = float2fix16(-0    , 8);   // 1      - j0
    assign W_8_real[1] = float2fix16(0.707 , 8);   // 0.707  - j0.707
    assign W_8_imag[1] = float2fix16(-0.707, 8);   // 0.707  - j0.707
    assign W_8_real[2] = float2fix16(0     , 8);   // 0      - j1
    assign W_8_imag[2] = float2fix16(-1    , 8);   // 0      - j1
    assign W_8_real[3] = float2fix16(-0.707, 8);   // -0.707 - j0.707
    assign W_8_imag[3] = float2fix16(-0.707, 8);   // -0.707 - j0.707

    logic signed [DATA_WIDTH-1:0] stage_1_real [N-1:0];
    logic signed [DATA_WIDTH-1:0] stage_1_imag [N-1:0];

    logic signed [DATA_WIDTH-1:0] stage_2_real [N-1:0];
    logic signed [DATA_WIDTH-1:0] stage_2_imag [N-1:0];

    logic signed [DATA_WIDTH-1:0] stage_3_real [N-1:0];
    logic signed [DATA_WIDTH-1:0] stage_3_imag [N-1:0];

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

    // stage 2
    generate
        for (genvar i = 0; i < N/4; i = i + 1)
        begin : stage_2
            bfly_2p #(
                .DATA_WIDTH ( DATA_WIDTH        )
            ) i_bfly_2p (
                .A_real     ( stage_1_real[i]   ),
                .A_imag     ( stage_1_imag[i]   ),
                .B_real     ( stage_1_real[i+2] ),
                .B_imag     ( stage_1_imag[i+2] ),
                .W_real     ( (i==0) ? W_8_real[0] : W_8_real[2] ),
                .W_imag     ( (i==0) ? W_8_imag[0] : W_8_imag[2] ),
                .Y0_real    ( stage_2_real[i]   ),
                .Y0_imag    ( stage_2_imag[i]   ),
                .Y1_real    ( stage_2_real[i+2] ),
                .Y1_imag    ( stage_2_imag[i+2] )
            );
        end

        for (genvar j = N/2; j < N/2+2; j++)
        begin : stage_2
            bfly_2p #(
                .DATA_WIDTH ( DATA_WIDTH        )
            ) i_bfly_2p (
                .A_real     ( stage_1_real[j]   ),
                .A_imag     ( stage_1_imag[j]   ),
                .B_real     ( stage_1_real[j+2] ),
                .B_imag     ( stage_1_imag[j+2] ),
                .W_real     ( (j==(N/2)) ? W_8_real[0] : W_8_real[2] ),
                .W_imag     ( (j==(N/2)) ? W_8_imag[0] : W_8_imag[2] ),
                .Y0_real    ( stage_2_real[j]   ),
                .Y0_imag    ( stage_2_imag[j]   ),
                .Y1_real    ( stage_2_real[j+2] ),
                .Y1_imag    ( stage_2_imag[j+2] )
            );
        end

    endgenerate

    // stage 3
    generate
        for (genvar i = 0; i < N/2; i = i + 1)
        begin : stage_3
            bfly_2p #(
                .DATA_WIDTH ( DATA_WIDTH        )
            ) i_bfly_2p (
                .A_real     ( stage_2_real[i]   ),
                .A_imag     ( stage_2_imag[i]   ),
                .B_real     ( stage_2_real[i+4] ),
                .B_imag     ( stage_2_imag[i+4] ),
                .W_real     ( W_8_real[i]       ),
                .W_imag     ( W_8_imag[i]       ),
                .Y0_real    ( stage_3_real[i]   ),
                .Y0_imag    ( stage_3_imag[i]   ),
                .Y1_real    ( stage_3_real[i+4] ),
                .Y1_imag    ( stage_3_imag[i+4] )
            );
        end
    endgenerate
endmodule : fft_8p