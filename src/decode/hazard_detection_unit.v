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
    input wire [WORD_WIDTH-1:0] execution_instruction,
    input wire [REGISTER_INDEX_WIDTH-1:0] memory_idx_src_dst,
    input wire [WORD_WIDTH-1:0] memory_instruction,
    input wire [REGISTER_INDEX_WIDTH-1:0] rf_write_idx,
    input wire [WORD_WIDTH-1:0] wb_instruction,

    // Out
    output reg stall
  );
`include "src/parameters.v"

  reg [REGISTER_INDEX_WIDTH-1:0] conflict_reg_idx = 0;
  integer case_if; // TODO DEBUG ONLY

  always @(negedge clk)
  begin
    if (decode_op_code === 7'bx)
    begin
      stall <= 0;
      case_if <= 0;
    end
    // If it's a nop don't stall
    else if (decode_op_code == 7'b0110011 & decode_idx_dst == 0 &
             decode_idx_src_1 == 0 & decode_idx_src_2 == 0)
    begin
      stall <= 0;
      case_if <= 1;
    end
    // If it's not the first instruction, detect hazards from execution stage:
    else if (execution_idx_dst != 0)
    begin
      // Instruction already wrote the register in conflict
      if(execution_instruction === wb_instruction)
      begin
        stall <= 0;
        case_if <= 2;
      end
      // Data hazard
      else if ((decode_idx_src_1 == execution_idx_dst ||
                decode_idx_src_2 == execution_idx_dst) & decode_op_code == 7'b0110011)
      begin
        stall <= 1;
        conflict_reg_idx <= execution_idx_dst;
        case_if <= 3;
      end
      // Load-use hazard
      else if (decode_idx_src_1 == execution_idx_dst & decode_op_code == 7'b0000011)
      begin
        stall <= 1;
        conflict_reg_idx <= execution_idx_dst;
        case_if <= 4;
      end
      // Store-use hazard
      else if (decode_idx_src_2 == execution_idx_dst & decode_op_code == 7'b0100011)
      begin
        stall <= 1;
        conflict_reg_idx <= execution_idx_dst;
        case_if <= 5;
      end
      // Jump-use hazard
      else if (decode_idx_src_1 == execution_idx_dst & decode_op_code == 7'b1100111)
      begin
        stall <= 1;
        conflict_reg_idx <= execution_idx_dst;
        case_if <= 6;
      end
      // Branch-use hazard
      else if ((decode_idx_src_1 == execution_idx_dst ||
                decode_idx_src_2 == execution_idx_dst) & decode_op_code == 7'b1100011)
      begin
        stall <= 1;
        conflict_reg_idx <= execution_idx_dst;
        case_if <= 7;
      end
    end
    // If it's not the second instruction, detect hazards from memory stage:
    else if (memory_idx_src_dst != 0)
    begin
      // Instruction already wrote the register in conflict
      if(memory_instruction === wb_instruction)
      begin
        stall <= 0;
        case_if <= 8;
      end
      // Data hazard
      if ((decode_idx_src_1 == memory_idx_src_dst ||
           decode_idx_src_2 == memory_idx_src_dst) & decode_op_code == 7'b0110011)
      begin
        stall <= 1;
        conflict_reg_idx <= memory_idx_src_dst;
        case_if <= 9;
      end
      // Load-use hazard
      else if (decode_idx_src_1 == memory_idx_src_dst & decode_op_code == 7'b0000011)
      begin
        stall <= 1;
        conflict_reg_idx <= memory_idx_src_dst;
        case_if <= 10;
      end
      // Store-use hazard
      else if (decode_idx_src_2 == memory_idx_src_dst & decode_op_code == 7'b0100011)
      begin
        stall <= 1;
        conflict_reg_idx <= memory_idx_src_dst;
        case_if <= 11;
      end
      // Jump-use hazard
      else if (decode_idx_src_1 == memory_idx_src_dst & decode_op_code == 7'b1100111)
      begin
        stall <= 1;
        conflict_reg_idx <= memory_idx_src_dst;
        case_if <= 12;
      end
      // Branch-use hazard
      else if ((decode_idx_src_1 == memory_idx_src_dst ||
                decode_idx_src_2 == memory_idx_src_dst) & decode_op_code == 7'b1100011)
      begin
        stall <= 1;
        conflict_reg_idx <= memory_idx_src_dst;
        case_if <= 13;
      end
    end
    else
    begin
      stall <= 0;
      case_if <= 14;
    end
  end

  always @(rf_write_idx)
  begin
    if (rf_write_idx == conflict_reg_idx)
    begin
      stall <= 0;
      case_if <= 15;
    end
  end
endmodule
