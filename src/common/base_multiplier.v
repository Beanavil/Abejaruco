// GNU General Public License
//
// Copyright : (c) 2023 Javier Beiro Piñón
//           : (c) 2023 Beatriz Navidad Vilches
//           : (c) 2023 Stefano Petrili
//
// This file is part of Abejaruco <https://github.com/Beanavil/Abejaruco>.
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
// If not, see <https://www.gnu.org/licenses/>.

`default_nettype none

`include "src/common/adder.v"

module BaseMultiplier #(parameter WIDTH = 4)
  (input [WIDTH - 1:0] a,
   input [WIDTH - 1:0] b,
   output [WIDTH * 2 - 1:0] result);

  initial
  begin
    if (WIDTH > 4)
    begin
      $display("\033[31mMultiplier instantiated with WIDTH > 4. WIDTH = %0d\033[0m", WIDTH);
    end
  end

  wire [WIDTH - 1:0] previous_stage;
  wire carry_out;

  genvar i;
  generate
    for (i = 0; i < WIDTH - 2; i = i + 1)
    begin : bit_loop
      Adder #(.WIDTH(4))
            adder_instance (
              .a(i == 0 ? a & b[i] >> 1 : previous_stage),
              .b(a & b[i + 1]),
              .carry_in(1'b0),
              .sum({carry_out, previous_stage[WIDTH - 1:1]}),
              .carry_out(carry_out)
            );
    end
    assign result = {carry_out, previous_stage, result[WIDTH - 2:0]};
  endgenerate

endmodule
