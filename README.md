# DFT Projects — VLSI Design for Testability

## Project 1: D Flip-Flop & Scan Chain
**Tools:** EDA Playground, Icarus Verilog
**Concepts:** Sequential logic, scan design, shift-capture-shift cycle

### Files
- `dff.v` — Standard D flip-flop with synchronous reset
- `scan_ff.v` — Scan-enabled flip-flop (SE-controlled MUX)
- `scan_chain.v` — 8-FF scan chain
- `scan_chain_tb.v` — Full shift-capture-shift testbench

### What this demonstrates
RTL implementation of the fundamental DFT building block.
Verified shift-in → capture → shift-out cycle targeting SA0/SA1 faults.
