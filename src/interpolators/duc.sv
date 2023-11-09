
`include "defines_duc.svh"

module duc #(
    parameter DATA_WIDTH  = `DATA_WIDTH,
    parameter COEFF_WIDTH = `COEFF_WIDTH,
    parameter N_COEFFS_0  = 20,
    parameter N_COEFFS_1  = 20,
    localparam OUTPUT_WIDTH = DATA_WIDTH + COEFF_WIDTH + $clog2(N_COEFFS_0) + 1
)(
    input  logic                                              clk,
    input  logic                                              arst_n,
    input  logic [2:0]                                        bypass,
    // input  logic [N_COEFFS_0+N_COEFFS_1-1:0][COEFF_WIDTH-1:0] coeffs[3],    // there are three interpolators
    input  logic [DATA_WIDTH-1:0]                             src_data_in,
    input  logic                                              src_valid_in,
    output logic                                              src_ready_out,
    output logic [`M_O_3+`N_O_3-1:0]                          dst_data_out,
    output logic                                              dst_valid_out,
    input  logic                                              dst_ready_in
);

    localparam OUTPUT_WIDTH_1 = DATA_WIDTH       + COEFF_WIDTH + $clog2(N_COEFFS_0 - 1);
    localparam OUTPUT_WIDTH_2 = (DATA_WIDTH + 2) + COEFF_WIDTH + $clog2(N_COEFFS_0 - 1);
    localparam OUTPUT_WIDTH_3 = (DATA_WIDTH + 4) + COEFF_WIDTH + $clog2(N_COEFFS_0 - 1);

    logic [OUTPUT_WIDTH_1-1:0] data_out_interp_1;
    logic                      valid_out_interp_1;
    logic                      ready_out_interp_1;
    logic [OUTPUT_WIDTH_2-1:0] data_out_interp_2;
    logic                      valid_out_interp_2;
    logic                      ready_out_interp_2;
    logic [OUTPUT_WIDTH_3-1:0] data_out_interp_3;
    logic                      valid_out_interp_3;
    logic                      ready_out_interp_3;
    logic [`M_O_1+`N_O_1-1:0]  data_out_sat_1;
    logic [`M_O_2+`N_O_2-1:0]  data_out_sat_2;
    logic [`M_O_3+`N_O_3-1:0]  data_out_sat_3;

    assign src_ready_out = ready_out_interp_1;
    assign dst_data_out  = data_out_sat_3;
    assign dst_valid_out = valid_out_interp_3;

    logic signed [N_COEFFS_0+N_COEFFS_1-1:0][COEFF_WIDTH-1:0] coeffs[3];    // there are three interpolators

    assign coeffs[0][39:20] = `COEFF_0_INTERP_1;
    assign coeffs[0][19:0]  = `COEFF_1_INTERP_1;

    assign coeffs[1][39:20] = `COEFF_0_INTERP_2;
    assign coeffs[1][19:0]  = `COEFF_1_INTERP_2;

    assign coeffs[2][39:20] = `COEFF_0_INTERP_3;
    assign coeffs[2][19:0]  = `COEFF_1_INTERP_3;

    interpolator #(
        .DATA_WIDTH    ( DATA_WIDTH         ),
    ) i_interpolator_1 (
        .clk           ( clk                ),
        .arst_n        ( arst_n             ),
        .bypass        ( bypass[0]          ),
        .coeffs        ( coeffs[0]          ),
        .src_data_in   ( src_data_in        ),
        .src_valid_in  ( src_valid_in       ),
        .src_ready_out ( ready_out_interp_1 ),
        .dst_data_out  ( data_out_interp_1  ),
        .dst_valid_out ( valid_out_interp_1 ),
        .dst_ready_in  ( ready_out_interp_2 )
    );

    sat_trunc # (
        .M_I   ( 1                 ),
        .N_I   ( OUTPUT_WIDTH_1-1  ),
        .M_O   ( `M_O_1            ),
        .N_O   ( `N_O_1            )
    ) i_sat_truc_1 (
        .sig_i ( data_out_interp_1 ),
        .sig_o ( data_out_sat_1    )
    );

    interpolator #(
        .DATA_WIDTH      ( DATA_WIDTH + 2     ),
    ) i_interpolator_2 (
        .clk             ( clk                ),
        .arst_n          ( arst_n             ),
        .bypass          ( bypass[1]          ),
        .coeffs          ( coeffs[1]          ),
        .src_data_in     ( data_out_sat_1     ),
        .src_valid_in    ( valid_out_interp_1 ),
        .src_ready_out   ( ready_out_interp_2 ),
        .dst_data_out    ( data_out_interp_2  ),
        .dst_valid_out   ( valid_out_interp_2 ),
        .dst_ready_in    ( ready_out_interp_3 )
    );

    sat_trunc # (
        .M_I   ( 1                 ),
        .N_I   ( OUTPUT_WIDTH_2-1  ),
        .M_O   ( `M_O_2            ),
        .N_O   ( `N_O_2            )
    ) i_sat_truc_2 (
        .sig_i ( data_out_interp_2 ),
        .sig_o ( data_out_sat_2    )
    );

    interpolator #(
        .DATA_WIDTH      ( DATA_WIDTH + 4     ),
    ) i_interpolator_3 (
        .clk             ( clk                ),
        .arst_n          ( arst_n             ),
        .bypass          ( bypass[2]          ),
        .coeffs          ( coeffs[2]          ),
        .src_data_in     ( data_out_sat_2     ),
        .src_valid_in    ( valid_out_interp_2 ),
        .src_ready_out   ( ready_out_interp_3 ),
        .dst_data_out    ( data_out_interp_3  ),
        .dst_valid_out   ( valid_out_interp_3 ),
        .dst_ready_in    ( dst_ready_in       )
    );

    sat_trunc # (
        .M_I   ( 1                 ),
        .N_I   ( OUTPUT_WIDTH_3-1  ),
        .M_O   ( `M_O_3            ),
        .N_O   ( `N_O_3            )
    ) i_sat_truc_3 (
        .sig_i ( data_out_interp_3 ),
        .sig_o ( data_out_sat_3    )
    );

endmodule : duc