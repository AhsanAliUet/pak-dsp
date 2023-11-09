// ddc
`include "defines_ddc.svh"

module ddc #(
    parameter DATA_WIDTH  = `DATA_WIDTH,
    parameter COEFF_WIDTH = `COEFF_WIDTH,
    parameter N_COEFFS_0  = 20,
    parameter N_COEFFS_1  = 20
)(
    input  logic                                  clk,
    input  logic                                  arst_n,
    input  logic [2:0]                            bypass,
    // input  logic signed [N_COEFFS_0+N_COEFFS_1-1:0][COEFF_WIDTH-1:0] coeffs[3],    // there are three interpolators
    input  logic [DATA_WIDTH-1:0]                 src_data_in,
    input  logic                                  src_valid_in,
    output logic                                  src_ready_out,
    output logic [`M_O_3+`N_O_3-1:0]              dst_data_out,
    output logic                                  dst_valid_out,
    input  logic                                  dst_ready_in
);

    localparam OUTPUT_WIDTH_1 = DATA_WIDTH       + COEFF_WIDTH + $clog2(N_COEFFS_0-1);
    localparam OUTPUT_WIDTH_2 = (DATA_WIDTH + 2) + COEFF_WIDTH + $clog2(N_COEFFS_0-1);
    localparam OUTPUT_WIDTH_3 = (DATA_WIDTH + 4) + COEFF_WIDTH + $clog2(N_COEFFS_0-1);

    localparam OUTPUT_WIDTH = OUTPUT_WIDTH_1;

    logic [OUTPUT_WIDTH_1-1:0] data_out_decim_1;
    logic                      valid_out_decim_1;
    logic                      ready_out_decim_1;
    logic [OUTPUT_WIDTH_2-1:0] data_out_decim_2;
    logic                      valid_out_decim_2;
    logic                      ready_out_decim_2;
    logic [OUTPUT_WIDTH_3-1:0] data_out_decim_3;
    logic                      valid_out_decim_3;
    logic                      ready_out_decim_3;
    logic [`M_O_1+`N_O_1-1:0]  data_out_sat_1;
    logic [`M_O_2+`N_O_2-1:0]  data_out_sat_2;
    logic [`M_O_3+`N_O_3-1:0]  data_out_sat_3;

    assign dst_data_out  = data_out_sat_3;
    assign src_ready_out = dst_ready_in;
    assign dst_valid_out = valid_out_decim_3;

    logic signed [N_COEFFS_0+N_COEFFS_1-1:0][COEFF_WIDTH-1:0] coeffs[3];

    assign coeffs[0][39:20] = `COEFF_0_DECIM_1;
    assign coeffs[0][19:0]  = `COEFF_1_DECIM_1;

    assign coeffs[1][39:20] = `COEFF_0_DECIM_2;
    assign coeffs[1][19:0]  = `COEFF_1_DECIM_2;

    assign coeffs[2][39:20] = `COEFF_0_DECIM_3;
    assign coeffs[2][19:0]  = `COEFF_1_DECIM_3;

    pp_decimator_2 #(
        .DATA_WIDTH      ( DATA_WIDTH        ),
        .COEFF_WIDTH     ( COEFF_WIDTH       ),
        .DECIM_FACTOR    ( 2                 ),
        .N_COEFFS_0      ( N_COEFFS_0        ),
        .N_COEFFS_1      ( N_COEFFS_1        )
    ) i_decim_1 (
        .clk             ( clk               ),
        .arst_n          ( arst_n            ),
        .bypass          ( bypass[0]         ),
        .coeffs          ( coeffs[0]         ),
        .data_in         ( src_data_in       ),
        .valid_in        ( src_valid_in      ),
        .data_out        ( data_out_decim_1  ),
        .valid_out       ( valid_out_decim_1 )
    );

    sat_trunc # (
        .M_I   ( 1                ),
        .N_I   (OUTPUT_WIDTH_1-1  ),
        .M_O   ( `M_O_1           ),
        .N_O   ( `N_O_1           )
    ) i_sat_truc_1 (
        .sig_i ( data_out_decim_1 ),
        .sig_o ( data_out_sat_1   )
    );

    pp_decimator_2 #(
        .DATA_WIDTH      ( DATA_WIDTH + 2    ),
        .COEFF_WIDTH     ( COEFF_WIDTH       ),
        .DECIM_FACTOR    ( 2                 ),
        .N_COEFFS_0      ( N_COEFFS_0        ),
        .N_COEFFS_1      ( N_COEFFS_1        )
    ) i_decim_2 (
        .clk             ( clk               ),
        .arst_n          ( arst_n            ),
        .bypass          ( bypass[1]         ),
        .coeffs          ( coeffs[1]         ),
        .data_in         ( data_out_sat_1    ),
        .valid_in        ( valid_out_decim_1 ),
        .data_out        ( data_out_decim_2  ),
        .valid_out       ( valid_out_decim_2 )
    );

    sat_trunc # (
        .M_I   ( 1                ),
        .N_I   ( OUTPUT_WIDTH_2-1 ),
        .M_O   ( `M_O_2           ),
        .N_O   ( `N_O_2           )
    ) i_sat_truc_2 (
        .sig_i ( data_out_decim_2 ),
        .sig_o ( data_out_sat_2   )
    );

    pp_decimator_2 #(
        .DATA_WIDTH      ( DATA_WIDTH + 4    ),
        .COEFF_WIDTH     ( COEFF_WIDTH       ),
        .DECIM_FACTOR    ( 2                 ),
        .N_COEFFS_0      ( N_COEFFS_0        ),
        .N_COEFFS_1      ( N_COEFFS_1        )
    ) i_decim_3 (
        .clk             ( clk               ),
        .arst_n          ( arst_n            ),
        .bypass          ( bypass[2]         ),
        .coeffs          ( coeffs[2]         ),
        .data_in         ( data_out_sat_2    ),
        .valid_in        ( valid_out_decim_2 ),
        .data_out        ( data_out_decim_3  ),
        .valid_out       ( valid_out_decim_3 )
    );

    sat_trunc # (
        .M_I   ( 1                ),
        .N_I   ( OUTPUT_WIDTH_3-1 ),
        .M_O   ( `M_O_3           ),
        .N_O   ( `N_O_3           )
    ) i_sat_truc_3 (
        .sig_i ( data_out_decim_3 ),
        .sig_o ( data_out_sat_3   )
    );

endmodule : ddc