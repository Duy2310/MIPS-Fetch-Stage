/* data_memory.v
 * Data memory for the MEM stage.
 *  - Inputs come from the EX/MEM latch: addr = alu_result, write_data = rdata2out (ReadData2_ex_mem).
 *  - READ  is combinational: when memread = 1, read_data = DMEM[addr]; otherwise 0.
 *  - WRITE is synchronous: on the rising clock edge, if memwrite = 1, DMEM[addr] <= write_data.
 *  - read_data goes to the MEM/WB latch.
 */
module data_memory (
    input  wire        clk,
    input  wire [31:0] addr,        // Memory address (ALU_Result)
    input  wire [31:0] write_data,  // Data to store (ReadData2_ex_mem)
    input  wire        memread,     // 1 = load
    input  wire        memwrite,    // 1 = store
    output wire [31:0] read_data    // Data read from memory
);
    // 256 (2^8) words of 32-bit memory
    reg [31:0] DMEM [0:255];
    integer i;

    initial begin
        // Initialize DMEM[0-255] to 0-255 (lab 4 memory stage)
        for (i = 0; i < 256; i = i + 1)
            DMEM[i] = i;

        // Load DMEM[0-5] from data.txt
        $readmemb("data.txt", DMEM, 0, 5);

        $display("From Data Memory (data.txt):");
        for (i = 0; i < 6; i = i + 1)
            $display("\tDMEM[%0d] = %0h", i, DMEM[i]);
        $display("From Data Memory (initial):");
        for (i = 6; i < 10; i = i + 1)
            $display("\tDMEM[%0d] = %0d", i, DMEM[i]);
        $display("\t...");
        $display("\tDMEM[%0d] = %0d", 255, DMEM[255]);
    end

    // Load: combinational read (only 8 address bits are used, since there are 256 words)
    assign read_data = memread ? DMEM[addr[7:0]] : 32'b0;

    // Store: synchronous write on rising edge
    always @(posedge clk) begin
        if (memwrite)
            DMEM[addr[7:0]] <= write_data;
    end
endmodule // data_memory
