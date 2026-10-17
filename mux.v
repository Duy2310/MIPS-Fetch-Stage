`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2026 04:40:39 PM
// Design Name: 
// Module Name: mux
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


module mux(
output wire [31:0] y,
    input  wire [31:0] a_true,
    input  wire [31:0] b_false,
    input  wire        sel
    );
    
    assign y = sel ? a_true : b_false;
    
endmodule
