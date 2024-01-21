// GNU General Public License
//
// Copyright : (c) 2023 Javier Beiro Piñón
//           : (c) 2023 Beatriz Navidad Vilches
//           : (c) 2023 Stefano Petrilli
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

module ALUControl(
  // In
  input wire clk,
  input [6:0] inst /*bytes [31,25]*/,
  input [1:0] cu_alu_op,

  // Out
  output reg [1:0] alu_op,
  output reg set_nop);

  always @(*)
  begin
    case (cu_alu_op)
      2'b10: /*R-type*/
      begin
        case (inst)
          7'b0000000: /*add*/
            alu_op <= 2'b00;
          7'b0100000: /*sub*/
            alu_op <= 2'b01;
          7'b0000001: /*mul*/
            alu_op <= 2'b10;
          default:
          begin
            // TODO: que hacer aqui
          end
        endcase
        set_nop <= 0;
      end

      2'b00: /*I-type & S-type*/
      begin
        alu_op <= 2'b00;
        set_nop <= 0;
      end

      2'b01: /*branch*/
      begin
        alu_op <= 2'b01;
      end

      2'b11: /*jump*/
      begin
        alu_op <= 2'b00;
        set_nop <= 1;
      end
    endcase
  end
endmodule
