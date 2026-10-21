# Design notes

## Source preservation

The `original/centralized_fsm` and `original/modular` folders contain two historical implementations. Neither is asserted to be the definitive undergraduate submission. The first implementation has known boundary-condition and display limitations; the second has different gate/occupancy behavior.

## Improvements in `rtl/`

The new controller uses edge-qualified request events, bounds checking, and independent gate-hold timers. The counter changes once per accepted event; a sustained input cannot repeatedly decrement or increment it. Two active-low seven-segment outputs display the default initial value 10 correctly. All inputs are assumed synchronous to the clock.

## Verification scope

The directed testbench covers reset, single entry/exit, held request, filling to capacity, rejecting entry when full, simultaneous requests at full and partially occupied conditions, and gate timeout. Additional tests should cover more capacities, random event sequences, FPGA synthesis, asynchronous input conditioning, and real vehicle detection.

## Design trade-off

This revised implementation is an event-driven synchronous controller, not a strict finite-state machine. A hardware gate controller could instead use separate explicit FSMs for entry and exit, including safety interlocks and actual gate limit sensors.
