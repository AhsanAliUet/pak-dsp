module tb_fft_np (
	clk,
	arst_n
);
	input wire clk;
	input wire arst_n;
	function automatic signed [15:0] sv2v_cast_16_signed;
		input reg signed [15:0] inp;
		sv2v_cast_16_signed = inp;
	endfunction
	function signed [15:0] float2fix16;
		input real x;
		input reg signed [15:0] fw;
		float2fix16 = sv2v_cast_16_signed(x * (2 ** fw));
	endfunction
	localparam N = 4;
	localparam SAMPLE_WIDTH = 16;
	reg [63:0] data_in;
	wire [63:0] data_out;
	fft_np #(
		.N(N),
		.SAMPLE_WIDTH(SAMPLE_WIDTH)
	) i_fft_np(
		.clk(clk),
		.arst_n(arst_n),
		.data_in(data_in),
		.data_out(data_out)
	);
	task driver;
		reg signed [31:0] i;
		for (i = 0; i < N; i = i + 1)
			data_in[i * 16+:16] = float2fix16(i + 1, N);
	endtask
	function automatic signed [7:0] sv2v_cast_8_signed;
		input reg signed [7:0] inp;
		sv2v_cast_8_signed = inp;
	endfunction
	function signed [7:0] converters_pkg_float2fix8;
		input real x;
		input reg signed [15:0] fw;
		converters_pkg_float2fix8 = sv2v_cast_8_signed(x * (2 ** fw));
	endfunction
	task monitor;
		begin
			begin : sv2v_autoblock_1
				reg signed [31:0] i;
				for (i = 0; i < N; i = i + 1)
					$display("data_in[%0d] = %d %d j", i, $signed(data_in[(i * 16) + 7-:8]), $signed(data_in[(i * 16) + 15-:8]));
			end
			begin : sv2v_autoblock_2
				reg signed [31:0] i;
				for (i = 0; i < N; i = i + 1)
					$display("data_out[%0d] = %d %d j", i, $signed(data_out[(i * 16) + 7-:8]), $signed(data_out[(i * 16) + 15-:8]));
			end
			$display("\n\n");
			$display("Decimal: %0d, binary is %0b", converters_pkg_float2fix8(0.70710678, 7), converters_pkg_float2fix8(0.70710678, 7));
		end
	endtask
	initial begin
		@(posedge clk)
			;
		@(posedge clk)
			;
		repeat (N) begin
			fork
				driver;
				monitor;
			join
			@(posedge clk)
				;
		end
	end
	initial begin
		$dumpfile("tb_fft_4p.vcd");
		$dumpvars(0, tb_fft_4p);
	end
endmodule
