// 2 point FFT caculator butterfly unit

module bfly_2p #(
    parameter DATA_WIDTH = 16
)(
    input  logic signed [DATA_WIDTH-1:0] A_real,
    input  logic signed [DATA_WIDTH-1:0] A_imag,
    input  logic signed [DATA_WIDTH-1:0] B_real,
    input  logic signed [DATA_WIDTH-1:0] B_imag,
    input  logic signed [DATA_WIDTH-1:0] W_real,
    input  logic signed [DATA_WIDTH-1:0] W_imag,
    output logic signed [DATA_WIDTH-1:0] Y0_real,
    output logic signed [DATA_WIDTH-1:0] Y0_imag,
    output logic signed [DATA_WIDTH-1:0] Y1_real,
    output logic signed [DATA_WIDTH-1:0] Y1_imag
);

    // Y0 = A + B*W;
    // Y1 = A - B*W;

    logic signed [DATA_WIDTH-1:0] mult_res_real;
    logic signed [DATA_WIDTH-1:0] mult_res_imag;

    cmul #(
        .DATA_WIDTH ( DATA_WIDTH    )
    ) i_cmul (
        .A_real     ( B_real        ),
        .A_imag     ( B_imag        ),
        .B_real     ( W_real        ),
        .B_imag     ( W_imag        ),
        .Y_real     ( mult_res_real ),
        .Y_imag     ( mult_res_imag )
    );

    cadd #(
        .DATA_WIDTH ( DATA_WIDTH    )
    ) i_cadd_0 (
        .A_real     ( A_real        ),
        .A_imag     ( A_imag        ),
        .B_real     ( mult_res_real ),
        .B_imag     ( mult_res_imag ),
        .Y_real     ( Y0_real       ),
        .Y_imag     ( Y0_imag       )
    );

    cadd #(
        .DATA_WIDTH ( DATA_WIDTH           )
    ) i_cadd_1 (
        .A_real     ( A_real               ),
        .A_imag     ( A_imag               ),
        .B_real     ( ~(mult_res_real) + 1 ),
        .B_imag     ( ~(mult_res_imag) + 1 ),
        .Y_real     ( Y1_real              ),
        .Y_imag     ( Y1_imag              )
    );

endmodule : bfly_2p