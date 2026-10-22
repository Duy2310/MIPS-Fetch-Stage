`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: control
// Purpose: Main control unit. Reads the 6-bit opcode (instr[31:26]) and
//          outputs the control signals each later stage needs.
//
// It's a lookup table: opcode in -> one row of the prof's control table out.
// Combinational (no clock): outputs update instantly when opcode changes.
// clk and rst are unused; they only exist because the skeleton has them.
//
// Bit packing (must match idExLatch and later stages):
//   ex  = {RegDst, ALUOp1, ALUOp0, ALUSrc}     (Execute)
//   mem = {Branch, MemRead, MemWrite}          (Memory)
//   wb  = {RegWrite, MemToReg}                 (Writeback)
//
// X (don't care) entries from the table are set to 0.
//
//  Instr     Opcode    RegDst ALUOp1 ALUOp0 ALUSrc | Branch MemRd MemWr | RegWr MemToReg
//  R-format  000000      1      1      0      0    |   0      0     0   |   1      0
//  LW        100011      0      0      0      1    |   0      1     0   |   1      1
//  SW        101011      X      0      0      1    |   0      0     1   |   0      X
//  BEQ       000100      X      0      1      0    |   1      0     0   |   0      X
//////////////////////////////////////////////////////////////////////////////////

module control(
    input  wire       clk,      // unused (required by skeleton)
    input  wire       rst,      // unused (required by skeleton)
    input  wire [5:0] opcode,   // instr[31:26]
    output reg  [1:0] wb,       // {RegWrite, MemToReg}
    output reg  [2:0] mem,      // {Branch, MemRead, MemWrite}
    output reg  [3:0] ex        // {RegDst, ALUOp1, ALUOp0, ALUSrc}
);

    // Opcode values for the 4 supported instructions
    localparam R_FORMAT = 6'b000000;
    localparam LW       = 6'b100011;
    localparam SW       = 6'b101011;
    localparam BEQ      = 6'b000100;

    // always @(*) = re-run whenever opcode changes (combinational)
    // 'case' works like a C switch statement
    always @(*) begin
        case (opcode)
            R_FORMAT: begin
                ex  = 4'b1100;   // RegDst=1, ALUOp=10, ALUSrc=0
                mem = 3'b000;    // no branch, no memory access
                wb  = 2'b10;     // RegWrite=1, MemToReg=0 (result from ALU)
            end

            LW: begin
                ex  = 4'b0001;   // RegDst=0 (dest is rt), ALUOp=00, ALUSrc=1
                mem = 3'b010;    // MemRead=1
                wb  = 2'b11;     // RegWrite=1, MemToReg=1 (result from memory)
            end

            SW: begin
                ex  = 4'b0001;   // RegDst=X->0, ALUOp=00, ALUSrc=1
                mem = 3'b001;    // MemWrite=1
                wb  = 2'b00;     // no register write, MemToReg=X->0
            end

            BEQ: begin
                ex  = 4'b0010;   // RegDst=X->0, ALUOp=01 (subtract to compare), ALUSrc=0
                mem = 3'b100;    // Branch=1
                wb  = 2'b00;     // no register write, MemToReg=X->0
            end

            default: begin       // unknown opcode: do nothing
                ex  = 4'b0000;
                mem = 3'b000;
                wb  = 2'b00;
            end
        endcase
    end

endmodule