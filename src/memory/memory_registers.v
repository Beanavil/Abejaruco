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

module MemoryRegisters (
    // In
    input wire clk,
    input wire [WORD_WIDTH-1:0] instruction_in,
    input wire [WORD_WIDTH-1:0] extended_inmediate_in,
    input wire cu_mem_to_reg_in,
    input wire cu_reg_write_in,
    input wire [REGISTER_INDEX_WIDTH-1:0] destination_register_in,
    input wire data_cache_data_ready_in,
    input wire [WORD_WIDTH-1:0] dst_reg_data_in,
    input wire cu_d_cache_access_in,
    input wire dcache_op_done_in,

    // Out
    output reg [WORD_WIDTH-1:0] instruction_out,
    output reg [WORD_WIDTH-1:0] dst_reg_data_out,
    output reg [WORD_WIDTH-1:0] extended_inmediate_out,
    output reg cu_mem_to_reg_out,
    output reg cu_reg_write_out,
    output reg [REGISTER_INDEX_WIDTH-1:0] destination_register_out,
    output reg data_cache_data_ready_out,
    output reg cu_d_cache_access_out,
    output reg dcache_op_done_out

  );
`include "src/parameters.v"

  initial
  begin
    instruction_out <= 0;
    extended_inmediate_out <= 0;
    cu_mem_to_reg_out <= 0;
    cu_reg_write_out <= 0;
    destination_register_out <= 0;
    dst_reg_data_out <= 0;
    data_cache_data_ready_out <= 0;
    cu_d_cache_access_out <= 0;
    dcache_op_done_out <= 0;
  end

  always @(negedge clk)
  begin
    instruction_out <= instruction_in;
    extended_inmediate_out <= extended_inmediate_in;
    cu_mem_to_reg_out <= cu_mem_to_reg_in;
    cu_reg_write_out <= cu_reg_write_in;
    destination_register_out <= destination_register_in;
    dst_reg_data_out <= dst_reg_data_in;
    data_cache_data_ready_out <= data_cache_data_ready_in;
    cu_d_cache_access_out <= cu_d_cache_access_in;
    dcache_op_done_out <= dcache_op_done_in;
  end
endmodule
