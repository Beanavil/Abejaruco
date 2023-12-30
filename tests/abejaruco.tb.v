`default_nettype none

`timescale 1ns / 1ps

`include "src/abejaruco.v"

module Abejaruco_tb();  
  reg reset;
  reg clk;

  Abejaruco uut(.reset(reset), .clk(clk));

  initial begin
    clk = 1'b0;
    reset = 1'b1;

    #10 reset = 1'b0;
    clk = 1'b1;

    #10 clk = 1'b0;
    #10 clk = 1'b1;
    #10 clk = 1'b0;
    #10 clk = 1'b1;
  end

endmodule
