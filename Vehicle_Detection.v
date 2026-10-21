module VehicleDetection(
    input clk,
    input reset_n,
    input entry_sensor,
    input exit_sensor,
    output reg car_present
);

    // FSM States
    parameter IDLE = 1'b0, VEHICLE_PRESENT = 1'b1;
    reg current_state, next_state;

    // State transition logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) current_state <= IDLE;
        else current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: if (entry_sensor) next_state = VEHICLE_PRESENT;
            VEHICLE_PRESENT: if (exit_sensor) next_state = IDLE;
        endcase
    end

    // Output logic
    always @(posedge clk) begin
        car_present <= (current_state == VEHICLE_PRESENT);
    end
endmodule