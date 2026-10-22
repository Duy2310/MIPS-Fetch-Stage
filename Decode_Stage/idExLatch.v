`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: idExLatch
// Purpose: ID/EX pipeline register. The handoff tray between Decode and
//          Execute. Same idea as ifIdLatch, just holding more stuff.
//
// On every rising clock edge it captures everything Decode produced and
// holds it steady for Execute during the next cycle.
//
// Control bit order (set in control.v):
//   ctl_wb  = {RegWrite, MemToReg}
//   ctl_mem = {Branch, MemRead, MemWrite}
//   ctl_ex  = {RegDst, ALUOp1, ALUOp0, ALUSrc}
//////////////////////////////////////////////////////////////////////////////////

module idExLatch(
    input  wire        clk,
    input  wire        rst,

    // ---------- inputs (from Decode) ----------
    input  wire [1:0]  ctl_wb,             // Writeback control bits
    input  wire [2:0]  ctl_mem,            // Memory control bits
    input  wire [3:0]  ctl_ex,             // Execute control bits
    input  wire [31:0] npc,                // PC + 4, passed through from IF/ID
    input  wire [31:0] readdat1,           // value of register rs
    input  wire [31:0] readdat2,           // value of register rt
    input  wire [31:0] sign_ext,           // sign-extended immediate
    input  wire [4:0]  instr_bits_20_16,   // rt (destination for lw)
    input  wire [4:0]  instr_bits_15_11,   // rd (destination for R-type)

    // ---------- outputs (to Execute) ----------
    output reg  [1:0]  wb_out,
    output reg  [2:0]  mem_out,
    output reg  [3:0]  ctl_out,            // EX control bits (prof's name)
    output reg  [31:0] npc_out,
    output reg  [31:0] readdat1_out,
    output reg  [31:0] readdat2_out,
    output reg  [31:0] sign_ext_out,
    output reg  [4:0]  instr_bits_20_16_out,
    output reg  [4:0]  instr_bits_15_11_out
);

    // Same pattern as pc.v and ifIdLatch.v:
    // reset clears everything, otherwise copy input -> output on the clock tick
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wb_out               <= 2'b0;
            mem_out              <= 3'b0;
            ctl_out              <= 4'b0;
            npc_out              <= 32'b0;
            readdat1_out         <= 32'b0;
            readdat2_out         <= 32'b0;
            sign_ext_out         <= 32'b0;
            instr_bits_20_16_out <= 5'b0;
            instr_bits_15_11_out <= 5'b0;
        end
        else begin
            wb_out               <= ctl_wb;
            mem_out              <= ctl_mem;
            ctl_out              <= ctl_ex;
            npc_out              <= npc;
            readdat1_out         <= readdat1;
            readdat2_out         <= readdat2;
            sign_ext_out         <= sign_ext;
            instr_bits_20_16_out <= instr_bits_20_16;
            instr_bits_15_11_out <= instr_bits_15_11;
        end
    end

endmodule