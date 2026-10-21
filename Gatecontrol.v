module GateControl(
    input car_present,
    input entry_request,
    input exit_request,
    input [3:0] available_spaces,
    output open_entry_gate,
    output open_exit_gate
);

    assign open_entry_gate = entry_request && (available_spaces > 0) && car_present;
    assign open_exit_gate = exit_request && car_present;
endmodule
