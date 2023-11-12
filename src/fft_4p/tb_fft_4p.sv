module tb_fft_4p ();

    localparam N = 4;
    localparam SAMPLE_WIDTH = 16;

    logic                           clk;
    logic                           rst_n;
    logic [N-1:0][SAMPLE_WIDTH-1:0] data_in;
    logic [N-1:0][SAMPLE_WIDTH-1:0] data_out;
    
    fft_4p # (
        .N            ( N            ),
        .SAMPLE_WIDTH ( SAMPLE_WIDTH )
    ) dut (
        .clk          ( clk          ),
        .rst_n        ( rst_n        ),
        .data_in      ( data_in      ),
        .data_out     ( data_out     )
    );

    initial 
    begin
        clk = 0;
        forever
        begin
            #5 clk = ~clk;
        end
    end

    initial
    begin
        rst_n = 0;
        #20;
        rst_n = 1;
        #20;

        data_in[0] = {8'd0, 8'd64};
        data_in[1] = {8'd0, 8'd83};
        data_in[2] = {8'd0, 8'd96};
        data_in[3] = {8'd0, 8'd42};

        #100;

        $display("data_out[0] = %d %d j", $signed(data_out[0][7:0]), $signed(data_out[0][15:8]));
        $display("data_out[1] = %d %d j", $signed(data_out[1][7:0]), $signed(data_out[1][15:8]));
        $display("data_out[2] = %d %d j", $signed(data_out[2][7:0]), $signed(data_out[2][15:8]));
        $display("data_out[3] = %d %d j", $signed(data_out[3][7:0]), $signed(data_out[3][15:8]));

        #100 ;
        $finish;
    end

    initial
    begin
        $dumpfile("tb_fft_4p.vcd");
        $dumpvars(0, tb_fft_4p);
    end

endmodule