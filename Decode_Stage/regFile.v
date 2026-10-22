`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: regfile
// Purpose: The 32 general-purpose MIPS registers ($0 - $31), each 32 bits.
//
// Think of it as a shelf of 32 cups:
//   READ  (always on, instant):  rs, rt  -> A_readdat1, B_readdat2
//   WRITE (on the clock tick):   if regwrite == 1, put writedata into reg[rd]
//
// Port note: 'rd' here means "which register to WRITE". In decode.v it gets
// wired to the Writeback stage's register number, NOT instr[15:11].
//
// $0 is hardwired to 0 in MIPS, so writes to register 0 are ignored.
//
// For easy testing, each register starts holding its own number
// ($1 = 1, $2 = 2, ...) so reads show real values in the waveform.
//////////////////////////////////////////////////////////////////////////////////

module regfile(
    input  wire        clk,
    input  wire        rst,         // reset: reload the starting values
    input  wire        regwrite,    // 1 = write writedata into reg[rd]
    input  wire [4:0]  rs,          // read register 1 number (instr[25:21])
    input  wire [4:0]  rt,          // read register 2 number (instr[20:16])
    input  wire [4:0]  rd,          // register number to write (from WB)
    input  wire [31:0] writedata,   // value to write (from WB)
    output wire [31:0] A_readdat1,  // value in reg[rs]
    output wire [31:0] B_readdat2   // value in reg[rt]
);

    // 32 registers, each 32 bits wide (same array syntax as instrMem)
    reg [31:0] registers [0:31];

    integer i;   // loop counter

    // Starting values at time 0: $0 = 0, $1 = 1, $2 = 2, ...
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = i;
    end

    // ---------- WRITE: clocked, like pc.v ----------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= i;               // reset to starting values
        end
        else if (regwrite && rd != 5'd0) begin
            registers[rd] <= writedata;          // write, but never to $0
        end
    end

    // ---------- READ: combinational, like instrMem ----------
    // Always on: outputs follow rs/rt instantly, no clock needed
    assign A_readdat1 = registers[rs];
    assign B_readdat2 = registers[rt];

endmodule