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

`include "src/common/adder.v"
`include "src/execution/multiplier.v"

module ALU
  (
    // In
    input wire clk,
    input wire [31:0] input_first,
    input wire [31:0] input_second,
    input wire [1:0] alu_op,

    // Out
    output reg zero,
    output reg [31:0] result,
    output reg op_done);

`include "src/parameters.v"

  wire [31:0] tmp_sum_result, tmp_mul_result;
  wire tmp_sum_zero;
  wire mul_done;

  reg [31:0] reg_result;
  reg reg_zero;

  Adder #(.WIDTH(32)) adder (
          .a(input_first),
          .b(input_second),
          .carry_in(1'b0),
          .sum(tmp_sum_result),
          .carry_out(tmp_sum_zero)
        );

  Multiplier multiplier (
               .clk(clk),
               .multiplicand(input_first),
               .multiplier(input_second),
               .start_mul(alu_op === 2'b10),
               .result(tmp_mul_result),
               .op_done(mul_done)
             );

  initial
  begin
    op_done = 1;
  end

  always @(posedge clk)
  begin
    op_done = 0;
    `ALU_DISPLAY($sformatf("Perform the operation: %d", alu_op));
    case (alu_op)
      2'b00: /*add*/
      begin
        `ALU_DISPLAY($sformatf("Performing add of %d plus %d with result %d", input_first, input_second, tmp_sum_result));
        {reg_result, reg_zero} = {tmp_sum_result, tmp_sum_zero};
        op_done = 1;
      end

      2'b01: /*sub*/
      begin
        `ALU_DISPLAY($sformatf("Performing sub of %d minus %d with result %d", input_first, input_second, tmp_sum_result));
        {reg_result, reg_zero} = {tmp_sum_result, tmp_sum_zero};
        op_done = 1;
      end

      2'b10: /*mul*/
      begin
        op_done = 0;
        `ALU_DISPLAY($sformatf("op_done %d before checking mul_done %d", op_done, mul_done));
        if(mul_done)
        begin
          `ALU_DISPLAY($sformatf("Performing mul of %d times %d with result %d", input_first, input_second, tmp_mul_result));
          {reg_result, reg_zero} = {tmp_mul_result, (tmp_mul_result == 0)};
          op_done = 1;
        end
      end

      default:
      begin
        op_done = 1;
      end
    endcase
  end
  assign result = reg_result;
  assign zero = reg_zero;
endmodule
