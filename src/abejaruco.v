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

`include "src/memory/cache.v"
`include "src/memory/memory.v"
`include "src/fetch/fetch_registers.v"
`include "src/decode/control_unit.v"

module Abejaruco #(parameter PROGRAM = "../../programs/random_binary.o")(
    input wire reset,
    input wire clk,
    output wire [31:0] dcache_data_out,
    output wire [1:0] cu_alu_op
  );

  reg [31:0] x0 = 0; /*zero*/
  reg [31:0] r [0:31];
  reg [31:0] rm0 = 32'b1000;
  reg [31:0] rm1;
  reg [31:0] rm2;

  // Data cache wires
  // -- In wires (from CPU)
  reg dcache_access;               // Enable the cache, to it obey the inputs
  reg dcache_reset;
  reg [31:0] dcache_address;
  reg [31:0] dcache_data_in;
  reg dcache_op;
  reg dcache_byte_op;

  // -- In wires (from memory)
  wire dcache_mem_data_ready;
  wire [127:0] dcache_mem_data_out;

  // -- Out wires (to CPU)
  wire dcache_data_ready;
  // wire [31:0] dcache_data_out;

  // -- Out wires (to memory)
  wire dcache_mem_enable;
  wire dcache_mem_op_init;
  wire dcache_mem_op;
  wire [31:0] dcache_mem_address;
  wire [127:0] dcache_mem_data_in;
  wire dcache_op_done;

  // Fetch registers wires
  // -- Out wires
  wire [31:0] fetch_rm0_out;
  wire [31:0] fetch_instruction_out;
  wire fetch_active_out;

  // Control unit wires
  // -- Out wires
  wire cu_branch;
  wire cu_reg_write;
  wire cu_mem_read;
  wire cu_mem_to_reg;
  wire cu_mem_write;
  wire cu_alu_src;

  //TODO cuando se implemente la memoria de instrucciones.
  // Common memory wires
  // -- In wires
  wire mem_enable;
  // wire mem_op;
  // wire [31:0] mem_address;
  // wire [127:0] mem_data_in;
  // wire op_done;
  // // -- Out wires
  // wire [127:0] mem_data_out;
  // wire mem_data_ready;
  wire memory_in_use;

  // Inital values modules not active
  assign dcache_reset = 0;
  assign dcache_address = rm0;
  assign dcache_op = 1'b1;
  assign dcache_access = 1'b1;
  assign dcache_data_in = dcache_mem_data_out;
  assign dcache_byte_op = 1'b0;

  // Instantiations
  Memory #(.MEMORY_LOCATIONS(4096), .ADDRESS_SIZE(32), .CACHE_LINE_SIZE(128)) main_memory (
           //IN
           .clk(clk),
           .enable(dcache_mem_enable),
           .op(dcache_mem_op),
           .address(dcache_mem_address),
           .data_in(dcache_mem_data_in),
           .op_init(dcache_mem_op_init),
           .op_done(dcache_op_done),

           //OUT
           .data_out(dcache_mem_data_out),
           .data_ready(dcache_mem_data_ready),
           .memory_in_use(memory_in_use)
         );

  Cache data_cache(
          //IN (from CPU)
          .clk(clk),
          .reset(dcache_reset),
          .access(dcache_access),
          .address(dcache_address),
          .data_in(dcache_data_in),
          .op(dcache_op),
          .byte_op(dcache_byte_op),

          //IN (from memory)
          .mem_data_ready(dcache_mem_data_ready),
          .mem_data_out(dcache_mem_data_out),
          .memory_in_use(memory_in_use),

          //OUT (to CPU)
          .data_out(dcache_data_out),
          .data_ready(dcache_data_ready),

          //OUT (to memory)
          .mem_op_init(dcache_mem_op_init),
          .mem_enable(dcache_mem_enable),
          .mem_op(dcache_mem_op),
          .mem_op_done(dcache_op_done),
          .mem_address(dcache_mem_address),
          .mem_data_in(dcache_mem_data_in)
        );

  FetchRegisters #(.WORD_SIZE(32)) fetch_registers(
          //IN
          .clk(clk),
          .rm0_in(rm0),
          .instruction_in(dcache_data_out),
          .active(dcache_op_done),

          //OUT
          .rm0_out(fetch_rm0_out),
          .instruction_out(fetch_instruction_out),
          .active_out(fetch_active_out)
        );

  ControlUnit control_unit(
          //IN
          .opcode(fetch_instruction_out[6:0]),

          //OUT
          .reg_write(cu_reg_write),
          .mem_read(cu_mem_read),
          .mem_to_reg(cu_mem_to_reg),
          .alu_op(cu_alu_op),
          .mem_write(cu_mem_write),
          .alu_src(cu_alu_src)
        );

  always @(posedge clk)
  begin
    if (dcache_op_done)
    begin
      rm0 = rm0 + 3'b100;
    end

    $display("Fetch stage values: rm0 = %h, instruction = %h", fetch_rm0_out, fetch_instruction_out);
    if (fetch_active_out) begin
      $display("Control unit values: branch = %b, reg_write = %b, mem_read = %b, mem_to_reg = %b, alu_op = %b, mem_write = %b, alu_src = %b", cu_branch, cu_reg_write, cu_mem_read, cu_mem_to_reg, cu_alu_op, cu_mem_write, cu_alu_src);
    end
  end
endmodule
