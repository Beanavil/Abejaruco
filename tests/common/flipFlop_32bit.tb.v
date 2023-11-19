//Define the time unit (#5 would be equal to 5ns)
`timescale 1ns / 1ps

module flipFlop_32bit_tb;

reg clk;
reg reset;
reg [31:0] d;
wire [31:0] q;

// Instantiate the FlipFlop module (Unit Under Test (UUT))
flipFlop_32bit uut (
    .clk(clk),
    .reset(reset),
    .d(d),
    .q(q)
);

initial begin
    // Monitor changes (each time on of the values changes it will be printed)
    $monitor("Time=%0d, clk=%b, reset=%b, d=%h, q=%h", $time, clk, reset, d, q);

    // Initialize Inputs
    clk = 0;
    reset = 0;
    d = 0;

    // Wait for the global reset
    #100;
    reset = 0;

    // Test Case 1: Check reset functionality
    #10;
    $display("Test Case 1: Reset functionality");
    reset = 1;
    #10;
    reset = 0;
    if (q !== 32'b0) $display("Error in Reset functionality at time %0d", $time);

    // Test Case 2: Load a value into the register
    #10;
    $display("Test Case 2: Load a value");
    d = 32'hA5A5A5A5;
    #10;
    if (q !== 32'hA5A5A5A5) $display("Error in loading value at time %0d", $time);

    // Test Case 3: Change the value
    #10;
    $display("Test Case 3: Change the value");
    d = 32'h5A5A5A5A;
    #10;
    if (q !== 32'h5A5A5A5A) $display("Error in changing value at time %0d", $time);

    // End of Test
    #10;
    $display("End of Test at time %0d", $time);
    $finish;
end

// Each 5 time units the clock will change its value
always #5 clk = ~clk; // Clock with a period of 10ns

endmodule
