// address generation unit for read and write to 2 port rams

module agu #(
    parameter DATA_WIDTH = 32
)(
    input  logic    clk,
    input  logic    arst_n,
    input  logic    start,
    output logic    fft_done,
    output logic    read_mem_sel,
    output logic    mem_1_wr,
    output logic    mem_2_wr,
    output logic [] twiddle_addr,
    output logic [] addr_1_a,
    output logic [] addr_1_b,
    output logic [] addr_2_a,
    output logic [] addr_2_b
);

endmodule : agu