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

`include "src/common/adder.v"
`include "src/execution/multiplier.v"

module ALU
  (input wire clk,
   input [31:0] input_first,
   input [31:0] input_second,
   input [1:0] alu_op,
   output zero,
   output [31:0] result);

  wire [31:0] tmp_sum_result, tmp_mul_result;
  wire tmp_sum_zero;

  reg [31:0] reg_result;
  reg reg_zero;

  Adder #(.WIDTH(32)) adder (
          .a(input_first),
          .b(input_second),
          .carry_in(1'b0),
          .sum(tmp_sum_result),
          .carry_out(tmp_sum_zero)
        );

  Multiplier #(.WIDTH(32), .NIBBLE_WIDTH(4)) multiplier (
               .clock(clk),
               .start_multiplication(1'b1), /*?*/
               .multiplicand(input_first),
               .multiplier(input_second),
               .result(tmp_mul_result)
             );

  always @(*)
  begin
    case (alu_op)
      2'b00: /*add*/
      begin
        {reg_result, reg_zero} <= {tmp_sum_result, tmp_sum_zero};
      end

      2'b01: /*sub*/
      begin
        {reg_result, reg_zero} <= {tmp_sum_result, tmp_sum_zero};
      end

      2'b10: /*mul*/
      begin
        {reg_result, reg_zero} <= {tmp_mul_result, (tmp_mul_result == 0)};
      end

      default:
      begin
        // TODO: que hacer aqui
      end
    endcase
  end
  assign result = reg_result;
  assign zero = reg_zero;
endmodule
