// GNU General Public License
//
// Copyright : (c) 2023-2024 Javier Beiro Piñón
//           : (c) 2023-2024 Beatriz Navidad Vilches
//           : (c) 2023-2024 Stefano Petrilli
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

module DecodeRegisters(
    // In
    input wire clk,
    input wire [WORD_WIDTH-1:0] rm0_in,
    input wire [WORD_WIDTH-1:0] instruction_in,
    input wire [REGISTER_INDEX_WIDTH-1:0] destination_register_in,
    input wire [WORD_WIDTH-1:0] first_input_in,
    input wire [WORD_WIDTH-1:0] second_input_in,
    input wire cu_branch_in,
    input wire cu_reg_write_in,
    // input wire cu_mem_read_in,
    // input wire cu_mem_to_reg_in,
    // input wire cu_mem_write_in,
    input wire [1:0] cu_alu_op_in,
    input wire cu_alu_src_in,
    input wire cu_is_imm_in,

    input wire cu_d_cache_access_in,
    input wire cu_d_cache_op_in,
    input wire cu_is_byte_op_in,


    input wire [REGISTER_INDEX_WIDTH-1:0] src_address_in,
    input wire [REGISTER_INDEX_WIDTH-1:0] dst_address_in,
    input wire [OFFSET_SIZE-1:0] offset_in,
    input wire stall_in,
    input wire execution_empty,
    input wire set_nop,

    // Out
    output reg [WORD_WIDTH-1:0] rm0_out,
    output reg [WORD_WIDTH-1:0] instruction_out,
    output reg [REGISTER_INDEX_WIDTH-1:0] destination_register_out,
    output reg [WORD_WIDTH-1:0] first_input_out,
    output reg [WORD_WIDTH-1:0] second_input_out,
    output reg cu_branch_out,
    output reg cu_reg_write_out,
    // output reg cu_mem_read_out,
    // output reg cu_mem_to_reg_out,
    // output reg cu_mem_write_out,
    output reg cu_d_cache_access_out,
    output reg cu_d_cache_op_out,
    output reg cu_is_byte_op_out,

    output reg [1:0] cu_alu_op_out,
    output reg cu_alu_src_out,
    output reg cu_is_imm_out,
    // output reg cu_is_mul_out,
    output reg [REGISTER_INDEX_WIDTH-1:0] src_address_out,
    output reg [REGISTER_INDEX_WIDTH-1:0] dst_address_out,
    output reg [OFFSET_SIZE-1:0] offset_out
  );
`include "src/parameters.v"

  initial
  begin
    rm0_out = 0;
    instruction_out = 0;
    cu_reg_write_out = 0;
  end

  always @(negedge clk)
  begin
    if(set_nop === 1)
    begin
      update_registers_to_nop;
    end
    else if(~stall_in & execution_empty)
    begin
      update_registers;
    end
  end
  task update_registers;
    begin
      rm0_out <= rm0_in;
      instruction_out <= instruction_in;
      destination_register_out <= destination_register_in;
      first_input_out <= first_input_in;
      second_input_out <= second_input_in;
      cu_branch_out <= cu_branch_in;
      cu_reg_write_out <= cu_reg_write_in;
      // cu_mem_read_out <= cu_mem_read_in;
      // cu_mem_to_reg_out <= cu_mem_to_reg_in;
      cu_alu_op_out <= cu_alu_op_in;
      cu_alu_src_out <= cu_alu_src_in;
      // cu_mem_write_out <= cu_mem_write_in;
      cu_d_cache_access_out <= cu_d_cache_access_in;
      cu_d_cache_op_out <= cu_d_cache_op_in;
      cu_is_imm_out <= cu_is_imm_in;
      // cu_is_mul_out <= is_mul_in;
      src_address_out <= src_address_in;
      dst_address_out <= dst_address_in;
      offset_out <= offset_in;
    end
  endtask

  task update_registers_to_nop;
    begin
      rm0_out <= rm0_in;
      instruction_out <= NOP_INSTRUCTION;
      destination_register_out <= 0;
      first_input_out <= 0;
      second_input_out <= 0;
      cu_branch_out <= 0;
      cu_reg_write_out <= 0;
      // cu_mem_read_out <= cu_mem_read_in;
      // cu_mem_to_reg_out <= cu_mem_to_reg_in;
      cu_alu_op_out <= cu_alu_op_in;
      cu_alu_src_out <= cu_alu_src_in;
      // cu_mem_write_out <= cu_mem_write_in;
      cu_d_cache_access_out <= 0;
      cu_d_cache_op_out <= 0;
      cu_is_imm_out <= cu_is_imm_in;
      // cu_is_mul_out <= 0;
      src_address_out <= src_address_in;
      dst_address_out <= dst_address_in;
      offset_out <= offset_in;
    end
  endtask
endmodule
