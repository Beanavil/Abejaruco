// GNU General Public License
//
// Copyright : (c) 2023 Javier Beiro Piñón
//           : (c) 2023 Beatriz Navidad Vilches
//           : (c) 2023 Stefano Petrilli
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

`include "src/common/full_adder.v"

module Adder #(parameter WIDTH = 8)
  (input [WIDTH-1:0] a,
   input [WIDTH-1:0] b,
   input carry_in,
   output [WIDTH-1:0] sum,
   output carry_out);

  wire [WIDTH - 1:0] carry;

  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i + 1)
    begin : bit_loop
      FullAdder full_adder_instance (
                  .a(a[i]),
                  .b(b[i]),
                  .carry_in(i == 0 ? carry_in : carry[i-1]),
                  .sum(sum[i]),
                  .carry_out(carry[i])
                );
    end
  endgenerate
  assign carry_out = carry[WIDTH - 1];
endmodule
