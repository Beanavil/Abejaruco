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

module Demux1to2 #(
    parameter N = 32          // Default bit width
  )(
    input [N-1:0] in,
    input sel,                // Selection input
    output reg [N-1:0] out0,
    output reg [N-1:0] out1
  );

  // Always block to update outputs based on selection
  always @(in or sel)
  begin
    if (sel == 1'b0)
    begin
      out0 = in;           // Route input to out0
      out1 = {N{1'b0}};    // Set out1 to 0 (N bits)
    end
    else
    begin
      out0 = {N{1'b0}};    // Set out0 to 0 (N bits)
      out1 = in;           // Route input to out1
    end
  end

endmodule

