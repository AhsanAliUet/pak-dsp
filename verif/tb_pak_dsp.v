module tb_pak_dsp (
	clk,
	arst_n
);
	input wire clk;
	input wire arst_n;
	function automatic signed [15:0] sv2v_cast_16_signed;
		input reg signed [15:0] inp;
		sv2v_cast_16_signed = inp;
	endfunction

	localparam N = 8;
	localparam SAMPLE_WIDTH = 16;
	localparam DATA_WIDTH = 16;
	wire [127:0] data_in;
	wire [127:0] data_out;
	reg [5:0] addr;
	reg write_en;
	reg [15:0] wdata;
	wire [15:0] rdata;
	pak_dsp #(
		.DATA_WIDTH(DATA_WIDTH),
		.COEFF_WIDTH(SAMPLE_WIDTH),
		.N(N)
	) i_pak_dsp(
		.clk(clk),
		.arst_n(arst_n),
		.addr(addr),
		.write_en(write_en),
		.wdata(wdata),
		.rdata(rdata),
		.src_data_in(),
		.src_valid_in(),
		.src_ready_out(),
		.dst_data_out(),
		.dst_valid_out(),
		.dst_ready_in()
	);
	task driver;
		begin
			write_en = 1;
			wdata = 1;
			begin : sv2v_autoblock_1
				reg signed [31:0] i;
				for (i = 31; i < 47; i = i + 1)
					begin
						addr = i;
						@(posedge clk)
							;
					end
			end
			@(posedge clk)
				;
			addr = 0;
			wdata = 64;
		end
	endtask
	initial repeat (N) begin
		driver;
		@(posedge clk)
			;
	end
	task monitor;
		;
	endtask
	initial repeat (200) @(posedge clk)
		;
	initial begin
		$dumpfile("tb_pak_dsp.vcd");
		$dumpvars;
	end
endmodule
