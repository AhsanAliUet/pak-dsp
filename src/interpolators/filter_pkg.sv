
package filter_pkg;
    parameter DATA_WIDTH = 16;
    parameter NUM_COEFFS = 40;
    parameter COEFF_WIDTH = 16;

    parameter COEFF_0_ODD = 0;
    parameter COEFF_1_ODD = 0;

    parameter NUM_COEFF_0 = 20;
    parameter NUM_COEFF_1 = 20;

    typedef struct packed {
        logic [NUM_COEFFS-1:0][COEFF_WIDTH-1:0] coeff;
    } coeff_s;
endpackage