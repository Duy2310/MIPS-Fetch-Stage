# MIPS Pipeline: Fetch and Decode Stages

This project implements and simulates the Instruction Fetch (IF) and Instruction Decode (ID) stages of a MIPS pipelined processor using Verilog and Vivado.

```
 IF ──[IF/ID]── ID ──[ID/EX]── EX ──[EX/MEM]── MEM ──[MEM/WB]── WB
```

---

## Stage 1: Instruction Fetch (IF)

### Components

- `mux.v`: Selects either PC + 4 or the branch target address
- `pc.v`: Stores the current program counter
- `incrementer.v`: Calculates PC + 4
- `instrMem.v`: Stores and returns 32-bit instructions
- `ifIdLatch.v`: Stores the fetched instruction and next PC
- `fetch.v`: Connects all Fetch-stage components
- `fetch_tb.v`: Tests sequential instruction fetching and branching

### Operation

During normal execution, the program counter advances by four for each instruction. When `ex_mem_pc_src` is 1, the multiplexer selects `ex_mem_npc` as the next PC. The IF/ID latch stores the fetched instruction and next PC on each rising clock edge.

The testbench demonstrates sequential fetching followed by a branch to address `0x20`. The Fetch stage then retrieves instruction `0x80000088` and continues sequentially.

### Simulation Waveform

![Fetch Stage Waveform](fetch_waveform.png)

---

## Stage 2: Instruction Decode (ID)

### Components

- `signExt.v`: Sign extends the 16-bit immediate field to 32 bits
- `regFile.v`: 32 general-purpose 32-bit registers with two read ports and one write port
- `control.v`: Decodes the opcode and generates the EX, MEM, and WB control signals
- `latch.v`: ID/EX pipeline latch that stores all Decode outputs for the Execute stage
- `decode.v`: Connects all Decode-stage components
- `decode_tb.v`: Tests R-format, LW, SW, and BEQ instructions and a register write

### Operation

The instruction from the IF/ID latch is split into fields. The opcode (`[31:26]`) goes to the control unit, `rs` (`[25:21]`) and `rt` (`[20:16]`) select the two registers read from the register file, and the immediate (`[15:0]`) is sign extended to 32 bits. The `rt` and `rd` (`[15:11]`) register numbers are passed through so the Execute stage can select the destination register.

The control unit generates 9 control signals grouped by the stage that uses them:

| Group | Bits | Signals |
|---|---|---|
| EX | 4 | RegDst, ALUOp1, ALUOp0, ALUSrc |
| MEM | 3 | Branch, MemRead, MemWrite |
| WB | 2 | RegWrite, MemToReg |

| Instruction | Opcode | EX | MEM | WB |
|---|---|---|---|---|
| R-format | 000000 | 1100 | 000 | 10 |
| LW | 100011 | 0001 | 010 | 11 |
| SW | 101011 | 0001 | 001 | 00 |
| BEQ | 000100 | 0010 | 100 | 00 |

Don't care (X) values are set to 0.

Register reads are combinational. Register writes occur on the rising clock edge when `wb_reg_write` is 1, using the register number and data from the Writeback stage. Register `$0` is hardwired to 0. The ID/EX latch stores the control signals, NPC, both read data values, the sign-extended immediate, and the `rt`/`rd` register numbers on each rising clock edge.

### Testbench

Registers are initialized to their own index (`$1 = 1`, `$2 = 2`, ...). The testbench applies the following instructions:

| Instruction | Hex | Verifies |
|---|---|---|
| `add $3, $1, $2` | `0x00221820` | R-format control signals and register reads |
| `lw $5, 8($4)` | `0x8C850008` | LW control signals and positive immediate |
| `sw $6, -4($7)` | `0xACE6FFFC` | SW control signals and negative sign extension (`0xFFFFFFFC`) |
| `beq $1, $2, 3` | `0x10220003` | BEQ control signals |
| `add $11, $10, $1` | `0x01415820` | Reads back `0xDEADBEEF`, written to `$10` by the simulated Writeback stage |

### Simulation Waveform

![Decode Stage Waveform](decode_waveform.png)

---

## Tools

- Verilog
- AMD Vivado Simulator

