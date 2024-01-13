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

//Condiciones: 
//1. Si el registro salida de ext es igual al registro entrada de id (y ex no ha terminado)

module HazzardDectUnit 
  (input wire clk,
   input reg [REGISTER_INDEX_WIDTH-1:0] id_reg_rt,
   input reg [REGISTER_INDEX_WIDTH-1:0] ex_reg_rs,
   input reg alu_op_done

   input reg [REGISTER_INDEX_WIDTH-1:0] men_reg_rt,
   input reg mem_op_done 
);
`include "src/parameters.v"

  always @(clk)
  begin
    if (id_reg_rt == ex_reg_rs && alu_op_done == 0)
      $display("Hazzard ALU - ALU");
    else if (id_reg_rt == mem_reg_re && mem_op_done == 0)
      $display("Hazzard ALU - MEM");
  end 

endmodule

