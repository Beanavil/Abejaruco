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

`include "tests/utils/tb_utils.v"
`include "src/execution/alu_control.v"

module ALUControl_tb();
  reg clk;
  reg [6:0] inst;
  reg [1:0] ctrl_alu_op;
  wire [1:0] alu_op;

  parameter CLK_PERIOD = 1;

  ALUControl alu_control
             (.inst(inst),
              .ctrl_alu_op(ctrl_alu_op),
              .alu_op(alu_op));

  task automatic reset;
    begin
      $display("*** Reset signals ***");
      clk = 1'b0;
      inst = 7'd0;
      ctrl_alu_op = 2'b00;
      #CLK_PERIOD;
      $display("Done");
    end
  endtask

  task automatic run_tests;
    begin
      integer err;
      $display("*** Run tests ***");
      test_add(err);
      check_err(err, "ADD");

      test_sub(err);
      check_err(err, "SUB");

      test_mul(err);
      check_err(err, "MUL");

      test_load(err);
      check_err(err, "LOAD");

      test_store(err);
      check_err(err, "STORE");

      test_branch(err);
      check_err(err, "BRANCH");

      test_jump(err);
      check_err(err, "JUMP");

      $display("Done");
    end
  endtask

  task automatic print_tb_info;
    input string test_name;
    input [1:0] alu_op_expected;
    begin
      $display("Test %s: assert when inst (func7) = %b and ctrl_alu_op = %b", test_name, inst, ctrl_alu_op);
      $display("-- alu_op should be %b, got %b", alu_op_expected, alu_op);
    end
  endtask

  //
  // Tests
  //
  task automatic test_add;
    output integer err;
    reg [1:0] alu_op_expected;

    begin
      #CLK_PERIOD;
      clk = 1;
      inst =  7'b0000000;
      ctrl_alu_op = 2'b10;

      alu_op_expected = 2'b00;

      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;

      print_tb_info("add", alu_op_expected);

      err = (alu_op !== alu_op_expected);
    end
  endtask

  task automatic test_sub;
    output integer err;
    reg [1:0] alu_op_expected;

    begin
      #CLK_PERIOD;
      clk = 1;
      inst =  7'b0100000;
      ctrl_alu_op = 2'b10;

      alu_op_expected = 2'b01;

      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;

      print_tb_info("sub", alu_op_expected);

      err = (alu_op !== alu_op_expected);
    end
  endtask

  task automatic test_mul;
    output integer err;
    reg [1:0] alu_op_expected;

    begin
      #CLK_PERIOD;
      clk = 1;
      inst =  7'b0000001;
      ctrl_alu_op = 2'b10;

      alu_op_expected = 2'b10;

      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;

      print_tb_info("mul", alu_op_expected);

      err = (alu_op !== alu_op_expected);
    end
  endtask

  task automatic test_load;
    output integer err;
    reg [1:0] alu_op_expected;

    begin
      #CLK_PERIOD;
      clk = 1;
      inst =  7'd0; /*we don't care*/
      ctrl_alu_op = 2'b00;

      alu_op_expected = 2'b00;

      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;

      print_tb_info("load", alu_op_expected);

      err = (alu_op !== alu_op_expected);
    end
  endtask

  task automatic test_store;
    output integer err;
    reg [1:0] alu_op_expected;

    begin
      #CLK_PERIOD;
      clk = 1;
      inst =  7'd0; /*we don't care*/
      ctrl_alu_op = 2'b00;

      alu_op_expected = 2'b00;

      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;

      print_tb_info("store", alu_op_expected);

      err = (alu_op !== alu_op_expected);
    end
  endtask

  task automatic test_branch;
    output integer err;
    reg [1:0] alu_op_expected;

    begin
      #CLK_PERIOD;
      clk = 1;
      inst =  7'd0; /*we don't care*/
      ctrl_alu_op = 2'b01;

      alu_op_expected = 2'b01;

      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;

      print_tb_info("branch", alu_op_expected);

      err = (alu_op !== alu_op_expected);
    end
  endtask

  task automatic test_jump;
    output integer err;
    reg [1:0] alu_op_expected;

    begin
      #CLK_PERIOD;
      clk = 1;
      inst =  7'd0; /*we don't care*/
      ctrl_alu_op = 2'b11;

      alu_op_expected = 2'b00;

      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;

      print_tb_info("jump", alu_op_expected);

      err = (alu_op !== alu_op_expected);
    end
  endtask

  //
  // Main tb code
  //
  initial
  begin
    print_info("Testing ALUControl");

    reset();
    run_tests();

    print_info("Done");

  end
endmodule
