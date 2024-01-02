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

module DecodeRegisters #(parameter WORD_SIZE = 32)(
    input wire clk,
    input wire [WORD_SIZE-1:0] rm0_in,
    output reg [WORD_SIZE-1:0] rm0_out,
    input wire [WORD_SIZE-1:0] instruction_in,
    output reg [WORD_SIZE-1:0] instruction_out,
    input wire cu_branch,
    output reg cu_branch_out,
    input wire cu_reg_write,
    output reg cu_reg_write_out,
    input wire cu_mem_read,
    output reg cu_mem_read_out,
    input wire cu_mem_to_reg,
    output reg cu_mem_to_reg_out,
    input wire [1:0] cu_alu_op,
    output reg [1:0] cu_alu_op_out,
    input wire cu_mem_write,
    output reg cu_mem_write_out,
    input wire cu_alu_src,
    output reg cu_alu_src_out
  );

  initial
  begin
    rm0_out = 0;
    instruction_out = 0;
  end

  always @(negedge clk)
  begin
    $display("DecodeRegisters: rm0_in = %h, instruction_in = %h", rm0_in, instruction_in);
    rm0_out = rm0_in;
    instruction_out = instruction_in;
  end
endmodule
