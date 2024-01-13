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

`default_nettype none

//Condiciones:
//1. Si el registro salida de ext es igual al registro entrada de id (y ex no ha terminado)

module HazardDetectionUnit
  (
    // In
    input wire clk,
    input wire [REGISTER_INDEX_WIDTH-1:0] decode_idx_src_1,
    input wire [REGISTER_INDEX_WIDTH-1:0] decode_idx_src_2,
    input wire [REGISTER_INDEX_WIDTH-1:0] execution_idx_dst,
    input wire alu_op_done,
    input wire [REGISTER_INDEX_WIDTH-1:0] memory_idx_src_dst,
    input wire mem_op_done,

    // Out
    output reg stall
  );
`include "src/parameters.v"

  always @(posedge clk)
  begin
    // If execution result or memory load writes in register 0 don't stall cause it's a nop.
    if (~execution_idx_dst || ~memory_idx_src_dst)
    begin
      stall = 0;
    end
    // Data hazard
    else if ((decode_idx_src_1 == execution_idx_dst || decode_idx_src_2 == execution_idx_dst) && alu_op_done == 0)
    begin
      stall = 1;
    end
    // Load-use hazard
    else if ((decode_idx_src_1 == memory_idx_src_dst || decode_idx_src_2 == memory_idx_src_dst) && mem_op_done == 0)
    begin
      stall = 1;
    end
    // Store-use hazard
    else if ((decode_idx_src_1 == execution_idx_dst) && alu_op_done == 0)
    begin
      stall = 1;
    end
    else
    begin
      stall = 0;
    end
    `HAZARD_DETECTION_UNIT_DISPLAY($sformatf("[ HAZARD DETECT UNIT ] - decode_idx_src_1: %h, decode_idx_src_2 %h, execution_idx_dst %h, memory_idx_src_dst %h, alu_op_done %h, mem_op_done %h => stall %h",
                                   decode_idx_src_1, decode_idx_src_2, execution_idx_dst,
                                   memory_idx_src_dst, alu_op_done, mem_op_done, stall));

  end

endmodule

