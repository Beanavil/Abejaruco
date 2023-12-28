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

`include "src/common/demux1to2.v"

module Demux1to2_tb;

  parameter N = 32;  // Specify the bit width

  reg [N-1:0] in;
  reg sel;
  wire [N-1:0] out0, out1;

  // Instantiate the Demultiplexer module (Unit Under Test (UUT))
  Demux1to2 #(.N(N)) uut (
              .in(in),
              .sel(sel),
              .out0(out0),
              .out1(out1)
            );

  initial
  begin
    // Monitor changes (each time one of the values changes it will be printed)
    $monitor("Time=%0d, sel=%b, in=%h, out0=%h, out1=%h", $time, sel, in, out0, out1);

    // Initialize Inputs
    in = 0;
    sel = 0;

    // Test Case 1: Select output 0
    #10;
    $display("Test Case 1: Select output 0");
    in = {N{1'b1}}; // Set input to all 1s for N bits
    sel = 1'b0;
    #10;
    if (out0 !== in || out1 !== 0)
    begin
      $display("Error in Test Case 1 at time %0d", $time);
    end

    // Test Case 2: Select output 1
    #10;
    $display("Test Case 2: Select output 1");
    sel = 1'b1;
    #10;
    if (out1 !== in || out0 !== 0)
    begin
      $display("Error in Test Case 2 at time %0d", $time);
    end

    // End of Test
    #10;
    $display("End of Test at time %0d", $time);
    $finish;
  end

endmodule
