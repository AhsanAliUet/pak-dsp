// saturation/truncation module

module sat_trunc # (
    parameter M_I  = 1,    //Qm.n where m = M_I for input  side
    parameter N_I  = 24,   //Qm.n where n = N_I for input  side
    parameter M_O  = 1,    //Qm.n where m = M_O for output side
    parameter N_O  = 20    //Qm.n where n = N_O for output side
) (
    input  logic signed [M_I+N_I-1:0] sig_i,
    output logic signed [M_O+N_O-1:0] sig_o
);



    localparam MSB_I  = M_I + N_I -1;
    localparam SAT_LO = {{M_O{(1'b1)}}, {N_O{(1'b0)}}}; //-1
    localparam SAT_HI = {{M_O{(1'b0)}}, {N_O{(1'b1)}}}; //0.99999...

    always_comb
    begin
      
        // the number is >=-1 and <1
        if      (sig_i[MSB_I:MSB_I-M_I+1] == '0 || sig_i[MSB_I:MSB_I-M_I+1] == '1)
        begin
            sig_o = sig_i[N_I+M_O-1: N_I-N_O];        //pick the central bits
        end

        // the number is less than -1 (underflow)
        else if ((sig_i[MSB_I] == 1'b1)  && (&sig_i[MSB_I-1:MSB_I-M_I+1] == 0))
        begin
            sig_o = SAT_LO;   
        end

        //the number is greater than 1 (overflow)
        else
        begin
            sig_o = SAT_HI;
        end

    end

endmodule: sat_trunc
