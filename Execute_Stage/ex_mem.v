`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: ex_mem
// Purpose: EX/MEM pipeline latch. Handoff tray between Execute and Memory.
//          On each rising clock edge it saves everything Execute produced.
//
// ctlwb = {RegWrite, MemToReg}            (2 bits, for Writeback)
// ctlm  = {Branch, MemRead, MemWrite}     (3 bits, for Memory)
//////////////////////////////////////////////////////////////////////////////////

module ex_mem(
    input wire clk,
    input wire [1:0]  ctlwb_in,     // WB control bits
    input wire [2:0]  ctlm_in,      // MEM control bits
    input wire [31:0] adder_in,     // branch target address
    input wire        zero_in,      // ALU zero flag (1 = result was 0)
    input wire [31:0] alu_in,       // ALU result
    input wire [31:0] rdata2_in,    // ReadData2 (the data for sw)
    input wire [4:0]  mux_in,       // destination register number

    output reg [1:0]  ctlwb_out,
    output reg [2:0]  ctlm_out,
    output reg [31:0] adder_out,
    output reg        zero_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] rdata2_out,
    output reg [4:0]  muxout_out
);

    // Copy every input to its output on the clock tick (same as your other latches)
    always @(posedge clk) begin
        ctlwb_out      <= ctlwb_in;
        ctlm_out       <= ctlm_in;
        adder_out      <= adder_in;
        zero_out       <= zero_in;
        alu_result_out <= alu_in;
        rdata2_out     <= rdata2_in;
        muxout_out     <= mux_in;
    end

endmodule