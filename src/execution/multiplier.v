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

module Multiplier #(parameter WIDTH = 32)
                   (input wire clock,
                    input wire start_multiplication,
                    input wire [WIDTH-1:0] multiplicand,
                    input wire [WIDTH-1:0] multiplier,
                    output reg [WIDTH-1:0] result,
                    output reg done);
    
    reg [16:0] partialProduct1 [0:64-1];
    reg [16:0] partialProduct2 [0:64-1];
    reg [WIDTH-1:0] multiplierReg;
    reg [WIDTH-1:0] multiplicandReg;
    integer i, j;
    parameter NIBBLE_WIDTH = 4;
    
    initial begin
        done = 0;
    end
    
    always @(posedge clock) begin
        if (!done) begin
            //TODO it could be if multiplicand or multiplier change instead of receiving an input
            if (start_multiplication) begin
                #10 $display("Update multiplicand and multiplier");
                multiplicandReg <= multiplicand;
                multiplierReg   <= multiplier;
            end
            #10
            for (i = 0; i < WIDTH/NIBBLE_WIDTH; i = i + 1) begin
                for (j = 0; j < WIDTH/NIBBLE_WIDTH; j = j + 1) begin
                    partialProduct1[i*WIDTH/NIBBLE_WIDTH + j] = (multiplicandReg[i*NIBBLE_WIDTH +: NIBBLE_WIDTH]) * (multiplierReg[j*NIBBLE_WIDTH +: NIBBLE_WIDTH]) << (i + j)* 4;
                    #10 $display("The sub register %d multiplies the nibble a = %b, b = %b and resutl in %b", i*WIDTH/NIBBLE_WIDTH + j, multiplicand[i*NIBBLE_WIDTH +: NIBBLE_WIDTH], multiplier[j*NIBBLE_WIDTH +: NIBBLE_WIDTH], partialProduct1[i*WIDTH/NIBBLE_WIDTH + j]);
                end
            end
        end
    end
    
    always @(posedge clock) begin
        result = 32'b0;
        for (i = 0; i < 64; i = i + 1) begin
            result = result + partialProduct1[i];
        end
    end
    
endmodule
