`default_nettype none

`timescale 1ns / 1ps

`include "src/abejaruco.v"

module Abejaruco_tb();  
  reg reset;
  Abejaruco uut(.reset(reset));

  initial begin
    reset = 1'b1;
    #2 reset = 1'b0;
    #10 $finish;
  end

endmodule
