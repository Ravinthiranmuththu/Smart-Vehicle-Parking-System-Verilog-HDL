`timescale 1ns/1ps

module SmartParking_tb;

    // Inputs
    reg clk;
    reg reset_n;
    reg entry_sensor;
    reg exit_sensor;
    reg entry_request;
    reg exit_request;
    
    // Outputs
    wire open_entry_gate;
    wire open_exit_gate;
    wire led_indicator;
    
    // Instantiate UUT
    SmartParkingSystem uut (
        .clk(clk),
        .reset_n(reset_n),
        .entry_sensor(entry_sensor),
        .exit_sensor(exit_sensor),
        .entry_request(entry_request),
        .exit_request(exit_request),
        .open_entry_gate(open_entry_gate),
        .open_exit_gate(open_exit_gate),
        .led_indicator(led_indicator)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Initialize and apply reset
    initial begin
        reset_n = 0;
        entry_sensor = 0;
        exit_sensor = 0;
        entry_request = 0;
        exit_request = 0;
        #20 reset_n = 1;
    end
    
    // Test sequence
    initial begin
        $dumpfile("SmartParking_tb.vcd");
        $dumpvars(0, SmartParking_tb);
        
        // Test 1: Entry request with space available
        #30;
        entry_sensor = 1;
        entry_request = 1;
        #20;
        entry_sensor = 0;
        entry_request = 0;
        
        // Test 2: Exit request
        #50;
        exit_sensor = 1;
        exit_request = 1;
        #20;
        exit_sensor = 0;
        exit_request = 0;
        
        // Test 3: Fill parking lot
        repeat(10) begin
            #30;
            entry_sensor = 1;
            entry_request = 1;
            #20;
            entry_sensor = 0;
            entry_request = 0;
            #30;
        end
        
        // Test 4: Try to enter when full
        #30;
        entry_sensor = 1;
        entry_request = 1;
        #20;
        entry_sensor = 0;
        entry_request = 0;
        
        // Test 5: Exit when full
        #30;
        exit_sensor = 1;
        exit_request = 1;
        #20;
        exit_sensor = 0;
        exit_request = 0;
        
        #100 $finish;
    end
endmodule
