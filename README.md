# Verilog Morse Code Encoder with C VPI

## Overview
This project implements a hardware Morse Code Encoder in Verilog, designed to translate ASCII alphanumeric characters (A-Z, 0-9) into their corresponding Morse code dot-dash patterns. It features a custom Verilog Procedural Interface (VPI) module written in C to seamlessly map hardware simulation states to human-readable console outputs.

## Features
- **Combinational Encoder:** Translates ASCII characters into packed 10-bit patterns (2-bit encoding per symbol) with a 3-bit length field.
- **Hardware/Software Co-simulation:** Bridges Verilog simulation with C via a custom `$print_morse` system task.
- **Automated Testbench:** Processes continuous text strings, decodes simulator states at runtime, and prints formatted `. -` characters directly to the terminal.

## Tools Used
- **Hardware Description:** Verilog
- **Co-simulation:** C, IEEE 1364 VPI 
- **Simulation:** Icarus Verilog (`iverilog`)
- **Waveform Viewing:** GTKWave

## File Structure
- `morse_encoder.v`: Core combinational logic for ASCII to Morse translation.
- `tb_morse.v`: Testbench driving the simulation with continuous strings.
- `morse_vpi.c`: C module bridging simulator states to the console output.
