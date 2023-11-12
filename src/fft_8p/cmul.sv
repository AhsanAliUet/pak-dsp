// complex multiplier

module cmul #(
    parameter DATA_WIDTH = 16    // for each real and imaginary
)(
    input  logic signed [DATA_WIDTH-1:0] A_real,
    input  logic signed [DATA_WIDTH-1:0] A_imag,
    input  logic signed [DATA_WIDTH-1:0] B_real,
    input  logic signed [DATA_WIDTH-1:0] B_imag,
    output logic signed [DATA_WIDTH-1:0] Y_real,
    output logic signed [DATA_WIDTH-1:0] Y_imag
);

    // saturation/truncation function
    `define TRUNCATOR(M_I, N_I, M_O, N_O)                                               \
        function automatic logic signed [M_O+N_O-1:0] truncator_``M_I``_``N_I``_``M_O``_``N_O`` ( \
            input  logic signed [M_I+N_I-1:0] sig_i                                     \
        );                                                                              \
            localparam MSB_I  = M_I + N_I -1;                                           \
            localparam SAT_LO = {{M_O{(1'b1)}}, {N_O{(1'b0)}}};                         \
            localparam SAT_HI = {{M_O{(1'b0)}}, {N_O{(1'b1)}}};                         \
            logic [M_O+N_O-1:0] data_out;                                               \
            data_out = sig_i[N_I+M_O-1: N_I-N_O];                                       \
            return data_out;                                                            \
        endfunction: truncator_``M_I``_``N_I``_``M_O``_``N_O``

    `TRUNCATOR(16, 16, 8, 8);

    assign Y_real = truncator_16_16_8_8(A_real*B_real) - truncator_16_16_8_8(A_imag*B_imag);   // real = real*real - imag*imag
    assign Y_imag = truncator_16_16_8_8(A_real*B_imag) + truncator_16_16_8_8(A_imag*B_real);   // imag = real*imag + imag*real

endmodule : cmul
