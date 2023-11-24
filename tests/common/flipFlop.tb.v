`timescale 1ns / 1ps

module flipFlopTb;

parameter N = 32; // Specify the bit width here. Change this to test different widths.

reg clk;
reg reset;
reg [N-1:0] d;
wire [N-1:0] q;

// Instantiate the FlipFlop module (Unit Under Test (UUT))
flipFlop #(.N(N)) uut (
    .clk(clk),
    .reset(reset),
    .d(d),
    .q(q)
);

initial begin
    // Monitor changes (each time one of the values changes it will be printed)
    $monitor("Time=%0d, clk=%b, reset=%b, d=%h, q=%h", $time, clk, reset, d, q);

    // Initialize Inputs
    clk = 0;
    reset = 0;
    d = 0;

    // Wait for the global reset
    #10;
    reset = 0;

    // Test Case 1: Load a value into the register
    #10;
    $display("Test Case 1: Load a value");
    d = {N{1'b1}}; // Set input to all 1s for N bits
    #10;
    if (q !== d) $display("Error in loading value at time %0d", $time);

    // Test Case 2: Check reset functionality
    #10;
    $display("Test Case 2: Reset functionality");
    reset = 1;
    #10;
    reset = 0;
    if (q !== {N{1'b0}}) $display("Error in Reset functionality at time %0d", $time);

    // Test Case 3: Change the value
    #10;
    $display("Test Case 3: Change the value");
    d = {N{1'b0}}; // Set input to all 0s for N bits
    #10;
    if (q !== d) $display("Error in changing value at time %0d", $time);

    // End of Test
    #10;
    $display("End of Test at time %0d", $time);
    $finish;
end

// Each 5 time units the clock will change its value
always #5 clk = ~clk; // Clock with a period of 10ns

endmodule
