`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: execute
// Purpose: Top-level Execute (EX) stage. Wires together:
//          adder, bottom_mux, alu_control, top_mux, alu, ex_mem.
//
// What happens each cycle:
//   1. adder:       branch target = NPC + SignExtend
//   2. top_mux:     ALU's 2nd input = ReadData2 (ALUSrc=0) or SignExtend (ALUSrc=1)
//   3. alu_control: ALUOp + funct -> 3-bit ALU operation
//   4. alu:         does the math, sets zero if the result is 0
//   5. bottom_mux:  destination register = rt (RegDst=0) or rd (RegDst=1)
//   6. ex_mem:      on the clock tick, saves everything for the Memory stage
//////////////////////////////////////////////////////////////////////////////////

module execute(
    input wire clk,
    input wire [1:0]  ctlwb_in,     // {RegWrite, MemToReg}, passed through
    input wire [2:0]  ctlm_in,      // {Branch, MemRead, MemWrite}, passed through
    input wire [31:0] npc,          // PC + 4 from ID/EX
    input wire [31:0] rdata1,       // value of rs
    input wire [31:0] rdata2,       // value of rt
    input wire [31:0] s_extend,     // sign-extended immediate
    input wire [4:0]  instr_2016,   // rt register number
    input wire [4:0]  instr_1511,   // rd register number
    input wire [1:0]  alu_op,       // from control: 00 add, 01 sub, 10 use funct
    input wire [5:0]  funct,        // instr[5:0] (same bits as s_extend[5:0])
    input wire        alusrc,       // 0 = register, 1 = constant
    input wire        regdst,       // 0 = rt, 1 = rd

    output wire [1:0]  ctlwb_out,
    output wire [2:0]  ctlm_out,
    output wire [31:0] adder_out,       // branch target (Add_Result)
    output wire        zero_out,        // ALU zero flag
    output wire [31:0] alu_result_out,  // ALU result
    output wire [31:0] rdata2_out,      // ReadData2 passed through (for sw)
    output wire [4:0]  muxout_out       // destination register (FiveBitMuxout)
);

    // Internal wires (block outputs before the latch)
    wire [31:0] branch_address;
    wire [31:0] alu_input_b;
    wire [31:0] alu_result;
    wire [4:0]  destination_register;
    wire [2:0]  alu_control_signal;
    wire        alu_zero;

    // Branch target: NPC + offset
    adder adder3 (
        .add_in1(npc),
        .add_in2(s_extend),
        .add_out(branch_address)
    );

    // RegDst mux: pick destination register
    bottom_mux bottom_mux3 (
        .a(instr_1511),   // sel = 1 -> rd (R-format)
        .b(instr_2016),   // sel = 0 -> rt (lw)
        .sel(regdst),
        .y(destination_register)
    );

    // ALU control: which operation?
    alu_control alu_control3 (
        .funct(funct),
        .aluop(alu_op),
        .select(alu_control_signal)
    );

    // ALUSrc mux: ALU's second input
    top_mux top_mux3 (
        .a(s_extend),     // alusrc = 1 -> constant (lw, sw)
        .b(rdata2),       // alusrc = 0 -> register (R-format, beq)
        .alusrc(alusrc),
        .y(alu_input_b)
    );

    // The ALU
    alu alu3 (
        .a(rdata1),
        .b(alu_input_b),
        .control(alu_control_signal),
        .result(alu_result),
        .zero(alu_zero)
    );

    // EX/MEM latch
    ex_mem ex_mem3 (
        .clk(clk),
        .ctlwb_in(ctlwb_in),
        .ctlm_in(ctlm_in),
        .adder_in(branch_address),
        .zero_in(alu_zero),
        .alu_in(alu_result),
        .rdata2_in(rdata2),
        .mux_in(destination_register),

        .ctlwb_out(ctlwb_out),
        .ctlm_out(ctlm_out),
        .adder_out(adder_out),
        .zero_out(zero_out),
        .alu_result_out(alu_result_out),
        .rdata2_out(rdata2_out),
        .muxout_out(muxout_out)
    );

endmodule