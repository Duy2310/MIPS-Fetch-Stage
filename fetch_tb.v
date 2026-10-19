`timescale 1ns / 1ps
// timescale: "#1" in this file means 1 ns, with 1 ps precision

//////////////////////////////////////////////////////////////////////////////////
// Module: fetch_tb
// Purpose: Testbench for the Fetch stage. Not real hardware, just a script
//          that drives inputs into the fetch module and lets us watch the
//          outputs in the waveform.
//
// Test plan:
//   1. Hold reset for 12 ns
//   2. Fetch a few instructions sequentially (0x00, 0x04, 0x08, 0x0C)
//   3. Simulate a taken branch to address 0x20 (32 decimal)
//   4. Go back to sequential fetching from 0x24
//
// Expected if_id_instr sequence:
//   A00000AA, 10000011, 20000022, 30000033, 80000088, 90000099, 00000000...
//   (30000033 still appears after the branch because it was already fetched
//    when the branch signal arrived. Later stages would flush it.)
//////////////////////////////////////////////////////////////////////////////////

module fetch_tb;

    // Inputs to the DUT are 'reg' because the testbench sets them
    reg        clk;
    reg        rst;
    reg        ex_mem_pc_src;
    reg [31:0] ex_mem_npc;

    // Outputs from the DUT are 'wire' because the DUT drives them
    wire [31:0] if_id_instr;
    wire [31:0] if_id_npc;

    // DUT = "Device Under Test": an instance of the fetch module
    fetch dut(
        .clk(clk),
        .rst(rst),
        .ex_mem_pc_src(ex_mem_pc_src),
        .ex_mem_npc(ex_mem_npc),
        .if_id_instr(if_id_instr),
        .if_id_npc(if_id_npc)
    );

    // Clock generator: flip clk every 5 ns -> 10 ns period (100 MHz)
    // Rising edges at 5, 15, 25, 35, 45, ... ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus: '#N' means "wait N ns" before the next line
    initial begin
        // t = 0 ns: start in reset, no branch
        rst = 1;
        ex_mem_pc_src = 0;
        ex_mem_npc = 32'd0;

        // t = 12 ns: release reset (between clock edges to avoid a race)
        #12 rst = 0;

        // t = 12 to 42 ns: let it fetch sequentially for 3 cycles
        #30;

        // t = 42 ns: pretend the EX/MEM stage says "branch taken to 0x20"
        ex_mem_pc_src = 1;
        ex_mem_npc = 32'd32;   // 32 decimal = 0x20

        // t = 52 ns: branch signal off after one clock edge (at 45 ns)
        #10 ex_mem_pc_src = 0;

        // t = 52 to 92 ns: keep fetching sequentially, then stop
        #40;
        $finish;   // end the simulation
    end

endmodule