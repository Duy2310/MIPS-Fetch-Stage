`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2026 05:39:57 PM
// Design Name: 
// Module Name: instrMem
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


module instrMem(
input wire clk,
    input wire rst,
    input wire [31:0] addr,
    output reg [31:0] data
);

    // Each memory location stores one 32-bit instruction
    reg [31:0] memory [0:39];

    integer i;

    initial begin
        // Initialize all available locations to zero
        for (i = 0; i < 40; i = i + 1)
            memory[i] = 32'h00000000;

        // First 10 instructions
        memory[0]  = 32'hA00000AA;
        memory[4]  = 32'h10000011;
        memory[8]  = 32'h20000022;
        memory[12] = 32'h30000033;
        memory[16] = 32'h40000044;
        memory[20] = 32'h50000055;
        memory[24] = 32'h60000066;
        memory[28] = 32'h70000077;
        memory[32] = 32'h80000088;
        memory[36] = 32'h90000099;
    end

    always @(*) begin
        if (rst)
            data = 32'h00000000;
        else if (addr <= 32'd39)
            data = memory[addr];
        else
            data = 32'h00000000;
    end

endmodule
