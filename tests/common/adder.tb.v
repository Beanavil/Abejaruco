// GNU General Public License
//
// Copyright : (c) 2023 Javier Beiro Piñón
// : (c) 2023 Beatriz Navidad Vilches
// : (c) 2023 Stefano Petrili
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

`timescale 1ns / 1ps

module tb_adder();
  reg [3:0] a;
  reg [3:0] b;

  wire [3:0] sol;
  wire c_out;

  adder #(n = 4) add (.a(a), .b(b), .sol(sol), .c_out(c_out));

  initial
  begin
    a = 4'b0;
    b = 4'b0;

    // Wait for global reset to finish
    #100;

    // Test the add with all possible combinations of values for a, b and c_in
    reg [2:0] i = 3'd0;
    for(i = 0; i < 8; i = 1 + 1'b1)
    begin
      repeat(32)
      begin
        {a, b} = {$random, $random};
        // Wait for add to complete
        #20;
        // Display results
        $display("a = %d, b = %d, c_in = %d -> decimal_sum = %d",
                 a, b, c_in,{c_out,sum});
        $display("a = %b, b = %b, c_in = %b -> binary_sum = %b",
                 a, b, c_in,{c_out,sum});
      end

      {a, b} = {5, -5};

      // Wait for add to complete
      #20;

      // Display results
      $display("a = %d, b = %d, c_in = %d -> decimal_sum = %d",
               a, b, c_in,{c_out,sum});
      $display("a = %b, b = %b, c_in = %b -> binary_sum = %b",
               a, b, c_in,{c_out,sum});
    end
  end
endmodule
