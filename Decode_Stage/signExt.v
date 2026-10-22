`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: signExtend
// Purpose: Stretch a 16-bit immediate to 32 bits without changing its value.
//
// I-type instructions (lw, sw, beq) only have 16 bits left for a constant
// (6 opcode + 5 rs + 5 rt = 16 used). The ALU works on 32 bits, so we copy
// the sign bit (bit 15) into the upper 16 bits:
//   0x0008 (+8) -> 0x00000008
//   0xFFF8 (-8) -> 0xFFFFFFF8
//////////////////////////////////////////////////////////////////////////////////

module signExtend(
    input  wire [15:0] immediate,   // instr[15:0]
    output wire [31:0] extended     // 32-bit sign-extended value
);

    // {16{immediate[15]}} = sign bit repeated 16 times (top half)
    // { top, immediate }  = glue the original 16 bits underneath (bottom half)
    assign extended = { {16{immediate[15]}}, immediate };

endmodule