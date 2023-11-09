// decimator

module pp_decimator_2 #(
    parameter DATA_WIDTH = 16,
    parameter COEFF_WIDTH     = 16,
    parameter DECIM_FACTOR    = 2,
    parameter N_COEFFS        = 20,
    parameter N_COEFFS_0      = 2,
    parameter N_COEFFS_1      = 1,

    localparam FIR_OUTPUT_SIZE  = DATA_WIDTH + COEFF_WIDTH + $clog2(N_COEFFS_0-1),
    localparam FIR_OUTPUT_SIZE1 = DATA_WIDTH + COEFF_WIDTH + $clog2(N_COEFFS_1-1),
    localparam OUTPUT_WORD_SIZE = FIR_OUTPUT_SIZE
)(
    input                                                            clk,
    input                                                            arst_n,
    input                                                            bypass,
    input  logic signed [N_COEFFS_0+N_COEFFS_1-1:0][COEFF_WIDTH-1:0] coeffs,
    input  logic signed [DATA_WIDTH-1:0]                             data_in,
    input                                                            valid_in,
    output logic signed [OUTPUT_WORD_SIZE-1:0]                       data_out,
    output logic                                                     valid_out
);

    // For zero padding and sign extension of bypass data
    localparam X           = DATA_WIDTH - 1;
    localparam Y           = COEFF_WIDTH - 1;
    localparam Z           = OUTPUT_WORD_SIZE - (X+Y);
    localparam MSB_BP_DATA = DATA_WIDTH - 1;

    logic        [DECIM_FACTOR-1:0]     pp_turns;
    logic        [DECIM_FACTOR-1:0]     pp_valid_in;
    logic        [DECIM_FACTOR-1:0]     pp_valid_out_reg;
    logic signed [FIR_OUTPUT_SIZE-1:0]  data_out_reg [DECIM_FACTOR-1:0];

    // Polyphase Branches
    logic signed [FIR_OUTPUT_SIZE-1:0]  pp_output0;
    logic signed [FIR_OUTPUT_SIZE1-1:0] pp_output1;
    logic        [DECIM_FACTOR-1:0]     pp_valid_out;
    
    logic signed [OUTPUT_WORD_SIZE-1:0] bp_data;

    assign pp_valid_in = pp_turns & {DECIM_FACTOR{valid_in}};

    assign bp_data  = {{{(Z-1)}{data_in[MSB_BP_DATA]}}, {data_in, (Y)'(0)}};

    // Final Adder
    assign data_out  = bypass ? bp_data  : data_out_reg[0] + data_out_reg[1];
    assign valid_out = bypass ? valid_in : pp_valid_out_reg[0];


    fir_filter #(
        .INPUT_WORD_SIZE ( DATA_WIDTH      ),
        .COEFF_WORD_SIZE ( COEFF_WIDTH     ),
        .N_COEFFS        ( N_COEFFS_0      )
    ) i_fir_filter_0 (
        .clk             ( clk             ),
        .arst_n          ( arst_n          ),
        .coeff           ( coeffs[39:20]   ),
        .data_in         ( data_in         ),
        .valid_in        ( pp_valid_in[0]  ),
        .data_out        ( pp_output0      ),
        .valid_out       ( pp_valid_out[0] )
    );

    fir_filter #(
        .INPUT_WORD_SIZE ( DATA_WIDTH  ),
        .COEFF_WORD_SIZE ( COEFF_WIDTH ),
        .N_COEFFS        ( N_COEFFS_1  )
    ) i_fir_filter_1 (
        .clk             ( clk             ),
        .arst_n          ( arst_n          ),
        .coeff           ( coeffs[19:0]    ),
        .data_in         ( data_in         ),
        .valid_in        ( pp_valid_in[1]  ),
        .data_out        ( pp_output1      ),
        .valid_out       ( pp_valid_out[1] )
    );

    always_ff @(posedge clk, negedge arst_n)
    begin
        if(~arst_n)
        begin
            pp_turns <= 1;
        end
        else if(valid_in)
        begin
            pp_turns <= {pp_turns[0], pp_turns[DECIM_FACTOR-1:1]};
        end
    end

    always_ff @ (posedge clk, negedge arst_n)
    begin
        if(~arst_n)
        begin
            for(int i=0; i<DECIM_FACTOR; i++)
            begin
                data_out_reg[i] <= #1 0;
            end
        end
        else
        begin
            if(pp_valid_out[0])
            begin
                data_out_reg[0] <= pp_output0;
            end
            if(pp_valid_out[1])
            begin
                data_out_reg[1] <= pp_output1;
            end
        end
    end
    
    always_ff@(posedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            pp_valid_out_reg <= 0;
        end
        else
        begin
            pp_valid_out_reg <= pp_valid_out;
        end
    end

endmodule
