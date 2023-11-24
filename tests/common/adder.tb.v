
// GNU General Public License
//
// Copyright : (c) 2023 Javier Beiro Piñón
// : (c) 2023 Beatriz Navidad Vilches
// : (c) 2023 Stefano Petrili
//
// This file is part of Abejaruco <https:// github.com/Beanavil/Abejaruco>.
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
`default_nettype none

`include "src/common/adder.v"

module Adder_tb();

  reg [3:0] a, b;
  reg carry_in;
  wire [3:0] sum;
  wire carry_out;

  Adder #(.WIDTH(4)) adder_instance_4_bit (
          .a(a),
          .b(b),
          .carry_in(carry_in),
          .sum(sum),
          .carry_out(carry_out)
        );

  initial
  begin
    $display("Testing 4bit Adder");
    $display("-------------------------------");

    a = 4'b0000;
    b = 4'b0000;
    carry_in = 0;
    #1
     $display("Test case 1: assert when a = 0000, b = 0000, carry_in = 0, sum = 0000, carry_out = 0");
    if (sum != 4'b0000)
    begin
      $display("Failed. Expected sum: 0000, Actual: %b", sum);
    end
    if (carry_out != 0)
    begin
      $display("Failed. Expected carry_out: 0, Actual: %b", carry_out);
    end

    a = 4'b0100;
    b = 4'b0000;
    carry_in = 0;
    #1
     $display("Test case 2: assert when a = 0100, b = 0000, carry_in = 0, sum = 0100, carry_out = 0");
    if (sum != 4'b0100)
    begin
      $display("Failed. Expected sum: 0100, Actual: %b", sum);
    end
    if (carry_out != 0)
    begin
      $display("Failed. Expected carry_out: 0, Actual: %b", carry_out);
    end

    a = 4'b0100;
    b = 4'b0100;
    carry_in = 0;
    #1
     $display("Test case 3: assert when a = 0100, b = 0100, carry_in = 0, sum = 1000, carry_out = 0");
    if (sum != 4'b1000)
    begin
      $display("Failed. Expected sum: 1000, Actual: %b", sum);
    end
    if (carry_out != 0)
    begin
      $display("Failed. Expected carry_out: 0, Actual: %b", carry_out);
    end

    a = 4'b1000;
    b = 4'b1000;
    carry_in = 0;
    #1
     $display("Test case 4: assert when a = 1000, b = 1000, carry_in = 0, sum = 0000, carry_out = 1");
    if (sum != 4'b0000)
    begin
      $display("Failed. Expected sum: 0000, Actual: %b", sum);
    end
    if (carry_out != 1)
    begin
      $display("Failed. Expected carry_out: 0, Actual: %b", carry_out);
    end

    a = 4'b0000;
    b = 4'b0000;
    carry_in = 1;
    #1
     $display("Test case 5: assert when a = 0000, b = 0000, carry_in = 1, sum = 0001, carry_out = 0");
    if (sum != 4'b0001)
    begin
      $display("Failed. Expected sum: 0001, Actual: %b", sum);
    end
    if (carry_out != 0)
    begin
      $display("Failed. Expected carry_out: 0, Actual: %b", carry_out);
    end

    a = 4'b0001;
    b = 4'b0000;
    carry_in = 1;
    #1
     $display("Test case 6: assert when a = 0001, b = 0000, carry_in = 1, sum = 0010, carry_out = 0");
    if (sum != 4'b0010)
    begin
      $display("Failed. Expected sum: 0001, Actual: %b", sum);
    end
    if (carry_out != 0)
    begin
      $display("Failed. Expected carry_out: 0, Actual: %b", carry_out);
    end
    $finish;
  end
endmodule
