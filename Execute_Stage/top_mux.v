`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: top_mux   (the ALUSrc mux)
// Purpose: Picks the ALU's SECOND input.
//
//   alusrc = 0 -> ReadData2   (a register)   used by: R-format (add), beq
//   alusrc = 1 -> SignExtend  (a constant)   used by: lw, sw
//
// Why: add does $1 + $2 (two registers), but lw does $4 + 8 (register +
// constant). This mux lets the same ALU handle both.
//
// 32-bit 2-to-1 mux, same as the one in Fetch.
//////////////////////////////////////////////////////////////////////////////////

module top_mux(
    input  wire [31:0] a,        // SignExtend  (chosen when alusrc = 1)
    input  wire [31:0] b,        // ReadData2   (chosen when alusrc = 0)
    input  wire        alusrc,   // select bit from control
    output wire [31:0] y         // goes to ALU input b
);

    // "if alusrc is 1, pick a (constant), else pick b (register)"
    assign y = alusrc ? a : b;

endmodule