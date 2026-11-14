/* memory.v
 * Memory Stage: takes the outputs of the EX/MEM latch and combines AND, data_memory and mem_wb.
 */
module MEMORY (
    input  wire        clk,
    input  wire [1:0]  wb_ctlout,        // WB control bits {RegWrite, MemtoReg}
    input  wire        branch,           // MemBranch
    input  wire        memread,
    input  wire        memwrite,
    input  wire        zero,
    input  wire [31:0] alu_result,       // ALU_Result -> Data Mem address + MEM/WB latch
    input  wire [31:0] rdata2out,        // ReadData2_ex_mem -> Data Mem write data
    input  wire [4:0]  five_bit_muxout,  // FiveBitMuxout -> MEM/WB latch
    output wire        MEM_PCSrc,        // from AND gate, to Fetch
    output wire        MEM_WB_regwrite,  // to Decode
    output wire        MEM_WB_memtoreg,  // to WB mux select
    output wire [31:0] read_data,        // ReadData (latched)
    output wire [31:0] mem_alu_result,   // Mem_ALU_Result (latched)
    output wire [4:0]  mem_write_reg     // MemWriteReg (latched), to Decode
);
    wire [31:0] read_data_in;

    AND AND_4 (
        .membranch(branch),
        .zero(zero),
        .PCSrc(MEM_PCSrc)
    );

    data_memory data_memory4 (
        .clk(clk),
        .addr(alu_result),
        .write_data(rdata2out),
        .memread(memread),
        .memwrite(memwrite),
        .read_data(read_data_in)
    );

    mem_wb mem_wb4 (
        .clk(clk),
        .control_wb_in(wb_ctlout),
        .read_data_in(read_data_in),
        .alu_result_in(alu_result),
        .write_reg_in(five_bit_muxout),
        .regwrite(MEM_WB_regwrite),
        .memtoreg(MEM_WB_memtoreg),
        .read_data(read_data),
        .mem_alu_result(mem_alu_result),
        .mem_write_reg(mem_write_reg)
    );
endmodule // MEMORY
