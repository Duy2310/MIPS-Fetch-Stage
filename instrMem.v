`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: instrMem
// Purpose: Instruction memory. Give it an address, it returns the 32-bit
//          instruction stored there.
//
// Sizing note: the spec says 2^32 words, but that would be 16 GB and the
// simulator can't allocate it. We only use 10 instructions, so we size the
// memory to 10 words.
//
// Addressing: the PC is a BYTE address (0, 4, 8, ...) but each memory slot
// holds one 32-bit WORD. So we convert byte address -> word index by
// dividing by 4, which is the same as dropping the bottom 2 bits: addr[31:2].
//   byte 0x00 -> slot 0, byte 0x04 -> slot 1, ..., byte 0x20 -> slot 8
//
// Read is combinational: data updates as soon as addr changes.
//////////////////////////////////////////////////////////////////////////////////

module instrMem(
    input  wire        clk,     // unused (required by skeleton)
    input  wire        rst,     // when high, output 0
    input  wire [31:0] addr,    // byte address from the PC
    output reg  [31:0] data     // instruction at that address
);

    // Memory array: 10 slots (index 0 to 9), each 32 bits wide.
    // Syntax: reg [width] name [depth];
    reg [31:0] memory [0:9];

    // 'initial' runs once at the start of simulation. Used here to preload
    // the dummy instructions. 32'hXXXXXXXX means a 32-bit hex value.
    initial begin
        memory[0] = 32'hA00000AA;  // byte addr 0x00
        memory[1] = 32'h10000011;  // byte addr 0x04
        memory[2] = 32'h20000022;  // byte addr 0x08
        memory[3] = 32'h30000033;  // byte addr 0x0C
        memory[4] = 32'h40000044;  // byte addr 0x10
        memory[5] = 32'h50000055;  // byte addr 0x14
        memory[6] = 32'h60000066;  // byte addr 0x18
        memory[7] = 32'h70000077;  // byte addr 0x1C
        memory[8] = 32'h80000088;  // byte addr 0x20
        memory[9] = 32'h90000099;  // byte addr 0x24
    end

    // always @(*) = combinational block: re-evaluates whenever any input
    // it reads (rst, addr, memory) changes. 'data' is 'reg' only because
    // it's assigned inside an always block, it is NOT a flip-flop here.
    always @(*) begin
        if (rst)
            data = 32'h00000000;            // reset: output nothing
        else if (addr[31:2] <= 9)
            data = memory[addr[31:2]];      // valid address: read the slot
        else
            data = 32'h00000000;            // past the end: return 0
        // '=' (blocking) is the standard for combinational always blocks.
    end

endmodule