module ParkingSpaceManagement(
    input clk,
    input reset_n,
    input entry_signal,
    input exit_signal,
    output reg [3:0] available_spaces
);

    parameter CAPACITY = 10;
    parameter INITIAL_SPACES = 10;

    // Edge detection for entry/exit signals
    reg entry_signal_prev, exit_signal_prev;
    wire entry_pulse = entry_signal && !entry_signal_prev;
    wire exit_pulse = exit_signal && !exit_signal_prev;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            available_spaces <= INITIAL_SPACES;
            entry_signal_prev <= 0;
            exit_signal_prev <= 0;
        end
        else begin
            entry_signal_prev <= entry_signal;
            exit_signal_prev <= exit_signal;
            
            // Update available spaces
            if (entry_pulse && (available_spaces > 0))
                available_spaces <= available_spaces - 1;
            else if (exit_pulse && (available_spaces < CAPACITY))
                available_spaces <= available_spaces + 1;
        end
    end
endmodule
