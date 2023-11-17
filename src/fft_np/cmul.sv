// complex multiplier

module cmul
    import sat_pkg::sym_sat_9_8;
# (
    parameter DATA_WIDTH = 8    // for each real and imaginary
) (
    input  logic signed [DATA_WIDTH-1:0] A_real,
    input  logic signed [DATA_WIDTH-1:0] A_imag,
    input  logic signed [DATA_WIDTH-1:0] B_real,
    input  logic signed [DATA_WIDTH-1:0] B_imag,
    output logic signed [DATA_WIDTH-1:0] Y_real,
    output logic signed [DATA_WIDTH-1:0] Y_imag
);

    logic signed [(2*DATA_WIDTH+1)-1:0] fp_real;
    logic signed [(2*DATA_WIDTH+1)-1:0] fp_imag;

    assign fp_real = (A_real * B_real) - ( A_imag * B_imag );
    assign fp_imag = (A_real * B_imag) + ( A_imag * B_real );

    assign Y_real = sym_sat_9_8(fp_real[DATA_WIDTH : 0]);
    assign Y_imag = sym_sat_9_8(fp_imag[DATA_WIDTH : 0]);

endmodule : cmul
