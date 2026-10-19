`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: incrementer
// Purpose: Computes PC + 4, the address of the next sequential instruction.
//
// Why 4? Each MIPS instruction is 32 bits = 4 bytes, and addresses count
// bytes. So instructions live at 0, 4, 8, 12, ...
//
// This is combinational (just an adder), so the output updates instantly.
// clk and rst are not used here; they only exist because the provided
// skeleton for the fetch module connects them.
//////////////////////////////////////////////////////////////////////////////////

module incrementer(
    input  wire        clk,     // unused (required by skeleton)
    input  wire        rst,     // unused (required by skeleton)
    input  wire [31:0] pcin,    // current PC
    output wire [31:0] pcout    // PC + 4
);

    // 32'd4 means "the number 4, written as a 32-bit decimal value"
    assign pcout = pcin + 32'd4;

endmodule