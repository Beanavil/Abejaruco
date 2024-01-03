// GNU General Public License
//
// Copyright : (c) 2023-2024 Javier Beiro Piñón
//           : (c) 2023-2024 Beatriz Navidad Vilches
//           : (c) 2023-2024 Stefano Petrili
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

`default_nettype none

`timescale 1ns / 1ps

module RegisterFile #(parameter WORD_SIZE = 32,
                        parameter NUM_REGS = 32,
                        parameter INDEX_WIDTH = $clog2(NUM_REGS))(
                          input wire clk,
                          input wire enable,
                          input wire reset,
                          input wire [INDEX_WIDTH-1:0] write_idx,
                          input wire [WORD_SIZE-1:0] write_data,
                          input wire [INDEX_WIDTH-1:0] read_idx_1,
                          input wire [INDEX_WIDTH-1:0] read_idx_2,
                          output reg [WORD_SIZE-1:0] read_data_1,
                          output reg [WORD_SIZE-1:0] read_data_2
                        );
  reg [WORD_SIZE-1:0] r[NUM_REGS]; /*registers*/

  always @(posedge clk)
  begin
    if(reset)
    begin
      for(integer i = 0; i < NUM_REGS; i = i + 1)
      begin
        r[i] = 0;
      end
    end
    else if(enable)
    begin
      r[write_idx] <= write_data;
    end
  end

  assign {read_data_1, read_data_2} = {r[read_idx_1], r[read_idx_2]};

endmodule
