`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: ifIdLatch
// Purpose: IF/ID pipeline register. Sits between the Fetch (IF) stage and the
//          Decode (ID) stage.
//
// Think of it as a handoff tray: on each rising clock edge, Fetch drops off
// the instruction it just read plus PC + 4. Decode works on those values for
// the whole next cycle while Fetch is already grabbing the next instruction.
// That overlap is what makes it a pipeline.
//
// PC + 4 is passed along because later stages need it to compute branch
// targets.
//////////////////////////////////////////////////////////////////////////////////

module ifIdLatch(
    input  wire        clk,        // system clock
    input  wire        rst,        // reset: clears both outputs
    input  wire [31:0] pc_in,      // PC + 4 from the incrementer
    input  wire [31:0] instr_in,   // instruction from instruction memory
    output reg  [31:0] pc_out,     // PC + 4 held for the Decode stage
    output reg  [31:0] instr_out   // instruction held for the Decode stage
);

    // Same structure as the PC register: update on rising clock edge,
    // asynchronous reset.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out    <= 32'd0;     // clear on reset
            instr_out <= 32'd0;
        end
        else begin
            pc_out    <= pc_in;     // capture PC + 4
            instr_out <= instr_in;  // capture the fetched instruction
        end
    end

endmodule