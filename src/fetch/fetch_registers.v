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
    input wire clk,
    input wire [WORD_WIDTH-1:0] rm0_in,
    output reg [WORD_WIDTH-1:0] rm0_out,
    input wire [WORD_WIDTH-1:0] instruction_in,
    output reg [WORD_WIDTH-1:0] instruction_out,
    input wire cache_op_done_in,
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

    // Reason to stall the fetch stage
    // - Cache has not finished

    if (cache_op_done_in)
    begin
      // $display("Control unit values: branch = %b, reg_write = %b, mem_read = %b, mem_to_reg = %b, alu_op = %b, mem_write = %b, alu_src = %b", cu_branch, cu_reg_write, cu_mem_read, cu_mem_to_reg, cu_alu_op, cu_mem_write, cu_alu_src);
      $display("FetchRegisters: rm0_in = %h, instruction_in = %h", rm0_in, instruction_in);
      rm0_out = rm0_in;
      instruction_out = instruction_in;
      active_out = 1'b1;
    end
    else
    begin
      active_out = 1'b0;
    end
  end
endmodule
