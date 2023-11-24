`default_nettype none

`include "src/common/base_multiplier.v"

module BaseMultiplier_tb();
    
    reg [3:0] a, b;
    wire [7:0] result;
    
    BaseMultiplier #(.WIDTH(4)) multiplier (
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

        a = 4'b1111; b = 4'b0001;
        #1
        $display("Test case 7: assert when a = 1111, b = 0001, result = 00001111");
        if (result != 8'b00001111) $display("Failed. Expected sum: 00001111, Actual: %b", result);

        a = 4'b1001; b = 4'b1001;
        #1
        $display("Test case 8: assert when a = 1001, b = 1001, result = 01100001");
        if (result != 8'b01100001) $display("Failed. Expected sum: 01100001, Actual: %b", result);

        a = 4'b1010; b = 4'b0101;
        #1
        $display("Test case 9: assert when a = 1010, b = 0101, result = 01111110");
        if (result != 8'b01111110) $display("Failed. Expected sum: 01111110, Actual: %b", result);

        a = 4'b1111; b = 4'b1111;
        #1
        $display("Test case 10: assert when a = 1111, b = 1111, result = 11100001");
        if (result != 8'b11100001) $display("Failed. Expected sum: 11100001, Actual: %b", result);

        a = 4'b0110; b = 4'b0010;
        #1
        $display("Test case 11: assert when a = 0110, b = 0010, result = 00001100");
        if (result != 8'b00001100) $display("Failed. Expected sum: 00001100, Actual: %b", result);

        a = 4'b1000; b = 4'b1000;
        #1
        $display("Test case 12: assert when a = 1000, b = 1000, result = 01000000");
        if (result != 8'b01000000) $display("Failed. Expected sum: 01000000, Actual: %b", result);

        a = 4'b1100; b = 4'b0011;
        #1
        $display("Test case 13: assert when a = 1100, b = 0011, result = 00101000");
        if (result != 8'b00101000) $display("Failed. Expected sum: 00101000, Actual: %b", result);

        a = 4'b1010; b = 4'b1010;
        #1
        $display("Test case 14: assert when a = 1010, b = 1010, result = 01100100");
        if (result != 8'b01100100) $display("Failed. Expected sum: 01100100, Actual: %b", result);

        a = 4'b1111; b = 4'b0000;
        #1
        $display("Test case 15: assert when a = 1111, b = 0000, result = 00000000");
        if (result != 8'b00000000) $display("Failed. Expected sum: 00000000, Actual: %b", result);
        $finish;
    end
endmodule
