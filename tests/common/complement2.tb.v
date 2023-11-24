`timescale 1ns / 1ps

module complement2Tb;

parameter N = 32; // Define the bit width for the test
reg [N-1:0] in;
wire [N-1:0] out;

// Instantiate the Two's Complement module (Unit Under Test (UUT))
complement2 #(.N(N)) uut (
    .in(in),
    .out(out)
);

initial begin
    // Monitor changes
    $monitor("Time=%0d, in=%h, out=%h", $time, in, out);

    // Test Case 1: Zero input
    #10;
    $display("Test Case 1: Zero input");
    in = 0; // Zero in N bits
    #10;
    if (out !== 0) $display("Error in Test Case 1 at time %0d", $time);

    // Test Case 2: Positive number
    #10;
    $display("Test Case 2: Positive number");
    in = 1; // Smallest positive number in N bits
    #10;
    if (out !== {N{1'b1}}) $display("Error in Test Case 2 at time %0d", $time);

    // Test Case 3: Negative number
    #10;
    $display("Test Case 3: Negative number");
    in = ~0; // Largest negative number in N bits (all 1's)
    #10;
    if (out !== 1) $display("Error in Test Case 3 at time %0d", $time);

    // End of Test
    #10;
    $display("End of Test at time %0d", $time);
    $finish;
end

endmodule

