module pipeline (
	clk,
	arst_n,
	en_in,
	src_data_in,
	src_valid_in,
	dst_data_out,
	dst_valid_out
);
	parameter NUM_STAGES = 10;
	parameter BYPASS = 0;
	parameter DATA_WIDTH = 16;
	input wire clk;
	input wire arst_n;
	input wire en_in;
	input wire signed [DATA_WIDTH - 1:0] src_data_in;
	input wire src_valid_in;
	output wire signed [DATA_WIDTH - 1:0] dst_data_out;
	output wire dst_valid_out;
	reg [(DATA_WIDTH >= 0 ? (NUM_STAGES * (DATA_WIDTH + 1)) - 1 : (NUM_STAGES * (1 - DATA_WIDTH)) + (DATA_WIDTH - 1)):(DATA_WIDTH >= 0 ? 0 : DATA_WIDTH + 0)] buffer;

	generate
		if ((NUM_STAGES > 0) && (BYPASS != 1)) begin : genblk1
			always @(posedge clk or negedge arst_n)
				if (~arst_n)
					buffer <= 0;
				else if (en_in) begin
					begin : sv2v_autoblock_1
						reg signed [31:0] i;
						for (i = 0; i < NUM_STAGES; i = i + 1)
							buffer[(DATA_WIDTH >= 0 ? 0 : DATA_WIDTH) + ((i + 1) * (DATA_WIDTH >= 0 ? DATA_WIDTH + 1 : 1 - DATA_WIDTH))+:(DATA_WIDTH >= 0 ? DATA_WIDTH + 1 : 1 - DATA_WIDTH)] <= buffer[(DATA_WIDTH >= 0 ? 0 : DATA_WIDTH) + (i * (DATA_WIDTH >= 0 ? DATA_WIDTH + 1 : 1 - DATA_WIDTH))+:(DATA_WIDTH >= 0 ? DATA_WIDTH + 1 : 1 - DATA_WIDTH)];
					end
					buffer[(DATA_WIDTH >= 0 ? 0 : DATA_WIDTH) + 0+:(DATA_WIDTH >= 0 ? DATA_WIDTH + 1 : 1 - DATA_WIDTH)] <= {src_valid_in, src_data_in};
				end
			assign {dst_valid_out, dst_data_out} = buffer[(DATA_WIDTH >= 0 ? 0 : DATA_WIDTH) + ((NUM_STAGES - 1) * (DATA_WIDTH >= 0 ? DATA_WIDTH + 1 : 1 - DATA_WIDTH))+:(DATA_WIDTH >= 0 ? DATA_WIDTH + 1 : 1 - DATA_WIDTH)];
		end
		else if (((NUM_STAGES == 0) || (NUM_STAGES < 0)) || (BYPASS == 1)) begin : genblk1
			assign dst_data_out = src_data_in;
			assign dst_valid_out = src_valid_in;
		end
	endgenerate
endmodule
