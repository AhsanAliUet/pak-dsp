import converters_pkg::*;

module tb_fft_np (
    input  logic clk,
    input  logic arst_n
);

    function shortint float2fix16(real x, shortint fw);
        return shortint'(x*(2**fw));
    endfunction

    localparam N = 4;
    localparam SAMPLE_WIDTH = 16;

    logic [N-1:0][SAMPLE_WIDTH-1:0] data_in;
    logic [N-1:0][SAMPLE_WIDTH-1:0] data_out;
    
    fft_np # (
        .N            ( N            ),
        .SAMPLE_WIDTH ( SAMPLE_WIDTH )
    ) i_fft_np (
        .clk          ( clk          ),
        .arst_n       ( arst_n       ),
        .data_in      ( data_in      ),
        .data_out     ( data_out     )
    );

    initial
    begin
        @(posedge clk);
        @(posedge clk);
        repeat(N)
        begin
            fork
                driver();
                monitor();
            join
            @(posedge clk);
        end
    end

    task driver();
        for (int i = 0; i < N; i++)
        begin
            data_in[i] = float2fix16(i+1, N);
        end
    endtask

    task monitor();
        for (int i = 0; i < N; i++)
        begin
            $display("data_in[%0d] = %d %d j", i, $signed(data_in[i][7:0]), $signed(data_in[i][15:8]));
        end
        for (int i = 0; i < N; i++)
        begin
            $display("data_out[%0d] = %d %d j", i, $signed(data_out[i][7:0]), $signed(data_out[i][15:8]));
        end
        $display("\n\n");
        $display("Decimal: %0d, binary is %0b", float2fix8(0.70710678, 7), float2fix8(0.70710678, 7));
    endtask

    initial
    begin
        $dumpfile("tb_fft_4p.vcd");
        $dumpvars(0, tb_fft_4p);
    end

endmodule