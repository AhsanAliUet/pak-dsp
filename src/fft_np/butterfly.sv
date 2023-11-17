// 2-input butterfly module

module butterfly
    import sat_pkg::sym_sat_9_8;
# (
    parameter DATAWIDTH = 16
) (
    input  logic signed [DATAWIDTH-1:0] data_1_in_real,
    input  logic signed [DATAWIDTH-1:0] data_1_in_imag,

    input  logic signed [DATAWIDTH-1:0] data_2_in_real,
    input  logic signed [DATAWIDTH-1:0] data_2_in_imag,
    
    output logic signed [DATAWIDTH-1:0] data_1_out_real,
    output logic signed [DATAWIDTH-1:0] data_1_out_imag,

    output logic signed [DATAWIDTH-1:0] data_2_out_real,
    output logic signed [DATAWIDTH-1:0] data_2_out_imag
);

    logic signed [(DATAWIDTH+1)-1:0] data_1_real_fp;
    logic signed [(DATAWIDTH+1)-1:0] data_1_imag_fp;
    logic signed [(DATAWIDTH+1)-1:0] data_2_real_fp;
    logic signed [(DATAWIDTH+1)-1:0] data_2_imag_fp;

    always_comb 
    begin
        data_1_real_fp = data_1_in_real + data_2_in_real;
        data_1_imag_fp = data_1_in_imag + data_2_in_imag;
        
        data_2_real_fp = data_1_in_real - data_2_in_real;
        data_2_imag_fp = data_1_in_imag - data_2_in_imag;
    end

    assign data_1_out_real = sym_sat_9_8(data_1_real_fp);
    assign data_1_out_imag = sym_sat_9_8(data_1_imag_fp);

    assign data_2_out_real = sym_sat_9_8(data_2_real_fp);
    assign data_2_out_imag = sym_sat_9_8(data_2_imag_fp);
    
endmodule : butterfly
