

module tb_pak_dsp (
    input logic clk,
    input logic arst_n
);

    function shortint float2fix16(real x, shortint fw);
        return shortint'(x*(2**fw));
    endfunction

    localparam N = 8;
    localparam SAMPLE_WIDTH = 16;
    localparam DATA_WIDTH = 16;

    logic [N-1:0][SAMPLE_WIDTH-1:0] data_in;
    logic [N-1:0][SAMPLE_WIDTH-1:0] data_out;

    logic [5:0] addr;
    logic write_en;
    logic [15:0] wdata;
    logic [15:0] rdata;

    pak_dsp # (
        .DATA_WIDTH        ( DATA_WIDTH   ),
        .COEFF_WIDTH       ( SAMPLE_WIDTH ),
        .N                 ( N            )
    ) i_pak_dsp (
        .clk               ( clk          ),
        .arst_n            ( arst_n       ),
        
        // read write interface for memory
        .addr              ( addr         ),
        .write_en          ( write_en     ),
        .wdata             ( wdata        ),
        .rdata             ( rdata        ),

        // src side ports
        .src_data_in       (              ),
        .src_valid_in      (              ),
        .src_ready_out     (              ),

        // dst side ports
        .dst_data_out      (              ),
        .dst_valid_out     (              ),
        .dst_ready_in      (              )
    );

    initial
    begin
        repeat(N)
        begin
            fork
                driver();
                // monitor();
            join
            @(posedge clk);
        end
    end

    task driver();
        write_en = 1;
        wdata = 1;
        for (int i = 31; i < 47; i++)
        begin
            addr = i;
            @(posedge clk);
        end
        @(posedge clk);
        addr = 0;
        wdata = 1<<6;
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