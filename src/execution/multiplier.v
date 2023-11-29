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

`include "src/common/base_multiplier.v"
`include "src/execution/sum_partial_products.v"

module Multiplier #(parameter WIDTH = 32, NIBBLE_WIDTH = 4)
                   (input wire clock,
                    input wire start_multiplication,
                    input wire [WIDTH-1:0] multiplicand,
                    input wire [WIDTH-1:0] multiplier,
                    output reg [WIDTH-1:0] result);
    
    reg [WIDTH-1:0] partialProduct1 [0:64-1];
    reg [WIDTH-1:0] partialProduct2 [0:32-1];
    reg [WIDTH-1:0] partialProduct3 [0:16-1];
    reg [WIDTH-1:0] multiplierReg;
    reg [WIDTH-1:0] multiplicandReg;
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
    
    always @(posedge clock) begin
        for (i = 0; i < 32; i = i + 1) begin
            partialProduct2[i] = partialProduct1[i * 2] + partialProduct1[(i * 2) + 1];
        end
    end
    
    always @(posedge clock) begin
        for (i = 0; i < 16; i = i + 1) begin
            partialProduct3[i] = partialProduct2[i * 2] + partialProduct2[(i * 2) + 1];
        end
    end
        
    always @(posedge clock) begin
        for (i = 0; i < 8; i = i + 1) begin
            partialProduct3[i] = partialProduct2[i * 2] + partialProduct2[(i * 2) + 1];
        end
    end

    SumPartialProducts #(WIDTH) sumPartialProducts (.clock(clock), .partialProduct3(partialProduct3), .result(result));    
endmodule