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

`include "src/memory/cache.v"

module Cache_tb;

  parameter LINE_SIZE = 128;
  parameter ADDRESS_WIDTH = 32;
  parameter WORD_WIDTH = 32;
  parameter WORDS_PER_LINE = 4;

  reg clk;
  reg reset;
  reg access;
  reg [ADDRESS_WIDTH-1:0] address;
  reg [WORD_WIDTH-1:0] data_in;
  reg op;
  reg byte_op;
  reg [LINE_SIZE-1:0] mem_data_out;
  wire [WORD_WIDTH-1:0] data_out;
  wire hit, data_ready;

  reg [LINE_SIZE-1:0] mem_data_in;
  reg mem_enable;
  reg mem_op;

  parameter CLK_PERIOD = 1;
  parameter D_CLK_PERIOD = 2;

  Cache uut (
          .clk(clk),
          .reset(reset),
          .address(address),
          .op(op),
          .byte_op(byte_op),
          .access(access),
          .mem_data_out(mem_data_out),
          .data_out(data_out),
          .mem_data_in(mem_data_in),
          .data_in(data_in),
          .mem_enable(mem_enable),
          .mem_op(mem_op),
          .hit(hit),
          .data_ready(data_ready)
        );

  // Clock generation
  // TODO: I think that in the tests it would be better to control the clock manually
  //       by setting it to 0 and 1 instead of using a clock generator.
  //       This way we can control that the modules actually take the number
  //       of cycles that we expect them to take. If we use a clock generator
  //       it's harder to know at any given point what the state of the system is.
  always #CLK_PERIOD clk = ~clk;

  task automatic reset_input;
    begin
      $display("*** Resetting input ***");
      clk = 1'b0;
      reset = 1'b0;
      access = 1'b0;
      address = 32'h0;
      data_in = 0;
      op = 1'b0;
      byte_op = 0;
      mem_data_out = 0;
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

      // test_2(err);
      // check_err(err, "2");

      // test_3(err);
      // check_err(err, "3");

      // test_4(err);
      // check_err(err, "4");

      // test_5(err);
      // check_err(err, "5");

      // test_6(err);
      // check_err(err, "6");

      // test_7(err);
      // check_err(err, "7");

      $display("Done");
    end
  endtask

  task automatic print_tb_info;
    input string test_name;
    input string test_description;
    input [31:0] data_out_expected;
    begin
      $display("Test case %s: %s", test_name, test_description);
      $display("-- data_out should be %h, got %h", data_out_expected, data_out);
    end
  endtask

  // Test Case 1: Write to an address
  task automatic test_1;
    output integer err;
    reg [31:0] data_out_expected;

    begin
      #CLK_PERIOD;
      address = 32'h00000004;
      data_in = 32'h00000011;
      op = 1'b0;  /*write*/
      access = 1;
      reset = 0;
      byte_op = 0;

      #D_CLK_PERIOD;

      op = 1'b1; /*read*/
      byte_op = 1;

      #D_CLK_PERIOD;

      data_out_expected = 32'h00000011;
      print_tb_info("1", "Write to an address then read", data_out_expected);

      err = (data_out !== data_out_expected);

      #D_CLK_PERIOD;
      access = 0;
    end
  endtask

  // Test Case 2: Write to the same memory address
  task automatic test_2;
    output integer err;
    reg [31:0] data_out_expected;

    begin
      #CLK_PERIOD;
      address = 32'h00000004;
      data_in = 32'h11111111;
      op = 1'b0;  /*write*/
      access = 1;
      reset = 0;
      byte_op = 0;

      #D_CLK_PERIOD;

      op = 1'b1; /*read*/
      byte_op = 1;

      #D_CLK_PERIOD;

      data_out_expected = 32'h00000011;
      print_tb_info("2", "Write to the same memory address", data_out_expected);

      err = (data_out !== data_out_expected);

      #D_CLK_PERIOD;
      access = 0;
    end
  endtask

  // Test Case 3: Write to the follow memory address
  task automatic test_3;
    output integer err;
    reg [31:0] data_out_expected;

    begin
      #CLK_PERIOD;
      address = 32'h00000002;
      data_in = 32'h11111111;
      op = 1'b0;  /*write*/
      access = 1;
      reset = 0;
      byte_op = 0;

      #D_CLK_PERIOD;

      op = 1'b1; /*read*/
      byte_op = 1;

      #D_CLK_PERIOD;

      data_out_expected = 32'h00000011;
      print_tb_info("3", "Write to another word in the same address", data_out_expected);

      err = (data_out !== data_out_expected);

      #D_CLK_PERIOD;
      access = 0;
    end
  endtask

  // Test Case 4: Write to another memory address
  task automatic test_4;
    output integer err;
    reg [31:0] data_out_expected;

    begin
      #CLK_PERIOD;
      address = 32'h00000004;
      data_in = 32'h22222222;
      op = 1'b0;  /*write*/
      access = 1;
      reset = 0;
      byte_op = 0;

      #D_CLK_PERIOD;

      op = 1'b1; /*read*/
      byte_op = 1;

      #D_CLK_PERIOD;

      data_out_expected = 32'h00000011;
      print_tb_info("4", "Write new address", data_out_expected);

      err = (data_out !== data_out_expected);

      #D_CLK_PERIOD;
      access = 0;
    end
  endtask

  // Test Case 5: Full cache and write in a new address
  task automatic test_5;
    output integer err;
    reg [31:0] data_out_expected;

    begin
      #CLK_PERIOD;
      address = 32'h00000008;
      data_in = 32'h33333333;
      op = 1'b0;  /*write*/
      access = 1;
      reset = 0;
      byte_op = 0;

      #D_CLK_PERIOD;

      op = 1'b1; /*read*/
      byte_op = 1;

      #D_CLK_PERIOD;

      data_out_expected = 32'h00000011;
      print_tb_info("5", "Line replacement", data_out_expected);

      err = (data_out !== data_out_expected);

      #D_CLK_PERIOD;
      access = 0;
    end
  endtask

  // Test Case 6: Read line and write in a new address
  task automatic test_6;
    output integer err;
    reg [31:0] data_out_expected;

    begin
      #CLK_PERIOD;
      address = 32'h00000004;
      // data_in = 32'h00000011;
      op = 1'b0;  /*write*/
      access = 1;
      reset = 0;
      byte_op = 0;

      #D_CLK_PERIOD;

      op = 1'b1; /*read*/
      byte_op = 1;

      #D_CLK_PERIOD;

      data_out_expected = 32'h00000011;
      print_tb_info("6", "Read from existing line", data_out_expected);

      err = (data_out !== data_out_expected);

      #D_CLK_PERIOD;
      access = 0;
    end
  endtask

  // Test Case 7: Write after the effect of read
  task automatic test_7;
    output integer err;
    reg [31:0] data_out_expected;

    begin
      #CLK_PERIOD;
      address = 32'h00000014;
      data_in = 32'h66666666;
      op = 1'b0;  /*write*/
      access = 1;
      reset = 0;
      byte_op = 0;

      #D_CLK_PERIOD;

      op = 1'b1; /*read*/
      byte_op = 1;

      #D_CLK_PERIOD;

      data_out_expected = 32'h00000011;
      print_tb_info("7", "Line replacement", data_out_expected);

      err = (data_out !== data_out_expected);

      #D_CLK_PERIOD;
      access = 0;
    end
  endtask

  initial
  begin
    print_info("Testing Cache");

    reset_input();
    run_tests();

    print_info("Testing finised");

    $finish;
  end
endmodule
