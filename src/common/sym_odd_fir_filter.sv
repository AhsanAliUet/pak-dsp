
module sym_odd_fir_filter #(
    parameter INPUT_WORD_SIZE = 16,
    parameter COEFF_WORD_SIZE = 5,
    parameter N_COEFFS        = 5,
    parameter signed [N_COEFFS-1:0][COEFF_WORD_SIZE-1:0] COEFFS = {5'd6, 5'd1},
    localparam OUTPUT_WORD_SIZE = INPUT_WORD_SIZE + COEFF_WORD_SIZE + $clog2(N_COEFFS) + 1
    )(
    input  logic                                clk,
    input  logic                                arst_n,
    input  logic signed  [INPUT_WORD_SIZE-1:0]  data_in,
    input  logic                                valid_in,
    output logic signed  [OUTPUT_WORD_SIZE-1:0] data_out,
    output logic                                valid_out
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

    logic signed [INPUT_WORD_SIZE-1:0]  delay_line  [2*N_COEFFS-3:0];
    logic signed [INPUT_WORD_SIZE:0]    pre_adder   [N_COEFFS-1:0];
    // logic signed [2*INPUT_WORD_SIZE:0]  product_out [N_COEFFS-1:0];
    logic signed [OUTPUT_WORD_SIZE-1:0] product_out [N_COEFFS-1:0];
    logic signed [OUTPUT_WORD_SIZE-1:0] adder_out   [N_COEFFS-2:0];
    logic signed [OUTPUT_WORD_SIZE-1:0] adder   [N_COEFFS-2:0];

    ///////////////////////////////////////////////////////////////////////////
    // Assignments and Instantiations
    ///////////////////////////////////////////////////////////////////////////

    generate
        if(N_COEFFS<=1)
        begin
            assign pre_adder[0] = {data_in[INPUT_WORD_SIZE-1], data_in};
        end
        else
        begin
            for(genvar i=0; i < (N_COEFFS-2); i++)
            begin
                assign pre_adder[i+1]    = delay_line[i] + delay_line[2*N_COEFFS-4-i];
            end
            assign pre_adder[N_COEFFS-1] = {delay_line[N_COEFFS-2][INPUT_WORD_SIZE-1], delay_line[N_COEFFS-2]};
            assign pre_adder[0]          = data_in + delay_line[2*N_COEFFS-3];
        end

        for(genvar i=0; i < N_COEFFS; i++)
        begin
            assign product_out[i] = $signed(pre_adder[i]) * $signed(COEFFS[i]);
        end

        // final adder
        assign adder_out[0] = product_out[0] + product_out[1];
        for(genvar I=1; I < (N_COEFFS-1); I++)
        begin
            assign adder[I] = adder_out[I-1] + product_out[I+1];
        end
        
        if (N_COEFFS<=1)
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

    // shifter
    always_ff @ (posedge clk, negedge arst_n)
    begin
        if(~arst_n)
        begin
            for (int i=0; i <= (2*N_COEFFS-3); i++)
            begin
                delay_line[i] <= '0;
            end
        end
        else if (valid_in)
        begin
            for(int i=0; i <= (2*N_COEFFS-3); i++)
            begin
                delay_line[i+1] <= delay_line[i];
            end
            delay_line[0] <= data_in;
        end
    end

endmodule: sym_odd_fir_filter
