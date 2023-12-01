// FIR filter

module fir_filter #(
    parameter INPUT_WORD_SIZE = 16,
    parameter COEFF_WORD_SIZE = 16,
    parameter N_COEFFS        = 5,
    localparam OUTPUT_WORD_SIZE = INPUT_WORD_SIZE + COEFF_WORD_SIZE + $clog2(N_COEFFS - 1) 
    )(
    input   logic                                             clk,
    input   logic                                             arst_n,
    input   logic                                             bypass,
    input   logic signed  [N_COEFFS-1:0][COEFF_WORD_SIZE-1:0] coeff,
    input   logic signed  [INPUT_WORD_SIZE-1:0]               data_in,
    input   logic                                             valid_in,
    output  logic                                             src_ready_out,
    output  logic signed  [OUTPUT_WORD_SIZE-1:0]              data_out,
    output  logic                                             valid_out,
    input   logic                                             dst_ready_in
);

    localparam DELAY_LINE_SIZE = N_COEFFS-1;

    // For zero padding and sign extension of bypass data
    localparam X           = INPUT_WORD_SIZE - 1;
    localparam Y           = COEFF_WORD_SIZE - 1;
    localparam Z           = OUTPUT_WORD_SIZE - (X+Y);
    localparam MSB_BP_DATA = INPUT_WORD_SIZE - 1;

    logic signed [INPUT_WORD_SIZE-1:0] delay_line [DELAY_LINE_SIZE-1:0];
    logic signed [OUTPUT_WORD_SIZE-1:0] data_out_interm;  // intermediate data out
    logic signed [OUTPUT_WORD_SIZE-1:0] bp_data;

    assign src_ready_out = dst_ready_in;

    always_ff @ (posedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            for (int i=0; i < DELAY_LINE_SIZE; i++)
            begin
                delay_line[i] <= '0;
            end
        end
        else if (valid_in)
        begin
            for (int i=0; i < DELAY_LINE_SIZE; i++)
            begin
                delay_line[i+1] <= delay_line[i];
            end
            delay_line[0] <= data_in;
        end
    end

    always_comb
    begin
        data_out_interm = $signed(data_in)*$signed(coeff[0]);
        for (int i=0; i<DELAY_LINE_SIZE; i++) 
        begin
            data_out_interm += $signed(delay_line[i])*$signed(coeff[i+1]);
        end
        valid_out = valid_in;
    end

    assign bp_data  = {{{(Z-1)}{data_in[MSB_BP_DATA]}}, {data_in, (Y)'(0)}};
    assign data_out = bypass ? bp_data : data_out_interm;

endmodule: fir_filter
