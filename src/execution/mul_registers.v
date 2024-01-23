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

module MulRegisters (
    // In
    input wire clk,
    input wire [WORD_WIDTH-1:0] instruction_in,
    input wire [REGISTER_INDEX_WIDTH-1:0] destination_register_in,
    input wire [WORD_WIDTH-1:0] first_input_in,
    input wire [WORD_WIDTH-1:0] second_input_in,
    input wire [2*WORD_WIDTH-1:0] mul_result_in,
    input wire init_op,
    input wire set_nop,
    input wire stall_in,

    // Out
    output reg [WORD_WIDTH-1:0] instruction_out,
    output reg [REGISTER_INDEX_WIDTH-1:0] destination_register_out,
    output reg [WORD_WIDTH-1:0] first_input_out,
    output reg [WORD_WIDTH-1:0] second_input_out,
    output reg [2*WORD_WIDTH-1:0] mul_result_out,
    output reg set_nop_out,
    output reg op_done
  );
`include "src/parameters.v"

  initial
  begin
    instruction_out <= 0;
    destination_register_out <= 0;
    op_done <= 0;
  end

  always @(negedge clk)
  begin
    if(stall_in)
    begin
      op_done <= 1'b0;
    end
    else if(set_nop === 1)
    begin
      update_registers_to_nop;
    end
    else if(init_op === 1)
    begin
      update_registers;
    end
    else
    begin
      op_done <= 1'b0;
    end
  end

  task update_registers;
    begin
      instruction_out <= instruction_in;
      destination_register_out <= destination_register_in;
      first_input_out <= first_input_in;
      second_input_out <= second_input_in;
      mul_result_out <= mul_result_in;
      set_nop_out <= set_nop;
      op_done = 1'b1;
    end
  endtask

  task update_registers_to_nop;
    begin
      instruction_out <= NOP_INSTRUCTION;
      destination_register_out <= 0;
      first_input_out <= 0;
      second_input_out <= 0;
      mul_result_out <= 0;
      set_nop_out <= set_nop;
      op_done = 1'b0;
    end

  endtask

endmodule
