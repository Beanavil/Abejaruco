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

`include "src/common/full_adder.v"

module adder #(parameter n = 4)
  (input [n-1:0] a,
   input [n-1:0] b,
   input c_in,
   output [n-1:0] sol,
   output c_out);

  wire [n-1:0] c_part;

  full_adder fa_base(a[0], b[0] ^ c_in, c_in, sol[0], c_part[0]);

  genvar i;
  generate
    for(i = 1; i < n; i = i + 1'b1)
    begin
      full_adder fa(a[i], b[i] ^ c_in, c_part[i-1], sol[i], c_part[i]);
    end
  endgenerate

  assign c_out = c_part[n-1];
endmodule
