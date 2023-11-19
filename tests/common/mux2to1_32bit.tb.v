`timescale 1ns / 1ps

module mux2to1_32bit_tb;

reg [31:0] in0;
reg [31:0] in1;
reg [1:0] sel;
wire [31:0] out;

// Instantiate the multiplexer module (Unit Under Test (UUT))
mux2to1_32bit uut (
    .in0(in0),
    .in1(in1),
    .sel(sel),
    .out(out)
);

initial begin
    // Monitor changes (each time one of the values changes it will be printed)
    $monitor("Time=%0d, sel=%b, in0=%h, in1=%h, out=%h", $time, sel, in0, in1, out);

    // Initialize Inputs
    in0 = 0;
    in1 = 0;
    sel = 0;

    // Test Case 1: Select input 0
    #10;
    $display("Test Case 1: Select input 0");
    in0 = 32'h00000001;
    in1 = 32'h00000002;
    sel = 1'b0;
    #10;
    if (out !== in0) $display("Error in Test Case 1 at time %0d", $time);

    // Test Case 2: Select input 1
    #10;
    $display("Test Case 2: Select input 1");
    sel = 1'b1;
    #10;
    if (out !== in1) $display("Error in Test Case 2 at time %0d", $time);

    // Test Case 3: Change input 0
    #10;
    $display("Test Case 3: Change input 0");
    sel = 1'b0;
    in0 = 32'h3C3C3C3C;
    #10;
    if (out !== in0) $display("Error in Test Case 3 at time %0d", $time);

    // End of Test
    #10;
    $display("End of Test at time %0d", $time);
    $finish;
end

endmodule
