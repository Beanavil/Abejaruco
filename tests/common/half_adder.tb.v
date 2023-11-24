`default_nettype none

`include "../../src/common/half_adder.v"

module HalfAdder_tb();
    
    reg a, b;
    wire sum, carry_out;
    
    Half_adder half_adder(
    .a(a),
    .b(b),
    .sum(sum),
    .carry_out(carry_out)
    );
    
    initial begin
        $display("Testing half_adder");
        $display("-------------------------------");
        
        a = 0; b = 0;
        #1
        $display("Test case 1: assert a = 0, b = 0, sum = 0, carry_out = 0");
        if (sum !                       = 0) $display("Failed. Expected sum: 0, Actual: %b", sum);
        if (carry_out !                 = 0) $display("Failed. Expected carry_out: 0, Actual: %b", carry_out);
        
        a = 1; b = 0;
        #1
        $display("Test case 2: assert a = 1, b = 0, sum = 1, carry_out = 0");
        if (sum !                       = 1) $display("Failed. Expected sum: 1, Actual: %b", sum);
        if (carry_out !                 = 0) $display("Failed. Expected carry_out: 0, Actual: %b", carry_out);
        
        a = 0; b = 1;
        #1
        $display("Test case 3: assert a = 0, b = 1, sum = 1, carry_out = 0");
        if (sum !                       = 1) $display("Failed. Expected sum: 1, Actual: %b", sum);
        if (carry_out !                 = 0) $display("Failed. Expected carry_out: 0, Actual: %b", carry_out);
        
        a = 1; b = 1;
        #1
        $display("Test case 4: assert a = 1, b = 1, sum = 1, carry_out = 1");
        if (sum !                       = 1) $display("Failed. Expected sum: 1, Actual: %b", sum);
        if (carry_out !                 = 1) $display("Failed. Expected carry_out: 1, Actual: %b", carry_out);
        $finish;
    end
endmodule
