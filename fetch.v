`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: fetch
// Purpose: Top-level Instruction Fetch (IF) stage. Wires together the 5
//          components: mux, pc, incrementer, instrMem, ifIdLatch.
//
// Data flow each clock cycle:
//   1. PC holds the current address (pc_out)
//   2. instrMem reads the instruction at pc_out       -> instr_data
//   3. incrementer computes pc_out + 4                -> next_pc
//   4. mux picks next_pc, or ex_mem_npc if a branch   -> pc_mux
//      was taken (ex_mem_pc_src = 1)
//   5. On the clock edge: PC loads pc_mux, and the IF/ID latch saves
//      instr_data and next_pc for the Decode stage
//
//   ex_mem_npc --+
//                v
//   +-------> [MUX] --pc_mux--> [PC] --pc_out--+--> [INSTR MEM] --instr_data--+
//   |                                          |                              v
//   |                                          +--> [+4] --next_pc--> [IF/ID LATCH]
//   +-------------------next_pc----------------------+
//
// Syntax note: module_name instance_name ( .port(wire), ... );
// ".port(wire)" connects the submodule's port to a wire in this module.
//////////////////////////////////////////////////////////////////////////////////

module fetch(
    input  wire        clk,            // system clock
    input  wire        rst,            // reset
    input  wire        ex_mem_pc_src,  // from EX/MEM stage: 1 = branch taken
    input  wire [31:0] ex_mem_npc,     // from EX/MEM stage: branch target address
    output wire [31:0] if_id_instr,    // to Decode: fetched instruction
    output wire [31:0] if_id_npc       // to Decode: PC + 4
);

    // Internal wires connecting the components (the "cables" between blocks)
    wire [31:0] pc_out;      // current PC (PC register output)
    wire [31:0] pc_mux;      // next PC chosen by the mux (PC register input)
    wire [31:0] next_pc;     // PC + 4 (incrementer output)
    wire [31:0] instr_data;  // instruction read from memory

    // Mux: choose the next PC
    // Branch taken -> ex_mem_npc, otherwise -> PC + 4
    mux m0(
        .y(pc_mux),
        .a_true(ex_mem_npc),
        .b_false(next_pc),
        .sel(ex_mem_pc_src)
    );

    // Program Counter: loads pc_mux on each clock edge
    pc pc0(
        .clk(clk),
        .rst(rst),
        .pc_in(pc_mux),
        .pc_out(pc_out)
    );

    // Incrementer: next_pc = pc_out + 4
    incrementer in0(
        .clk(clk),
        .rst(rst),
        .pcin(pc_out),
        .pcout(next_pc)
    );

    // Instruction Memory: read instruction at the current PC
    instrMem inMem0(
        .clk(clk),
        .rst(rst),
        .addr(pc_out),
        .data(instr_data)
    );

    // IF/ID Latch: hand the instruction and PC + 4 to the Decode stage
    // Its outputs are the outputs of this whole module.
    ifIdLatch ifIdLatch0(
        .clk(clk),
        .rst(rst),
        .pc_in(next_pc),
        .instr_in(instr_data),
        .pc_out(if_id_npc),
        .instr_out(if_id_instr)
    );

endmodule
