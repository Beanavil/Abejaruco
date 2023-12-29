// GNU General Public License
//
// Copyright : (c) 2023 Javier Beiro Piñón
//           : (c) 2023 Beatriz Navidad Vilches
//           : (c) 2023 Stefano Petrili
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

module Abejaruco(input wire reset);
  reg [31:0] r [0:31];
  reg [31:0] rm0 = 32'b1000;
  reg [31:0] rm1;
  reg [31:0] rm2;
  reg clk = 0;

  always #1 clk = ~clk;

  // Instruction cache wires
  wire instruction_cache_op;
  wire instruction_cache_byte_op;
  wire instruction_cache_access;
  wire [31:0] instruction_cache_data_out;
  wire [127:0] instruction_mem_data_in;
  wire instruction_cache_hit;
  wire instruction_cache_miss;

  assign instruction_cache_op = 1;
  assign instruction_cache_byte_op = 0;
  assign instruction_cache_access = 1;
  assign instruction_mem_data_in = 0;
  assign instruction_cache_hit = 0;
  assign instruction_cache_miss = 0;

  // Data cache wires
  wire [31:0] data_cache_data_in;
  wire data_cache_op;
  wire data_cache_byte_op;
  wire data_cache_access;
  wire [127:0] data_mem_out;
  wire [31:0] data_cache_data_out;
  wire [127:0] data_mem_in;
  wire data_cache_hit;
  wire data_cache_miss;

  assign data_cache_op = 1;
  assign data_cache_byte_op = 0;
  assign data_cache_access = 1;
  assign data_mem_in = 0;
  assign data_cache_hit = 0;
  assign data_cache_miss = 0;

  // Common wires
  wire [31:0] mem_address;
  wire mem_read_enable;
  wire mem_write_enable;
  wire [127:0] mem_data_in;
  wire [127:0] mem_data_out;

  assign mem_address = rm0;
  assign mem_read_enable = 0;
  assign mem_write_enable = 0;

  // Instantiations
  Memory #(.MEMORY_LOCATIONS(4096), .ADDRESS_SIZE(32), .CACHE_LINE_SIZE(128)) main_memory (
           .clk(clk),
           .write_enable(mem_write_enable),
           .read_enable(mem_read_enable),
           .address(mem_address),
           .data_in(mem_data_in),
           .data_out(mem_data_out)
         );

  Cache instruction_cache(
          .clk(clk),
          .reset(reset),
          .address(mem_address),
          .data_in('b0),
          .op(instruction_cache_op),
          .byte_op(instruction_cache_byte_op),
          .access(instruction_cache_access),
          .mem_data_out(mem_data_out),
          .data_out(instruction_cache_data_out),
          .mem_data_in(mem_data_in),
          .mem_read_enable(mem_read_enable),
          .mem_write_enable(mem_write_enable),
          .hit(instruction_cache_hit),
          .miss(instruction_cache_miss)
        );

  Cache data_cache(
          .clk(clk),
          .reset(reset),
          .address(mem_address),
          .data_in(data_cache_data_in),
          .op(data_cache_op),
          .byte_op(data_cache_byte_op),
          .access(data_cache_access),
          .mem_data_out(mem_data_out),
          .data_out(data_cache_data_out),
          .mem_data_in(mem_data_in),
          .mem_read_enable(mem_read_enable),
          .mem_write_enable(mem_write_enable),
          .hit(data_cache_hit),
          .miss(data_cache_miss)
        );

  always @(posedge clk)
  begin
    // $display("Instruction cache hit: %b", instruction_cache_hit);
  end
endmodule
