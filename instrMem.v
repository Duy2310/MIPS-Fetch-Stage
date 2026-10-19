`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: instrMem
// Purpose: Instruction memory. Give it an address, it returns the 32-bit
//          instruction stored there.
//
// Width: each slot is 32 bits, declared [31:0] so bit 31 (leftmost) is the
// most significant bit (big-endian ordering, per the assignment).
//
// Depth: the spec calls for 2^32 slots, i.e. reg [31:0] memory [0:2**32-1].
// That is 2^32 x 4 bytes = 16 GB, which the simulator cannot allocate, so we
// size it down to 40 slots (enough to cover addresses 0 through 39).
//
// Addressing: per the assignment, the 10 dummy instructions are placed at
// addresses 0, 4, 8, ..., 36, and the PC value is used directly as the index.
// The PC increments by 4, so it lands exactly on these slots.
//
// Read is combinational: data updates as soon as addr changes.
//////////////////////////////////////////////////////////////////////////////////

module instrMem(
    input  wire        clk,     // unused (required by skeleton)
    input  wire        rst,     // when high, output 0
    input  wire [31:0] addr,    // address from the PC
    output reg  [31:0] data     // instruction at that address
);

    // Memory array: 40 slots (index 0 to 39), each 32 bits wide.
    // Syntax: reg [width] name [depth];
    // Full spec would be: reg [31:0] memory [0:2**32-1];
    reg [31:0] memory [0:39];

    integer i;   // loop counter for initialization

    // 'initial' runs once at the start of simulation to preload memory.
    initial begin
        // Clear every slot first so unused addresses read as 0, not X (unknown)
        for (i = 0; i < 40; i = i + 1)
            memory[i] = 32'h00000000;

        // First 10 instructions at addresses 0, 4, 8, ... (32'h = 32-bit hex)
        memory[0]  = 32'hA00000AA;
        memory[4]  = 32'h10000011;
        memory[8]  = 32'h20000022;
        memory[12] = 32'h30000033;
        memory[16] = 32'h40000044;
        memory[20] = 32'h50000055;
        memory[24] = 32'h60000066;
        memory[28] = 32'h70000077;
        memory[32] = 32'h80000088;
        memory[36] = 32'h90000099;
    end

    // always @(*) = combinational block: re-evaluates whenever addr or rst
    // changes. 'data' is 'reg' only because it's assigned inside an always
    // block, it is NOT a flip-flop here.
    always @(*) begin
        if (rst)
            data = 32'h00000000;        // reset: output nothing
        else if (addr <= 32'd39)
            data = memory[addr];        // valid address: read that slot
        else
            data = 32'h00000000;        // past the end of memory: return 0
        // '=' (blocking) is the standard for combinational always blocks.
    end

endmodule