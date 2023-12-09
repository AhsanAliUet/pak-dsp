
`ifndef ddc_defines
`define ddc_defines

`define DATA_WIDTH      16
`define COEFF_WIDTH_DDC 5
`define NUM_COEFF_0     2
`define NUM_COEFF_1     1

`define COEFFS_0 {5'd6, 5'd1}
`define COEFFS_1 {5'd4}

`define COEFFS_0_ODD 1
`define COEFFS_1_ODD 0

// parameters of truncation block number 1
`define M_O_1_DDC 1
`define N_O_1_DDC 17

// parameters of truncation block number 2
`define M_O_2_DDC 1
`define N_O_2_DDC 19

// parameters of truncation block number 3
`define M_O_3_DDC 1
`define N_O_3_DDC 15

`endif