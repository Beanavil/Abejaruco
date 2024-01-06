// GNU General Public License
//
// Copyright : (c) 2024 Javier Beiro Piñón
//           : (c) 2024 Beatriz Navidad Vilches
//           : (c) 2024 Stefano Petrilli
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

module SignExtend(
    input [SIGN_EXTENDER_INPUT_SIZE-1:0] in,
    output [WORD_WIDTH-1:0] out
  );
`include "src/parameters.v"

  localparam EXTEND_SIZE = WORD_WIDTH - SIGN_EXTENDER_INPUT_SIZE;

  assign out = {{EXTEND_SIZE{in[SIGN_EXTENDER_INPUT_SIZE-1]}}, in};
endmodule
