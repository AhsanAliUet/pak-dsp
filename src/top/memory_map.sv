// memory mapping module for Pak-DSP

module memory_map #(
    parameter  DATA_WIDTH      = 16,
    parameter  NUM_GPR_REGS    = 1,  // contains bypass, enables/starting signals
    parameter  NUM_COEFFS_REGS = 30, // number of co-efficient registers for conditioning FIR filter
    localparam TOTAL_REGS = NUM_GPR_REGS + NUM_COEFFS_REGS
)(
    input  logic                                              clk,
    input  logic                                              arst_n,

    // write and read interface of memory map
    input  logic                     [$clog2(TOTAL_REGS)-1:0] addr,
    input  logic                                              write_en,
    input  logic signed                      [DATA_WIDTH-1:0] wdata,
    output logic signed                      [DATA_WIDTH-1:0] rdata,

    // status register (say)
    output logic signed [   NUM_GPR_REGS-1:0][DATA_WIDTH-1:0] gpr,
    output logic signed [NUM_COEFFS_REGS-1:0][DATA_WIDTH-1:0] coeffs    // for FIR filter
);



    logic [DATA_WIDTH-1:0] Regs [TOTAL_REGS];

    // gprs read port
    always_ff @ (posedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            for (int j = 0; j < NUM_GPR_REGS; j++)
            begin
                gpr <= '0;
            end
        end
        else
        begin
            for (int j = 0; j < NUM_GPR_REGS; j++)
            begin
                gpr[j] <= Regs[j];
            end
        end
    end

    // coeffs read port
    always_ff @ (posedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            for (int i = 0; i < NUM_COEFFS_REGS; i++)
            begin
                coeffs[i] <= '0;
            end
        end
        else
        begin
            for (int i = 0; i < NUM_COEFFS_REGS; i++)
            begin
                coeffs[i] <= Regs[NUM_GPR_REGS+i];
            end
        end
    end

    // read from the registers
    assign rdata = ~(write_en) ? Regs[addr] : '0;

    // write at all registers
    always_ff @ (posedge clk, negedge arst_n)
    begin
        if (~arst_n)
        begin
            Regs <= '{default :'0};
        end
        else if (write_en)
        begin
            Regs[addr] <= wdata;
        end
    end

endmodule : memory_map