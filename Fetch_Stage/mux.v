`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: mux
// Purpose: 2-to-1 multiplexer (a switch that picks one of two 32-bit inputs)
//
// In the Fetch stage this decides what the NEXT PC will be:
//   sel = 1 -> branch was taken, use the branch target address (a_true)
//   sel = 0 -> normal operation, use PC + 4 (b_false)
//
// This is combinational logic: no clock, the output changes instantly
// whenever any input changes.
//////////////////////////////////////////////////////////////////////////////////

module mux(
    output wire [31:0] y,        // selected 32-bit output
    input  wire [31:0] a_true,   // chosen when sel = 1 (branch target)
    input  wire [31:0] b_false,  // chosen when sel = 0 (PC + 4)
    input  wire        sel       // 1-bit select signal
);

    assign y = sel ? a_true : b_false;

endmodule