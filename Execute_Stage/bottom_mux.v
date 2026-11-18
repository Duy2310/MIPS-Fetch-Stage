`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: bottom_mux   (the RegDst mux)
// Purpose: Picks which register the result will be SAVED into.
//
//   regdst = 0 -> Instr[20:16]  (rt)   used by: lw    (lw $5, 8($4) -> $5)
//   regdst = 1 -> Instr[15:11]  (rd)   used by: R-format (add $3,$1,$2 -> $3)
//
// Why: different instruction formats put the destination in different
// fields. Decode passed BOTH along; this is where we finally choose.
//
// 5 bits wide because register numbers are 0 to 31.
// Output goes through EX/MEM as FiveBitMuxout, then to Writeback.
//////////////////////////////////////////////////////////////////////////////////

module bottom_mux(
    input  wire [4:0] a,     // rd, Instr[15:11]  (chosen when sel = 1)
    input  wire [4:0] b,     // rt, Instr[20:16]  (chosen when sel = 0)
    input  wire       sel,   // RegDst bit from control
    output wire [4:0] y      // destination register number
);

    assign y = sel ? a : b;

endmodule