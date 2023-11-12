// the module which gives n cycles delay to a signal

module pipeline #(
    parameter NUM_STAGES = 10,
    parameter BYPASS     = 0,
    parameter DATA_WIDTH = 16
)(
    input  logic                         clk,
    input  logic                         arst_n,
    input  logic                         en_in,
    input  logic signed [DATA_WIDTH-1:0] src_data_in,
    output logic signed [DATA_WIDTH-1:0] dst_data_out
);

    logic [DATA_WIDTH-1:0] buffer [NUM_STAGES-1:0];

    generate
        if (NUM_STAGES > 0 && BYPASS != 1)
        begin
            always_ff @ (posedge clk, negedge arst_n)
            begin
                if (~arst_n)
                begin
                    buffer <= '{default: '0};
                end
                else if (en_in)
                begin
                    for (int i = 0; i < NUM_STAGES; i++)
                    begin
                        buffer[i+1] <= buffer[i];
                    end
                    buffer[0] <= src_data_in;
                end
            end

            assign dst_data_out = buffer[NUM_STAGES-1];
        end
        else if (NUM_STAGES == 0 || NUM_STAGES < 0 || BYPASS == 1)
        begin
            assign dst_data_out = src_data_in;
        end
    endgenerate

endmodule : pipeline