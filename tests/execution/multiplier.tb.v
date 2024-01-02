// GNU General Public License
//
// Copyright : (c) 2023-2024 Javier Beiro Piñón
//           : (c) 2023-2024 Beatriz Navidad Vilches
//           : (c) 2023-2024 Stefano Petrili
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

`include "tests/utils/tb_utils.v"

`include "src/execution/multiplier.v"

module Multiplier_tb();
  reg clk;
  reg [31:0] multiplicand, multiplier;
  wire [31:0] result;
  wire overflow;
  integer i;

  parameter CLK_PERIOD = 1;

  Multiplier #(32) uut (
               .clk(clk),
               .multiplicand(multiplicand),
               .multiplier(multiplier),
               .result(result),
               .overflow(overflow)
             );

  task automatic reset_input;
    begin
      $display("*** Resetting input ***");
      clk = 1'b0;
      multiplicand = 32'd0;
      multiplier = 32'd0;
      #CLK_PERIOD;
      $display("Done");
    end
  endtask

  task automatic run_tests;
    begin
      integer err;
      $display("*** Run tests ***");
      test_1(err);
      check_err(err, "1");

      test_2(err);
      check_err(err, "2");

      test_3(err);
      check_err(err, "3");

      test_4(err);
      check_err(err, "4");

      test_5(err);
      check_err(err, "5");

      test_6(err);
      check_err(err, "6");

      $display("Done");
    end
  endtask

  task automatic print_tb_info;
    input string test_name;
    input [31:0] result_expected;
    input overflow_expected;
    begin
      $display("Test case %s: assert when multiplicand = %h and multiplier = %h", test_name, multiplicand, multiplier);
      $display("-- result should be %h, got %h", result_expected, result);
      $display("-- overflow should be %h, got %h", overflow_expected, overflow);
    end
  endtask

  task automatic test_1;
    output integer err;
    reg [31:0] result_expected;
    reg overflow_expected;

    begin
      #CLK_PERIOD;
      clk = 1'b1;
      multiplicand = 32'h000000FF;
      multiplier = 32'h00000083;

      result_expected = 32'h0000827D;
      overflow_expected = 1'b0;

      #CLK_PERIOD;
      clk = 1'b0;

      for (i = 0; i < 4; i = i + 1)
      begin
        #CLK_PERIOD clk = ~clk;
        #CLK_PERIOD clk = ~clk;
      end

      print_tb_info("1", result_expected, overflow_expected);

      err = (result !== result_expected);
    end
  endtask

  task automatic test_2;
    output integer err;
    reg [31:0] result_expected;
    reg overflow_expected;

    begin
      #CLK_PERIOD;
      clk = 1'b1;
      multiplicand = 32'h000000AA;
      multiplier = 32'h000000BB;

      result_expected = 32'h00007C2E;
      overflow_expected = 1'b0;

      #CLK_PERIOD;
      clk = 1'b0;

      for (i = 0; i < 4; i = i + 1)
      begin
        #CLK_PERIOD clk = ~clk;
        #CLK_PERIOD clk = ~clk;
      end

      print_tb_info("2", result_expected, overflow_expected);

      err = (result !== result_expected);
    end
  endtask

  task automatic test_3;
    output integer err;
    reg [31:0] result_expected;
    reg overflow_expected;

    begin
      #CLK_PERIOD;
      clk = 1'b1;
      multiplicand = 32'h00001FFF;
      multiplier = 32'h00001FFF;

      result_expected = 32'h03FFC001;
      overflow_expected = 1'b0;

      #CLK_PERIOD;
      clk = 1'b0;

      for (i = 0; i < 4; i = i + 1)
      begin
        #CLK_PERIOD clk = ~clk;
        #CLK_PERIOD clk = ~clk;
      end

      print_tb_info("3", result_expected, overflow_expected);

      err = (result !== result_expected);
    end
  endtask

  task automatic test_4;
    output integer err;
    reg [31:0] result_expected;
    reg overflow_expected;

    begin
      #CLK_PERIOD;
      clk = 1'b1;
      multiplicand = 32'h00007FFF;
      multiplier = 32'h00007FFF;

      result_expected = 32'h3FFF0001;
      overflow_expected = 1'b0;

      #CLK_PERIOD;
      clk = 1'b0;

      for (i = 0; i < 4; i = i + 1)
      begin
        #CLK_PERIOD clk = ~clk;
        #CLK_PERIOD clk = ~clk;
      end

      print_tb_info("4", result_expected, overflow_expected);

      err = (result !== result_expected);
    end
  endtask

  task automatic test_5;
    output integer err;
    reg [31:0] result_expected;
    reg overflow_expected;

    begin
      #CLK_PERIOD;
      clk = 1'b1;
      multiplicand = 32'h0001FFFF;
      multiplier = 32'h000FFFF;

      result_expected = 32'hFFFD0001;
      overflow_expected = 1'b1;

      #CLK_PERIOD;
      clk = 1'b0;

      for (i = 0; i < 4; i = i + 1)
      begin
        #CLK_PERIOD clk = ~clk;
        #CLK_PERIOD clk = ~clk;
      end

      print_tb_info("5", result_expected, overflow_expected);

      err = (result !== result_expected);
    end
  endtask

  task automatic test_6;
    output integer err;
    reg [31:0] result_expected;
    reg overflow_expected;

    begin
      #CLK_PERIOD;
      clk = 1'b1;
      multiplicand = 32'h0000000;
      multiplier = 32'h000000;

      result_expected = 32'h00000000;
      overflow_expected = 1'b0;

      #CLK_PERIOD;
      clk = 1'b0;

      for (i = 0; i < 4; i = i + 1)
      begin
        #CLK_PERIOD clk = ~clk;
        if ({overflow, result} === {1'b0, 32'h00000000})
        begin
          begin_red_print();
          $display("Failed. Result available before five clock cycles");
          end_color_print();
          $finish;
        end
        #CLK_PERIOD clk = ~clk;
      end

      print_tb_info("6", result_expected, overflow_expected);

      err = (result !== result_expected);
    end
  endtask

  initial
  begin
    print_info("Testing multiple stage Multiplier");

    reset_input();
    run_tests();

    print_info("Testing finised");

    $finish;
  end
endmodule
