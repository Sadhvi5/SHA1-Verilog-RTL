# SHA-1  RTL Implementation — Verilog

B.Tech Final Year Project | SASTRA Deemed University | AI for Chip Design

## Overview
RTL implementation of SHA-1 cryptographic hash algorithm in SystemVerilog,
extended to a parameterized dual SHA-1/SHA-256 engine using LLM-assisted
automation. Verified against Python software reference and online hash generators.

## Modules
| Module | Description |
|---|---|
| sha1_padding | Converts input message into 512-bit blocks |
| sha_design | Core FSM — Ideal, Expand, Compute, Finalize states |
| sha1_top1 | Top-level module integrating padding + SHA core |
| tb_sha1_top1 | Testbench — applies test vectors, checks 160-bit output |
| parametrised_sha_top | Unified SHA-1/SHA-256 engine via parameters |

## Key Results
- SHA-1 RTL output matches Python FIPS 180-1 reference for all test vectors
- Verified against online SHA generator (abc, a, empty string, custom strings)
- Parametrised engine supports SHA-1 (160-bit) and SHA-256 (256-bit)
  by changing HASH_WIDTH, NUM_ROUNDS, ALGORITHM parameters only

## Tools Used
- SystemVerilog / Verilog
- ModelSim (simulation)
- Yosys (synthesis)
- Python (software reference verification)

## Synthesis Stats (sha_design)
- Number of cells: 34,536
- Number of wires: 30,620

## Test Vectors Verified
| Input | Expected SHA-1 Hash | Result |
|---|---|---|
| "abc" | a9993e364706816aba3e25717850c26c9cd0d89d | PASS |
| "a" | 86f7e437faa5a7fce15d1ddcb9eaeaea377667b8 | PASS |
| "" (empty) | da39a3ee5e6b4b0d3255bfef95601890afd80709 | PASS |

## References
- Cryptography and Network Security, 8th Ed. — William Stallings
- IEEE Xplore: Design of SHA-1 Algorithm based on FPGA (2010)
- ResearchGate: Analysis and Evolution of SHA-1 (2024)
