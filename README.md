# DFT Projects — VLSI Design for Testability

> Self-directed study portfolio targeting semiconductor internships.  
> Tools: Verilog · Python 3 · EDA Playground · Icarus Verilog

---

## Projects

### ✅ Project 1 — Scan Chain + Fault Injection
**Language:** Verilog  
**Tools:** EDA Playground, Icarus Verilog 12.0  
**Concepts:** Scan design, shift-capture-shift cycle, SA1 fault detection

#### What this demonstrates
- Designed a scan-enabled D flip-flop with SE-controlled 2:1 MUX
- Chained 8 scan FFs into a complete scan chain
- Verified full shift-in → capture → shift-out cycle
- Injected SA1 fault on d[0] (models wire shorted to VDD)
- Proved fault is invisible during scan shift-in (SE=1 bypasses d)
  but captured and detected after the functional capture phase (SE=0)
- Compared faulty vs fault-free shift-out responses to confirm detection

#### Files
| File | Description |
|---|---|
| `dff.v` | Standard D flip-flop with synchronous reset |
| `scan_ff.v` | Scan-enabled FF — SE=0 normal, SE=1 scan mode |
| `scan_chain.v` | 8 scan FFs stitched in series |
| `scan_chain_tb.v` | Shift-capture-shift testbench |
| `scan_ff_faulty.v` | Scan FF with SA1 fault on d (d_final forced to 1) |
| `scan_chain_faulty.v` | Scan chain with FF0 replaced by faulty FF |
| `fault_injection_tb.v` | Runs both chains, compares shift-out responses |
| `waveform.png` | EPWave output — DFF verification |
| `fault_injection_waveform.png` | EPWave output — fault detection moment |

#### Fault injection results
| | Fault-free | SA1 on d[0] |
|---|---|---|
| Driven value | d[0] = 0 | d[0] = 0 |
| Captured value | Q[0] = 0 | Q[0] = 1 (stuck!) |
| Shift-out response | `00000000` | `00000001` |
| **Result** | — | **DETECTED ✓** |

#### Key insight
The fault is completely invisible during shift-in because SE=1 bypasses
the d input entirely. It only manifests during the one capture clock
(SE=0) when the functional path is active — demonstrating the
excite → capture → propagate detection mechanism.

---

### ✅ Project 2 — ISCAS-85 c17 Fault Simulator
**Language:** Python 3  
**Concepts:** Stuck-at fault simulation, fault collapsing, fault coverage, ATPG motivation

#### What this demonstrates
- Modelled the ISCAS-85 c17 benchmark circuit (5 NAND gates, 5 inputs, 2 outputs)
- Generated all SA0/SA1 faults across every node (20 total)
- Implemented equivalence-based fault collapsing to remove redundant faults
- Simulated fault-free vs faulty circuit for each fault across all test patterns
- Computed fault coverage — the core DFT metric used in industry
- Demonstrated why ATPG is necessary by comparing exhaustive vs manual patterns

#### Files
| File | Description |
|---|---|
| `fault_simulator.py` | Complete fault simulator — circuit model, simulation, collapsing, report |

#### Results

| Patterns used | Faults simulated | Detected | Undetected | Coverage |
|---|---|---|---|---|
| 32 (exhaustive, all 2^5) | 14 | 14 | 0 | **100%** |
| 4 (manual selection) | 11 | 10 | 1 | **90.9%** |

#### Key finding
With 4 manually chosen patterns, `I3 SA0` escaped detection.
To detect this fault, I2=1 and I3=1 must both be true simultaneously —
I2=1 ensures G2's output depends on I3 (propagation path open),
and I3=1 excites the SA0 fault. None of the 4 manual patterns
satisfied both conditions. The exhaustive set catches it via pattern
`01100`. This concretely demonstrates why ATPG tools are needed —
they algorithmically find the exact pattern that satisfies all
excite + propagate constraints, rather than relying on manual selection.

#### Fault collapsing insight
With 32 patterns, 6 faults were collapsed (14 simulated).  
With 4 patterns, 9 faults were collapsed (11 simulated).  
Fewer patterns = more faults appear equivalent = more collapsing.
This shows that fault collapsing results are pattern-set dependent.

---

### ✅ Project 3 — LFSR + MISR Logic BIST Core
**Language:** Verilog  
**Tools:** EDA Playground, Icarus Verilog 12.0  
**Concepts:** LBIST, LFSR pseudo-random pattern generation, 
MISR signature compression, golden signature verification

#### What this demonstrates
- Implemented a 4-bit maximal-length LFSR (feedback polynomial x^4+x^3+1)
  generating 15 unique pseudo-random patterns before repeating
- Implemented a 4-bit MISR compressing CUT responses into a running signature
- Connected LFSR → CUT → MISR to form a complete Logic BIST core
- Established golden signature by running fault-free simulation
- Verified repeatability — identical signature across multiple runs confirms
  deterministic BIST behaviour required for production use

#### Files
| File | Description |
|---|---|
| `lfsr.v` | 4-bit maximal-length LFSR, seed=0001, feedback x^4+x^3+1 |
| `misr.v` | 4-bit MISR signature compressor |
| `cut.v` | Circuit under test — 4-bit AND/OR combinational logic |
| `lbist_tb.v` | Drives LFSR→CUT→MISR, prints per-cycle table, checks repeatability |

#### Results
| Run | Cycles | Final signature | Result |
|---|---|---|---|
| Run 1 (fault-free) | 16 | `0001` | PASS ✓ |
| Run 2 (repeatability) | 16 | `0001` | PASS ✓ |

#### Key insight
After exactly 15 cycles (one full LFSR period), the MISR signature
mathematically returns to zero — a known XOR compression property.
Running for 16 cycles breaks this symmetry and produces a stable
non-zero golden signature (`0001`). In real LBIST designs, the number
of test cycles is chosen deliberately to avoid this cancellation point.

#### How LBIST works
1. LFSR generates pseudo-random patterns — no external tester needed
2. CUT evaluates each pattern and produces a response
3. MISR compresses all responses into one 4-bit signature
4. At end of test, signature compared to pre-computed golden value
5. Match = PASS (circuit fault-free), mismatch = FAIL (fault present)

---

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

---

## Skills demonstrated
- Verilog RTL design and testbench writing
- Scan chain architecture and shift-capture-shift verification
- Stuck-at fault modelling and injection
- Fault simulation and coverage analysis
- Equivalence-based fault collapsing
- Understanding of ATPG, BIST, and industrial DFT flow

## Tools used
| Tool | Purpose |
|---|---|
| EDA Playground + Icarus Verilog | Verilog simulation and waveform viewing |
| Python 3 | Fault simulation scripting |
| GitHub | Version control and portfolio |

## Roadmap
- [x] Project 1 — Scan chain + fault injection
- [x] Project 2 — ISCAS-85 fault simulator
- [ ] Project 3 — LFSR + MISR BIST core
- [ ] Project 4 — DFT-aware ALU capstone
