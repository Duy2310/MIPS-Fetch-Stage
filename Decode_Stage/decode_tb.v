`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: decode_tb
// Purpose: Testbench for the Decode stage. Feeds in real MIPS instructions
//          (one of each type in the control table) plus a register write
//          from the "Writeback stage", and lets us check the ID/EX outputs.
//
// Clock: 10 ns period, rising edges at 5, 15, 25, 35, ...
// Inputs change between edges (12, 22, 32...) to avoid races.
// The ID/EX latch captures on the NEXT rising edge, so outputs appear at
// 15, 25, 35, ...
//
// Registers start as their own number ($1 = 1, $2 = 2, ...), set in regfile.v
//
// ---------------- Test instructions ----------------
//  Time  Instr                 Hex         Fields
//  12    add $3, $1, $2        0x00221820  op=000000 rs=1 rt=2  rd=3
//  22    lw  $5, 8($4)         0x8C850008  op=100011 rs=4 rt=5  imm=8
//  32    sw  $6, -4($7)        0xACE6FFFC  op=101011 rs=7 rt=6  imm=-4
//  42    beq $1, $2, 3         0x10220003  op=000100 rs=1 rt=2  imm=3
//  52    nop (all zeros)       0x00000000  + WB writes 0xDEADBEEF into $10
//  62    add $11, $10, $1      0x01415820  op=000000 rs=10 rt=1 rd=11
//
// ---------------- Expected ID/EX outputs ----------------
//  Edge  Instr   wb  mem  execute readdat1  readdat2  sign_ext   20_16 15_11
//  15    add     10  000  1100    1         2         00001820   2     3
//  25    lw      11  010  0001    4         5         00000008   5     0
//  35    sw      00  001  0001    7         6         FFFFFFFC   6     31
//  45    beq     00  100  0010    1         2         00000003   2     0
//  55    nop     10  000  1100    0         0         00000000   0     0
//  65    add     10  000  1100    DEADBEEF  1         00005820   1     11
//
// Things to point out in the demo:
//  - Control bits change per instruction type and match the prof's table
//  - sw's sign_ext is FFFFFFFC: -4 was sign extended correctly
//  - At 65 ns readdat1 = DEADBEEF: the Writeback write into $10 worked
//////////////////////////////////////////////////////////////////////////////////

module decode_tb;

    // Inputs to the DUT (testbench drives these) -> reg
    reg        clk;
    reg        rst;
    reg        wb_reg_write;
    reg [4:0]  wb_write_reg_location;
    reg [31:0] mem_wb_write_data;
    reg [31:0] if_id_instr;
    reg [31:0] if_id_npc;

    // Outputs from the DUT (we watch these) -> wire
    wire [1:0]  id_ex_wb;
    wire [2:0]  id_ex_mem;
    wire [3:0]  id_ex_execute;
    wire [31:0] id_ex_npc;
    wire [31:0] id_ex_readdat1;
    wire [31:0] id_ex_readdat2;
    wire [31:0] id_ex_sign_ext;
    wire [4:0]  id_ex_instr_bits_20_16;
    wire [4:0]  id_ex_instr_bits_15_11;

    // Device Under Test
    decode dut(
        .clk(clk),
        .rst(rst),
        .wb_reg_write(wb_reg_write),
        .wb_write_reg_location(wb_write_reg_location),
        .mem_wb_write_data(mem_wb_write_data),
        .if_id_instr(if_id_instr),
        .if_id_npc(if_id_npc),
        .id_ex_wb(id_ex_wb),
        .id_ex_mem(id_ex_mem),
        .id_ex_execute(id_ex_execute),
        .id_ex_npc(id_ex_npc),
        .id_ex_readdat1(id_ex_readdat1),
        .id_ex_readdat2(id_ex_readdat2),
        .id_ex_sign_ext(id_ex_sign_ext),
        .id_ex_instr_bits_20_16(id_ex_instr_bits_20_16),
        .id_ex_instr_bits_15_11(id_ex_instr_bits_15_11)
    );

    // Clock: flip every 5 ns -> 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // t = 0: reset, nothing being written back, no instruction
        rst                   = 1;
        wb_reg_write          = 0;
        wb_write_reg_location = 5'd0;
        mem_wb_write_data     = 32'd0;
        if_id_instr           = 32'h00000000;
        if_id_npc             = 32'd0;

        // t = 12: release reset, R-format: add $3, $1, $2
        #12 rst         = 0;
            if_id_instr = 32'h00221820;
            if_id_npc   = 32'd4;

        // t = 22: lw $5, 8($4)
        #10 if_id_instr = 32'h8C850008;
            if_id_npc   = 32'd8;

        // t = 32: sw $6, -4($7)   (negative immediate tests sign extend)
        #10 if_id_instr = 32'hACE6FFFC;
            if_id_npc   = 32'd12;

        // t = 42: beq $1, $2, 3
        #10 if_id_instr = 32'h10220003;
            if_id_npc   = 32'd16;

        // t = 52: nop, and pretend Writeback is saving 0xDEADBEEF into $10
        //         (the write happens on the 55 ns clock edge)
        #10 if_id_instr           = 32'h00000000;
            if_id_npc             = 32'd20;
            wb_reg_write          = 1;
            wb_write_reg_location = 5'd10;
            mem_wb_write_data     = 32'hDEADBEEF;

        // t = 62: stop writing, then read $10 back: add $11, $10, $1
        #10 wb_reg_write          = 0;
            if_id_instr           = 32'h01415820;
            if_id_npc             = 32'd24;

        // let the last instruction get latched, then stop
        #20;
        $finish;
    end

endmodule