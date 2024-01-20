// GNU General Public License
//
// Copyright : (c) 2024 Javier Beiro Piñón
//           : (c) 2024 Beatriz Navidad Vilches
//           : (c) 2024 Stefano Petrilli
//
// This file is part of Abejaruco <https://github.com/Beanavil/Abejaruco>.
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
// If not, see <https://www.gnu.org/licenses/>.

module StallUnit
  (
    // In
    input wire clk,
    input wire alu_op_done,
    input wire icache_op_done,
    input wire reg_write,

    // Out
    output reg increase_pc,
    output reg stall_f_registers,
    output reg stall_d_registers,
    output reg stall_e_registers,
    output reg stall_m_registers,
    output reg stall_wb_registers
  );

  initial
  begin
    increase_pc = 1;
  end

  always @(negedge clk)
  begin
    increase_pc = 0;
    stall_f_registers = 0;
    stall_d_registers = 0;
    stall_e_registers = 0;
    stall_m_registers = 0;
    stall_wb_registers = 0;

    if (alu_op_done & icache_op_done)
    begin
      increase_pc = 1;
    end

    if(~alu_op_done & reg_write)
    begin
      increase_pc = 0;
      stall_f_registers = 1;
      stall_d_registers = 1;
    end
  end
endmodule
