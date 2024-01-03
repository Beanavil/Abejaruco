// GNU General Public License
//
// Copyright : (c) 2023-2024 Javier Beiro Piñón
//           : (c) 2023-2024 Beatriz Navidad Vilches
//           : (c) 2023-2024 Stefano Petrili
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

`timescale 1ns / 1ps

`include "tests/utils/tb_utils.v"

`include "src/abejaruco.v"

module Abejaruco_tb();
  reg clk;
  reg reset;
  wire [WORD_WIDTH-1:0] icache_data_out;
  wire [1:0] cu_alu_op;
  wire [WORD_WIDTH-1:0] alu_result;

  parameter CLK_PERIOD = 1;
  parameter RESET_PERIOD = 5;
  parameter CACHE_LINE_SIZE = 128;
  parameter WORD_WIDTH = 32;

  Abejaruco uut(
              .reset(reset),
              .clk(clk),
              .icache_data_out(icache_data_out),
              .cu_alu_op(cu_alu_op)
            );

  task automatic reset_input;
    begin
      $display("*** Resetting input ***");
      clk = 0;
      reset = 1;
      #RESET_PERIOD reset = 0;
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

      $display("Done");
    end
  endtask

  task automatic print_tb_info;
    input string test_name;
    input string test_description;
    input [WORD_WIDTH-1:0] icache_data_out_expected;
    input [1:0] cu_alu_op_expected;
    begin
      $display("Test case %s: %s", test_name, test_description);
      $display("-- icache_data_out should be %h, got %h", icache_data_out_expected, icache_data_out);
      $display("-- cu_alu_op should be %h, got %h", cu_alu_op_expected, cu_alu_op);
    end
  endtask

  // Test 1: Test that after 6 clock cycles we have the first instruction in icache_data_out
  task automatic test_1;
    output integer err;
    reg [CACHE_LINE_SIZE-1:0] icache_data_out_expected;
    reg [1:0] cu_alu_op_expected;

    begin
      clk = 1'b0;
      reset = 1'b1;

      #2;
      reset = 1'b0;

      clk = 1'b1;

      for (integer i = 0; i < 5; i = i + 1)
      begin
        #CLK_PERIOD clk = 1'b0;
        #CLK_PERIOD clk = 1'b1;
      end

      #CLK_PERIOD;

      icache_data_out_expected = 32'h00000033;
      cu_alu_op_expected = 2'b00;

      print_tb_info("1", "Load first instruction", icache_data_out_expected, cu_alu_op_expected);

      err = (icache_data_out !== icache_data_out_expected);
    end
  endtask

  // Test 2: Test that after 6 clock cycles we also have the second instruction and the control unit detects an add
  task automatic test_2;
    output integer err;
    reg [CACHE_LINE_SIZE-1:0] icache_data_out_expected;
    reg [1:0] cu_alu_op_expected;

    begin
      #CLK_PERIOD clk = 1'b0;
      #CLK_PERIOD clk = 1'b1;

      #CLK_PERIOD;
      #CLK_PERIOD;

      icache_data_out_expected = 32'h00000004;
      cu_alu_op_expected = 2'b10;

      print_tb_info("2", "Load second instruction", icache_data_out_expected, cu_alu_op_expected);

      err = ({icache_data_out, cu_alu_op} !== {icache_data_out_expected, cu_alu_op_expected});
    end
  endtask

  initial
  begin
    print_info("Testing Abejaruco");

    reset_input();
    run_tests();

    print_info("Testing finised");

    $finish;
  end

endmodule

