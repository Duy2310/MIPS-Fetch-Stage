`timescale 1ns / 1ps

module ex_mem(
    input wire clk,
    input wire [1:0] ctlwb_in,
    input wire [1:0] ctlm_in,
    input wire [31:0] adder_in,
    input wire [31:0] alu_in,
    input wire [31:0] rdata2_in,
    input wire [4:0] mux_in,

    output reg [1:0] ctlwb_out,
    output reg [1:0] ctlm_out,
    output reg [31:0] adder_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] rdata2_out,
    output reg [4:0] muxout_out
);

    always @(posedge clk) begin
        ctlwb_out <= ctlwb_in;
        ctlm_out <= ctlm_in;
        adder_out <= adder_in;
        alu_result_out <= alu_in;
        rdata2_out <= rdata2_in;
        muxout_out <= mux_in;
    end

endmodule
