`timescale 1ns/1ps
// Improved portfolio version of the undergraduate Smart Vehicle Parking System.
// Inputs must be synchronous to clk_50MHz; debounce/synchronize physical buttons externally.
module SmartVehicleParkingSystem #(
    parameter integer CAPACITY = 10,
    parameter integer GATE_HOLD_CYCLES = 3
)(
    input wire clk_50MHz, reset_n,
    input wire entry_sensor_btn, exit_sensor_btn,
    input wire entry_request_btn, exit_request_btn,
    output wire open_entry_gate_led, open_exit_gate_led,
    output wire green_led, red_led,
    output wire [6:0] hex0_segments,
    output wire [6:0] hex1_segments,
    output wire [3:0] available_spaces
);
    wire entry_event = entry_sensor_btn & entry_request_btn;
    wire exit_event  = exit_sensor_btn & exit_request_btn;
    wire [3:0] spaces;
    ParkingController #(.CAPACITY(CAPACITY), .GATE_HOLD_CYCLES(GATE_HOLD_CYCLES)) ctrl (
        .clk(clk_50MHz), .reset_n(reset_n),
        .entry_event(entry_event), .exit_event(exit_event),
        .available_spaces(spaces),
        .open_entry_gate(open_entry_gate_led),
        .open_exit_gate(open_exit_gate_led)
    );
    assign available_spaces = spaces;
    assign green_led = (spaces != 0);
    assign red_led = (spaces == 0);
    SevenSegDisplay ones (.num(spaces % 10), .segments(hex0_segments));
    SevenSegDisplay tens (.num(spaces / 10), .segments(hex1_segments));
endmodule

// One accepted transaction per rising edge of a combined sensor/request signal.
// Simultaneous requests are processed together when 0 < spaces < CAPACITY.
// At full capacity, exit is accepted and entry is rejected in that cycle.
// At zero occupancy, entry is accepted and exit is rejected in that cycle.
// A held-high request is not counted repeatedly.
module ParkingController #(
    parameter integer CAPACITY = 10,
    parameter integer GATE_HOLD_CYCLES = 3
)(
    input wire clk, reset_n, entry_event, exit_event,
    output reg [3:0] available_spaces,
    output wire open_entry_gate, open_exit_gate
);
    reg prev_entry, prev_exit;
    reg [31:0] entry_hold, exit_hold;
    wire entry_pulse = entry_event && !prev_entry;
    wire exit_pulse = exit_event && !prev_exit;
    wire can_entry = entry_pulse && (available_spaces > 0);
    wire can_exit  = exit_pulse && (available_spaces < CAPACITY);
    assign open_entry_gate = (entry_hold != 0);
    assign open_exit_gate  = (exit_hold != 0);
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            available_spaces <= CAPACITY;
            prev_entry <= 0;
            prev_exit <= 0;
            entry_hold <= 0;
            exit_hold <= 0;
        end else begin
            prev_entry <= entry_event;
            prev_exit <= exit_event;
            if (can_entry && !can_exit) available_spaces <= available_spaces - 1'b1;
            else if (can_exit && !can_entry) available_spaces <= available_spaces + 1'b1;
            if (can_entry) entry_hold <= GATE_HOLD_CYCLES;
            else if (entry_hold != 0) entry_hold <= entry_hold - 1'b1;
            if (can_exit) exit_hold <= GATE_HOLD_CYCLES;
            else if (exit_hold != 0) exit_hold <= exit_hold - 1'b1;
        end
    end
endmodule

// Common-anode, active-low segments: {g,f,e,d,c,b,a}.
module SevenSegDisplay(input wire [3:0] num, output reg [6:0] segments);
    always @(*) begin
        case (num)
            4'd0: segments = 7'b1000000;
            4'd1: segments = 7'b1111001;
            4'd2: segments = 7'b0100100;
            4'd3: segments = 7'b0110000;
            4'd4: segments = 7'b0011001;
            4'd5: segments = 7'b0010010;
            4'd6: segments = 7'b0000010;
            4'd7: segments = 7'b1111000;
            4'd8: segments = 7'b0000000;
            4'd9: segments = 7'b0010000;
            default: segments = 7'b1111111;
        endcase
    end
endmodule
