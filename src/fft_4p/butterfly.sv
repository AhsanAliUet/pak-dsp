module butterfly 
# (
    parameter DATAWIDTH = 32
) (
    input  logic [DATAWIDTH-1:0] data_1_in,
    input  logic [DATAWIDTH-1:0] data_2_in,
    output logic [DATAWIDTH-1:0] data_1_out,
    output logic [DATAWIDTH-1:0] data_2_out
);

    logic [(DATAWIDTH/2)-1:0] data_1_in_real;
    logic [(DATAWIDTH/2)-1:0] data_2_in_real;
    logic [(DATAWIDTH/2)-1:0] data_1_in_imag;
    logic [(DATAWIDTH/2)-1:0] data_2_in_imag;
    
    logic [(DATAWIDTH/2)-1:0] data_1_out_real;
    logic [(DATAWIDTH/2)-1:0] data_2_out_real;
    logic [(DATAWIDTH/2)-1:0] data_1_out_imag;
    logic [(DATAWIDTH/2)-1:0] data_2_out_imag;

    always_comb
    begin
        data_1_in_real = data_1_in[            0+:(DATAWIDTH/2)];
        data_2_in_real = data_2_in[            0+:(DATAWIDTH/2)];
        data_1_in_imag = data_1_in[(DATAWIDTH/2)+:(DATAWIDTH/2)];
        data_2_in_imag = data_2_in[(DATAWIDTH/2)+:(DATAWIDTH/2)];
    end

    always_comb 
    begin
        data_1_out_real = data_1_in_real + data_2_in_real;
        data_2_out_real = data_1_in_real - data_2_in_real;
        data_1_out_imag = data_1_in_imag + data_2_in_imag;
        data_2_out_imag = data_1_in_imag - data_2_in_imag;
    end

    assign data_1_out = {data_1_out_imag, data_1_out_real};
    assign data_2_out = {data_2_out_imag, data_2_out_real};
    
endmodule