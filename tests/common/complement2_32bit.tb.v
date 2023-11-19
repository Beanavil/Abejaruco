`timescale 1ns / 1ps

module twos_complement_32bit_tb;

reg [31:0] in;
wire [31:0] out;

// Instantiate the Two's Complement module (Unit Under Test (UUT))
twos_complement_32bit uut (
    .in(in),
    .out(out)
);

initial begin
    // Monitor changes (each time one of the values changes it will be printed)
    $monitor("Time=%0d, in=%h, out=%h", $time, in, out);

    // Test Case 1: Zero input
    #10;
    $display("Test Case 1: Zero input");
    in = 32'h00000000;
    #10;
    if (out !== 32'h00000000) $display("Error in Test Case 1 at time %0d", $time);

    // Test Case 2: Positive number
    #10;
    $display("Test Case 2: Positive number");
    in = 32'h00000001; // 1
    #10;
    if (out !== 32'hFFFFFFFF) $display("Error in Test Case 2 at time %0d", $time);

    // Test Case 3: Negative number
    #10;
    $display("Test Case 3: Negative number");
    in = 32'hFFFFFFFF; // -1
    #10;
    if (out !== 32'h00000001) $display("Error in Test Case 3 at time %0d", $time);

    // End of Test
    #10;
    $display("End of Test at time %0d", $time);
    $finish;
end

endmodule
