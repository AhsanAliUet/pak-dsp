`ifndef duc_defines
`define duc_defines

// parameters of truncation block number 1
`define M_O_1 1
`define N_O_1 17

// parameters of truncation block number 2
`define M_O_2 1
`define N_O_2 19

// parameters of truncation block number 3
`define M_O_3 1
`define N_O_3 15

`define DATA_WIDTH  16
`define COEFF_WIDTH 16

`define COEFFS_0_ODD_INTERP_1 0
`define COEFFS_1_ODD_INTERP_1 0
`define COEFFS_0_ODD_INTERP_2 0
`define COEFFS_1_ODD_INTERP_2 0
`define COEFFS_0_ODD_INTERP_3 0
`define COEFFS_1_ODD_INTERP_3 0

`define N_COEFFS_0_INTERP_1 10
`define N_COEFFS_1_INTERP_1 10
`define N_COEFFS_0_INTERP_2 11
`define N_COEFFS_1_INTERP_2 11
`define N_COEFFS_0_INTERP_3 3
`define N_COEFFS_1_INTERP_3 3

`define COEFF_0_INTERP_1 {16'd20751, -16'd6629, 16'd3649, -16'd2284, 16'd1482, -16'd957, 16'd599, -16'd355, 16'd193, -16'd108}
`define COEFF_1_INTERP_1 {16'd32767, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0}
`define COEFF_0_INTERP_2 {16'd28, -16'd198, 16'd802, -16'd2526, 16'd8725, 16'd29742, -16'd5246, 16'd1973, -16'd683, 16'd176, -16'd25}
`define COEFF_1_INTERP_2 {-16'd25, 16'd176, -16'd683, 16'd1973, -16'd5246, 16'd29742, 16'd8725, -16'd2526, 16'd802, -16'd198, 16'd28}
`define COEFF_0_INTERP_3 {16'd19333, -16'd3406, 16'd458}
`define COEFF_1_INTERP_3 {16'd32767, 16'd0, 16'd0}

`endif
