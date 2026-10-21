module SmartParkingSystem(
    input clk,
    input reset_n,
    input entry_sensor,
    input exit_sensor,
    input entry_request,
    input exit_request,
    output open_entry_gate,
    output open_exit_gate,
    output led_indicator
);

    wire car_present;
    wire [3:0] available_spaces;

    VehicleDetection vd(
        .clk(clk),
        .reset_n(reset_n),
        .entry_sensor(entry_sensor),
        .exit_sensor(exit_sensor),
        .car_present(car_present)
    );

    ParkingSpaceManagement psm(
        .clk(clk),
        .reset_n(reset_n),
        .entry_signal(entry_request),
        .exit_signal(exit_request),
        .available_spaces(available_spaces)
    );

    GateControl gc(
        .car_present(car_present),
        .entry_request(entry_request),
        .exit_request(exit_request),
        .available_spaces(available_spaces),
        .open_entry_gate(open_entry_gate),
        .open_exit_gate(open_exit_gate)
    );

    LEDIndicator li(
        .available_spaces(available_spaces),
        .led_indicator(led_indicator)
    );

endmodule
