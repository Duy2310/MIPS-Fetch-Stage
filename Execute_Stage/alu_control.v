`timescale 1ns / 1ps

module alu_control(
    input wire [5:0] funct,
    input wire [1:0] aluop,
    output reg [2:0] select
);

    always @(*) begin
        case (aluop)

            2'b00: begin
                select = 3'b010;   // lw/sw: add
            end

            2'b01: begin
                select = 3'b110;   // beq: subtract
            end

            2'b10: begin
                case (funct)
                    6'b100000: select = 3'b010; // add
                    6'b100010: select = 3'b110; // subtract
                    6'b100100: select = 3'b000; // AND
                    6'b100101: select = 3'b001; // OR
                    6'b101010: select = 3'b111; // SLT
                    default:   select = 3'b011; // unknown
                endcase
            end

            default: begin
                select = 3'b011;       // unknown operation
            end

        endcase
    end

endmodule
