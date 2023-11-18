`default_nettype none

`include "../../src/common/adder.v"
`include "../../src/common/multiplier.v"
`include "../../src/common/full_adder.v"
`include "../../src/common/half_adder.v"

module Multiplier_tb();
    
    reg [3:0] a, b;
    wire [7:0] result;
    
    Multiplier #(.WIDTH(4)) multiplier (
    .a(a),
    .b(b),
    .result(result)
    );
    
    initial begin
        $display("Testing 4bit Multiplier");
        $display("-------------------------------");
        
        a = 4'b0000; b = 4'b0000;
        #1
        $display("Test case 1: assert when a = 0000, b = 0000, result = 00000000");
        if (result != 8'b00000000) $display("Failed. Expected sum: 00000000, Actual: %b", result);
        
        a = 4'b0100; b = 4'b0000;
        #1
        $display("Test case 2: assert when a = 0100, b = 0000, result = 00000000");
        if (result != 8'b00000000) $display("Failed. Expected sum: 00000000, Actual: %b", result);

        a = 4'b0100; b = 4'b0001;
        #1
        $display("Test case 3: assert when a = 0100, b = 0001, result = 00000100");
        if (result != 8'b00000100) $display("Failed. Expected sum: 00001000, Actual: %b", result);

        a = 4'b0100; b = 4'b0010;
        #1
        $display("Test case 4: assert when a = 0100, b = 0101, result = 00001000");
        if (result != 8'b00001000) $display("Failed. Expected sum: 00001000, Actual: %b", result);

        a = 4'b0100; b = 4'b0100;
        #1
        $display("Test case 5: assert when a = 0100, b = 0101, result = 00010000");
        if (result != 8'b00010000) $display("Failed. Expected sum: 00010000, Actual: %b", result);

        a = 4'b0011; b = 4'b0011;
        #1
        $display("Test case 6: assert when a = 0011, b = 0011, result = 00001001");
        if (result != 8'b00001001) $display("Failed. Expected sum: 00001001, Actual: %b", result);
        $finish;
    end
endmodule
