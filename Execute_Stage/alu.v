`timescale 1ns / 1ps

module alu(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [2:0] control,
    output reg [31:0] result,
    output wire zero
);

    always @(*) begin
        case (control)

            3'b010: result = a + b;  // add
            3'b110: result = a - b;  // subtract
            3'b000: result = a & b;  // AND
            3'b001: result = a | b;  // OR
            3'b111: begin             // signed set-less-than
                if ($signed(a) < $signed(b))
                    result = 32'd1;
                else
                    result = 32'd0;
            end

            default: result = 32'bx;

        endcase
    end

    assign zero = (result == 32'd0);

endmodule
