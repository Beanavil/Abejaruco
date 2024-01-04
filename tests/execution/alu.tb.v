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

`include "src/parameters.v"

`include "tests/utils/tb_utils.v"

`include "src/execution/alu.v"

module ALU_tb();
  reg clk;
  reg [31:0] input_first, input_second;
  reg [1:0] alu_op;
  wire zero;
  wire [31:0] result;

  ALU alu
      (.clk(clk),
       .input_first(input_first),
       .input_second(input_second),
       .alu_op(alu_op),
       .zero(zero),
       .result(result));

  task automatic reset_input;
    begin
      $display("*** Resetting input ***");
      clk = 1'b0;
      input_first = 32'd0;
      input_second = 32'd0;
      alu_op = 2'b00;
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

      test_add_of(err);
      check_err(err, "ADD WITH OVERFLOW");

      test_sub(err);
      check_err(err, "SUB");

      test_sub_uf(err);
      check_err(err, "SUB WITH UNDERFLOW");

      test_mul(err);
      check_err(err, "MUL");

      $display("Done");
    end
  endtask

  task automatic print_tb_info;
    input string test_name;
    input zero_expected;
    input [31:0] result_expected;
    begin
      $display("Test %s: assert when input_first = %h and input_second = %h", test_name, input_first, input_second);
      $display("-- result should be %h, got %h", result_expected, result);
      $display("-- zero should be %h, got %h", zero_expected, zero);
    end
  endtask

  //
  // Tests
  //
  task automatic test_add;
    output integer err;
    reg [31:0] result_expected;
    reg zero_expected;

    begin
      #CLK_PERIOD;
      clk = 1'b1;
      input_first =  32'shE;
      input_second = 32'sh9;
      alu_op = 2'b00;

      result_expected = 32'sh17;
      zero_expected = 1'b0;

      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;

      print_tb_info("add", zero_expected, result_expected);

      err = ({result, zero} !== {result_expected, zero_expected});
    end
  endtask

  task automatic test_add_of;
    output integer err;
    reg [31:0] result_expected;
    reg zero_expected;

    begin
      #CLK_PERIOD;
      clk = 1'b1;
      input_first =  32'sh7FFFFFFF;
      input_second = 32'sh1;
      alu_op = 2'b00;

      result_expected = 32'sh80000000;
      zero_expected = 1'b0;

      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;

      print_tb_info("add", zero_expected, result_expected);

      err = ({result, zero} !== {result_expected, zero_expected});
    end
  endtask

  task automatic test_sub;
    output integer err;
    reg [31:0] result_expected;
    reg zero_expected;

    begin
      #CLK_PERIOD;
      clk = 1'b1;
      input_first = 32'shE;
      input_second = -32'sh9;
      alu_op = 2'b01;

      result_expected = 32'sh5;
      zero_expected = 1'b1;

      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;

      print_tb_info("sub", 0, result_expected);

      err = ({result, zero} !== {result_expected, zero_expected});
    end
  endtask

  task automatic test_sub_uf;
    output integer err;
    reg [31:0] result_expected;
    reg zero_expected;

    begin
      #CLK_PERIOD;
      clk = 1'b1;
      input_first = -32'sh7FFFFFFF;
      input_second = -32'sh1;
      alu_op = 2'b01;

      result_expected = -32'sh80000000;
      zero_expected = 1'b1;

      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;
      #CLK_PERIOD clk = ~clk;

      print_tb_info("sub with underflow", 1, result_expected);

      err = ({result, zero} !== {result_expected, zero_expected});
    end
  endtask

  task automatic test_mul;
    output integer err;
    reg [31:0] result_expected;
    reg zero_expected;

    integer i;

    begin
      #CLK_PERIOD;
      clk = 1'b1;
      input_first = 32'shE;
      input_second = 32'sh9;
      alu_op = 2'b10;

      result_expected = 32'sh7E;
      zero_expected = 1'b0;

      for (i = 0; i < 5; i = i + 1)
      begin
        #1 clk = ~clk;
        #1 clk = ~clk;
      end

      print_tb_info("mul", 0, result_expected);

      err = ({result, zero} !== {result_expected, zero_expected});
    end
  endtask

  //
  // Main tb code
  //
  initial
  begin
    print_info("Testing ALU");

    reset_input();
    run_tests();

    print_info("Testing finised");

    $finish;
  end
endmodule
