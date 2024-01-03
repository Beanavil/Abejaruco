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

`include "src/decode/control_unit.v"
`include "src/decode/decode_registers.v"
`include "src/decode/register_file.v"
`include "src/fetch/fetch_registers.v"
`include "src/memory/cache.v"
`include "src/memory/memory.v"
`include "src/execution/alu.v"

module Abejaruco #(parameter PROGRAM = "../../programs/random_binary.o",
                     parameter NUM_REGS = 32,
                     parameter INDEX_WIDTH = $clog2(NUM_REGS))(
                       input wire clk,
                       input wire reset,
                       output wire [31:0] icache_data_out,
                       output wire [1:0] cu_alu_op,
                       output wire [31:0] alu_result
                     );

  // Special registers
  // TODO change rm0 to 32'h1000, also in tests
  reg [31:0] rm0 = 32'b1000; /*return PC on exception*/
  reg [31:0] rm1 = 32'h2000; /*@ for certain exceptions*/
  reg [31:0] rm2; /*exception type info*/
  reg [31:0] x0 = 32'h0; /*zero*/
  reg [31:0] x1; /*ra*/

  // Register file wires
  reg rf_write_enable; // TODO in WB stage
  reg [INDEX_WIDTH-1:0] rf_write_idx; // TODO in WB stage
  reg [31:0] rf_write_data; // TODO in WB stage
  reg [INDEX_WIDTH-1:0] rf_read_idx_1;
  reg [INDEX_WIDTH-1:0] rf_read_idx_2;
  reg [31:0] rf_read_data_1;
  reg [31:0] rf_read_data_2;

  // Main memory wires
  // -- In wires from icache
  wire icache_mem_enable;
  wire icache_mem_op_init;
  wire icache_mem_op;
  wire [31:0] icache_mem_address;
  wire [127:0] icache_mem_data_in;
  wire icache_op_done;

  // -- Out wires to icache
  wire icache_mem_data_ready;
  wire [127:0] icache_mem_data_out;


  // Data cache wires
  // -- In wires from CPU
  reg icache_access;               // Enable the cache, to it obey the inputs
  reg [31:0] icache_address;
  reg [31:0] icache_data_in;
  reg icache_op;
  reg icache_byte_op;

  // -- Out wires to CPU
  wire icache_data_ready;
  // wire [31:0] icache_data_out;

  // -- Inital values
  assign icache_access = 1'b1;
  assign icache_address = rm0;
  assign icache_data_in = icache_mem_data_out;
  assign icache_op = 1'b1;
  assign icache_byte_op = 1'b0;

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

  // Decode registers wires
  // -- Out wires
  wire [31:0] decode_rm0_out;
  wire [31:0] decode_instruction_out;
  wire [4:0] decode_dst_register_out;
  wire [31:0] decode_first_register_out;
  wire [31:0] decode_second_register_out;
  wire decode_cu_branch_out;
  wire decode_cu_reg_write_out;
  wire decode_cu_mem_read_out;
  wire decode_cu_mem_to_reg_out;
  wire [1:0] decode_cu_alu_op_out;
  wire decode_cu_mem_write_out;
  wire decode_cu_alu_src_out;

  // ALU wires
  // -- Out wires
  //wire [31:0] alu_result;
  wire alu_zero;

  //TODO cuando se implemente la memoria de datos.
  // Common memory wires
  // -- In wires
  // wire mem_enable;
  // wire mem_op;
  // wire [31:0] mem_address;
  // wire [127:0] mem_data_in;
  // wire op_done;
  // // -- Out wires
  // wire [127:0] mem_data_out;
  // wire mem_data_ready;
  wire memory_in_use;

  // Instantiations

  //----------------------------------------//
  //              Fetch stage               //
  //----------------------------------------//

  Memory #(.MEMORY_LOCATIONS(4096), .ADDRESS_SIZE(32), .CACHE_LINE_SIZE(128)) main_memory (
           // In
           .clk(clk),
           .enable(icache_mem_enable),
           .op(icache_mem_op),
           .address(icache_mem_address),
           .data_in(icache_mem_data_in),
           .op_init(icache_mem_op_init),
           .op_done(icache_op_done),

           // Out
           .data_out(icache_mem_data_out),
           .data_ready(icache_mem_data_ready),
           .memory_in_use(memory_in_use)
         );

  Cache instruction_cache(
          // In
          // -- from CPU
          .clk(clk),
          .reset(reset),
          .access(icache_access),
          .address(icache_address),
          .data_in(icache_data_in),
          .op(icache_op),
          .byte_op(icache_byte_op),
          // -- from main memory
          .mem_data_ready(icache_mem_data_ready),
          .mem_data_out(icache_mem_data_out),
          .memory_in_use(memory_in_use),

          // Out
          // -- to CPU
          .data_out(icache_data_out),
          .data_ready(icache_data_ready),
          // -- to main memory
          .mem_op_init(icache_mem_op_init),
          .mem_enable(icache_mem_enable),
          .mem_op(icache_mem_op),
          .mem_op_done(icache_op_done),
          .mem_address(icache_mem_address),
          .mem_data_in(icache_mem_data_in)
        );

  FetchRegisters #(.WORD_SIZE(32)) fetch_registers(
                   // In
                   .clk(clk),
                   .rm0_in(rm0),
                   .instruction_in(icache_data_out),
                   .active(icache_op_done),

                   // Out
                   .rm0_out(fetch_rm0_out),
                   .instruction_out(fetch_instruction_out),
                   .active_out(fetch_active_out)
                 );

  //----------------------------------------//
  //             Decode stage               //
  //----------------------------------------//

  RegisterFile register_file(
                 .clk(clk),
                 .write_enable(rf_write_enable),
                 .reset(reset),
                 .write_idx(rf_write_idx),
                 .write_data(rf_write_data),
                 .read_idx_1(fetch_instruction_out[19:15]),
                 .read_idx_2(fetch_instruction_out[24:20]),
                 .read_data_1(rf_read_data_1),
                 .read_data_2(rf_read_data_2));

  ControlUnit control_unit(
                // In
                .opcode(fetch_instruction_out[6:0]),

                // Out
                .branch(cu_branch),
                .reg_write(cu_reg_write),
                .mem_read(cu_mem_read),
                .mem_to_reg(cu_mem_to_reg),
                .alu_op(cu_alu_op),
                .mem_write(cu_mem_write),
                .alu_src(cu_alu_src)
              );

  DecodeRegisters decode_registers(
                    // In
                    .clk(clk),
                    .rm0_in(fetch_rm0_out),
                    .instruction_in(fetch_instruction_out),
                    .destination_register_in(fetch_instruction_out[11:7]),
                    .first_register_in(rf_read_data_1),
                    .second_register_in(rf_read_data_2),
                    .cu_branch_in(cu_branch),
                    .cu_reg_write_in(cu_reg_write),
                    .cu_mem_read_in(cu_mem_read),
                    .cu_mem_to_reg_in(cu_mem_to_reg),
                    .cu_alu_op_in(cu_alu_op),
                    .cu_mem_write_in(cu_mem_write),
                    .cu_alu_src_in(cu_alu_src),

                    // Out
                    .rm0_out(decode_rm0_out),
                    .instruction_out(decode_instruction_out),
                    .destination_register_out(decode_dst_register_out),
                    .first_register_out(decode_first_register_out),
                    .second_register_out(decode_second_register_out),
                    .cu_branch_out(decode_cu_branch_out),
                    .cu_reg_write_out(decode_cu_reg_write_out),
                    .cu_mem_read_out(decode_cu_mem_read_out),
                    .cu_mem_to_reg_out(decode_cu_mem_to_reg_out),
                    .cu_alu_op_out(decode_cu_alu_op_out),
                    .cu_mem_write_out(decode_cu_mem_write_out),
                    .cu_alu_src_out(decode_cu_alu_src_out)
                  );

  //--------------------------------------------//
  //               Execution stage              //
  //--------------------------------------------//

  ALU alu(
        //IN
        .clk(clk),
        .input_first(decode_first_register_out),
        .input_second(decode_second_register_out),
        .alu_op(decode_cu_alu_op_out),

        //OUT
        .zero(alu_zero),
        .result(alu_result)
      );

  always @(posedge clk)
  begin
    if (icache_op_done)
    begin
      rm0 = rm0 + 3'b100;
    end

    $display("Fetch stage values: rm0 = %h, instruction = %h", fetch_rm0_out, fetch_instruction_out);
    if (fetch_active_out)
    begin
      $display("Control unit values: branch = %b, reg_write = %b, mem_read = %b, mem_to_reg = %b, alu_op = %b, mem_write = %b, alu_src = %b", cu_branch, cu_reg_write, cu_mem_read, cu_mem_to_reg, cu_alu_op, cu_mem_write, cu_alu_src);
    end
  end
endmodule
