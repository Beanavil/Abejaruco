// GNU General Public License
//
// Copyright : (c) 2023-2024 Javier Beiro Piñón
//           : (c) 2023-2024 Beatriz Navidad Vilches
//           : (c) 2023-2024 Stefano Petrilli
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

module Multiplier
  (
    // In
    input wire clk,
    input wire [WORD_WIDTH-1:0] multiplicand,
    input wire [WORD_WIDTH-1:0] multiplier,

    // Out
    output reg [WORD_WIDTH-1:0] result,
    output reg overflow);

`include "src/parameters.v"

  reg [WORD_WIDTH*2-1:0] internal_result;
  reg [4:0] stages_finished;
  reg [WORD_WIDTH-1:0] partial_product_1 [0:64-1];
  reg [WORD_WIDTH-1:0] partial_product_2 [0:32-1];
  reg [WORD_WIDTH-1:0] partial_product_3 [0:16-1];
  reg [WORD_WIDTH-1:0] partial_product_4 [0:8-1];
  reg [WORD_WIDTH-1:0] multiplier_reg;
  reg [WORD_WIDTH-1:0] multiplicand_reg;
  integer i, j;

  always @(*)
  begin
    multiplicand_reg = multiplicand;
    multiplier_reg = multiplier;
    internal_result = 0;

    for (i = 0; i < WORD_WIDTH/NIBBLE_WIDTH; i = i + 1)
    begin
      for (j = 0; j < WORD_WIDTH/NIBBLE_WIDTH; j = j + 1)
      begin
        partial_product_1[i*WORD_WIDTH/NIBBLE_WIDTH + j] = (multiplicand_reg[i*NIBBLE_WIDTH +: NIBBLE_WIDTH]) * (multiplier_reg[j*NIBBLE_WIDTH +: NIBBLE_WIDTH]) << (i + j)* 4;
      end
    end

    for (i = 0; i < 32; i = i + 1)
    begin
      partial_product_2[i] = partial_product_1[i * 2] + partial_product_1[(i * 2) + 1];
    end

    for (i = 0; i < 16; i = i + 1)
    begin
      partial_product_3[i] = partial_product_2[i * 2] + partial_product_2[(i * 2) + 1];
    end

    for (i = 0; i < 8; i = i + 1)
    begin
      partial_product_4[i] = partial_product_3[i * 2] + partial_product_3[(i * 2) + 1];
    end

    for (i = 0; i < 8; i = i + 1)
    begin
      internal_result = internal_result + partial_product_4[i];
    end

    overflow = |internal_result[63:32];
    result = internal_result[31:0];
  end
endmodule
