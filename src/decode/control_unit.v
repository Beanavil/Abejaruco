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

module ControlUnit
  (input wire clk,
  input [6:0] opcode,
   input [2:0] funct3,
   output reg branch,
   output reg reg_write,
   output reg mem_read,
   output reg mem_to_reg,
   output reg [1:0] alu_op,
   output reg mem_write,
   output reg alu_src,
   output reg is_imm);

  always @(clk)
  begin
    $display("--------->Opcode: %b", opcode);
    case (opcode)
      7'b0110011: /*R-type*/
      begin
        branch = 1'b0;
        reg_write = 1'b1;
        mem_read = 1'b0;
        mem_to_reg = 1'b0;
        alu_op = 2'b10;
        mem_write = 1'b0;
        alu_src = 1'b0;
        is_imm = 1'b0;
      end

      7'b0000011: /*I-type*/
      begin
        branch = 1'b0;
        reg_write = 1'b1;
        mem_read = 1'b1;
        mem_to_reg = 1'b1;
        alu_op = 2'b00;
        mem_write = 1'b0;
        alu_src = 1'b1;
        case (funct3)
          3'b001:
            is_imm = 1'b1;
          default:
            is_imm = 1'b0;
        endcase
      end

      7'b0100011: /*S-type*/
      begin
        branch = 1'b0;
        reg_write = 1'b0;
        mem_read = 1'b0;
        mem_to_reg = 1'b0; /*reg_write is 0, so we do not actually care about this bit*/
        alu_op = 2'b00;
        mem_write = 1'b1;
        alu_src = 1'b1;
        case (funct3)
          3'b001:
            is_imm = 1'b1;
          default:
            is_imm = 1'b0;
        endcase
      end

      7'b1100011: /*branch*/
      begin
        branch = 1'b1;
        reg_write = 1'b0;
        mem_read = 1'b0;
        mem_to_reg = 1'b0; /*reg_write is 0, so we do not actually care about this bit*/
        alu_op = 2'b01;
        mem_write = 1'b0;
        alu_src = 1'b0;
        is_imm = 1'b0;
      end

      7'b1100111: /*jump*/
      begin
        branch = 1'b1;
        reg_write = 1'b0;
        mem_read = 1'b0;
        mem_to_reg = 1'b0; /*reg_write is 0, so we do not actually care about this bit*/
        alu_op = 2'b11;
        mem_write = 1'b0;
        alu_src = 1'b0;
        is_imm = 1'b0;
      end

      default:
      begin
        // TODO: que se hace aqui
      end
    endcase
  end
endmodule
