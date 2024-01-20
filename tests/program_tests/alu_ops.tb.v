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

`include "src/abejaruco.v"
`include "tests/utils/tb_utils.v"

module ALUOps_tb();
`include "src/parameters.v"

  reg clk = 0;
  reg reset = 0;

  parameter PROGRAM = "../../../programs/alu_ops.o";

  Abejaruco #(.PROGRAM(PROGRAM)) uut (
              .reset(reset),
              .clk(clk),
              .rm0_initial(32'b1000)
            );

  initial
  begin
    print_info("Testing ALU instructions (mul, add, sub)");

    $dumpfile("alu_ops.vcd");
    $dumpvars(0, uut);

    #100;

    print_info("Testing finised");

    $finish;
  end

  always
  begin
    #CLK_PERIOD clk = ~clk;
  end

endmodule
