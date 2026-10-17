`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2026 05:59:38 PM
// Design Name: 
// Module Name: fetch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fetch(
    input wire clk,
    input wire rst,
    input wire ex_mem_pc_src,
    input wire [31:0] ex_mem_npc,
    output wire [31:0] if_id_instr,
    output wire [31:0] if_id_npc
);

    // Internal connections
    wire [31:0] pc_out;
    wire [31:0] pc_mux;
    wire [31:0] next_pc;
    wire [31:0] instr_data;

    // Select PC + 4 or branch address
    mux m0(
        .y(pc_mux),
        .a_true(ex_mem_npc),
        .b_false(next_pc),
        .sel(ex_mem_pc_src)
    );

    // Program counter
    pc pc0(
        .clk(clk),
        .rst(rst),
        .pc_in(pc_mux),
        .pc_out(pc_out)
    );

    // Calculate PC + 4
    incrementer in0(
        .clk(clk),
        .rst(rst),
        .pcin(pc_out),
        .pcout(next_pc)
    );

    // Instruction memory
    instrMem inMem0(
        .clk(clk),
        .rst(rst),
        .addr(pc_out),
        .data(instr_data)
    );

    // IF/ID pipeline latch
    ifIdLatch ifIdLatch0(
        .clk(clk),
        .rst(rst),
        .pc_in(next_pc),
        .instr_in(instr_data),
        .pc_out(if_id_npc),
        .instr_out(if_id_instr)
    );

endmodule
