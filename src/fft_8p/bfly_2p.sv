// 2 point FFT caculator butterfly unit

module bfly_2p #(
    parameter DATA_WIDTH = 16
)(
    input  logic signed [DATA_WIDTH-1:0]   A,
    input  logic signed [DATA_WIDTH-1:0]   B,
    input  logic signed [DATA_WIDTH-1:0]   W,     // twiddle factor
    output logic signed [2*DATA_WIDTH-1:0] A_out, // A_out = A + B*W
    output logic signed [2*DATA_WIDTH-1:0] B_out  // B_out = A - B*W
);

    logic signed [2*DATA_WIDTH-1:0] mult_res;

    assign mult_res = B * W;

    assign A_out    = A + mult_res;
    assign B_out    = A - mult_res;

endmodule : bfly_2p