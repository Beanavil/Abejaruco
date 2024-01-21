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
    input wire [6:0] decode_op_code,
    input wire [REGISTER_INDEX_WIDTH-1:0] decode_idx_src_1,
    input wire [REGISTER_INDEX_WIDTH-1:0] decode_idx_src_2,
    input wire [REGISTER_INDEX_WIDTH-1:0] decode_idx_dst,
    input wire [REGISTER_INDEX_WIDTH-1:0] execution_idx_dst,
    input wire [REGISTER_INDEX_WIDTH-1:0] memory_idx_src_dst,
    input wire [REGISTER_INDEX_WIDTH-1:0] rf_write_idx,

    // Out
    output reg stall
  );
`include "src/parameters.v"

  reg [REGISTER_INDEX_WIDTH-1:0] conflict_reg_idx = 0;
  integer case_if; // TODO DEBUG ONLY

  always @(*)
  begin
    if (decode_op_code === 7'bx)
    begin
      stall <= 0;
      case_if <= 99;
    end
    // If it's a nop don't stall
    else if (decode_op_code == 7'b0110011 & decode_idx_dst == 0 &
             decode_idx_src_1 == 0 & decode_idx_src_2 == 0)
    begin
      stall <= 0;
      case_if <= 0;
    end
    // If it's not the first instruction:
    else if (execution_idx_dst != 0)
    begin
      // Data hazard from execution stage
      if ((decode_idx_src_1 == execution_idx_dst ||
              decode_idx_src_2 == execution_idx_dst) & decode_op_code == 7'b0110011)
      begin
        stall <= 1;
        conflict_reg_idx <= execution_idx_dst;
        case_if <= 1;
      end
      // Load-use hazard from execution stage
      else if (decode_idx_src_1 == execution_idx_dst & decode_op_code == 7'b0000011)
      begin
        stall <= 1;
        conflict_reg_idx <= execution_idx_dst;
        case_if <= 3;
      end
      // Store-use hazard from execution stage
      else if (decode_idx_src_2 == execution_idx_dst & decode_op_code == 7'b0100011)
      begin
        stall <= 1;
        conflict_reg_idx <= execution_idx_dst;
        case_if <= 3;
      end
      else if (decode_idx_src_1 == execution_idx_dst & decode_op_code == 7'b1100111)
      begin
        stall <= 1;
        conflict_reg_idx <= decode_idx_src_1;
        case_if <= 4;
      end
    end
    // If it's not the second instruction:
    else if (memory_idx_src_dst != 0)
    begin
      // Data hazard from memory stage
      if ((decode_idx_src_1 == memory_idx_src_dst ||
              decode_idx_src_2 == memory_idx_src_dst) & decode_op_code == 7'b0110011)
      begin
        stall <= 1;
        conflict_reg_idx <= memory_idx_src_dst;
        case_if <= 5;
      end
      // Load-use hazard from memory stage
      else if (decode_idx_src_1 == memory_idx_src_dst & decode_op_code == 7'b0000011)
      begin
        stall <= 1;
        conflict_reg_idx <= memory_idx_src_dst;
        case_if <= 6;
      end
      // Store-use hazard from memory stage
      else if (decode_idx_src_2 == memory_idx_src_dst & decode_op_code == 7'b0100011)
      begin
        stall <= 1;
        conflict_reg_idx <= memory_idx_src_dst;
        case_if <= 7;
      end
      else if (decode_idx_src_1 == memory_idx_src_dst & decode_op_code == 7'b1100111)
      begin
        stall <= 1;
        conflict_reg_idx <= execution_idx_dst;
        case_if <= 8;
      end
    end
    else
    begin
      stall <= 0;
      case_if <= 100;
    end
    `HAZARD_DETECTION_UNIT_DISPLAY($sformatf("Decode_idx_src_1: %b, decode_idx_src_2 %b, execution_idx_dst %b, memory_idx_src_dst %b, alu_op_done %b, mem_op_done %b => stall %h",
                                   decode_idx_src_1, decode_idx_src_2, execution_idx_dst,
                                   memory_idx_src_dst, alu_op_done, mem_op_done, stall));
  end

  always @(rf_write_idx)
  begin
    if (rf_write_idx == conflict_reg_idx)
    begin
      stall <= 0;
    end
  end
endmodule
