// pak-dsp core

module pak_dsp #(
    parameter DATA_WIDTH  = 16,
    parameter COEFF_WIDTH = 16
)(
    input  logic                  clk,
    input  logic                  arst_n,

    // interpolator's src side ports
    input  logic [DATA_WIDTH-1:0] src_data_in_interp,
    input  logic                  src_valid_in_interp,
    output logic                  src_ready_out_interp,

    // decimator's src side ports
    input  logic [DATA_WIDTH-1:0] src_data_in_decim,
    input  logic                  src_valid_in_decim,
    output logic                  src_ready_out_decim,

    // fft's src side ports
    input  logic [DATA_WIDTH-1:0] src_data_in_fft,
    input  logic                  src_valid_in_fft,
    output logic                  src_ready_out_fft,

    // interpolator's dst side ports
    output logic [DATA_WIDTH-1:0] dst_data_out_interp,
    output logic                  dst_valid_out_interp,
    input  logic                  dst_ready_in_interp,

    // decimator's dst side ports
    output logic [DATA_WIDTH-1:0] dst_data_out_decim,
    output logic                  dst_valid_out_decim,
    input  logic                  dst_ready_in_decim,

    // fft's dst side ports
    output logic [DATA_WIDTH-1:0] dst_data_out_fft,
    output logic                  dst_valid_out_fft,
    input  logic                  dst_ready_in_fft
);

    duc #(
        .DATA_WIDTH    ( DATA_WIDTH           ),
        .COEFF_WIDTH   ( COEFF_WIDTH          ),
        .N_COEFFS_0    (                      ),
        .N_COEFFS_1    (                      )
    ) i_duc (
        .clk           ( clk                  ),
        .arst_n        ( arst_n               ),
        .bypass        ( /*from RIF*/         ),
        .coeffs        ( /*from RIF*/         ),
        .src_data_in   ( src_data_in_interp   ),
        .src_valid_in  ( src_valid_in_interp  ),
        .src_ready_out ( src_ready_out_interp ),
        .dst_data_out  ( dst_data_out_interp  ),
        .dst_valid_out ( dst_valid_out_interp ),
        .dst_ready_in  ( dst_ready_in_interp  )
    );

    ddc #(
        DATA_WIDTH     ( DATA_WIDTH          ),
        COEFF_WIDTH    ( COEFF_WIDTH         ),
        N_COEFFS_0     (                     ),
        N_COEFFS_1     (                     )
    ) i_ddc (
        .clk           ( clk                 ),
        .arst_n        ( arst_n              ),
        .bypass        ( /*from RIF*/        ),
        .coeffs        ( /*from RIF*/        ),
        .src_data_in   ( src_data_in_interp  ),
        .src_valid_in  ( src_valid_in_decim  ),
        .src_ready_out ( src_ready_out_decim ),
        .dst_data_out  ( dst_data_out_decim  ),
        .dst_valid_out ( dst_valid_out_decim ),
        .dst_ready_in  ( dst_ready_in_decim  )
    );

    fft_8p #(
        .DATA_WIDTH ( 16     ),
        .N          ( 8      )
    ) i_fft_8p (
        .clk        ( clk    ),
        .arst_n     ( arst_n ),
        .x_real     (        ),   // real part of input
        .x_imag     (        ),   // imag part of input
        .X_real     (        ),   // real part of output
        .X_imag     (        )    // imag part of output
    );

endmodule : pak_dsp