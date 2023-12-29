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

// TODO: handle synchronization between caches
module Memory #(parameter MEMORY_LOCATIONS = 4096,
                  ADDRESS_SIZE = 12,
                  CACHE_LINE_SIZE = 128)
  (input wire clk,
   input wire write_enable,
   input wire read_enable,
   input wire [ADDRESS_SIZE-1:0] address,
   input wire [CACHE_LINE_SIZE-1:0] data_in,
   output reg [CACHE_LINE_SIZE-1:0] data_out,
   output reg data_ready);

  reg [7:0] memory [0:MEMORY_LOCATIONS-1];

  always_ff @(posedge clk)
            begin
              integer i;
              if (write_enable)
              begin
                for (i = 0; i < CACHE_LINE_SIZE / 8; i = i + 1)
                begin
                  memory[address + i] <= data_in[i*8 +: 8];
                end
              end
              else if (read_enable)
              begin
                for (i = 0; i < CACHE_LINE_SIZE / 8; i = i + 1)
                begin
                  data_out[i*8 +: 8] = memory[address + i];
                end
              end
            end
          endmodule
