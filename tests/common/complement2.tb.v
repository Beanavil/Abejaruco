// GNU General Public License
//
// Copyright : (c) 2023 Javier Beiro Piñón
// : (c) 2023 Beatriz Navidad Vilches
// : (c) 2023 Stefano Petrili
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

`include "src/common/complement2.v"

module Complement2_tb;

  parameter N = 32; // Define the bit width for the test
  reg [N-1:0] in;
  wire [N-1:0] out;

  // Instantiate the Two's Complement module (Unit Under Test (UUT))
  Complement2 #(.N(N)) uut (
                .in(in),
                .out(out)
              );

  initial
  begin
    // Monitor changes
    $monitor("Time=%0d, in=%h, out=%h", $time, in, out);

    // Test Case 1: Zero input
    #10;
    $display("Test Case 1: Zero input");
    in = 0; // Zero in N bits
    #10;
    if (out !== 0)
    begin
      $display("Error in Test Case 1 at time %0d", $time);
    end

    // Test Case 2: Positive number
    #10;
    $display("Test Case 2: Positive number");
    in = 1; // Smallest positive number in N bits
    #10;
    if (out !== {N{1'b1}})
    begin
      $display("Error in Test Case 2 at time %0d", $time);
    end

    // Test Case 3: Negative number
    #10;
    $display("Test Case 3: Negative number");
    in = ~0; // Largest negative number in N bits (all 1's)
    #10;
    if (out !== 1)
    begin
      $display("Error in Test Case 3 at time %0d", $time);
    end

    // End of Test
    #10;
    $display("End of Test at time %0d", $time);
    $finish;
  end

endmodule

