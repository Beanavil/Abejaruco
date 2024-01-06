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


module flipFlop (
    input clk,
    input reset,
    input [WORD_SIZE-1:0] d,
    output reg [WORD_SIZE-1:0] q
  );
`include "src/parameters.v"

  always @(posedge clk or posedge reset)
  begin
    if (reset)
    begin
      q <= {WORD_SIZE{1'b0}};  // Reset the register to 0 (WORD_SIZE bits)
    end
    else
    begin
      q <= d;          // On each clock cycle, store the input data in the register
    end
  end

endmodule
