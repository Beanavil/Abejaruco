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

`timescale 1ns / 1ps

module CalculatePartialProduct #(parameter WIDTH = 32, NIBBLE_WIDTH = 4)
                        (input wire clock,
                         input wire [WIDTH-1:0] multiplicand,
                         input wire [WIDTH-1:0] multiplier,
                         output reg [WIDTH-1:0] partialProduct1 [0:64-1],
                         output reg [WIDTH-1:0] multiplicandReg,
                         output reg [WIDTH-1:0] multiplierReg);
    integer i, j;

    always @(posedge clock) begin
        multiplicandReg <= multiplicand;
        multiplierReg <= multiplier;
        for (i = 0; i < WIDTH/NIBBLE_WIDTH; i = i + 1) begin
            for (j = 0; j < WIDTH/NIBBLE_WIDTH; j = j + 1) begin
                partialProduct1[i*WIDTH/NIBBLE_WIDTH + j] = (multiplicandReg[i*NIBBLE_WIDTH +: NIBBLE_WIDTH]) * (multiplierReg[j*NIBBLE_WIDTH +: NIBBLE_WIDTH]) << (i + j)* 4;
            end
        end
    end
endmodule