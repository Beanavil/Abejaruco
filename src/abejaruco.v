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

`include "src/common/mux2to1.v"
`include "src/common/sign_extend.v"
`include "src/decode/control_unit.v"
`include "src/decode/decode_registers.v"
`include "src/decode/register_file.v"
`include "src/decode/hazard_detection_unit.v"
`include "src/execution/alu.v"
`include "src/execution/alu_control.v"
`include "src/execution/execution_registers.v"
`include "src/fetch/fetch_registers.v"
`include "src/memory/cache.v"
`include "src/memory/memory.v"
`include "src/memory/memory_registers.v"


module Abejaruco #(parameter PROGRAM = "../../programs/zero.o")(
    input wire clk,
    input wire reset,
    input wire [31:0] rm0_initial
  );
`include "src/parameters.v"

  // Special registers
  reg [31:0] rm0; /*return PC on exception*/
  reg [31:0] rm1 = 32'h2000; /*@ for certain exceptions*/
  reg [31:0] rm2; /*exception type info*/
  // reg [31:0] x1; /*ra*/

  // Register file wires
  reg rf_write_enable; // TODO in WB stage
  reg [REGISTER_INDEX_WIDTH-1:0] rf_write_idx; // TODO in WB stage
  reg [31:0] rf_write_data; // TODO in WB stage
  reg [REGISTER_INDEX_WIDTH-1:0] rf_read_idx_1;
  reg [REGISTER_INDEX_WIDTH-1:0] rf_read_idx_2;
  reg [31:0] rf_read_data_1;
  reg [31:0] rf_read_data_2;

  // assign rf_write_enable = 1'b0;

  // Main memory wires
  // -- In wires from icache
  wire icache_mem_enable;
  wire icache_mem_op_init;
  wire icache_mem_op;
  wire [11:0] icache_mem_address;
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
  wire [31:0] icache_data_out;

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

  // Control unit wires
  // -- Out wires
  wire cu_branch;
  wire cu_reg_write;
  wire cu_mem_read;
  wire cu_mem_to_reg;
  wire cu_mem_write;
  wire cu_alu_src;
  wire cu_is_imm;
  wire [1:0] cu_alu_op;

  // ALU control unit wires
  // -- Out wires
  wire [1:0] alu_ctrl_alu_op;
  wire alu_op_done;

  // Decode registers wires
  // -- Out wires
  wire [31:0] decode_alu_result_out;
  wire decode_alu_zero_out;
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
  wire decode_cu_is_imm_out;
  wire decode_cu_alu_src_out;
  wire [4:0] decode_src_address_out;
  wire [4:0] decode_dst_address_out;
  wire [11:0] decode_offset_out;
  wire stall;
  // Sign extend wires
  wire [31:0] sign_extend_out;

  // ALU wires
  // -- In wires
  wire [31:0] alu_first_input;
  wire [31:0] alu_second_input;
  wire [31:0] alu_address;

  // -- Out wires
  wire alu_zero;

  // Execution registers wires
  wire [31:0] execution_alu_result_out;
  wire execution_alu_zero_out;
  wire [31:0] execution_sign_extend_out;
  wire execution_cu_mem_to_reg_out;
  wire execution_cu_reg_write_out;
  wire [4:0] execution_dst_register_out;
  wire execution_active_out;


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

  // Memory registers wires
  wire [31:0] memory_alu_result_out;
  wire memory_alu_zero_out;
  wire [31:0] memory_sign_extend_out;
  wire memory_cu_mem_to_reg_out;

  // Instantiations

  //----------------------------------------//
  //              Fetch stage               //
  //----------------------------------------//

  Memory #(.PROGRAM(PROGRAM)) main_memory (
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

  FetchRegisters fetch_registers(
                   // In
                   .clk(clk),
                   .rm0_in(rm0),
                   .instruction_in(icache_data_out),
                   .cache_op_done_in(icache_op_done), //TODO think this about this
                   .stall_in(stall),

                   // Out
                   .rm0_out(fetch_rm0_out),
                   .instruction_out(fetch_instruction_out)
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
                .clk(clk),
                .opcode(fetch_instruction_out[6:0]),
                .funct3(fetch_instruction_out[14:12]),

                // Out
                .branch(cu_branch),
                .reg_write(cu_reg_write),
                .mem_read(cu_mem_read),
                .mem_to_reg(cu_mem_to_reg),
                .alu_op(cu_alu_op),
                .mem_write(cu_mem_write),
                .alu_src(cu_alu_src),
                .is_imm(cu_is_imm)
              );

  HazardDetectionUnit hazard_detection_unit(.clk(clk),
                                    .decode_idx_src_1(fetch_instruction_out[19:15]),
                                    .decode_idx_src_2(fetch_instruction_out[24:20]),
                                    .execution_idx_dst(decode_dst_address_out),
                                    .alu_op_done(alu_op_done),

                                    .memory_idx_src_dst(execution_dst_register_out),
                                    .mem_op_done(1'b1), //TODO modify this bit to mem_op_done of data cache
                                    .stall(stall));

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
                    .cu_is_imm_in(cu_is_imm),
                    .src_address_in(fetch_instruction_out[19:15]),
                    .dst_address_in(fetch_instruction_out[11:7]),
                    .offset_in(fetch_instruction_out[31:20]),
                    .stall_in(stall),

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
                    .cu_is_imm_out(decode_cu_is_imm_out),
                    .cu_alu_src_out(decode_cu_alu_src_out),
                    .src_address_out(decode_src_address_out),
                    .dst_address_out(decode_dst_address_out),
                    .offset_out(decode_offset_out)
                  );

  //--------------------------------------------//
  //               Execution stage              //
  //--------------------------------------------//

  SignExtend sign_extend(
               // In (offset is the same as the immediate)
               .in(decode_offset_out),

               // Out
               .out(sign_extend_out)
             );

  ALUControl alu_control
             (.clk(clk),
              .inst(decode_offset_out[11:5]),
              .cu_alu_op(decode_cu_alu_op_out),
              .alu_op(alu_ctrl_alu_op));

  // If alu_op is store/load, use destination/source and offset as arguments of the operation. Else, use registers' contents.
  assign alu_address = (1/*ld*/) ? decode_src_address_out : decode_dst_address_out;
  assign alu_first_input = (decode_cu_alu_src_out) ? alu_address : decode_first_register_out;
  assign alu_second_input = (decode_cu_alu_src_out) ? {20'b0, decode_offset_out} : decode_second_register_out;

  ALU alu(
        //IN
        .clk(clk),
        .input_first(alu_first_input),
        .input_second(alu_second_input),
        .alu_op(alu_ctrl_alu_op),

        //OUT
        .zero(alu_zero),
        .result(decode_alu_result_out),
        .op_done(alu_op_done)
      );

  // res = alu_res o offset (mux) -> mux que elige entre el alu result y el offset (immediate) en caso que sea una immediate
  // assign res = (is_imm) ? offset : alu_result;

  ExecutionRegisters execution_registers(
                       // In
                       .clk(clk),
                       .extended_inmediate_in(sign_extend_out),
                       .cu_mem_to_reg_in(decode_cu_mem_to_reg_out),
                       .cu_reg_write_in(decode_cu_reg_write_out),
                       .destination_register_in(decode_dst_register_out),
                       .alu_result_in(decode_alu_result_out),
                       .alu_zero_in(decode_alu_zero_out),
                       .active(alu_op_done),

                       // Out
                       .extended_inmediate_out(execution_sign_extend_out),
                       .cu_mem_to_reg_out(execution_cu_mem_to_reg_out),
                       .cu_reg_write_out(execution_cu_reg_write_out),
                       .destination_register_out(execution_dst_register_out),
                       .alu_result_out(execution_alu_result_out),
                       .alu_zero_out(execution_alu_zero_out),
                       .active_out(execution_active_out)
                     );

  //--------------------------------------------//
  //               Memory stage                 //
  //--------------------------------------------//

  MemoryRegisters memory_registers(
                    // In
                    .clk(clk),
                    .alu_result_in(execution_alu_result_out),
                    .extended_inmediate_in(execution_sign_extend_out),
                    .cu_mem_to_reg_in(execution_cu_mem_to_reg_out),
                    .cu_reg_write_in(execution_cu_reg_write_out),
                    .destination_register_in(execution_dst_register_out),

                    // Out
                    .alu_result_out(memory_alu_result_out),
                    .extended_inmediate_out(memory_sign_extend_out),
                    .cu_mem_to_reg_out(memory_cu_mem_to_reg_out),
                    .cu_reg_write_out(rf_write_enable),
                    .destination_register_out(rf_write_idx)
                  );

  //--------------------------------------------//
  //              Write Back stage              //
  //--------------------------------------------//

  // TODO: When adding ALU this will change to add the ALU result
  Mux2to1 reg_write_mux(
            // In
            .sel(memory_cu_mem_to_reg_out),
            .in0(memory_alu_result_out),
            .in1(memory_sign_extend_out),

            // Out
            .out(rf_write_data)
          );

  initial
  begin
    rm0 = rm0_initial;
    `ABEJARUCO_DISPLAY($sformatf("[ ABEJARUCO ] - Initial rm0 = %h", rm0));
  end

  // Main pipeline execution
  always @(posedge clk)
  begin
    if (icache_op_done & alu_op_done)
    begin
      `ABEJARUCO_DISPLAY($sformatf("alu_op_done %b", alu_op_done));
      `ABEJARUCO_DISPLAY("Update rm0");
      rm0 = rm0 + 3'b100;
    end

    `ABEJARUCO_DISPLAY($sformatf("Fetch stage values: rm0 = %h, instruction = %h", fetch_rm0_out, fetch_instruction_out));
  end
endmodule
