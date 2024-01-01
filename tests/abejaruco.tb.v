`default_nettype none

`timescale 1ns / 1ps

`include "src/abejaruco.v"

//TODO I dont know if i see the point of this class
//TODO this is not compiling with the CMAKE I did the test compiling manually 
module Abejaruco_tb();
  reg reset;
  reg clk;

  initial begin
    clk = 0;           // Initialize clk to 0
    reset = 1;         // Assert reset
    #5 reset = 0;      // Deassert reset after 5 ns
  end

  Abejaruco uut(
    .reset(reset),
    .clk(clk)
  );


  integer i;
  initial begin
      for (i = 0; i < 20; i = i + 1) begin
          clk = ~clk;  // Toggle clk
          #5;          // Wait for 5 ns
      end
  end

endmodule

