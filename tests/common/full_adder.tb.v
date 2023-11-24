// GNU General Public License
//
// Copyright : (c) 2023 Javier Beiro Piñón
// : (c) 2023 Beatriz Navidad Vilches
// : (c) 2023 Stefano Petrili
//
// Thclkis file is part of Abejaruco <https:// github.com/Beanavil/Abejaruco>.
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

`timescale 1ns / 1ps
`default_nettype none

`include "src/common/full_adder.v"

module HalfAdder_tb();
    
    reg a, b, carry_in;
    wire sum, carry_out;
    
    Full_adder full_adder(
    .a(a),
    .b(b),
    .carry_in(carry_in),
    .sum(sum),
    .carry_out(carry_out)
    );
    
    initial begin
        $display("Testing full_adder");
        $display("-------------------------------");
        
        a = 0; b = 0; carry_in = 0;
        #1
        $display("Test case 1: assert when a = 0, b = 0, carry_in = 0, sum = 0, carry_out = 0");
        if (sum != 0) $display("Failed. Expected sum: 0, Actual: %b", sum);
        if (carry_out != 0) $display("Failed. Expected carry_out: 0, Actual: %b", carry_out);
        
        a = 0; b = 0; carry_in = 1;
        #1
        $display("Test case 2: assert when a = 0, b = 0, carry_in = 1, sum = 1, carry_out = 0");
        if (sum != 1) $display("Failed. Expected sum: 1, Actual: %b", sum);
        if (carry_out != 0) $display("Failed. Expected carry_out: 0, Actual: %b", carry_out);
        
        a = 0; b = 1; carry_in = 0;
        #1
        $display("Test case 3: assert when a = 0, b = 1, carry_in = 0, sum = 1, carry_out = 0");
        if (sum != 1) $display("Failed. Expected sum: 1, Actual: %b", sum);
        if (carry_out != 0) $display("Failed. Expected carry_out: 0, Actual: %b", carry_out);
        
        a = 0; b = 1; carry_in = 1;
        #1
        $display("Test case 4: assert when a = 0, b = 1, carry_in = 1, sum = 0, carry_out = 1");
        if (sum != 0) $display("Failed. Expected sum: 0, Actual: %b", sum);
        if (carry_out != 1) $display("Failed. Expected carry_out: 1, Actual: %b", carry_out);
        
        a = 1; b = 0; carry_in = 0;
        #1
        $display("Test case 5: assert when a = 1, b = 0, carry_in = 0, sum = 1, carry_out = 0");
        if (sum != 1) $display("Failed. Expected sum: 1, Actual: %b", sum);
        if (carry_out != 0) $display("Failed. Expected carry_out: 0, Actual: %b", carry_out);
        
        a = 1; b = 0; carry_in = 1;
        #1
        $display("Test case 6: assert when a = 1, b = 0, carry_in = 1, sum = 0, carry_out = 1");
        if (sum != 0) $display("Failed. Expected sum: 0, Actual: %b", sum);
        if (carry_out != 1) $display("Failed. Expected carry_out: 1, Actual: %b", carry_out);
        
        a = 1; b = 1; carry_in = 0;
        #1
        $display("Test case 7: assert when a = 1, b = 1, carry_in = 0, sum = 0, carry_out = 1");
        if (sum != 0) $display("Failed. Expected sum: 0, Actual: %b", sum);
        if (carry_out != 1) $display("Failed. Expected carry_out: 1, Actual: %b", carry_out);
        
        a = 1; b = 1; carry_in = 1;
        #1
        $display("Test case 8: assert when a = 1, b = 1, carry_in = 1, sum = 1, carry_out = 1");
        if (sum != 1) $display("Failed. Expected sum: 1, Actual: %b", sum);
        if (carry_out != 1) $display("Failed. Expected carry_out: 1, Actual: %b", carry_out);
        $finish;
    end
endmodule
