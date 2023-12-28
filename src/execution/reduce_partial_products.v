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

module ReducePartialProducts #(parameter WIDTH = 32, INPUT_COUNT = 32)
                                 (input wire clock,
                                  input wire [WIDTH-1:0] inputPartialProducts [0:INPUT_COUNT-1],
                                  output reg [WIDTH-1:0] outputPartialProducts [0:INPUT_COUNT/2-1]);
    integer i;

    always @(posedge clock) begin
        for (i = 0; i < INPUT_COUNT/2; i = i + 1) begin
            outputPartialProducts[i] = inputPartialProducts[i * 2] + inputPartialProducts[(i * 2) + 1];
        end
    end
endmodule
