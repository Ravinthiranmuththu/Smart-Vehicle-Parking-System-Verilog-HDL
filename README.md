# Smart Vehicle Parking System — Verilog HDL

An **improved portfolio implementation** of an undergraduate smart parking controller. The original submitted/final version cannot be established from the surviving files, so both earlier design variants are preserved in `original/`. The revised RTL is not presented as the original submission.

## Features

- Configurable **10-space** parking lot (default; supported capacity range 1–15).
- Entry and exit events require both a sensor and a request input.
- Rising-event detection prevents repeated counts while buttons remain held.
- Gate indicators remain active for a configurable number of clock cycles.
- Full/available LEDs and **two-digit** seven-segment available-space display.
- Simultaneous entry/exit requests are handled with occupancy boundary checks.
- Self-checking Verilog testbench and optional VCD waveform output.

## Architecture

`SmartVehicleParkingSystem` connects request/sensor qualification, `ParkingController`, two `SevenSegDisplay` decoders, and status indicators. `ParkingController` is a synchronous event-driven controller; it is **not** the original eight-state FSM. A real FPGA implementation must synchronize and debounce physical sensor/button inputs and use realistic gate timers.

### Occupancy policy

- Available spaces initialize to `CAPACITY` after active-low reset.
- An entry is accepted only if at least one space is free.
- An exit is accepted only if at least one vehicle is present.
- Simultaneous requests at intermediate occupancy open both gates and leave the count unchanged.
- At full capacity, only the exit is accepted; at empty occupancy, only the entry is accepted.
- A held-high request generates only one event; lower the signal before issuing another.

## Project structure

```text
rtl/SmartVehicleParkingSystem.v       Improved RTL
 tb/tb_SmartVehicleParkingSystem.v     Self-checking testbench
 original/centralized_fsm/            Preserved first implementation and waveform
 original/modular/                    Preserved alternative implementation
 docs/DESIGN_NOTES.md                 Design choices and limitations
 simulation/                          Output directory for generated VCD
```

## Simulate (no FPGA required)

Install [Icarus Verilog](https://steveicarus.github.io/iverilog/) and optionally [GTKWave](https://gtkwave.sourceforge.net/). From the repository root:

```bash
iverilog -g2012 -s tb_SmartVehicleParkingSystem -o simulation/parking_test.vvp rtl/SmartVehicleParkingSystem.v tb/tb_SmartVehicleParkingSystem.v
vvp simulation/parking_test.vvp
```

Expected success message **after a passing simulation**: `PASS: all directed parking tests passed`.

To inspect the waveform:

```bash
gtkwave simulation/waveform.vcd
```

**Verification status:** RTL and testbench are prepared, but simulation has **not been executed in this environment**. The expected success message is not a claimed result. No synthesis or FPGA hardware validation has been performed.

## Interface

| Input | Meaning |
|---|---|
| `clk_50MHz` | 50 MHz clock |
| `reset_n` | Active-low asynchronous reset |
| `entry_sensor_btn`, `entry_request_btn` | Qualified entry event |
| `exit_sensor_btn`, `exit_request_btn` | Qualified exit event |

| Output | Meaning |
|---|---|
| `open_entry_gate_led`, `open_exit_gate_led` | Gate-active indicators |
| `green_led`, `red_led` | Spaces available / lot full |
| `hex0_segments`, `hex1_segments` | Ones and tens digits (active-low `{g,f,e,d,c,b,a}`) |
| `available_spaces` | Binary count for testbench/other modules |

## Limitations

This is a **simulation-oriented RTL prototype**, not a deployed parking system. It does not include mechanical gate actuation, vehicle passage confirmation, physical button debounce, clock-domain synchronization, security checks, or production timing. Counter updates occur on accepted request events rather than confirmed vehicle crossings. For real-world hardware, adapt the input conditioning and gate-control timing to the target FPGA board.

## Background

Undergraduate Verilog HDL project in Electrical and Information Engineering, University of Ruhuna. Original files retained for traceability; the improved version was prepared later for portfolio use.
