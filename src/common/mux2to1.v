// GNU General Public License
//
// Copyright : (c) 2023-2024 Javier Beiro Piñón
//           : (c) 2023-2024 Beatriz Navidad Vilches
//           : (c) 2023-2024 Stefano Petrilli
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

module Mux2to1 #(
    parameter N = 32    // Default bit
  )(
    input sel,          // Two-bit selection input
    input [N-1:0] in0,
    input [N-1:0] in1,
    output reg [N-1:0] out
  );

  // When any of the inputs change, the output will be updated
  always @(in0, in1, sel)
  begin
    case(sel)
      1'b0:
        out <= in0;        // Select input in0
      1'b1:
        out <= in1;        // Select input in1
      default:
        out <= {N{1'b0}};  // Default case (N-bit 0)
    endcase
  end
endmodule
