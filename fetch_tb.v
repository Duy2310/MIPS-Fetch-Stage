`timescale 1ns / 1ps

module fetch_tb;

    reg clk;
    reg rst;
    reg ex_mem_pc_src;
    reg [31:0] ex_mem_npc;

    wire [31:0] if_id_instr;
    wire [31:0] if_id_npc;

    // Fetch stage under test
    fetch dut(
        .clk(clk),
        .rst(rst),
        .ex_mem_pc_src(ex_mem_pc_src),
        .ex_mem_npc(ex_mem_npc),
        .if_id_instr(if_id_instr),
        .if_id_npc(if_id_npc)
    );

    // Create a clock with a 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Apply test inputs
    initial begin
        rst = 1;
        ex_mem_pc_src = 0;
        ex_mem_npc = 32'd0;

        // Release reset at 12 ns
        #12 rst = 0;

        // Fetch sequential instructions
        #30;

        // Branch to address 32
        ex_mem_pc_src = 1;
        ex_mem_npc = 32'd32;

        // Return to normal sequential fetching
        #10 ex_mem_pc_src = 0;

        #40;
        $finish;
    end

endmodule