`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: decode
// Purpose: Top-level Instruction Decode (ID) stage. Wires together:
//          signExtend, regfile, control, idExLatch.
//
// What happens each cycle:
//   1. The instruction from IF/ID is chopped into fields:
//        [31:26] opcode -> control
//        [25:21] rs     -> regfile read port 1
//        [20:16] rt     -> regfile read port 2 AND straight to the latch
//        [15:11] rd     -> straight to the latch
//        [15:0]  imm    -> sign extend
//   2. Control turns the opcode into WB / MEM / EX control bits
//   3. Regfile reads the values in rs and rt
//   4. Sign extend stretches the 16-bit immediate to 32 bits
//   5. On the clock tick, the ID/EX latch saves all of it for Execute
//
// The regfile's WRITE side (regwrite, rd, writedata) comes from the
// Writeback stage of an older instruction, not from this instruction.
//
// Note: the `include lines from the skeleton were removed. Vivado finds the
// modules automatically when all files are added to the project, and the
// includes would cause "module already defined" errors.
//////////////////////////////////////////////////////////////////////////////////

module decode(
    input  wire        clk,
    input  wire        rst,
    input  wire        wb_reg_write,            // from WB: write a register?
    input  wire [4:0]  wb_write_reg_location,   // from WB: which register
    input  wire [31:0] mem_wb_write_data,       // from WB: value to write
    input  wire [31:0] if_id_instr,             // from IF/ID: the instruction
    input  wire [31:0] if_id_npc,               // from IF/ID: PC + 4
    output wire [1:0]  id_ex_wb,                // to EX: {RegWrite, MemToReg}
    output wire [2:0]  id_ex_mem,               // to EX: {Branch, MemRead, MemWrite}
    output wire [3:0]  id_ex_execute,           // to EX: {RegDst, ALUOp1, ALUOp0, ALUSrc}
    output wire [31:0] id_ex_npc,               // to EX: PC + 4
    output wire [31:0] id_ex_readdat1,          // to EX: value of rs
    output wire [31:0] id_ex_readdat2,          // to EX: value of rt
    output wire [31:0] id_ex_sign_ext,          // to EX: sign-extended immediate
    output wire [4:0]  id_ex_instr_bits_20_16,  // to EX: rt number
    output wire [4:0]  id_ex_instr_bits_15_11   // to EX: rd number
);

    // Internal wires (outputs of the blocks, before the latch)
    wire [31:0] sign_ext_internal;
    wire [31:0] readdat1_internal;
    wire [31:0] readdat2_internal;
    wire [1:0]  wb_internal;
    wire [2:0]  mem_internal;
    wire [3:0]  ex_internal;

    // Sign extend: 16-bit immediate -> 32 bits
    signExtend sE0(
        .immediate(if_id_instr[15:0]),
        .extended(sign_ext_internal)
    );

    // Register file
    // READ side uses this instruction's rs/rt.
    // WRITE side uses the Writeback stage's inputs (rd here = WB's register #).
    regfile rf0(
        .clk(clk),
        .rst(rst),
        .regwrite(wb_reg_write),
        .rs(if_id_instr[25:21]),
        .rt(if_id_instr[20:16]),
        .rd(wb_write_reg_location),
        .writedata(mem_wb_write_data),
        .A_readdat1(readdat1_internal),
        .B_readdat2(readdat2_internal)
    );

    // Control: opcode -> control bits
    control c0(
        .clk(clk),
        .rst(rst),
        .opcode(if_id_instr[31:26]),
        .wb(wb_internal),
        .mem(mem_internal),
        .ex(ex_internal)
    );

    // ID/EX latch: hand everything to Execute on the clock tick
    idExLatch iEL0(
        .clk(clk),                                      // inputs
        .rst(rst),
        .ctl_wb(wb_internal),
        .ctl_mem(mem_internal),
        .ctl_ex(ex_internal),
        .npc(if_id_npc),                                // passed straight through
        .readdat1(readdat1_internal),
        .readdat2(readdat2_internal),
        .sign_ext(sign_ext_internal),
        .instr_bits_20_16(if_id_instr[20:16]),          // rt, straight from instr
        .instr_bits_15_11(if_id_instr[15:11]),          // rd, straight from instr
                                                        // outputs
        .wb_out(id_ex_wb),
        .mem_out(id_ex_mem),
        .ctl_out(id_ex_execute),
        .npc_out(id_ex_npc),
        .readdat1_out(id_ex_readdat1),
        .readdat2_out(id_ex_readdat2),
        .sign_ext_out(id_ex_sign_ext),
        .instr_bits_20_16_out(id_ex_instr_bits_20_16),
        .instr_bits_15_11_out(id_ex_instr_bits_15_11)
    );

endmodule