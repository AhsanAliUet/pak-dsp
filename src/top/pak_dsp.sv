// pak-dsp core

module pak_dsp #(
    parameter  DATA_WIDTH      = 16,
    parameter  COEFF_WIDTH     = 16,
    parameter  N               = 8,    // number of FFT points
    localparam NUM_GPR_REGS    = 1,
    localparam NUM_COEFFS_REGS = 30,
    localparam TOTAL_REGS      = NUM_GPR_REGS +  NUM_COEFFS_REGS
)(
    input  logic                                              clk,
    input  logic                                              arst_n,

    // read write interface for memory
    input  logic                     [$clog2(TOTAL_REGS)-1:0] addr,
    input  logic                                              write_en,
    input  logic signed                      [DATA_WIDTH-1:0] wdata,
    output logic signed                      [DATA_WIDTH-1:0] rdata,

    // src side ports
    input  logic signed [DATA_WIDTH-1:0]                      src_data_in,
    input  logic                                              src_valid_in,
    output logic                                              src_ready_out,

    // dst side ports
    output logic signed [DATA_WIDTH-1:0]                      dst_data_out,
    output logic                                              dst_valid_out,
    input  logic                                              dst_ready_in,

    // fft's src side ports
    input  logic [DATA_WIDTH-1:0] src_data_in_fft,
    input  logic                  src_valid_in_fft,
    output logic                  src_ready_out_fft,

    // fft's dst side ports
    output logic [DATA_WIDTH-1:0] dst_data_out_fft,
    output logic                  dst_valid_out_fft,
    input  logic                  dst_ready_in_fft
);

    localparam OUTPUT_WORD_SIZE_FIR = 2*DATA_WIDTH + $clog2(NUM_COEFFS_REGS - 1);

    logic        [NUM_GPR_REGS-1:0][DATA_WIDTH-1:0]    gpr;        // general purpose register(s)
    logic signed [NUM_COEFFS_REGS-1:0][DATA_WIDTH-1:0] coeffs_fir; // coefficients for FIR

    // interpolator's dst side signals
    logic signed [DATA_WIDTH-1:0] dst_data_out_interp;
    logic                         dst_valid_out_interp;
    logic                         dst_ready_in_interp;

    // decimator's dst side signals
    logic signed [DATA_WIDTH-1:0] dst_data_out_decim;
    logic                         dst_valid_out_decim;
    logic                         dst_ready_in_decim;

    // fir filter related signals
    logic signed [DATA_WIDTH-1:0]           src_data_in_fir;
    logic                                   src_valid_in_fir;
    logic                                   src_ready_out_fir;
    logic signed [OUTPUT_WORD_SIZE_FIR-1:0] dst_data_out_fir;

    // fft signals
    logic signed [DATA_WIDTH-1:0] fft_x_real [N-1:0];
    logic signed [DATA_WIDTH-1:0] fft_x_imag [N-1:0];
    logic signed [DATA_WIDTH-1:0] fft_X_real [N-1:0];
    logic signed [DATA_WIDTH-1:0] fft_X_imag [N-1:0];

    // some internal signals
    logic src_ready_out_ddc;
    logic src_ready_out_duc;
    logic mux_en;

    assign src_ready_out = src_ready_out_ddc | src_ready_out_duc;

    duc #(
        .DATA_WIDTH    ( DATA_WIDTH           ),
        .COEFF_WIDTH   ( COEFF_WIDTH          )
    ) i_duc (
        .clk           ( clk                  ),
        .arst_n        ( arst_n               ),
        .bypass        ( /*from RIF*/         ),
        .src_data_in   ( src_data_in          ),
        .src_valid_in  ( src_valid_in         ),
        .src_ready_out ( src_ready_out_duc    ),
        .dst_data_out  ( dst_data_out_interp  ),
        .dst_valid_out ( dst_valid_out_interp ),
        .dst_ready_in  ( src_ready_out_fir    )
    );

    ddc #(
        .DATA_WIDTH    ( DATA_WIDTH          ),
        .COEFF_WIDTH   ( COEFF_WIDTH         ),
        .N_COEFFS_0    ( 1                   ),
        .N_COEFFS_1    ( 1                   )
    ) i_ddc (
        .clk           ( clk                 ),
        .arst_n        ( arst_n              ),
        .bypass        ( /*from RIF*/        ),
        .src_data_in   ( src_data_in         ),
        .src_valid_in  ( src_valid_in        ),
        .src_ready_out ( src_ready_out_ddc   ),
        .dst_data_out  ( dst_data_out_decim  ),
        .dst_valid_out ( dst_valid_out_decim ),
        .dst_ready_in  ( src_ready_out_fir   )
    );

    assign mux_en           = gpr[0][0];
    assign src_data_in_fir  = mux_en ? dst_data_out_interp : dst_data_out_decim;
    assign src_valid_in_fir = mux_en ? dst_valid_out_interp : dst_valid_out_decim;

    fir_filter #(
        .INPUT_WORD_SIZE ( DATA_WIDTH        ),
        .COEFF_WORD_SIZE ( DATA_WIDTH        ),
        .N_COEFFS        ( NUM_COEFFS_REGS   )
    ) i_fir_filter (
        .clk             ( clk               ),
        .arst_n          ( arst_n            ),
        .coeff           ( coeffs_fir        ),
        .data_in         ( src_data_in_fir   ),
        .valid_in        ( src_valid_in_fir  ),
        .src_ready_out   ( src_ready_out_fir ),
        .data_out        ( dst_data_out_fir  ),
        .valid_out       ( dst_valid_out     ),
        .dst_ready_in    ( dst_ready_in      )
    );

    fft_8p #(
        .DATA_WIDTH    ( DATA_WIDTH ),
        .N             ( N          )
    ) i_fft_np (
        .clk           ( clk        ),
        .arst_n        ( arst_n     ),
        .x_real        ( fft_x_real ),
        .x_imag        ( fft_x_imag ),
        .X_real        ( fft_X_real ),
        .X_imag        ( fft_X_imag )
    );

    memory_map #(
        .DATA_WIDTH      ( DATA_WIDTH      ),
        .NUM_GPR_REGS    ( NUM_GPR_REGS    ),
        .NUM_COEFFS_REGS ( NUM_COEFFS_REGS )
    ) i_memory_map (
        .clk             ( clk             ),
        .arst_n          ( arst_n          ),
        .addr            ( addr            ),
        .write_en        ( write_en        ),
        .wdata           ( wdata           ),
        .rdata           ( rdata           ),
        .gpr             ( gpr             ),
        .coeffs          ( coeffs_fir      )
    );

endmodule : pak_dsp