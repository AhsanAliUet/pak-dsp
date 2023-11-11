// complex adder

module cadd #(
    parameter DATA_WIDTH = 16    // for each real and imaginary
)(
    input  logic signed [DATA_WIDTH-1:0] A_real,
    input  logic signed [DATA_WIDTH-1:0] A_imag,
    input  logic signed [DATA_WIDTH-1:0] B_real,
    input  logic signed [DATA_WIDTH-1:0] B_imag,
    output logic signed [DATA_WIDTH-1:0] Y_real,
    output logic signed [DATA_WIDTH-1:0] Y_imag
);

    assign Y_real = A_real + B_real;   // real = real + real
    assign Y_imag = A_imag + B_imag;   // imag = imag + imag

endmodule : cadd
