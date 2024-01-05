// GNU General Public License
//
// Copyright : (c) 2023-2024 Javier Beiro Piñón
//           : (c) 2023-2024 Beatriz Navidad Vilches
//           : (c) 2023-2024 Stefano Petrilli
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

`include "src/parameters.v"

`include "tests/utils/tb_utils.v"

`include "src/decode/control_unit.v"

module ControlUnit_tb();
  reg clk;
  reg [6:0] opcode;
  reg [2:0] funct3;
  wire branch;
  wire reg_write;
  wire mem_read;
  wire mem_to_reg;
  wire [1:0] alu_op;
  wire mem_write;
  wire alu_src;
  wire is_imm;

  ControlUnit control_unit
              (.opcode(opcode),
               .funct3(funct3),
               .branch(branch),
               .reg_write(reg_write),
               .mem_read(mem_read),
               .mem_to_reg(mem_to_reg),
               .alu_op(alu_op),
               .mem_write(mem_write),
               .alu_src(alu_src),
               .is_imm(is_imm));

  task automatic reset_input;
    begin
      $display("*** Resetting input ***");
      clk = 1'b0;
      opcode = 7'd0;
      funct3 = 3'b000;
      #CLK_PERIOD;
      $display("Done");
    end
  endtask

  task automatic run_tests;
    begin
      integer err;
      $display("*** Run tests ***");
      test_R(err);
      check_err(err, "R TYPE");

      test_I(err);
      check_err(err, "I TYPE");

      test_S(err);
      check_err(err, "S TYPE");

      test_branch(err);
      check_err(err, "BRANCH");

      test_jump(err);
      check_err(err, "JUMP");

      $display("Done");
    end
  endtask

  task automatic print_tb_info;
    input string test_name;
    input branch_expected;
    input reg_write_expected;
    input mem_read_expected;
    input mem_to_reg_expected;
    input [1:0] alu_op_expected;
    input mem_write_expected;
    input alu_src_expected;
    input is_imm_expected;
    begin
      $display("Test %s: assert when opcode = %b ", test_name, opcode);
      $display("-- branch should be %b, got %b", branch_expected, branch);
      $display("-- reg_write should be %b, got %b", reg_write_expected, reg_write);
      $display("-- mem_read should be %b, got %b", mem_read_expected, mem_read);
      $display("-- mem_to_reg should be %b, got %b", mem_to_reg_expected, mem_to_reg);
      $display("-- alu_op should be %b, got %b", alu_op_expected, alu_op);
      $display("-- mem_write should be %b, got %b", mem_write_expected, mem_write);
      $display("-- alu_src should be %b, got %b", alu_src_expected, alu_src);
      $display("-- is_imm should be %b, got %b",is_imm_expected, is_imm);
    end
  endtask

  //
  // Tests
  //
  task automatic test_R;
    output integer err;
    reg branch_expected;
    reg reg_write_expected;
    reg mem_read_expected;
    reg mem_to_reg_expected;
    reg [1:0] alu_op_expected;
    reg mem_write_expected;
    reg alu_src_expected;
    reg is_imm_expected;

    begin
      #CLK_PERIOD;
      clk = 1'b1;
      opcode = 7'b0110011;
      funct3 = 3'b001;

      branch_expected = 1'b0;
      reg_write_expected = 1'b1;
      mem_read_expected = 1'b0;
      mem_to_reg_expected = 1'b0;
      alu_op_expected = 2'b10;
      mem_write_expected = 1'b0;
      alu_src_expected = 1'b0;
      is_imm_expected = 1'b0;

      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;

      print_tb_info("R type", branch_expected, reg_write_expected, mem_read_expected,
                    mem_to_reg_expected, alu_op_expected, mem_write_expected, alu_src_expected, is_imm_expected);

      err = ({branch_expected, reg_write_expected, mem_read_expected,
              mem_to_reg_expected, alu_op_expected, mem_write_expected, alu_src_expected}!==
             {branch, reg_write, mem_read, mem_to_reg, alu_op, mem_write, alu_src});
    end
  endtask

  task automatic test_I;
    output integer err;
    reg branch_expected;
    reg reg_write_expected;
    reg mem_read_expected;
    reg mem_to_reg_expected;
    reg [1:0] alu_op_expected;
    reg mem_write_expected;
    reg alu_src_expected;
    reg is_imm_expected;

    begin
      #CLK_PERIOD;
      clk = 1'b1;
      opcode = 7'b0000011;
      funct3 = 3'b001;

      branch_expected = 1'b0;
      reg_write_expected = 1'b1;
      mem_read_expected = 1'b1;
      mem_to_reg_expected = 1'b1;
      alu_op_expected = 2'b00;
      mem_write_expected = 1'b0;
      alu_src_expected = 1'b1;
      is_imm_expected = 1'b1;

      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;

      print_tb_info("I type", branch_expected, reg_write_expected, mem_read_expected,
                    mem_to_reg_expected, alu_op_expected, mem_write_expected, alu_src_expected, is_imm_expected);

      err = ({branch_expected, reg_write_expected, mem_read_expected,
              mem_to_reg_expected, alu_op_expected, mem_write_expected, alu_src_expected}!==
             {branch, reg_write, mem_read, mem_to_reg, alu_op, mem_write, alu_src});
    end
  endtask

  task automatic test_S;
    output integer err;
    reg branch_expected;
    reg reg_write_expected;
    reg mem_read_expected;
    reg mem_to_reg_expected;
    reg [1:0] alu_op_expected;
    reg mem_write_expected;
    reg alu_src_expected;
    reg is_imm_expected;

    begin
      #CLK_PERIOD;
      clk = 1'b1;
      opcode = 7'b0100011;
      funct3 = 3'b000;

      branch_expected = 1'b0;
      reg_write_expected = 1'b0;
      mem_read_expected = 1'b0;
      mem_to_reg_expected = 1'b0;
      alu_op_expected = 2'b00;
      mem_write_expected = 1'b1;
      alu_src_expected = 1'b1;
      is_imm_expected = 1'b0;

      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;

      print_tb_info("S type", branch_expected, reg_write_expected, mem_read_expected,
                    mem_to_reg_expected, alu_op_expected, mem_write_expected, alu_src_expected, is_imm_expected);

      err = ({branch_expected, reg_write_expected, mem_read_expected,
              mem_to_reg_expected, alu_op_expected, mem_write_expected, alu_src_expected}!==
             {branch, reg_write, mem_read, mem_to_reg, alu_op, mem_write, alu_src});
    end
  endtask

  task automatic test_branch;
    output integer err;
    reg branch_expected;
    reg reg_write_expected;
    reg mem_read_expected;
    reg mem_to_reg_expected;
    reg [1:0] alu_op_expected;
    reg mem_write_expected;
    reg alu_src_expected;
    reg is_imm_expected;

    begin
      #CLK_PERIOD;
      clk = 1'b1;
      opcode = 7'b1100011;
      funct3 = 3'b001;

      branch_expected = 1'b1;
      reg_write_expected = 1'b0;
      mem_read_expected = 1'b0;
      mem_to_reg_expected = 1'b0;
      alu_op_expected = 2'b01;
      mem_write_expected = 1'b0;
      alu_src_expected = 1'b0;
      is_imm_expected = 1'b0;

      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;

      print_tb_info("branch", branch_expected, reg_write_expected, mem_read_expected,
                    mem_to_reg_expected, alu_op_expected, mem_write_expected, alu_src_expected, is_imm_expected);

      err = ({branch_expected, reg_write_expected, mem_read_expected,
              mem_to_reg_expected, alu_op_expected, mem_write_expected, alu_src_expected}!==
             {branch, reg_write, mem_read, mem_to_reg, alu_op, mem_write, alu_src});
    end
  endtask

  task automatic test_jump;
    output integer err;
    reg branch_expected;
    reg reg_write_expected;
    reg mem_read_expected;
    reg mem_to_reg_expected;
    reg [1:0] alu_op_expected;
    reg mem_write_expected;
    reg alu_src_expected;
    reg is_imm_expected;

    begin
      #CLK_PERIOD;
      clk = 1'b1;
      opcode = 7'b1100111;
      funct3 = 3'b001;

      branch_expected = 1'b1;
      reg_write_expected = 1'b0;
      mem_read_expected = 1'b0;
      mem_to_reg_expected = 1'b0;
      alu_op_expected = 2'b11;
      mem_write_expected = 1'b0;
      alu_src_expected = 1'b0;
      is_imm_expected = 1'b0;

      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;

      print_tb_info("jump", branch_expected, reg_write_expected, mem_read_expected,
                    mem_to_reg_expected, alu_op_expected, mem_write_expected, alu_src_expected, is_imm_expected);

      err = ({branch_expected, reg_write_expected, mem_read_expected,
              mem_to_reg_expected, alu_op_expected, mem_write_expected, alu_src_expected}!==
             {branch, reg_write, mem_read, mem_to_reg, alu_op, mem_write, alu_src});
    end
  endtask

  //
  // Main tb code
  //
  initial
  begin
    print_info("Testing ControlUnit");

    reset_input();
    run_tests();

    print_info("Testing finised");

    $finish;
  end
endmodule
