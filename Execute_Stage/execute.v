`timescale 1ns / 1ps

module execute(
    input wire clk,
    input wire [1:0] ctlwb_in,
    input wire [1:0] ctlm_in,
    input wire [31:0] npc,
    input wire [31:0] rdata1,
    input wire [31:0] rdata2,
    input wire [31:0] s_extend,
    input wire [4:0] instr_2016,
    input wire [4:0] instr_1511,
    input wire [1:0] alu_op,
    input wire [5:0] funct,
    input wire alusrc,
    input wire regdst,

    output wire [1:0] ctlwb_out,
    output wire [1:0] ctlm_out,
    output wire [31:0] adder_out,
    output wire [31:0] alu_result_out,
    output wire [31:0] rdata2_out,
    output wire [4:0] muxout_out
);

    wire [31:0] branch_address;
    wire [31:0] alu_input_b;
    wire [31:0] alu_result;
    wire [4:0] destination_register;
    wire [2:0] alu_control_signal;
    wire alu_zero;

    adder adder3 (
        .add_in1(npc),
        .add_in2(s_extend),
        .add_out(branch_address)
    );

    bottom_mux bottom_mux3 (
        .a(instr_1511),
        .b(instr_2016),
        .sel(regdst),
        .y(destination_register)
    );

    alu_control alu_control3 (
        .funct(funct),
        .aluop(alu_op),
        .select(alu_control_signal)
    );

    top_mux top_mux3 (
        .a(s_extend),
        .b(rdata2),
        .alusrc(alusrc),
        .y(alu_input_b)
    );

    alu alu3 (
        .a(rdata1),
        .b(alu_input_b),
        .control(alu_control_signal),
        .result(alu_result),
        .zero(alu_zero)
    );

    ex_mem ex_mem3 (
        .clk(clk),
        .ctlwb_in(ctlwb_in),
        .ctlm_in(ctlm_in),
        .adder_in(branch_address),
        .alu_in(alu_result),
        .rdata2_in(rdata2),
        .mux_in(destination_register),

        .ctlwb_out(ctlwb_out),
        .ctlm_out(ctlm_out),
        .adder_out(adder_out),
        .alu_result_out(alu_result_out),
        .rdata2_out(rdata2_out),
        .muxout_out(muxout_out)
    );

endmodule
