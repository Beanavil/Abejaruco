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

module FetchRegisters (
    // In
    input wire clk,
    input wire [WORD_WIDTH-1:0] rm0_in,
    input wire [WORD_WIDTH-1:0] instruction_in,
    input wire cache_op_done_in,
    input wire stall_in,
    input wire alu_op_done,
    input wire set_nop,

    // Out
    output reg [WORD_WIDTH-1:0] instruction_out,
    output reg [WORD_WIDTH-1:0] rm0_out,
    output reg active_out
  );
`include "src/parameters.v"

  initial
  begin
    rm0_out = 0;
    instruction_out = 0;
  end

  always @(negedge clk)
  begin
    if (~stall_in & alu_op_done & cache_op_done_in & set_nop !== 1)
    begin
      update_registers;
    end
    else if (set_nop == 1)
    begin
      update_registers_to_nop;
    end
    else
    begin
      active_out = 1'b0;
    end
  end

  task update_registers;
  begin
    rm0_out <= rm0_in;
    instruction_out <= instruction_in;
    active_out = 1'b1;
  end
  endtask

  task update_registers_to_nop;
  begin
    rm0_out <= rm0_in;
    instruction_out <= NOP_INSTRUCTION;
    active_out = 1'b1;
  end
  endtask
endmodule
