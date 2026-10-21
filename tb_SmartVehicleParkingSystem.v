`timescale 1ns/1ps
module tb_SmartVehicleParkingSystem;
    reg clk=0, reset_n=0, entry_sensor_btn=0, exit_sensor_btn=0;
    reg entry_request_btn=0, exit_request_btn=0;
    wire entry_gate, exit_gate, green_led, red_led;
    wire [6:0] hex0, hex1;
    wire [3:0] spaces;
    integer errors=0, i;
    always #10 clk=~clk; // 50 MHz
    SmartVehicleParkingSystem dut (
        .clk_50MHz(clk), .reset_n(reset_n),
        .entry_sensor_btn(entry_sensor_btn), .exit_sensor_btn(exit_sensor_btn),
        .entry_request_btn(entry_request_btn), .exit_request_btn(exit_request_btn),
        .open_entry_gate_led(entry_gate), .open_exit_gate_led(exit_gate),
        .green_led(green_led), .red_led(red_led),
        .hex0_segments(hex0), .hex1_segments(hex1), .available_spaces(spaces)
    );
    task check;
        input [3:0] expected;
        begin
            #1;
            if (spaces !== expected) begin
                $display("FAIL t=%0t expected=%0d got=%0d", $time, expected, spaces);
                errors=errors+1;
            end
            if (green_led !== (expected!=0) || red_led !== (expected==0)) begin
                $display("FAIL status LEDs at t=%0t",$time); errors=errors+1;
            end
        end
    endtask
    task drive;
        input ent, ext;
        begin
            @(negedge clk);
            entry_sensor_btn=ent; entry_request_btn=ent;
            exit_sensor_btn=ext; exit_request_btn=ext;
            @(posedge clk); #1;
        end
    endtask
    task release_inputs;
        begin
            @(negedge clk);
            entry_sensor_btn=0; entry_request_btn=0;
            exit_sensor_btn=0; exit_request_btn=0;
            @(posedge clk); #1;
        end
    endtask
    initial begin
        $dumpfile("simulation/waveform.vcd"); $dumpvars(0,tb_SmartVehicleParkingSystem);
        repeat(2) @(posedge clk);
        @(negedge clk); reset_n=1;
        check(10);
        if(hex1 !== 7'b1111001 || hex0 !== 7'b1000000) begin
            $display("FAIL initial display for 10"); errors=errors+1;
        end
        drive(1,0); check(9);
        if(!entry_gate) begin $display("FAIL entry gate"); errors=errors+1; end
        // Holding a request must not count repeatedly.
        repeat(5) @(posedge clk);
        check(9); release_inputs;
        drive(0,1); check(10); release_inputs;
        for(i=0;i<10;i=i+1) begin drive(1,0); check(9-i); release_inputs; end
        if(!red_led || green_led) begin $display("FAIL full LEDs"); errors=errors+1; end
        drive(1,0); check(0);
        if(entry_gate) begin $display("FAIL entry accepted when full"); errors=errors+1; end
        release_inputs;
        drive(1,1); check(1);
        if(entry_gate || !exit_gate) begin
            $display("FAIL simultaneous requests at full"); errors=errors+1;
        end
        release_inputs;
        drive(1,1); check(1);
        if(!entry_gate || !exit_gate) begin
            $display("FAIL simultaneous requests with free space"); errors=errors+1;
        end
        release_inputs;
        drive(0,1); check(2); release_inputs;
        // Reset mid-operation and verify full initial occupancy.
        @(negedge clk); reset_n=0; #1; check(10);
        @(negedge clk); reset_n=1;
        repeat(5) @(posedge clk);
        if(entry_gate || exit_gate) begin $display("FAIL gate hold timeout"); errors=errors+1; end
        if(errors==0) $display("PASS: all directed parking tests passed");
        else $display("FAIL: %0d error(s)",errors);
        $finish;
    end
endmodule
