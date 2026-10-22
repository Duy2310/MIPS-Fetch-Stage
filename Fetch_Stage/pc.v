`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: pc
// Purpose: Program Counter register. Holds the address of the instruction
//          currently being fetched.
//
// Think of it as a bookmark: on every rising clock edge it moves to the new
// address given at pc_in. Between clock edges it holds its value steady.
//
// This is sequential logic (it has memory), so it uses always @(posedge clk).
//////////////////////////////////////////////////////////////////////////////////

module pc(
    input  wire        clk,     // system clock
    input  wire        rst,     // reset: forces PC back to address 0
    input  wire [31:0] pc_in,   // next address (comes from the mux)
    output reg  [31:0] pc_out   // current address (goes to memory + incrementer)
);
    // pc_out is declared 'reg' because it is assigned inside an always block
    // and must HOLD its value between clock edges.

    // Runs on every rising clock edge OR the moment reset goes high
    // (this is called an asynchronous reset: it doesn't wait for the clock).
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc_out <= 32'd0;    // reset: start fetching from address 0
        else
            pc_out <= pc_in;    // normal: load the next address
        // '<=' is a non-blocking assignment, the standard for clocked logic.
        // All '<=' updates happen together at the clock edge.
    end

endmodule