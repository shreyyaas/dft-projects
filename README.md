### ✅ Project 4 — DFT-Aware 4-bit ALU (Capstone)
**Language:** Verilog  
**Tools:** EDA Playground, Icarus Verilog  
**Concepts:** Full DFT flow — RTL design, scan insertion,
manual ATPG, shift-capture-shift verification

#### What this demonstrates
- Designed a 4-bit ALU supporting ADD, SUB, AND, OR operations
- Inserted 5 scan FFs on ALU outputs (result[3:0] + carry)
  chained into a single scan chain
- Wrote 7 manual test patterns targeting SA0/SA1 faults
  on all output nodes
- Verified each pattern using full shift-capture-shift cycle
- All 7 tests passed — fault coverage analysis documented

#### Files
| File | Description |
|---|---|
| `alu.v` | 4-bit combinational ALU — ADD/SUB/AND/OR |
| `scan_ff.v` | Scan-enabled DFF with SE-controlled MUX |
| `alu_dft.v` | DFT wrapper — ALU + 5-FF scan chain |
| `alu_dft_tb.v` | Shift-capture-shift testbench, 7 test patterns |

#### Test results
| Test | A | B | Op | Expected | Got | Result |
|---|---|---|---|---|---|---|
| ADD 3+5 | 0011 | 0101 | ADD | 01000 | 01000 | PASS ✓ |
| ADD 9+9 | 1001 | 1001 | ADD | 10010 | 10010 | PASS ✓ |
| AND | 1010 | 1100 | AND | 01000 | 01000 | PASS ✓ |
| OR | 1010 | 0101 | OR | 01111 | 01111 | PASS ✓ |
| SUB 8-3 | 1000 | 0011 | SUB | 00101 | 00101 | PASS ✓ |
| ADD 0+0 | 0000 | 0000 | ADD | 00000 | 00000 | PASS ✓ |
| ADD F+F | 1111 | 1111 | ADD | 11110 | 11110 | PASS ✓ |

#### Fault coverage
| Pattern | Faults targeted |
|---|---|
| ADD 0+0 → `00000` | SA1 on all 5 output bits |
| ADD F+F → `11110` | SA0 on result[3:2:1] and carry |
| OR → `01111` | SA0 on result[3:0] |
| ADD 9+9 → `10010` | SA0 on carry and result[1] |
| AND → `01000` | SA1 on result[3:2:0], SA0 on result[3] |
