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

module Abejaruco #(parameter PROGRAM = "../../programs/random_binary.o")(input wire reset, input wire clk);
  reg [31:0] r [0:31];
  reg [31:0] rm0 = 32'b1000;
  reg [31:0] rm1;
  reg [31:0] rm2;

  // Instruction cache wires
  wire instruction_cache_op;
  wire instruction_cache_byte_op;
  wire instruction_cache_access;
  wire [31:0] instruction_cache_data_out;
  wire [127:0] instruction_mem_data_in;
  wire instruction_cache_hit;
  wire instruction_cache_data_ready;

  assign instruction_cache_op = 1;
  assign instruction_cache_byte_op = 0;
  assign instruction_cache_access = 1;
  assign instruction_mem_data_in = 0;
  assign instruction_cache_hit = 0;
  assign instruction_cache_data_ready = 0;

  // Data cache wires
  wire [31:0] data_cache_data_in;
  wire data_cache_op;
  wire data_cache_byte_op;
  wire data_cache_access;
  wire [127:0] data_mem_out;
  wire [31:0] data_cache_data_out;
  wire [127:0] data_mem_in;
  wire data_cache_hit;
  wire data_cache_data_ready;

  assign data_cache_op = 1;
  assign data_cache_byte_op = 0;
  assign data_cache_access = 1;
  assign data_mem_in = 0;
  assign data_cache_hit = 0;
  assign data_cache_data_ready = 0;

  // Common wires
  wire mem_enable;
  wire mem_op;
  wire [31:0] mem_address;
  wire [127:0] mem_data_in;
  wire [127:0] mem_data_out;
  wire mem_data_ready;

  assign mem_enable = 0;
  assign mem_op = 0;
  assign mem_address = rm0;
  assign mem_data_ready = 0;

  // Instantiations
  Memory #(.MEMORY_LOCATIONS(4096), .ADDRESS_SIZE(32), .CACHE_LINE_SIZE(128)) main_memory (
           .clk(clk),
           .enable(mem_enable),
           .op(mem_op),
           .address(mem_address),
           .data_in(mem_data_in),
           .data_out(mem_data_out),
           .data_ready(mem_data_ready)
         );

  Cache instruction_cache(
          .clk(clk),
          .reset(reset),
          .address(mem_address),
          .data_in('b0),
          .op(instruction_cache_op),
          .byte_op(instruction_cache_byte_op),
          .access(instruction_cache_access),
          .mem_data_ready(mem_data_ready),
          .mem_data_out(mem_data_out),
          .data_out(instruction_cache_data_out),
          .mem_data_in(mem_data_in),
          .mem_enable(mem_enable),
          .mem_op(mem_op),
          .hit(instruction_cache_hit),
          .data_ready(instruction_cache_data_ready)
        );

  // Cache data_cache(
  //         .clk(clk),
  //         .reset(reset),
  //         .address(mem_address),
  //         .data_in(data_cache_data_in),
  //         .op(data_cache_op),
  //         .byte_op(data_cache_byte_op),
  //         .access(data_cache_access),
  //         .mem_data_ready(mem_data_ready),
  //         .mem_data_out(mem_data_out),
  //         .data_out(data_cache_data_out),
  //         .mem_data_in(mem_data_in),
  //         .mem_op(mem_op),
  //         .mem_enable(mem_enable),
  //         .hit(data_cache_hit),
  //         .data_ready(data_cache_data_ready)
  //       );

  initial
  begin
    //#10 rm0 = rm0 + 32'b01000;
    //$display("The memory address inside ram is: %h", rm0);
    //$display("The mem_address is: %h", mem_address);
  end

  // always @(*) begin
  //   mem_address = rm0;
  // end

  always @(mem_op)
  begin
    $display("Activate reading %b", mem_op);
  end
  // always @(*)
  // begin
  //   //rm0 <= rm0 + 2'b10;
  // end
endmodule
