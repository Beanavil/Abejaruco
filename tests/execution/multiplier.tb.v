`default_nettype none

`timescale 1ns / 1ps

`include "src/execution/multiplier.v"

module Multiplier_tb();
    reg clock;
    reg start_multiplication;
    reg [31:0] multiplicand, multiplier;
    wire [31:0] result;
    wire done;
    
    Multiplier #(32) uut (
    .clock(clock),
    .start_multiplication(start_multiplication),
    .multiplicand(multiplicand),
    .multiplier(multiplier),
    .result(result),
    .done(done)
    );

    initial begin
        $display("Testing multiple stage Multiplier");
        $display("-------------------------------");
        clock = 0;
        start_multiplication = 0;
        multiplicand = 0;
        multiplier = 0;
         
        #10;
        clock = 1;
        start_multiplication = 1;
        multiplicand = 32'b00000000000000000000000011111111;
        multiplier = 32'b00000000000000000000000000000011;


        #1000;
        clock = 0;
        start_multiplication = 0;
        #1000;
        clock = 1;

        #1000;
        clock = 0;

        #1000;
        clock = 1;

        #1000;
        clock = 0;

        #1000;
        clock = 1;

        #1000;
        clock = 0;

        #1000;
        clock = 1;

        #1000;
        $display("result = %b", result);
        $finish;

    end
endmodule
