module fft_4p
# (
    parameter N            = 4,
    parameter SAMPLE_WIDTH = 16,
    parameter PHASE_WIDTH  = 2,
    parameter DATA_WIDTH   = 16
) (
  	input  logic                           clk,
  	input  logic                           rst_n,
  	input  logic [N-1:0][SAMPLE_WIDTH-1:0] data_in,
    output logic [N-1:0][SAMPLE_WIDTH-1:0] data_out
);

    localparam NUM_STAGES = $clog2(N);

    logic [NUM_STAGES-1:0][N-1:0][SAMPLE_WIDTH-1:0] data_bfly_in;
    logic [NUM_STAGES-1:0][N-1:0][SAMPLE_WIDTH-1:0] data_bfly_out;

    logic [PHASE_WIDTH-1:0] ph;
    logic [ DATA_WIDTH-1:0] re;
    logic [ DATA_WIDTH-1:0] im;

    twiddle # (
        .PHASE_WIDTH ( 2  ),
        .DATA_WIDTH  ( 16 )
    ) twiddle_i (
        .ph          ( ph ),
        .re          ( re ),
        .im          ( im )
    );

    generate
        for(genvar k = 0; k < NUM_STAGES; k++) 
        begin
            for(genvar j = 0; j < k+1; j++) 
            begin
                for(genvar i = 0; i < N/(2**(k+1)); i++) 
                begin
                    butterfly # (
                        .DATAWIDTH ( SAMPLE_WIDTH                                    )
                    ) butterfly_i (
                        .data_1_in ( data_bfly_in [k][j*(N/(2**k)) +              i] ),
                        .data_2_in ( data_bfly_in [k][j*(N/(2**k)) + N/(2**(k+1))+i] ),
                        .data_1_out( data_bfly_out[k][j*(N/(2**k)) +              i] ),
                        .data_2_out( data_bfly_out[k][j*(N/(2**k)) + N/(2**(k+1))+i] )
                    );
                end
            end
        end
    endgenerate
    
    assign data_bfly_in[0] = data_in;

    always_ff @(posedge clk) 
    begin
        if(~rst_n)
        begin
            for(int i = 0; i < NUM_STAGES-1; i++)
            begin
                data_bfly_in[i+1] <= 'b0;
            end
        end
        else
        begin
            for(int i = 0; i < NUM_STAGES-1; i++)
            begin
                data_bfly_in[i+1] <= data_bfly_out[i];
            end
        end
    end

    assign data_out = data_bfly_out[NUM_STAGES];

endmodule
