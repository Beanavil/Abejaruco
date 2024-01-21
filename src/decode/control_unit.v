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

`default_nettype none

module ControlUnit
  (
    // In
    input wire clk,
    input [6:0] opcode,
    input [2:0] funct3,

    // Out
    // output reg mem_write,
    // output reg mem_read,
    // output reg mem_to_reg,
    output reg d_cache_access,
    output reg d_cache_op,
    output reg branch,
    output reg reg_write,
    output reg [1:0] alu_op,
    output reg alu_src,
    output reg is_imm,
    output reg is_byte_op);
`include "src/parameters.v"

  initial
  begin
    // mem_write = 0;
    reg_write = 0;
    branch = 0;
    // mem_to_reg = 0;
    alu_src = 0;
    is_imm = 0;
  end

  always @(*)
  begin
    `CONTROL_UNIT_DISPLAY($sformatf("---------> Opcode: %b", opcode));
    case (opcode)
      7'b0110011: /*R-type*/
      begin
        branch <= 1'b0;
        reg_write <= 1'b1;
        // mem_read <= 1'b0;
        // mem_to_reg <= 1'b0;
        alu_op <= 2'b10;
        // mem_write <= 1'b0;
        alu_src <= 1'b0;
        is_imm <= 1'b0;

        d_cache_access = 1'b0;
      end

      7'b0000011: /*I-type*/
      begin

        //LDW/LDB
        branch <= 1'b0;
        reg_write <= 1'b1;
        alu_op <= 2'b00;
        alu_src <= 1'b1;

        d_cache_access = 1'b1;
        d_cache_op = 1'b1;
        // mem_read <= 1'b1;
        // mem_to_reg <= 1'b1;
        // mem_write <= 1'b0;

        //LDI
        case (funct3)
          3'b001:
            begin
              is_imm <= 1'b1;
              d_cache_access <= 1'b0;
            end
          default:
            begin
              is_imm <= 1'b0;
              d_cache_access <= 1'b0;
            end
        endcase
      end

      7'b0100011: /*S-type*/
      begin
        d_cache_access = 1'b1;
        d_cache_op = 1'b0;
        branch <= 1'b0;
        reg_write <= 1'b0;
        alu_src <= 1'b1;
        alu_op <= 2'b00;

        case (funct3)
          3'b000:
            begin
              is_byte_op <= 1;
            end
              default:
            begin
              is_byte_op <= 0;
            end
        endcase

        // mem_write <= 1'b1;
        // mem_read <= 1'b0;
        // mem_to_reg <= 1'b0; /*reg_write is 0, so we do not actually care about this bit*/
        // case (funct3)
        //   3'b001:
        //     is_imm <= 1'b1;
        //   default:
        //     is_imm <= 1'b0;
        // endcase
      end

      7'b1100011: /*branch*/
      begin
        branch <= 1'b1;
        reg_write <= 1'b0;
        alu_op <= 2'b01;
        alu_src <= 1'b0;
        is_imm <= 1'b0;

        // mem_read <= 1'b0;
        // mem_to_reg <= 1'b0; /*reg_write is 0, so we do not actually care about this bit*/
        // mem_write <= 1'b0;
      end

      7'b1100111: /*jump*/
      begin
        branch <= 1'b1;
        reg_write <= 1'b0;
        alu_op <= 2'b11;
        alu_src <= 1'b0;
        is_imm <= 1'b0;

        // mem_read <= 1'b0;
        // mem_to_reg <= 1'b0; /*reg_write is 0, so we do not actually care about this bit*/
        // mem_write <= 1'b0;
      end

      default:
      begin
        d_cache_access = 0;
        branch = 0;
        reg_write = 0;
        alu_op = 0;
        alu_src = 0;
        is_imm = 0;
      end
    endcase
  end
endmodule
