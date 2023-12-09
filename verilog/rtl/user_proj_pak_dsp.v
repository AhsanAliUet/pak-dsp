// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_pak_dsp #(
    parameter BITS = 16
)(
`ifdef USE_POWER_PINS
    inout vdd,	// User area 1 1.8V supply
    inout vss,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [63:0] la_data_in,
    output [63:0] la_data_out,
    input  [63:0] la_oenb,

    // IOs
    input  [37:0] io_in,
    output [37:0] io_out,
    output [37:0] io_oeb,

    // IRQ
    output [2:0] irq
);

    wire [6:0]  addr;
    wire        write_en;
    wire [13:0] wdata;
    wire [13:0] rdata;
    wire [13:0] src_data_in;
    wire        src_valid_in;
    wire        src_ready_out;
    wire [13:0] dst_data_out;
    wire        dst_valid_out;
    wire        dst_ready_in;

    reg [5:0]   count_value;

    pak_dsp #(
        .DATA_WIDTH     ( 14            ),
        .COEFF_WIDTH    ( 16            ),
        .N              ( 8             )
    ) i_pak_dsp (
        .clk            ( wb_clk_i      ),
        .arst_n         ( wb_rst_i      ),
        .addr           ( wbs_adr_i[5:0]),
        .ack_out        ( wbs_ack_o     )
        .write_en       ( wbs_we_i      ),
        .wdata          ( wbs_dat_i[13:0]),
        .rdata          ( wbs_dat_o[13:0]),
        .src_data_in    ( src_data_in   ),
        .src_valid_in   ( src_valid_in  ),
        .src_ready_out  ( src_ready_out ),
        .dst_data_out   ( dst_data_out  ),
        .dst_valid_out  ( dst_valid_out ),
        .dst_ready_in   ( dst_ready_in  )
    );

    assign src_data_in   = io_in [13:0];
    assign io_oeb[13:0]  = 14'h3FFF;      // set direction to input
    assign src_valid_in  = io_in [14   ];
    assign io_oeb[14]    = 1'b1;          // set direction to input
    assign io_out[15]    = src_ready_out;
    assign io_oeb[15]    = 1'b0;          // set direction to output

    assign io_out[29:16] = dst_data_out;
    assign io_oeb[29:16] = 14'd0;         // set direction to output
    assign io_out[30]    = dst_valid_out;
    assign io_oeb[30]    = 1'b0;          // set direction to output
    assign dst_ready_in  = io_in[31];
    assign io_oeb[31]    = 1'b1;          // set direction to input

    assign io_out[37:32] = count_value;
    assign io_oeb[37:32] = 6'b0;

    assign irq = 3'b101;

    assign la_data_out = ~la_oenb ? {35'h7_FFFF_FFFF, display, anode, src_data_in} : 0;

    // free running counter
    always @ (posedge wb_clk_i,)
    begin
        if (~wb_rst_i)
        begin
            count_value <= 0;
        end
        else
        begin
            count_value <= count_value + 1;
        end
    end

    wire [7:0] anode;
    wire [6:0] display;

    ssd #(
        .DW     ( 32       ),
    ) i_ssd     (
        .clk    ( wb_clk_i ),
        .rst_i  ( wb_rst_i ),
        .data_i ( {10'b0, count_value, 2'b0, dst_data_out} ),
        .anode  ( anode    ), 
        .display( display  )
    );

endmodule

`default_nettype wire
