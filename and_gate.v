/* and_gate.v
 * ANDs MemBranch and Zero. PCSrc = 1 means take the branch (goes to the IF-stage mux).
 */
module AND (
    input  wire membranch,
    input  wire zero,
    output wire PCSrc
);
    assign PCSrc = membranch & zero;
endmodule // AND
