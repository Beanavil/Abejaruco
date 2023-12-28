// GNU General Public License
//
// Copyright : (c) 2023 Javier Beiro Piñón
//           : (c) 2023 Beatriz Navidad Vilches
//           : (c) 2023 Stefano Petrili
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

`default_nettype none

`timescale 1ns / 1ps

`include "src/execution/multiplier.v"

module Multiplier_tb();
  reg clock;
  reg start_multiplication;
  reg [31:0] multiplicand, multiplier;
  wire [31:0] result;
  wire overflow;
  integer i;

  Multiplier #(32) uut (
               .clock(clock),
               .start_multiplication(start_multiplication),
               .multiplicand(multiplicand),
               .multiplier(multiplier),
               .result(result),
               .overflow(overflow)
             );

  initial
  begin
    $display("Testing multiple stage Multiplier");
    $display("-------------------------------");
    clock = 0;

    start_multiplication = 0;
    multiplicand = 0;
    multiplier = 0;

    #1;
    clock = 1;
    start_multiplication = 1;
    multiplicand = 32'h000000FF;
    multiplier = 32'h00000083;

    #1;
    start_multiplication = 0;
    clock = 0;

    for (i = 0; i < 4; i = i + 1)
    begin
      #1 clock = ~clock;
      #1 clock = ~clock;
    end

    $display("Test case 1: assert when multiplicand = 32'h000000FF, multiplier = 32'h00000083, result should be 32'h0000827D");
    if (result !== 32'h0000827D)
    begin
      $display("Failed. Expected result: 32'h0000827D, Actual: %h", result);
    end
    else
    begin
      $display("Passed. Expected result: 32'h0000827D, Actual: %h", result);
    end

    clock = 1;
    start_multiplication = 1;
    multiplicand = 32'h000000AA;
    multiplier = 32'h000000BB;
    #1;
    start_multiplication = 0;
    clock = 0;
    for (i = 0; i < 4; i = i + 1)
    begin
      #1 clock = ~clock;
      #1 clock = ~clock;
    end
    $display("Test case 2: assert when multiplicand = 32'h000000AA, multiplier = 32'h000000BB, result should be 32'h00007c2e");
    if (result !== 32'h00007c2e)
    begin
      $display("Failed. Expected result: 32'h00007c2e, Actual: %h", result);
    end
    else
    begin
      $display("Passed. Expected result: 32'h00007c2e, Actual: %h", result);
    end

    clock = 1;
    start_multiplication = 1;
    multiplicand = 32'h00001FFF;
    multiplier = 32'h00001FFF;
    #1;
    start_multiplication = 0;
    clock = 0;
    for (i = 0; i < 4; i = i + 1)
    begin
      #1 clock = ~clock;
      #1 clock = ~clock;
    end
    $display("Test case 3: assert when multiplicand = 32'h00001FFF, multiplier = 32'h00001FFF, result should be 32'h03ffc001");
    if (result !== 32'h03ffc001)
    begin
      $display("Failed. Expected result: 32'h03ffc001, Actual: %h", result);
    end
    else
    begin
      $display("Passed. Expected result: 32'h03ffc001, Actual: %h", result);
    end

    clock = 1;
    start_multiplication = 1;
    multiplicand = 32'h00007FFF;
    multiplier = 32'h00007FFF;
    #1;
    start_multiplication = 0;
    clock = 0;

    for (i = 0; i < 4; i = i + 1)
    begin
      #1 clock = ~clock;
      #1 clock = ~clock;
    end
    $display("Test case 4: assert when multiplicand = 32'h00007FFF, multiplier = 32'h00007FFF, result should be 32'h3FFF0001");
    if (result !== 32'h3FFF0001)
    begin
      $display("Failed. Expected result: 32'3FFF0001, Actual: %h", result);
    end
    else
    begin
      $display("Passed. Expected result: 32'h3FFF0001, Actual: %h", result);
    end

    clock = 1;
    start_multiplication = 1;
    multiplicand = 32'h0001FFFF;
    multiplier = 32'h000FFFF;
    #1;
    start_multiplication = 0;
    clock = 0;
    for (i = 0; i < 4; i = i + 1)
    begin
      #1 clock = ~clock;
      #1 clock = ~clock;
    end
    $display("Test case 5: assert when multiplicand = 32'h0001FFFF, multiplier = 32'h0000FFFF, overflow should be 1");
    if (overflow !== 1)
    begin
      $display("Failed. Expected overflow 1, Actual: 0");
    end
    else
    begin
      $display("Passed. Overflow set to 1");
    end


    $display("Test case 6: assert that the multiplication finishes after five clock cycles");
    clock = 1;
    start_multiplication = 1;
    multiplicand = 32'h0000000;
    multiplier = 32'h000000;
    #1;
    start_multiplication = 0;
    clock = 0;

    for (i = 0; i < 4; i = i + 1)
    begin
      #1 clock = ~clock;
        if (overflow === 0 && result === 32'h00000000)
        begin
          $display("Failed. Result available before five clock cycles");
          $finish;
        end
      #1 clock = ~clock;
    end

    if (overflow === 0 && result === 32'h00000000)
    $display("Passed. Result available at fifth clock cycle");
    
    $finish;
  end
endmodule
