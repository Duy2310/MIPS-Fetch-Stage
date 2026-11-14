`timescale 1ns / 1ps
/* memoryTB.v
 * Self-checking testbench for the MEMORY stage.
 * Inputs change on the falling edge; results are checked 1 ns after the rising edge
 * (when the MEM/WB latch has updated).
 */
module memoryTB();
    reg         clk;
    reg  [31:0] ALUResult, WriteData;
    reg  [4:0]  WriteReg;
    reg  [1:0]  WBControl;               // {RegWrite, MemtoReg}
    reg         MemWrite, MemRead, Branch, Zero;

    wire [31:0] ReadData, ALUResult_out;
    wire [4:0]  WriteReg_out;
    wire        RegWrite_out, MemtoReg_out;
    wire        PCSrc;

    integer errors = 0;

    MEMORY uut (
        .clk(clk),
        .wb_ctlout(WBControl),
        .branch(Branch),
        .memread(MemRead),
        .memwrite(MemWrite),
        .zero(Zero),
        .alu_result(ALUResult),
        .rdata2out(WriteData),
        .five_bit_muxout(WriteReg),
        .MEM_PCSrc(PCSrc),
        .MEM_WB_regwrite(RegWrite_out),
        .MEM_WB_memtoreg(MemtoReg_out),
        .read_data(ReadData),
        .mem_alu_result(ALUResult_out),
        .mem_write_reg(WriteReg_out)
    );

    // 10 ns clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Compare a value against what we expect and report
    task check32(input [8*24-1:0] name, input [31:0] got, input [31:0] exp);
        begin
            if (got === exp)
                $display("  PASS  %0s = %h", name, got);
            else begin
                $display("  FAIL  %0s = %h (expected %h)", name, got, exp);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("memoryTB.vcd");
        $dumpvars(0, memoryTB);

        // Idle values
        ALUResult = 0; WriteData = 0; WriteReg = 0; WBControl = 2'b00;
        MemWrite = 0; MemRead = 0; Branch = 0; Zero = 0;

        // ---------- 1. Load (lw): read DMEM[4] ----------
        @(negedge clk);
        ALUResult = 32'h00000004;
        WriteData = 32'h12345678;
        WriteReg  = 5'd2;
        WBControl = 2'b11;          // RegWrite = 1, MemtoReg = 1
        MemRead = 1; MemWrite = 0;
        @(posedge clk); #1;
        $display("\n[%0t] Test 1: Load from address 4", $time);
        check32("ReadData",      ReadData,      32'h00000004);
        check32("ALUResult_out", ALUResult_out, 32'h00000004);
        check32("WriteReg_out",  WriteReg_out,  32'd2);
        check32("RegWrite",      RegWrite_out,  1);
        check32("MemtoReg",      MemtoReg_out,  1);

        // ---------- 2. Store (sw): DMEM[4] <= 0x12345678 ----------
        @(negedge clk);
        WBControl = 2'b00;          // sw does not write a register
        MemRead = 0; MemWrite = 1;
        @(posedge clk); #1;
        $display("\n[%0t] Test 2: Store 0x12345678 to address 4", $time);
        check32("DMEM[4]",  uut.data_memory4.DMEM[4], 32'h12345678);
        check32("RegWrite", RegWrite_out, 0);

        // ---------- 3. Load again: read back DMEM[4] ----------
        @(negedge clk);
        WBControl = 2'b11;
        MemWrite = 0; MemRead = 1;
        @(posedge clk); #1;
        $display("\n[%0t] Test 3: Read back address 4", $time);
        check32("ReadData", ReadData, 32'h12345678);

        // ---------- 4. R-type: ALU result passes through, MemtoReg = 0 ----------
        @(negedge clk);
        ALUResult = 32'h0000ABCD;
        WriteReg  = 5'd9;
        WBControl = 2'b10;          // RegWrite = 1, MemtoReg = 0
        MemRead = 0; MemWrite = 0;
        @(posedge clk); #1;
        $display("\n[%0t] Test 4: R-type pass-through", $time);
        check32("ALUResult_out", ALUResult_out, 32'h0000ABCD);
        check32("WriteReg_out",  WriteReg_out,  32'd9);
        check32("MemtoReg",      MemtoReg_out,  0);

        // ---------- 5. Branch (beq) ----------
        @(negedge clk);
        WBControl = 2'b00;
        Branch = 1; Zero = 1;
        #1;
        $display("\n[%0t] Test 5a: Branch = 1, Zero = 1 (taken)", $time);
        check32("PCSrc", PCSrc, 1);
        Zero = 0; #1;
        $display("[%0t] Test 5b: Branch = 1, Zero = 0 (not taken)", $time);
        check32("PCSrc", PCSrc, 0);
        Branch = 0; Zero = 1; #1;
        $display("[%0t] Test 5c: Branch = 0, Zero = 1 (not a branch)", $time);
        check32("PCSrc", PCSrc, 0);

        // ---------- Summary ----------
        if (errors == 0) $display("\nALL TESTS PASSED\n");
        else             $display("\n%0d TEST(S) FAILED\n", errors);
        $finish;
    end
endmodule // memoryTB
