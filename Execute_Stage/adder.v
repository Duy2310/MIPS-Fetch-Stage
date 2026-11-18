`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: adder
// Purpose: Computes the BRANCH TARGET address for beq.
//
//   branch target = NPC + SignExtend
//
// NPC is PC + 4 (passed down from Fetch). SignExtend is beq's offset.
// So this answers: "if the branch is taken, where do we jump to?"
//
// Same idea as Fetch's incrementer, except it adds the offset instead of 4.
// Combinational (assign), so the answer updates instantly.
//
// The result goes through EX/MEM as Add_Result and eventually back to the
// Fetch mux as ex_mem_npc.
//////////////////////////////////////////////////////////////////////////////////

module adder(
    input  wire [31:0] add_in1,   // NPC (PC + 4)
    input  wire [31:0] add_in2,   // sign-extended offset
    output wire [31:0] add_out    // branch target address
);

    assign add_out = add_in1 + add_in2;

endmodule