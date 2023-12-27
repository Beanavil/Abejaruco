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

module Memory #(parameter MEMORY_LOCATIONS = 4096,
                ADDRESS_SIZE = 12,
                WORD_SIZE = 32)
               (input wire clock,
                input wire write_enable,
                input wire read_enable,
                input wire byte_enable,
                input wire half_word_enable,
                input wire word_enable,
                input wire [ADDRESS_SIZE:0] address,
                input wire [WORD_SIZE:0] data_in,
                output reg [WORD_SIZE-1:0] data_out);
    
    logic [MEMORY_LOCATIONS-1:0] memory [7:0];

    always_ff @(posedge clock) begin
        if (write_enable) begin
            if (byte_enable) begin
                memory[address] <= data_in[7:0];
            end
            else if (half_word_enable) begin
                memory[address] <= data_in[7:0];
                memory[address + 1] <= data_in[15:8];
            end
            else if (word_enable) begin
                memory[address] <= data_in[7:0];
                memory[address + 1] <= data_in[15:8];
                memory[address + 2] <= data_in[23:16];
                memory[address + 3] <= data_in[31:24];
            end
        end
        else if (read_enable) begin
            if (byte_enable) begin
                data_out[7:0] <= memory[address][7:0];
            end
            else if (half_word_enable) begin
                data_out[15:0] <= {memory[address + 1][7:0], memory[address][7:0]};
            end 
            else if (word_enable) begin
                data_out <= {memory[address + 3][7:0], memory[address + 2][7:0],
                             memory[address + 1][7:0], memory[address][7:0]};
            end
        end
    end

endmodule
