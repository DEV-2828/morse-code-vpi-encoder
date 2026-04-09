# Verilog Morse Code Encoder with VPI
**Digital Design and Computer Organisation Laboratory — 3rd Semester, 2025**

| Field | Detail |
|---|---|
| **Authors** | Devopam Pal, Karan Varshney |
| **SRN** | PES2UG24CS152, PES2UG24CS903 |
| **Section** | C |
| **Date** | 10-Nov-2025 |

---

## Table of Contents
1. [Project Goal](#1-project-goal)
2. [System Architecture](#2-system-architecture)
3. [How It Works — Step by Step](#3-how-it-works--step-by-step)
4. [File Details](#4-file-details)
   - [morse_encoder.v — The Hardware Design](#41-morse_encoderv--the-hardware-design)
   - [tb_morse.v — The Testbench](#42-tb_morsev--the-testbench)
   - [morse_vpi.c — The C VPI Module](#43-morse_vpic--the-c-vpi-module)
5. [State Machine](#5-state-machine)
6. [How to Build and Run](#6-how-to-build-and-run)
7. [Sample Output](#7-sample-output)

---

## 1. Project Goal

This project converts text typed by a user into Morse code using a hardware/software co-simulation approach. The key challenge it solves is that **Verilog normally cannot read from a console**. 

We solve this using **VPI (Verilog Procedural Interface)** — an IEEE 1364 standard that lets C code register custom system tasks (like `$get_next_char`) that Verilog can call during simulation. This bridges the hardware simulation world with real-world user input.

---

## 2. System Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    Icarus Verilog Simulation              │
│                                                          │
│   ┌─────────────────┐        ┌──────────────────────┐   │
│   │   tb_morse.v    │        │   morse_encoder.v    │   │
│   │   (Testbench)   │──────▶│   (DUT / Hardware)   │   │
│   │                 │◀──────│                      │   │
│   └────────┬────────┘        └──────────────────────┘   │
│            │  $get_next_char()                           │
│            ▼                                             │
│   ┌─────────────────┐                                    │
│   │  morse_vpi.c    │◀── fgets() ── User Console Input   │
│   │  (VPI / C Layer)│                                    │
│   └─────────────────┘                                    │
└──────────────────────────────────────────────────────────┘
```

The system has **three main components**:

| Component | File | Role |
|---|---|---|
| Hardware Encoder | `morse_encoder.v` | Converts one ASCII character into dot/dash symbols using an FSM |
| Testbench | `tb_morse.v` | Provides clock/reset, drives the encoder, and prints output |
| C VPI Module | `morse_vpi.c` | Registers `$get_next_char` — reads user input from console and feeds it to Verilog |

---

## 3. How It Works — Step by Step

1. The Verilog simulation starts and **resets the encoder**.
2. The testbench calls `$get_next_char` — this triggers the C code.
3. The C code **pauses the simulation** and waits for the user to type a line of text.
4. Once the user presses Enter, C feeds the **first character** to the testbench.
5. The testbench passes this character to the encoder and pulses `start`.
6. The encoder goes **busy**, outputting dots and dashes one symbol per clock cycle.
7. The testbench's `always` monitor block watches `symbol_ready` and **prints each symbol**.
8. When the encoder finishes, the testbench calls `$get_next_char` for the **next character**.
9. This repeats until C returns `0` (end of line), and `$finish` stops the simulation.

---

## 4. File Details

### 4.1 `morse_encoder.v` — The Hardware Design

**Module:** `morse_encoder`

**Ports:**

| Port | Direction | Width | Description |
|---|---|---|---|
| `clk` | Input | 1-bit | System clock |
| `reset` | Input | 1-bit | Active-high synchronous reset |
| `ascii_char_in` | Input | 8-bit | ASCII character to encode |
| `start` | Input | 1-bit | Pulse high to begin encoding |
| `encoder_busy` | Output | 1-bit | High throughout the encoding process |
| `morse_symbol` | Output | 3-bit | Current symbol: `1`=dot, `2`=dash, `3`=end-of-char, `4`=end-of-word |
| `symbol_ready` | Output | 1-bit | Pulses high for one cycle when a new symbol is ready |

**Internal Storage:**
- `morse_pattern[0:7]` — array storing the dot/dash sequence for the current character
- `morse_len` — number of symbols in the current Morse code sequence
- `symbol_index` — tracks which symbol is currently being output

**Character Lookup:**  
On entering `S_LOOKUP`, a large `case` statement maps the ASCII character to its Morse pattern. Example:
```
"A" → pattern = [DOT, DASH]      → .-
"B" → pattern = [DASH, DOT, DOT, DOT] → -...
"S" → pattern = [DOT, DOT, DOT]  → ...
"O" → pattern = [DASH, DASH, DASH] → ---
```

---

### 4.2 `tb_morse.v` — The Testbench

**Module:** `testbench_encoder_vpi`

**Key sections:**

**1. DUT Instantiation**
```verilog
morse_encoder dut (
    .clk(clk),
    .reset(reset),
    .ascii_char_in(char_from_c),
    .start(start_encode),
    .encoder_busy(encoder_busy),
    .morse_symbol(morse_symbol_out),
    .symbol_ready(symbol_ready)
);
```

**2. Main Control Loop (`initial` block)**
```verilog
// Get first character from C
$get_next_char(char_from_c);

while (char_from_c != 0) begin
    start_encode <= 1;
    @(posedge clk);       // DUT sees start=1, sets busy=1
    start_encode <= 0;
    @(negedge encoder_busy); // Wait for encoding to complete
    @(posedge clk);
    $get_next_char(char_from_c); // Get next character
end
```

**3. Output Monitor (`always` block)**
```verilog
always @(posedge clk) begin
    if (symbol_ready) begin
        case (morse_symbol_out)
            1: $write(".");  // Dot
            2: $write("-");  // Dash
            3: $write(" ");  // End of character
        endcase
        $fflush;
    end
end
```

---

### 4.3 `morse_vpi.c` — The C VPI Module

**Purpose:** Registers a custom Verilog system task `$get_next_char` using the IEEE 1364 VPI standard.

**Key functions:**

**`get_next_char_calltf()`** — Called every time Verilog executes `$get_next_char`
- On first call: reads a full line from stdin using `fgets()` into a buffer
- Converts characters to uppercase using `toupper()`
- Returns one character at a time on successive calls
- Returns `0` (ASCII null) when the line is exhausted to signal end-of-input

**`register_get_next_char_task()`** — Registers the system task with the simulator
```c
s_vpi_systf_data tf_data;
tf_data.type   = vpiSysTask;
tf_data.tfname = "$get_next_char";
tf_data.calltf = get_next_char_calltf;
vpi_register_systf(&tf_data);
```

**`vlog_startup_routines[]`** — The entry point that Icarus Verilog looks for when loading the `.vpi` shared library:
```c
void (*vlog_startup_routines[])() = {
    register_get_next_char_task,
    register_print_morse_task,
    0
};
```

---

## 5. State Machine

The encoder uses a 6-state FSM:

```
         reset
           │
           ▼
        ┌──────┐   start pulse   ┌──────────┐
        │S_IDLE│───────────────▶│ S_LOOKUP │
        └──────┘                └────┬─────┘
           ▲                         │ pattern loaded
           │                         ▼
  ┌─────────────────┐        ┌───────────────┐
  │S_WAIT_AFTER_GAP │        │ S_SEND_SYMBOL │
  └────────┬────────┘        └───────┬───────┘
           │                         │ symbol output
           │                         ▼
    ┌──────────┐            ┌──────────────────────┐
    │ S_SEND   │◀───────────│ S_WAIT_FOR_NEXT      │
    │   GAP    │  last sym  │       SYMBOL         │
    └──────────┘            └──────────────────────┘
```

| State | Action |
|---|---|
| `S_IDLE` | Waits for `start` pulse |
| `S_LOOKUP` | Looks up the Morse pattern for the input character |
| `S_SEND_SYMBOL` | Outputs the current dot/dash, pulses `symbol_ready` |
| `S_WAIT_FOR_NEXT_SYMBOL` | Waits one cycle between symbols |
| `S_SEND_GAP` | Outputs end-of-character marker (`morse_symbol = 3`) |
| `S_WAIT_AFTER_GAP` | Ensures `encoder_busy` doesn't drop prematurely |

---

## 6. How to Build and Run

> **Environment:** Linux/macOS with Icarus Verilog installed

### Step 1 — Compile the C code into a VPI shared library
```bash
gcc -shared -fPIC -o morse_combined.vpi morse_combined_vpi.c -I/usr/include/iverilog/
```

### Step 2 — Compile the Verilog files and link the VPI library
```bash
iverilog -m morse_combined.vpi -o my_vpi_encoder morse_encoder.v tb_morse.v
```

### Step 3 — Run the simulation
```bash
vvp my_vpi_encoder
```

**Usage:**
- The simulation starts and pauses, waiting for input.
- Type any text (e.g., `SOS`) and press **Enter**.
- The Morse code output prints immediately to the terminal.

---

## 7. Sample Output

```
$ vvp my_vpi_encoder
Testbench starting...
Reset released. Waiting for first input...
SOS
MORSE CODE : ... --- ...

PRECODE: SOS
End of input (ASCII 0) received. Finishing.
```

```
$ vvp my_vpi_encoder
HELLO WORLD
MORSE CODE : .... . .-.. .-.. --- / .-- --- .-. .-.. -..

PRECODE: HELLO WORLD
```
