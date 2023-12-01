
module sym_even_fir_filter #(
    parameter INPUT_WORD_SIZE = 16,
    parameter COEFF_WORD_SIZE = 16,
    parameter N_COEFFS        = 5,
    parameter signed [N_COEFFS-1:0][COEFF_WORD_SIZE-1:0] COEFFS = '{N_COEFFS{0}},

    localparam OUTPUT_WORD_SIZE = INPUT_WORD_SIZE + COEFF_WORD_SIZE + $clog2(N_COEFFS) + 1
    )(
    input  logic                               clk,
    input  logic                               arst_n,
    input  logic signed [INPUT_WORD_SIZE-1:0]  data_in,
    input  logic                               valid_in,
    output logic signed [OUTPUT_WORD_SIZE-1:0] data_out,
    output logic                               valid_out
);

    ///////////////////////////////////////////////////////////////////////////
    // Local Parameters
    ///////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////
    // Functions
    ///////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////
    // Signals
    ///////////////////////////////////////////////////////////////////////////

    logic signed [INPUT_WORD_SIZE-1:0]               delay_line  [2*N_COEFFS-2:0];
    logic signed [INPUT_WORD_SIZE:0]                 pre_adder   [N_COEFFS-1:0];
    logic signed [OUTPUT_WORD_SIZE-1:0]              adder_out   [N_COEFFS-2:0];
    logic signed [OUTPUT_WORD_SIZE-1:0]              adder       [N_COEFFS-2:0];
    logic signed [OUTPUT_WORD_SIZE-1:0]              product_out [N_COEFFS-1:0];

    ///////////////////////////////////////////////////////////////////////////
    // Assignments and Instantiations
    ///////////////////////////////////////////////////////////////////////////

    assign pre_adder[0] = data_in + delay_line[2*N_COEFFS-2];
    
    generate
        for (genvar I=0; I < (N_COEFFS-1); I++)
        begin
            assign pre_adder[I+1] = delay_line[I] + delay_line[2*N_COEFFS-3-I];
        end
        for (genvar j=0; j < N_COEFFS; j++)
        begin
            assign product_out[j] = $signed(pre_adder[j]) * $signed(COEFFS[j]);
        end
    endgenerate

    // final adder
    generate
        if (N_COEFFS <= 1)
        begin
            assign adder[0] = product_out[0];
        end
        else
        begin
            assign adder[0] = product_out[0] + product_out[1];
            for(genvar I=1; I < (N_COEFFS-1); I++)
            begin
                assign adder[I] = adder_out[I-1] + product_out[I+1];
            end
        end
    endgenerate

    generate
        if (N_COEFFS <= 1)
        begin
            assign data_out  = product_out[0];
            assign valid_out = valid_in;
        end
        else
        begin
            assign data_out  = adder[N_COEFFS-2];
            assign valid_out = valid_in;
        end
    endgenerate

    ///////////////////////////////////////////////////////////////////////////
    // Always Statements
    ///////////////////////////////////////////////////////////////////////////

    // delay line
    always_ff @ (posedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            for (int i=0; i <= (2*N_COEFFS-2); i++)
            begin
                delay_line[i] <= '0;
            end
        end
        else if (valid_in)
        begin
            for (int i=0; i <= (2*N_COEFFS-2); i++)
            begin
                delay_line[i+1] <= delay_line[i];
            end
            delay_line[0] <= data_in;
        end
    end

endmodule
