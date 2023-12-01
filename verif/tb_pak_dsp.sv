

module tb_pak_dsp (
    input logic clk,
    input logic arst_n
);

    function shortint float2fix16(real x, shortint fw);
        return shortint'(x*(2**fw));
    endfunction

    localparam N = 4;
    localparam SAMPLE_WIDTH = 16;
    localparam DATA_WIDTH = 16;

    logic [N-1:0][SAMPLE_WIDTH-1:0] data_in;
    logic [N-1:0][SAMPLE_WIDTH-1:0] data_out;

    pak_dsp # (
        .DATA_WIDTH        ( DATA_WIDTH   ),
        .COEFF_WIDTH       ( SAMPLE_WIDTH ),
        .N                 ( N            )
    ) i_pak_dsp (
        .clk               ( clk          ),
        .arst_n            ( arst_n       ),
        
        // read write interface for memory
        .addr              (              ),
        .write_en          (              ),
        .wdata             (              ),
        .rdata             (              ),

        // src side ports
        .src_data_in       (              ),
        .src_valid_in      (              ),
        .src_ready_out     (              ),

        // dst side ports
        .dst_data_out      (              ),
        .dst_valid_out     (              ),
        .dst_ready_in      (              ),

        // fft's src side ports
        .src_data_in_fft   (              ),
        .src_valid_in_fft  (              ),
        .src_ready_out_fft (              ),

        // fft's dst side ports
        .dst_data_out_fft  (              ),
        .dst_valid_out_fft (              ),
        .dst_ready_in_fft  (              )
    );

    initial
    begin
        repeat(N)
        begin
            fork
                // driver();
                // monitor();
            join
            @(posedge clk);
        end
    end

    task driver();
    endtask

    task monitor();
    endtask

    initial
    begin
        repeat(200) @(posedge clk);
        // $finish;
    end

    initial
    begin
        $dumpfile("tb_pak_dsp.vcd");
        $dumpvars;
    end

endmodule