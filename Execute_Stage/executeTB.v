`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: executeTB
// Purpose: Testbench for the Execute stage (based on the provided testbench).
//
// Clock: 10 ns period, rising edges at 5, 15, 25, 35...
//
// Expected EX/MEM outputs:
//  Test               Latched at  alu_result       zero  adder_out  muxout
//  1. add w/ ALUSrc=1   5 ns       10 + 4 = 14 (0E)  0     104 (68)   10 (0A)
//  2. beq, not equal    15, 25 ns  10 - 20 = -10     0     108 (6C)   5
//                                  (FFFFFFF6)
//  3. beq, equal        35 ns      10 - 10 = 0       1     108 (6C)   5
//
// Inputs change at 0, 12, 27 ns (between clock edges) to avoid races.
//////////////////////////////////////////////////////////////////////////////////

module executeTB;

    reg clk;

    reg [1:0]  ctlwb_in;
    reg [2:0]  ctlm_in;
    reg [31:0] npc;
    reg [31:0] rdata1;
    reg [31:0] rdata2;
    reg [31:0] s_extend;
    reg [4:0]  instr_2016;
    reg [4:0]  instr_1511;
    reg [1:0]  alu_op;
    reg [5:0]  funct;
    reg        alusrc;
    reg        regdst;

    wire [1:0]  ctlwb_out;
    wire [2:0]  ctlm_out;
    wire [31:0] adder_out;
    wire        zero_out;
    wire [31:0] alu_result_out;
    wire [31:0] rdata2_out;
    wire [4:0]  muxout_out;

    execute uut (
        .clk(clk),
        .ctlwb_in(ctlwb_in),
        .ctlm_in(ctlm_in),
        .npc(npc),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .s_extend(s_extend),
        .instr_2016(instr_2016),
        .instr_1511(instr_1511),
        .alu_op(alu_op),
        .funct(funct),
        .alusrc(alusrc),
        .regdst(regdst),
        .ctlwb_out(ctlwb_out),
        .ctlm_out(ctlm_out),
        .adder_out(adder_out),
        .zero_out(zero_out),
        .alu_result_out(alu_result_out),
        .rdata2_out(rdata2_out),
        .muxout_out(muxout_out)
    );

    // Clock: 10 ns period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Test 1 (t = 0): R-type add, but with ALUSrc = 1 (from provided TB)
        //   ALU = rdata1 + s_extend = 10 + 4 = 14
        ctlwb_in   = 2'b10;      // RegWrite = 1
        ctlm_in    = 3'b000;     // no branch, no memory
        npc        = 32'd100;
        rdata1     = 32'd10;
        rdata2     = 32'd20;
        s_extend   = 32'd4;
        instr_2016 = 5'd5;
        instr_1511 = 5'd10;
        alu_op     = 2'b10;      // R-type: look at funct
        funct      = 6'b100000;  // add
        alusrc     = 1'b1;
        regdst     = 1'b1;       // destination = rd = 10

        // Test 2 (t = 12): beq, values NOT equal
        //   ALU = 10 - 20 = -10, zero = 0
        //   (changed at 12, BETWEEN clock edges, to avoid a race at 15)
        #12;
        ctlwb_in   = 2'b00;      // beq doesn't write a register
        ctlm_in    = 3'b100;     // Branch = 1
        alusrc     = 1'b0;       // compare two registers
        regdst     = 1'b0;
        s_extend   = 32'd8;      // branch offset
        alu_op     = 2'b01;      // subtract
        funct      = 6'b100010;  // ignored when ALUOp = 01

        // Test 3 (t = 27): beq, values EQUAL
        //   ALU = 10 - 10 = 0, zero = 1 -> branch would be taken
        #15;
        rdata2     = 32'd10;

        #15;
        $finish;
    end

endmodule