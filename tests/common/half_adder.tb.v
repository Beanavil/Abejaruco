// GNU General Public License
//
// Copyright : (c) 2023 Javier Beiro Piñón
//           : (c) 2023 Beatriz Navidad Vilches
//           : (c) 2023 Stefano Petrilli
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

`default_nettype none

`include "src/common/half_adder.v"

module HalfAdder_tb();

  reg a, b;
  wire sum, carry_out;

  HalfAdder half_adder(
              .a(a),
              .b(b),
              .sum(sum),
              .carry_out(carry_out)
            );

  initial
  begin
    $display("Testing half_adder");
    $display("-------------------------------");

    a = 0;
    b = 0;
    #1
     $display("Test case 1: assert a = 0, b = 0, sum = 0, carry_out = 0");
    if (sum != 0)
    begin
      $display("Failed. Expected sum: 0, Actual: %b", sum);
    end
    if (carry_out != 0)
    begin
      $display("Failed. Expected carry_out: 0, Actual: %b", carry_out);
    end

    a = 1;
    b = 0;
    #1
     $display("Test case 2: assert a = 1, b = 0, sum = 1, carry_out = 0");
    if (sum != 1)
    begin
      $display("Failed. Expected sum: 1, Actual: %b", sum);
    end
    if (carry_out != 0)
    begin
      $display("Failed. Expected carry_out: 0, Actual: %b", carry_out);
    end

    a = 0;
    b = 1;
    #1
     $display("Test case 3: assert a = 0, b = 1, sum = 1, carry_out = 0");
    if (sum != 1)
    begin
      $display("Failed. Expected sum: 1, Actual: %b", sum);
    end
    if (carry_out != 0)
    begin
      $display("Failed. Expected carry_out: 0, Actual: %b", carry_out);
    end

    a = 1;
    b = 1;
    #1
     $display("Test case 4: assert a = 1, b = 1, sum = 1, carry_out = 1");
    if (sum != 1)
    begin
      $display("Failed. Expected sum: 1, Actual: %b", sum);
    end
    if (carry_out != 1)
    begin
      $display("Failed. Expected carry_out: 1, Actual: %b", carry_out);
    end
    $finish;
  end
endmodule
