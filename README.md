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

### 🔄 Project 3 — LFSR + MISR Logic BIST Core *(in progress)*
**Language:** Verilog  
**Concepts:** LFSR pseudo-random pattern generation, MISR signature compression, LBIST

---

### 🔄 Project 4 — DFT-Aware 4-bit ALU *(planned)*
**Language:** Verilog  
**Concepts:** Full DFT flow — RTL design, scan insertion, manual ATPG, fault coverage

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
