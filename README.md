# ARM-Processor
Pipelined version of an ARM processor that can detect control and data hazards

OVERVIEW

This project implements a 5-stage pipelined CPU in VHDL based on the ARM LEGv8 architecture. The processor adds hardware support for detecting and resolving data hazards using pipeline stalling and forwarding logic.

The design was developed and simulated using GHDL with waveform-based debugging performed using GTKWave.

------------------------------------------------------------

KEY FEATURES

- 5-stage pipeline: IF, ID, EX, MEM, WB
- Load-use hazard detection with pipeline stalling
- EX-stage forwarding from EX/MEM and MEM/WB
- MEM-stage forwarding for store data hazards
- Structural VHDL design
- Single reusable testbench for multiple programs
- Waveform-based verification

------------------------------------------------------------

ARCHITECTURE SUMMARY

The processor datapath closely follows the LEGv8 pipelined architecture, with additional hardware for hazard resolution.

Hazard Detection Unit
Detects load-use hazards between the ID and EX stages and generates control signals to stall the pipeline by disabling PC and IF/ID writes.

Forwarding Unit
Resolves data hazards without stalling by forwarding results from later pipeline stages to earlier stages when required.

Control hazard flushing for branches is not implemented in this version. Instructions following a taken branch are not squashed and will still execute.

------------------------------------------------------------

REPOSITORY STRUCTURE

pipelinedcpu1.vhd      Top-level pipelined CPU
pipecpu1_tb.vhd       Unified testbench
hazardunit.vhd        Load-use hazard detection logic
forwardingunit.vhd    EX and MEM forwarding logic
alumux3.vhd           Three-input ALU operand multiplexer
imem_p1.vhd           Instruction memory (Program 1)
imem_p2.vhd           Instruction memory (Program 2)
dmem.vhd              Data memory
regfile.vhd           Register file
Makefile              Build and simulation automation

------------------------------------------------------------

INSTRUCTION PROGRAMS

Program 1 (p1)
- Tests load-use hazards
- Tests EX-stage forwarding
- Tests MEM-stage forwarding for store instructions
- Includes dependent arithmetic and back-to-back store operations

Program 2 (p2)
- Tests conditional branching using CBNZ
- Tests arithmetic forwarding chains
- Demonstrates control hazards

------------------------------------------------------------

SIMULATION AND USAGE

Requirements
- GHDL
- GTKWave
- Linux environment (Tufts servers or local setup)

To run the simulation:

make [p1/p2]

To change programs, update the instruction memory file referenced in the Makefile.

------------------------------------------------------------

VERIFICATION APPROACH

- Single testbench used for all programs
- No assert-based checking
- Correctness verified through waveform inspection
- Expected behavior compared against pipeline timing tables

------------------------------------------------------------

KNOWN LIMITATIONS

- No control hazard flushing
- No branch prediction
- No performance metrics such as CPI

These limitations are intentional and consistent with the scope of the assignment.

------------------------------------------------------------

LEARNING OUTCOMES

This project demonstrates:
- Implementation of a pipelined CPU in VHDL
- Hardware-based data hazard detection and resolution
- Structural and modular hardware design
- Debugging complex pipelines using waveform analysis
- Understanding of real-world pipeline tradeoffs

------------------------------------------------------------

ACKNOWLEDGEMENTS

Course materials and datapath reference from Computer Organization and Design
GHDL and GTKWave for simulation and debugging
