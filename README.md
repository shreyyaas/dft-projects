### Results

| Patterns used | Faults simulated | Detected | Coverage |
|---|---|---|---|
| 32 (exhaustive) | 14 | 14 | 100% |
| 4 (manual) | 11 | 10 | 90.9% |

### Key finding
Manual pattern `I3 SA0` escaped with 4 patterns — I2=0 masked
the fault at G2 in all 4 patterns. The exhaustive set catches it
via pattern `01100` where I2=1, I3=1 simultaneously excites and
propagates the fault. This demonstrates exactly why ATPG is needed
over manual pattern selection.
