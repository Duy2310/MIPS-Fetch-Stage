`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: alu_control
// Purpose: Decides EXACTLY which operation the ALU does.
//
// Two inputs:
//   aluop (2 bits) from the main control unit in Decode: a rough hint
//   funct (6 bits) = Instr[5:0]: the exact R-format operation
//
// Why two levels? Every R-format instruction has opcode 000000, so the main
// control can't tell add from sub. It just says "it's R-format, check funct"
// (aluop = 10), and this module reads funct to decide.
//
// Table (from the lab, Fig. 2):
//   Instr     ALUOp  funct    ALU action   select
//   lw / sw    00    XXXXXX   add          010   (address = base + offset)
//   beq        01    XXXXXX   subtract     110   (equal if result = 0)
//   add        10    100000   add          010
//   sub        10    100010   subtract     110
//   and        10    100100   and          000
//   or         10    100101   or           001
//   slt        10    101010   set < than   111
//   anything else             unknown      011
//
// Combinational lookup table, same style as control.v in Decode.
//////////////////////////////////////////////////////////////////////////////////

module alu_control(
    input  wire [5:0] funct,    // Instr[5:0]
    input  wire [1:0] aluop,    // from main control
    output reg  [2:0] select    // operation code sent to the ALU
);

    always @(*) begin
        case (aluop)

            2'b00: begin
                select = 3'b010;   // lw/sw: always ADD (compute the address)
            end

            2'b01: begin
                select = 3'b110;   // beq: always SUBTRACT (compare registers)
            end

            2'b10: begin           // R-format: look at funct to decide
                case (funct)
                    6'b100000: select = 3'b010; // add
                    6'b100010: select = 3'b110; // subtract
                    6'b100100: select = 3'b000; // AND
                    6'b100101: select = 3'b001; // OR
                    6'b101010: select = 3'b111; // set less than
                    default:   select = 3'b011; // unknown funct
                endcase
            end

            default: begin
                select = 3'b011;   // unknown aluop
            end

        endcase
    end

endmodule