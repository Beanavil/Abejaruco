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

module FlipFlop #(
    parameter N = 32    // Default bit width
  )(
    input clk,
    input reset,
    input [N-1:0] d,
    output reg [N-1:0] q
  );

  // Sequential logic for the register
  /*
      1. Sensitive to posedge of clock
      2. Sensitive to posedge of reset (asynchronous reset)
  */
  always @(posedge clk or posedge reset)
  begin
    if (reset)
    begin
      q <= {N{1'b0}};  // Reset the register to 0 (N bits)
    end
    else
    begin
      q <= d;          // On each clock cycle, store the input data in the register
    end
  end

endmodule
