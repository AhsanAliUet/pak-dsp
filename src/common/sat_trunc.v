module sat_trunc (
	sig_i,
	sig_o
);
	parameter M_I = 1;
	parameter N_I = 24;
	parameter M_O = 1;
	parameter N_O = 20;
	input wire signed [(M_I + N_I) - 1:0] sig_i;
	output reg signed [(M_O + N_O) - 1:0] sig_o;
	localparam MSB_I = (M_I + N_I) - 1;
	localparam SAT_LO = {{M_O {1'b1}}, {N_O {1'b0}}};
	localparam SAT_HI = {{M_O {1'b0}}, {N_O {1'b1}}};
	always @(*)
		if ((sig_i[MSB_I:(MSB_I - M_I) + 1] == {(MSB_I >= ((MSB_I - M_I) + 1) ? (MSB_I - ((MSB_I - M_I) + 1)) + 1 : (((MSB_I - M_I) + 1) - MSB_I) + 1) * 1 {1'sb0}}) || (sig_i[MSB_I:(MSB_I - M_I) + 1] == {(MSB_I >= ((MSB_I - M_I) + 1) ? (MSB_I - ((MSB_I - M_I) + 1)) + 1 : (((MSB_I - M_I) + 1) - MSB_I) + 1) * 1 {1'sb1}}))
			sig_o = sig_i[(N_I + M_O) - 1:N_I - N_O];
		else if ((sig_i[MSB_I] == 1'b1) && (&sig_i[MSB_I - 1:(MSB_I - M_I) + 1] == 0))
			sig_o = SAT_LO;
		else
			sig_o = SAT_HI;
endmodule
