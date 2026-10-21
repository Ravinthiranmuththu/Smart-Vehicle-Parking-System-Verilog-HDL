module LEDIndicator(
    input [3:0] available_spaces,
    output led_indicator
);

    assign led_indicator = (available_spaces > 0);
endmodule
