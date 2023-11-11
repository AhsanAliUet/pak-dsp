module twiddle
# (
    parameter PHASE_WIDTH = 2,
    parameter  DATA_WIDTH = 16
) (
    input  logic [PHASE_WIDTH-1:0] ph,
    output logic [ DATA_WIDTH-1:0] re,
    output logic [ DATA_WIDTH-1:0] im
);

    always_comb
    begin
        case(ph)
            2'b00:
            begin
                re = 16'd1;
                im = 16'd0;
            end
            2'b01:
            begin
                re =  16'd0;
                im = -16'd1;
            end
            2'b10:
            begin
                re = -16'd1;
                im =  16'd0;
            end
            2'b11:
            begin
                re = 16'd0;
                im = 16'd1;
            end
            default: begin end
        endcase
    end

endmodule
