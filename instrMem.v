`timescale 1ns / 1ps

module instrMem(
    input wire clk,
    input wire rst,
    input wire [31:0] addr,
    output reg [31:0] data
);

    // 10 words, each 32 bits wide (word-addressed)
    reg [31:0] memory [0:9];

    initial begin
        memory[0] = 32'hA00000AA;  // byte addr 0x00
        memory[1] = 32'h10000011;  // byte addr 0x04
        memory[2] = 32'h20000022;  // byte addr 0x08
        memory[3] = 32'h30000033;  // byte addr 0x0C
        memory[4] = 32'h40000044;  // byte addr 0x10
        memory[5] = 32'h50000055;  // byte addr 0x14
        memory[6] = 32'h60000066;  // byte addr 0x18
        memory[7] = 32'h70000077;  // byte addr 0x1C
        memory[8] = 32'h80000088;  // byte addr 0x20
        memory[9] = 32'h90000099;  // byte addr 0x24
    end

    // addr[31:2] drops the bottom 2 bits = byte address / 4 = word index
    always @(*) begin
        if (rst)
            data = 32'h00000000;
        else if (addr[31:2] <= 9)
            data = memory[addr[31:2]];
        else
            data = 32'h00000000;
    end

endmodule