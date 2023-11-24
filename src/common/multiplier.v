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

`include "src/common/adder.v"

module multiplier4x4
  (input [3:0] a,
   input [3:0] b,
   output [3:0] sol);
  // if(n < 4)
  wire [7:0] sol_part;
  wire [7:0] c_part;

  genvar i, j;
  generate
    for(i = 0; i < 4; i = i + 1'b1)
    begin
      full_adder fa_base(a[4*(i+1)-1], b[4*(i+1)-1], b[3], sol[0], c_part[0]);
      for(j = 0; j < 3; j = j + 1'b1)
      begin
        full_adder fa(a[4*(j+1)-1], b[4*(j+1)-1], b[3], sol[0], c_part[0]);
      end
    end
  endgenerate
endmodule

module multiplier #(parameter n = 32)
  (input [n-1:0] a,
   input [n-1:0] b,
   output [n-1:0] sol);
  // if(n < 4)
  wire [n-1:0] sol_part;
  wire [n-1:0] c_part;

  genvar i;
  generate
    for(i = 0; i < n; i = i + 1'b1)
    begin
      // adder partial_adder #(n = 4) (a[4*(i+1)-1:4*i], b[4*(i+1)-1:4*i], b[n-1], sol[0], c_part[0]);
    end
  endgenerate
endmodule
