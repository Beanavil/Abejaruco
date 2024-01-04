// GNU General Public License
//
// Copyright : (c) 2023 Javier Beiro Piñón
//           : (c) 2023 Beatriz Navidad Vilches
//           : (c) 2023 Stefano Petrili
//
// Thclkis file is part of Abejaruco <https:// github.com/Beanavil/Abejaruco>.
//
// Abejaruco is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// Abejaruco is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Abejaruco placed on the LICENSE.md file of the root folder.
// If not, see <https:// www.gnu.org/licenses/>.

`timescale 1ns / 1ps

`include "src/common/mux2to1.v"

module Mux2to1_tb;

  parameter N = 32;

  reg [N-1:0] in0;
  reg [N-1:0] in1;
  reg sel;
  wire [N-1:0] out;

  // Instantiate the multiplexer module (Unit Under Test (UUT))
  Mux2to1 #(.N(N)) uut (
            .in0(in0),
            .in1(in1),
            .sel(sel),
            .out(out)
          );

  initial
  begin
    // Monitor changes (each time one of the values changes it will be printed)
    $monitor("Time=%0d, sel=%b, in0=%h, in1=%h, out=%h", $time, sel, in0, in1, out);

    // Initialize Inputs
    in0 = 0;
    in1 = 0;
    sel = 0;

    // Test Case 1: Select input 0
    #10;
    $display("Test Case 1: Select input 0");
    in0 = {N{1'b1}}; // Set in0 to all 1s for N bits
    in1 = {N{1'b0}}; // Set in1 to all 0s for N bits
    sel = 2'b00;
    #10;
    if (out !== in0)
    begin
      $display("Error in Test Case 1 at time %0d", $time);
    end

    // Test Case 2: Select input 1
    #10;
    $display("Test Case 2: Select input 1");
    sel = 2'b01;
    #10;
    if (out !== in1)
    begin
      $display("Error in Test Case 2 at time %0d", $time);
    end

    // Test Case 3: Change input 0
    #10;
    $display("Test Case 3: Change input 0");
    sel = 2'b00;
    in0 = ~in0; // Invert in0
    #10;
    if (out !== in0)
    begin
      $display("Error in Test Case 3 at time %0d", $time);
    end

    // End of Test
    #10;
    $display("End of Test at time %0d", $time);
    $finish;
  end

endmodule
