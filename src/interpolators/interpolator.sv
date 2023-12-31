// configurable interpolation rate interpolator
// supported interpolation rates are 2, 4 and 8.

`ifdef VERILATOR
    `include "defines_duc.svh"
`else
    `include "../include/defines_duc.svh"
`endif

module interpolator #(
    parameter  DATA_WIDTH   = 16,
    parameter  COEFF_WIDTH  = 16,
    parameter  COEFFS_0_ODD = `COEFFS_0_ODD_INTERP_3,
    parameter  COEFFS_1_ODD = `COEFFS_1_ODD_INTERP_3,
    parameter  N_COEFFS_0   = `N_COEFFS_0_INTERP_3,
    parameter  N_COEFFS_1   = `N_COEFFS_1_INTERP_3,
    parameter  signed [N_COEFFS_0-1:0][COEFF_WIDTH-1:0] COEFFS_0 = `COEFF_0_INTERP_3,
    parameter  signed [N_COEFFS_0-1:0][COEFF_WIDTH-1:0] COEFFS_1 = `COEFF_1_INTERP_3,
    localparam OUTPUT_WIDTH = DATA_WIDTH + COEFF_WIDTH + $clog2(N_COEFFS_0) + 1
)(
    input  logic                           clk,
    input  logic                           arst_n,
    input  logic                           bypass,
    input  logic signed [DATA_WIDTH-1:0]   src_data_in,
    input  logic                           src_valid_in,
    output logic                           src_ready_out,
    output logic signed [OUTPUT_WIDTH-1:0] dst_data_out,
    output logic                           dst_valid_out,
    input  logic                           dst_ready_in
);

    // For zero padding and sign extension of bypass data
    localparam X           = DATA_WIDTH - 1;
    localparam Y           = COEFF_WIDTH - 1;
    localparam Z           = OUTPUT_WIDTH - (X+Y);
    localparam MSB_BP_DATA = DATA_WIDTH - 1;

    logic [1:0]              filter_val;   // 2 polyphase branches
    logic [OUTPUT_WIDTH-1:0] bp_data_out;
    logic [OUTPUT_WIDTH-1:0] filter_output;
    logic [OUTPUT_WIDTH-1:0] filter_output0;
    logic [OUTPUT_WIDTH-1:0] filter_output0_q;
    logic [OUTPUT_WIDTH-1:0] filter_output1;
    logic [OUTPUT_WIDTH-1:0] filter_output1_q;

    logic [OUTPUT_WIDTH-1:0] dst_bp_data_out;

    // control signals
    logic dm;
    logic en_out;
    logic dst_valid;
    logic src_ready;

    generate
        if (COEFFS_0_ODD==0)
        begin
            sym_even_fir_filter #(
                .INPUT_WORD_SIZE( DATA_WIDTH     ),
                .COEFF_WORD_SIZE( COEFF_WIDTH    ),
                .N_COEFFS       ( N_COEFFS_0     ),
                .COEFFS         ( COEFFS_0       )
            ) u_sym_even_fir_filter_0 (
                .clk            ( clk            ),
                .arst_n         ( arst_n         ),
                .data_in        ( src_data_in    ),
                .valid_in       ( src_valid_in   ),
                .data_out       ( filter_output0 ),
                .valid_out      ( filter_val[0]  )
            );
        end
        else
        begin
            sym_odd_fir_filter #(
                .INPUT_WORD_SIZE( DATA_WIDTH     ),
                .COEFF_WORD_SIZE( COEFF_WIDTH    ),
                .N_COEFFS       ( N_COEFFS_0     ),
                .COEFFS         ( COEFFS_0       )
            ) u_sym_odd_fir_filter_0 (
                .clk            ( clk            ),
                .arst_n         ( arst_n         ),
                .data_in        ( src_data_in    ),
                .valid_in       ( src_valid_in   ),
                .data_out       ( filter_output0 ),
                .valid_out      ( filter_val[0]  )
            );
        end

        if (COEFFS_1_ODD==0)
        begin
            sym_even_fir_filter #(
                .INPUT_WORD_SIZE( DATA_WIDTH     ),
                .COEFF_WORD_SIZE( COEFF_WIDTH    ),
                .N_COEFFS       ( N_COEFFS_1     ),
                .COEFFS         ( COEFFS_1       )
            ) u_sym_even_fir_filter_1 (
                .clk            ( clk            ),
                .arst_n         ( arst_n         ),
                .data_in        ( src_data_in    ),
                .valid_in       ( src_valid_in   ),
                .data_out       ( filter_output1 ),
                .valid_out      ( filter_val[1]  )
            );
        end
        else
        begin
            sym_odd_fir_filter #(
                .INPUT_WORD_SIZE( DATA_WIDTH     ),
                .COEFF_WORD_SIZE( COEFF_WIDTH    ),
                .N_COEFFS       ( N_COEFFS_1     ),
                .COEFFS         ( COEFFS_1       )
            ) u_sym_odd_fir_filter_1 (
                .clk            ( clk            ),
                .arst_n         ( arst_n         ),
                .data_in        ( src_data_in    ),
                .valid_in       ( src_valid_in   ),
                .data_out       ( filter_output1 ),
                .valid_out      ( filter_val[1]  )
            );
        end
    endgenerate

    assign filter_output    = dm ? filter_output1_q : filter_output0_q;

    // sign extension and zero padding for bypass data to be equal as output data width
    assign dst_bp_data_out  = {{{(Z-1)}{src_data_in[MSB_BP_DATA]}}, {src_data_in, (Y)'(0)}};

    assign dst_data_out     = bypass ? dst_bp_data_out : filter_output;
    assign dst_valid_out    = bypass ? src_valid_in    : dst_valid;
    assign src_ready_out    = bypass ? dst_ready_in    : src_ready;

    always_ff @ (posedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            filter_output0_q <= '0;
            filter_output1_q <= '0;
        end
        else if (en_out)
        begin
            filter_output0_q <= filter_output0;
            filter_output1_q <= filter_output1;
        end
    end

    interpolator_ctrl i_interpolator_ctrl (
        .clk           ( clk          ),
        .arst_n        ( arst_n       ),
        .dst_ready_in  ( dst_ready_in ),
        .src_valid_in  ( src_valid_in ),
        .src_ready_out ( src_ready    ),
        .dst_valid_out ( dst_valid    ),
        .en_out        ( en_out       ),
        .dm_out        ( dm           )
    );

endmodule : interpolator