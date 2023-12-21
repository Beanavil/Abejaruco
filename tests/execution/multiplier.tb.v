`default_nettype none

`timescale 1ns / 1ps

`include "src/execution/multiplier.v"

module Multiplier_tb();
    reg clock;
    reg start_multiplication;
    reg [31:0] multiplicand, multiplier;
    wire [31:0] result;
    integer i;

    Multiplier #(32) uut (
    .clock(clock),
    .start_multiplication(start_multiplication),
    .multiplicand(multiplicand),
    .multiplier(multiplier),
    .result(result)
    );

    initial begin
        $display("Testing multiple stage Multiplier");
        $display("-------------------------------");
        clock = 0;

        start_multiplication = 0;
        multiplicand = 0;
        multiplier = 0;
        
        #1;
        clock = 1;
        start_multiplication = 1;
        multiplicand = 32'h000000FF;
        multiplier = 32'h00000083;

        #1;
        start_multiplication = 0;
        clock = 0;

        for (i = 0; i < 4; i = i + 1) begin
            #1 clock = ~clock;
            #1 clock = ~clock;
        end

        $display("Test case 1: assert when multiplicand = 32'h000000FF, multiplier = 32'h00000083, result should be 32'h0000827D");
        if (result !== 32'h0000827D) $display("Failed. Expected result: 32'h0000827D, Actual: %b", result);
        else $display("Failed. Expected result: 32'h0000827D, Actual: %b", result);
        
        clock = 1;
        start_multiplication = 1;
        multiplicand = 32'h000000AA;
        multiplier = 32'h000000BB;
        #1;
        start_multiplication = 0;
        clock = 0;
        for (i = 0; i < 4; i = i + 1) begin
            #1 clock = ~clock;
            #1 clock = ~clock;
        end
        $display("Test case 2: assert when multiplicand = 32'h000000AA, multiplier = 32'h000000BB, result should be 32'h00007c2e");
        if (result !== 32'h00007c2e) $display("Failed. Expected result: 32'h00007c2e, Actual: %h", result);
        else $display("Passed. Expected result: 32'h00007c2e, Actual: %h", result);

        clock = 1;
        start_multiplication = 1;
        multiplicand = 32'h00001FFF;
        multiplier = 32'h00001FFF;
        #1;
        start_multiplication = 0;
        clock = 0;
        for (i = 0; i < 4; i = i + 1) begin
            #1 clock = ~clock;
            #1 clock = ~clock;
        end
        $display("Test case 3: assert when multiplicand = 32'h00001FFF, multiplier = 32'h00001FFF, result should be 32'h03ffc001");
        if (result !== 32'h03ffc001) $display("Failed. Expected result: 32'h03ffc001, Actual: %h", result);
        else $display("Passed. Expected result: 32'h03ffc001, Actual: %h", result);
        
        $finish;
    end
endmodule
