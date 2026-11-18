`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: alu   (Arithmetic Logic Unit)
// Purpose: The calculator. Does the actual math for every instruction.
//
//   a       = ReadData1 (value of rs)
//   b       = output of the ALUSrc mux (ReadData2 or SignExtend)
//   control = which operation, from alu_control
//
// What it computes per instruction:
//   add $3,$1,$2   -> $1 + $2           (the answer)
//   lw/sw          -> base + offset     (a memory ADDRESS)
//   beq            -> $1 - $2           (if 0, the registers are equal)
//
// zero = 1 when the result is 0. beq uses this: zero = 1 means equal,
// so the branch should be taken.
//
// Combinational: always @(*) re-runs whenever a, b, or control changes.
//////////////////////////////////////////////////////////////////////////////////

module alu(
    input  wire [31:0] a,         // ReadData1
    input  wire [31:0] b,         // ReadData2 or SignExtend
    input  wire [2:0]  control,   // operation select from alu_control
    output reg  [31:0] result,    // ALU_Result
    output wire        zero       // 1 if result == 0
);

    always @(*) begin
        case (control)

            3'b010: result = a + b;  // add
            3'b110: result = a - b;  // subtract
            3'b000: result = a & b;  // bitwise AND
            3'b001: result = a | b;  // bitwise OR

            3'b111: begin            // set less than (signed)
                // $signed so negatives compare correctly (-1 < 5, not 0xFFFFFFFF > 5)
                if ($signed(a) < $signed(b))
                    result = 32'd1;
                else
                    result = 32'd0;
            end

            default: result = 32'bx; // unknown operation -> unknown result

        endcase
    end

    // Zero flag: 1 if the result is exactly 0
    assign zero = (result == 32'd0);

endmodule