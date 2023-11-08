
module interpolator_ctrl(
    input  logic clk,
    input  logic arst_n,
    input  logic src_valid_in,
    output logic src_ready_out,
    output logic dst_valid_out,
    input  logic dst_ready_in,
    output logic en_out,
    output logic dm_out
);

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        TX_0 = 2'b01,
        TX_1 = 2'b10
    } state_t;

    state_t  current_state;
    state_t  next_state;

    always_comb
    begin
        next_state    = current_state;
        dm_out        = 1'b0;
        en_out        = 1'b0;
        dst_valid_out = 1'b0;
        src_ready_out = 1'b0;

        case(current_state)
            IDLE:
            begin
                dst_valid_out = 1'b1;
                if(src_valid_in & !dst_ready_in)
                begin
                    next_state = TX_0;
                end
                else if (src_valid_in & dst_ready_in)
                begin
                    next_state = TX_1;
                end
            end
            TX_0:
            begin
                dst_valid_out = 1'b1;
                if(dst_ready_in)
                begin
                    next_state = TX_1;
                end
            end
            TX_1:
            begin
                dst_valid_out = 1'b1;
                dm_out        = 1'b1;
                if(dst_ready_in)
                begin
                    en_out        = 1'b1;
                    src_ready_out = 1'b1;
                    next_state    = IDLE;
                end
            end
            default:
            begin
            end
        endcase
    end

    always_ff @ (posedge clk, negedge arst_n)
    begin
        if(~arst_n)
        begin
            current_state <= IDLE;
        end
        else
        begin
            current_state <= next_state;
        end
    end

endmodule: interpolator_ctrl