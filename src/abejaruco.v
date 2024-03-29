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
`include "src/execution/mul_registers.v"
`include "src/fetch/fetch_registers.v"

`include "src/common/priority_encoder.v"
`include "src/common/tag_comparator.v"
`include "src/memory/d_cache.v"
`include "src/memory/i_cache.v"
`include "src/memory/memory.v"
`include "src/memory/memory_registers.v"
`include "src/memory/memory_arbiter.v"


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
  reg rf_write_enable;
  reg [REGISTER_INDEX_WIDTH-1:0] rf_write_idx;
  reg [31:0] rf_write_data;
  reg [REGISTER_INDEX_WIDTH-1:0] rf_read_idx_1;
  reg [REGISTER_INDEX_WIDTH-1:0] rf_read_idx_2;
  reg [31:0] rf_read_data_1;
  reg [31:0] rf_read_data_2;

  // assign rf_write_enable = 1'b0;

  // Main memory wires
  // -- In wires from icache
  wire icache_mem_op_init;
  wire icache_op_done;
  wire [11:0] icache_mem_address;
  wire icache_mem_op;
  wire [127:0] icache_mem_data_in;
  wire icache_start_access;

  // -- In wires from dcache
  wire dcache_mem_op_init;
  wire dcache_op_done;
  wire dcache_mem_op;
  wire [11:0] dcache_mem_address;
  wire [127:0] dcache_mem_data_in;
  wire dcache_start_access;

  //Instruction cache wires
  // -- In wires from CPU
  reg [31:0] icache_address;
  reg [31:0] icache_data_in;
  reg icache_byte_op;

  // -- Out wires to CPU
  wire icache_data_ready;
  wire [31:0] icache_data_out;

  // -- Inital values
  assign icache_address = rm0;

  // Fetch registers wires
  // -- Out wires
  wire [31:0] fetch_rm0_out;
  wire [31:0] fetch_instruction_out;

  // Control unit wires
  // -- Out wires
  wire cu_branch;

  wire cu_reg_write;
  wire cu_mem_to_reg;
  wire cu_alu_src;
  wire cu_is_imm;
  wire [1:0] cu_alu_op;
  wire cu_is_byte_op;

  // ALU control unit wires
  // -- Out wires
  wire [1:0] alu_ctrl_alu_op;
  wire mul_done;

  // Decode registers wires
  // -- Out wires
  wire decode_alu_zero_out;
  wire [31:0] decode_rm0_out;
  wire [31:0] decode_instruction_out;
  wire [4:0] decode_dst_register_out;
  wire [31:0] decode_first_input_out;
  wire [31:0] decode_second_input_out;
  wire decode_cu_branch_out;
  wire decode_cu_reg_write_out;
  wire decode_cu_d_cache_access_out;
  wire decode_cu_mem_to_reg_out;
  wire decode_cu_d_cache_op_out;
  wire decode_cu_is_byte_op_out;

  wire [1:0] decode_cu_alu_op_out;
  wire decode_cu_is_imm_out;
  wire decode_cu_alu_src_out;
  wire [11:0] decode_offset_out;
  wire stall;
  wire [31:0] sign_extend_out;
  wire d_cache_access;
  wire d_cache_op;

  // ALU wires
  // -- In wires
  wire [31:0] op_first_input;
  wire [31:0] op_second_input;
  wire [31:0] alu_address;

  // -- Out wires
  wire alu_zero;

  // Execution registers wires
  wire [31:0] execution_instruction_out;
  wire [31:0] execution_alu_result_out;
  wire execution_alu_zero_out;
  wire [31:0] execution_sign_extend_out;
  wire execution_cu_mem_to_reg_out;
  wire execution_cu_reg_write_out;
  wire [4:0] execution_dst_register_out;
  wire execution_active_out;
  wire execution_cu_d_cache_access_out;
  wire execution_cu_d_cache_op_out;
  wire [31:0] execution_second_register_out;
  wire execution_cu_is_byte_op_out;

  wire memory_in_use;
  wire [31:0] dcache_data_out;
  wire dcache_data_ready;

  //---Memory
  wire mem_enable;
  wire mem_access_finish;
  wire mem_op;
  wire [MEMORY_ADDRESS_SIZE-1:0] mem_address;
  wire [CACHE_LINE_SIZE-1:0] mem_data_in;
  wire [CACHE_LINE_SIZE-1:0] mem_data_out;
  wire [CACHE_LINE_SIZE-1:0] arbiter_mem_data_out;
  wire dcache_mem_data_ready;
  wire icache_mem_data_ready;
  wire dcache_allow_op;
  wire icache_allow_op;
  wire mem_data_ready;


  // Memory registers wires
  wire [31:0] memory_dst_reg_data;
  wire memory_alu_zero_out;
  wire [31:0] memory_sign_extend_out;
  wire memory_cu_mem_to_reg_out;
  reg execution_op_done;

  // Instantiations

  ////----------------------------------------///
  //                Fetch stage                //
  ////----------------------------------------///

  MemArbiter memory_arbiter(
               // In
               //--from DCache
               .dcache_mem_op_init(dcache_mem_op_init),
               .dcache_op_done(dcache_op_done),
               .dcache_mem_op(dcache_mem_op),
               .dcache_mem_address(dcache_mem_address),
               .dcache_mem_data_in(dcache_mem_data_in),
               .dcache_start_access(dcache_start_access),

               //--from ICache
               .icache_mem_op_init(icache_mem_op_init),
               .icache_op_done(icache_op_done),
               .icache_mem_address(icache_mem_address),
               .icache_start_access(icache_start_access),

               //--from memory
               .mem_data_ready(mem_data_ready),
               .mem_data_out(mem_data_out),

               // Out
               //--To memory
               .mem_enable(mem_enable),
               .mem_op(mem_op),
               .mem_address(mem_address),
               .mem_data_in(mem_data_in),

               //-To cache
               .mem_data_out_to_cache(arbiter_mem_data_out),
               //--Dcache
               .dcache_mem_data_ready(dcache_mem_data_ready),
               .dcache_allow_op(dcache_allow_op),
               //--Icache
               .icache_mem_data_ready(icache_mem_data_ready),
               .icache_allow_op(icache_allow_op)

             );

  Memory #(.PROGRAM(PROGRAM)) main_memory (
           // In
           .clk(clk),
           .enable(mem_enable),
           .op(mem_op),
           .address(mem_address),
           .data_in(mem_data_in),

           // Out
           .data_out(mem_data_out),
           .data_ready(mem_data_ready)
         );

  ICache instruction_cache(
           // In
           // -- from CPU
           .clk(clk),
           .reset(reset),
           .address(icache_address),

           // -- from arbiter
           .mem_data_ready(icache_mem_data_ready),
           .mem_data_out(arbiter_mem_data_out),
           .allow_op(icache_allow_op),
           .start_access(icache_start_access),

           // Out
           // -- to CPU
           .data_out(icache_data_out),
           .data_ready(icache_data_ready),

           // -- to arbiter
           .mem_op_init(icache_mem_op_init),
           .mem_op_done(icache_op_done),
           .mem_address(icache_mem_address)
         );



  FetchRegisters fetch_registers(
                   // In
                   .clk(clk),
                   .rm0_in(rm0),
                   .instruction_in(icache_data_out),
                   .icache_op_done(icache_data_ready),
                   .stall_in(stall),
                   .execution_empty(execution_op_done),
                   .set_nop(alu_control.set_nop),
                   .d_cache_access(execution_cu_d_cache_access_out),
                   .unlock(dcache_data_ready),

                   // Out
                   .rm0_out(fetch_rm0_out),
                   .instruction_out(fetch_instruction_out)
                 );

  ////----------------------------------------///
  //               Decode stage                //
  ////----------------------------------------///

  RegisterFile register_file(
                 //In
                 .clk(clk),
                 .write_enable(rf_write_enable),
                 .reset(reset),
                 .write_idx(rf_write_idx),
                 .write_data(rf_write_data),
                 .read_idx_1(fetch_registers.instruction_out[19:15]),
                 .read_idx_2(fetch_registers.instruction_out[24:20]),

                 //Out
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
                .d_cache_access(d_cache_access),
                .d_cache_op(d_cache_op),
                .is_imm(cu_is_imm),
                .alu_op(cu_alu_op),
                .alu_src(cu_alu_src),
                .is_byte_op(cu_is_byte_op),

                .mem_to_reg(cu_mem_to_reg)
              );

  HazardDetectionUnit hazard_detection_unit(.clk(clk),
                      // In
                      .decode_op_code(fetch_instruction_out[6:0]),
                      .decode_idx_src_1(fetch_instruction_out[19:15]),
                      .decode_idx_src_2(fetch_instruction_out[24:20]),
                      .execution_idx_dst(decode_dst_register_out),
                      .execution_instruction(decode_registers.instruction_out),
                      .memory_idx_src_dst(execution_dst_register_out),
                      .memory_instruction(execution_registers.instruction_out),
                      .rf_write_enable(rf_write_enable),
                      .rf_write_idx(memory_registers.destination_register_out),
                      .wb_instruction(memory_registers.instruction_out),

                      // Out
                      .stall(stall));

  DecodeRegisters decode_registers(
                    // In
                    .clk(clk),
                    .rm0_in(fetch_rm0_out),
                    .instruction_in(fetch_instruction_out),
                    .destination_register_in(fetch_instruction_out[11:7]),
                    .first_input_in(rf_read_data_1),
                    .second_input_in(rf_read_data_2),
                    .cu_branch_in(cu_branch),
                    .cu_reg_write_in(cu_reg_write),
                    .cu_mem_to_reg_in(cu_mem_to_reg),
                    //--DCache
                    .cu_d_cache_access_in(d_cache_access),
                    .cu_d_cache_op_in(d_cache_op),
                    .cu_is_byte_op_in(cu_is_byte_op),

                    .cu_alu_op_in(cu_alu_op),
                    .cu_alu_src_in(cu_alu_src),
                    .cu_is_imm_in(cu_is_imm),
                    .offset_in(fetch_instruction_out[31:20]),
                    .stall_in(stall),
                    .execution_empty(execution_op_done),
                    .set_nop(alu_control.set_nop),
                    .d_cache_access(execution_cu_d_cache_access_out),
                    .unlock(dcache_data_ready),

                    // Out
                    .rm0_out(decode_rm0_out),
                    .instruction_out(decode_instruction_out),
                    .destination_register_out(decode_dst_register_out),
                    .first_input_out(decode_first_input_out),
                    .second_input_out(decode_second_input_out),
                    .cu_branch_out(decode_cu_branch_out),
                    .cu_reg_write_out(decode_cu_reg_write_out),
                    .cu_mem_to_reg_out(decode_cu_mem_to_reg_out),
                    .cu_d_cache_access_out(decode_cu_d_cache_access_out),
                    .cu_d_cache_op_out(decode_cu_d_cache_op_out),
                    .cu_is_byte_op_out(decode_cu_is_byte_op_out),

                    .cu_alu_op_out(decode_cu_alu_op_out),
                    .cu_is_imm_out(decode_cu_is_imm_out),
                    .cu_alu_src_out(decode_cu_alu_src_out),
                    .offset_out(decode_offset_out)
                  );

  ////----------------------------------------///
  //               Execution stage             //
  ////----------------------------------------///

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

  // If alu_op is store/load, use destination/source and offset as arguments
  // of the operation. Else, use registers' contents.
  // If it's a load, address is source address. For stores we use destination address.
  assign alu_address = (decode_registers.instruction_out[6:0] == 7'b0000011) ?
         decode_registers.first_input_out : decode_registers.second_input_out;

  assign op_first_input = (decode_cu_alu_src_out) ?
         alu_address : decode_first_input_out;

  assign op_second_input = (decode_cu_branch_out & decode_instruction_out[6:0] === 7'b1100111) ?
         {decode_instruction_out[31:25], decode_instruction_out[11:7]} :
         ((decode_cu_alu_src_out) ?
          sign_extend_out : decode_second_input_out);

  //-------------------------------------------//
  //                ALU pipeline               //
  //-------------------------------------------//


  ALU alu(
        //IN
        .clk(clk),
        .input_first(op_first_input),
        .input_second(op_second_input),
        .alu_op(alu_ctrl_alu_op),

        //OUT
        .zero(alu_zero)
      );

  //-------------------------------------------//
  //            Multiplier pipeline            //
  //-------------------------------------------//

  MulRegisters mul1_to_mul2_registers(
                 .clk(clk),
                 .instruction_in(decode_registers.instruction_out),
                 .destination_register_in(decode_registers.destination_register_out),
                 .first_input_in(op_first_input),
                 .second_input_in(op_second_input),
                 .mul_result_in(64'd0),
                 .init_op(alu_control.is_mul),
                 .set_nop(alu_control.set_nop),
                 .stall_in(stall)
               );

  MulRegisters mul2_to_mul3_registers(
                 .clk(clk),
                 .instruction_in(mul1_to_mul2_registers.instruction_out),
                 .destination_register_in(mul1_to_mul2_registers.destination_register_out),
                 .first_input_in(mul1_to_mul2_registers.first_input_out),
                 .second_input_in(mul1_to_mul2_registers.second_input_out),
                 .mul_result_in(mul1_to_mul2_registers.mul_result_out),
                 .init_op(mul1_to_mul2_registers.op_done),
                 .set_nop(alu_control.set_nop),
                 .stall_in(stall)
               );

  MulRegisters mul3_to_mul4_registers(
                 .clk(clk),
                 .instruction_in(mul2_to_mul3_registers.instruction_out),
                 .destination_register_in(mul2_to_mul3_registers.destination_register_out),
                 .first_input_in(mul2_to_mul3_registers.first_input_out),
                 .second_input_in(mul2_to_mul3_registers.second_input_out),
                 .mul_result_in(mul2_to_mul3_registers.mul_result_out),
                 .init_op(mul2_to_mul3_registers.op_done),
                 .set_nop(alu_control.set_nop),
                 .stall_in(stall)
               );

  MulRegisters mul4_to_mul5_registers(
                 .clk(clk),
                 .instruction_in(mul3_to_mul4_registers.instruction_out),
                 .destination_register_in(mul3_to_mul4_registers.destination_register_out),
                 .first_input_in(mul3_to_mul4_registers.first_input_out),
                 .second_input_in(mul3_to_mul4_registers.second_input_out),
                 .mul_result_in(mul3_to_mul4_registers.mul_result_out),
                 .init_op(mul3_to_mul4_registers.op_done),
                 .set_nop(alu_control.set_nop),
                 .stall_in(stall)
               );

  Multiplier multiplier(.clk(clk),
                        .multiplicand(mul4_to_mul5_registers.first_input_out),
                        .multiplier(mul4_to_mul5_registers.second_input_out));

  // res = alu_res o offset (mux) -> mux que elige entre el alu result y el offset (immediate) en caso que sea una immediate
  // assign res = (is_imm) ? offset : alu_result;


  //-------------------------------------------//
  //              End of execution             //
  //-------------------------------------------//


  assign execution_op_done = (alu_control.is_mul & mul4_to_mul5_registers.op_done === 1) || ~alu_control.is_mul;

  ExecutionRegisters execution_registers(
                       // In
                       .clk(clk),
                       .instruction_in(decode_instruction_out),
                       .extended_inmediate_in(sign_extend_out),
                       .cu_mem_to_reg_in(decode_cu_mem_to_reg_out),
                       .cu_d_cache_access_in(decode_cu_d_cache_access_out),
                       .cu_d_cache_op_in(decode_cu_d_cache_op_out),
                       .cu_is_byte_op_in(decode_cu_is_byte_op_out),

                       .cu_reg_write_in(decode_cu_reg_write_out),
                       .destination_register_in(alu_control.is_mul ? mul4_to_mul5_registers.destination_register_out : decode_dst_register_out),
                       .second_input_in(decode_registers.second_input_out),
                       .alu_result_in(alu_control.is_mul ? multiplier.result : alu.result),//decode_alu_result_out),
                       .alu_zero_in(decode_alu_zero_out),
                       .active(execution_op_done),
                       .unlock(dcache_data_ready),
                       .stall_in(stall),

                       // Out
                       .instruction_out(execution_instruction_out),
                       .extended_inmediate_out(execution_sign_extend_out),
                       .cu_mem_to_reg_out(execution_cu_mem_to_reg_out),
                       .cu_reg_write_out(execution_cu_reg_write_out),
                       .destination_register_out(execution_dst_register_out),
                       .alu_zero_out(execution_alu_zero_out),
                       .active_out(execution_active_out),

                       //--to DCache
                       .alu_result_out(execution_alu_result_out),
                       .cu_d_cache_access_out(execution_cu_d_cache_access_out),
                       .cu_d_cache_op_out(execution_cu_d_cache_op_out),
                       .cu_is_byte_op_out(execution_cu_is_byte_op_out)
                     );

  ////----------------------------------------///
  //               Memory stage                //
  ////----------------------------------------///

  DCache data_cache(
           //In
           //--from CPU
           .clk(clk),
           .access(execution_cu_d_cache_access_out),
           .reset(1'b0),
           .address(execution_alu_result_out),
           .destination_register_in(execution_dst_register_out),
           .data_in(execution_registers.second_input_out),
           .op(execution_cu_d_cache_op_out),
           .byte_op(execution_cu_is_byte_op_out),
           .cu_reg_write_in(execution_cu_reg_write_out),

           //--from arbiter
           .mem_data_ready(dcache_mem_data_ready),
           .mem_data_out(arbiter_mem_data_out),
           .allow_op(dcache_allow_op),

           //Out
           //-- to CPU
           .data_out(dcache_data_out),
           .data_ready(dcache_data_ready),

           //-- to Arbiter
           .mem_op_init(dcache_mem_op_init),
           .mem_op_done(dcache_op_done),
           .mem_address(dcache_mem_address),
           .mem_op(dcache_mem_op),
           .mem_data_in(dcache_mem_data_in),
           .start_access(dcache_start_access)
         );


  MemoryRegisters memory_registers(
                    // In
                    .clk(clk),
                    .instruction_in(execution_instruction_out),
                    .dst_reg_data_in(data_cache.data_ready ? data_cache.data_out : execution_alu_result_out),
                    .extended_inmediate_in(execution_sign_extend_out),
                    .cu_mem_to_reg_in(execution_cu_mem_to_reg_out),
                    .cu_reg_write_in(data_cache.cu_reg_write_out),
                    .destination_register_in(data_cache.destination_register_out),
                    .data_cache_data_ready_in(data_cache.data_ready),
                    .cu_d_cache_access_in(execution_cu_d_cache_access_out),
                    .dcache_op_done_in(dcache_op_done),

                    // Out
                    .dst_reg_data_out(memory_dst_reg_data),
                    .extended_inmediate_out(memory_sign_extend_out),
                    .cu_mem_to_reg_out(memory_cu_mem_to_reg_out),
                    .cu_reg_write_out(rf_write_enable),
                    .destination_register_out(rf_write_idx)
                  );

  ////----------------------------------------///
  //              Write Back stage             //
  ////----------------------------------------///

  Mux2to1 reg_write_mux(
            // In
            .sel(memory_cu_mem_to_reg_out && memory_registers.data_cache_data_ready_out),
            .in0(memory_sign_extend_out),
            .in1(memory_dst_reg_data),

            // Out
            .out(rf_write_data)
          );

  initial
  begin
    rm0 = rm0_initial;
    `ABEJARUCO_DISPLAY($sformatf("[ ABEJARUCO ] - Initial rm0 = %h, clk = %b", rm0, clk));
  end

  reg take_jump, take_branch, increment_pc;
  reg [7:0] branch_pc_value;

  // Main pipeline execution
  always @(negedge clk)
  begin
    take_jump = decode_registers.cu_branch_out &
              decode_registers.instruction_out[6:0] === 7'b1100111;
    take_branch = decode_registers.cu_branch_out &
                decode_registers.instruction_out[6:0] === 7'b1100011 & alu_zero;
    increment_pc = icache_data_ready & ~stall &
                 execution_op_done &
                 ~(memory_registers.cu_d_cache_access_out & ~memory_registers.data_cache_data_ready_out);

    branch_pc_value = {execution_registers.instruction_in[31],
                       execution_registers.instruction_in[7],
                       execution_registers.instruction_in[30:25],
                       execution_registers.instruction_in[11:8]};

    // Jump pc
    if (take_jump)
    begin
      rm0 <= alu.result;
    end
    // Branch pc
    else if (take_branch)
    begin
      rm0 <= branch_pc_value;
    end
    // pc + 4
    else if (increment_pc)
    begin
      rm0 <= rm0 + 3'b100;
    end

    `ABEJARUCO_DISPLAY($sformatf("Update rm0, the new program counter is: %h", rm0));
  end
endmodule
