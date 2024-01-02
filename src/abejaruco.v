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

module Abejaruco #(parameter PROGRAM = "../../programs/random_binary.o")(
    input wire reset,
    input wire clk,
    output wire [31:0] data_cache_data_out
  );

  reg [31:0] r [0:31];
  reg [31:0] rm0 = 32'b1000;
  reg [31:0] rm1;
  reg [31:0] rm2;

  // Data cache wires
  // -- In wires (from CPU)
  reg data_cache_access;               // Enable the cache, to it obey the inputs
  reg data_cache_reset;
  reg [31:0] data_cache_address;
  reg [31:0] data_cache_data_in;
  reg data_cache_op;
  reg data_cache_byte_op;

  // -- In wires (from memory)
  wire data_cache_mem_data_ready;
  wire [127:0] data_cache_mem_data_out;

  // -- Out wires (to CPU)
  wire data_cache_data_ready;
  // wire [31:0] data_cache_data_out;

  // -- Out wires (to memory)
  wire data_cache_mem_enable;
  wire data_cache_mem_op_init;
  wire data_cache_mem_op;
  wire [31:0] data_cache_mem_address;
  wire [127:0] data_cache_mem_data_in;
  wire data_cache_op_done;

  // Fetch registers wires
  // -- Out wires
  wire [31:0] fetch_rm0_out;
  wire [31:0] fetch_instruction_out;

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

  // Inital values values disenablig modules
  // assign mem_enable = 0;
  assign data_cache_reset = 0;


  // Instantiations
  Memory #(.MEMORY_LOCATIONS(4096), .ADDRESS_SIZE(32), .CACHE_LINE_SIZE(128)) main_memory (
           //IN
           .clk(clk),
           .enable(data_cache_mem_enable),
           .op(data_cache_mem_op),
           .address(data_cache_mem_address),
           .data_in(data_cache_mem_data_in),
           .op_init(data_cache_mem_op_init),
           .op_done(data_cache_op_done),

           //OUT
           .data_out(data_cache_mem_data_out),
           .data_ready(data_cache_mem_data_ready),
           .memory_in_use(memory_in_use)
         );

  Cache data_cache(
          //IN (from CPU)
          .clk(clk),
          .reset(data_cache_reset),
          .access(data_cache_access),
          .address(data_cache_address),
          .data_in(data_cache_data_in),
          .op(data_cache_op),
          .byte_op(data_cache_byte_op),

          //IN (from memory)
          .mem_data_ready(data_cache_mem_data_ready),
          .mem_data_out(data_cache_mem_data_out),
          .memory_in_use(memory_in_use),

          //OUT (to CPU)
          .data_out(data_cache_data_out),
          .data_ready(data_cache_data_ready),

          //OUT (to memory)
          .mem_op_init(data_cache_mem_op_init),
          .mem_enable(data_cache_mem_enable),
          .mem_op(data_cache_mem_op),
          .mem_op_done(data_cache_op_done),
          .mem_address(data_cache_mem_address),
          .mem_data_in(data_cache_mem_data_in)
        );

  FetchRegisters #(.WORD_SIZE(32)) fetch_registers(
          //IN
          .clk(clk),
          .rm0_in(rm0),
          .instruction_in(data_cache_data_out),
          .active(data_cache_op_done),

          //OUT
          .rm0_out(fetch_rm0_out),
          .instruction_out(fetch_instruction_out)
        );

  assign data_cache_address = rm0;
  //assign data_cache_mem_address = rm0;
  assign data_cache_op = 1'b1;
  assign data_cache_access = 1'b1;
  assign data_cache_data_in = data_cache_mem_data_out;
  assign data_cache_byte_op = 1'b0;

  always @(posedge clk)
  begin
    if (data_cache_op_done)
    begin
      rm0 = rm0 + 3'b100;
    end

    $display("Fetch stage values: rm0 = %h, instruction = %h", fetch_rm0_out, fetch_instruction_out);
    //data_cache_data_in = 32'h00000011;
    //data_cache_address = 0;
    //data_cache_op = 1'b0;
    //data_cache_access = 1'b1;
  end
endmodule
