module interpolator_ctrl (
	clk,
	arst_n,
	src_valid_in,
	src_ready_out,
	dst_valid_out,
	dst_ready_in,
	en_out,
	dm_out
);
	input wire clk;
	input wire arst_n;
	input wire src_valid_in;
	output reg src_ready_out;
	output reg dst_valid_out;
	input wire dst_ready_in;
	output reg en_out;
	output reg dm_out;
	reg [1:0] current_state;
	reg [1:0] next_state;
	always @(*) begin
		next_state = current_state;
		dm_out = 1'b0;
		en_out = 1'b0;
		dst_valid_out = 1'b0;
		src_ready_out = 1'b0;
		case (current_state)
			2'b00: begin
				dst_valid_out = 1'b1;
				if (src_valid_in & !dst_ready_in)
					next_state = 2'b01;
				else if (src_valid_in & dst_ready_in)
					next_state = 2'b10;
			end
			2'b01: begin
				dst_valid_out = 1'b1;
				if (dst_ready_in)
					next_state = 2'b10;
			end
			2'b10: begin
				dst_valid_out = 1'b1;
				dm_out = 1'b1;
				if (dst_ready_in) begin
					en_out = 1'b1;
					src_ready_out = 1'b1;
					next_state = 2'b00;
				end
			end
			default:
				;
		endcase
	end
	always @(posedge clk or negedge arst_n)
		if (~arst_n)
			current_state <= 2'b00;
		else
			current_state <= next_state;
endmodule
