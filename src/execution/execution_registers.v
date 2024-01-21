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

module ExecutionRegisters (
    // In
    input wire clk,
    input wire [WORD_WIDTH-1:0] instruction_in,
    input wire [WORD_WIDTH-1:0] extended_inmediate_in,
    input wire cu_mem_to_reg_in,
    input wire cu_reg_write_in,
    input [REGISTER_INDEX_WIDTH-1:0] destination_register_in,
    input [WORD_WIDTH-1:0] alu_result_in,
    input alu_zero_in,
    input wire active,
    input wire cu_d_cache_access_in,
    input wire cu_d_cache_op_in,
    input wire second_register_in,
    input wire cu_is_byte_op_in,

    // Out
    output reg [WORD_WIDTH-1:0] instruction_out,
    output reg [WORD_WIDTH-1:0] extended_inmediate_out,
    output reg cu_mem_to_reg_out,
    output reg cu_reg_write_out,
    output reg [REGISTER_INDEX_WIDTH-1:0] destination_register_out,
    output reg [WORD_WIDTH-1:0] alu_result_out,
    output reg alu_zero_out,
    output reg active_out,
    output reg cu_d_cache_access_out,
    output reg cu_d_cache_op_out,
    output reg second_register_out,
    output reg cu_is_byte_op_out,
  );
`include "src/parameters.v"

  initial
  begin
    instruction_out <= 0;
    extended_inmediate_out <= 0;
    cu_mem_to_reg_out <= 0;
    cu_reg_write_out <= 0;
    alu_result_out <= 0;
    alu_zero_out <= 0;
  end

  always @(negedge clk)
  begin
    if (active)
    begin
      instruction_out <= instruction_in;
      extended_inmediate_out <= extended_inmediate_in;
      cu_mem_to_reg_out <= cu_mem_to_reg_in;
      cu_reg_write_out <= cu_reg_write_in;
      destination_register_out <= destination_register_in;
      alu_result_out <= alu_result_in;
      alu_zero_out <= alu_zero_in;
      active_out <= 1'b1;
    end
    else
    begin
      active_out <= 1'b0;
    end
  end

endmodule
