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

`include "src/parameters.v"
`include "tests/utils/tb_utils.v"
`include "src/abejaruco.v"

module LoadAdd_tb();
  reg clk;
  reg reset;
  reg [WORD_WIDTH-1:0] rm0_initial [];
  wire [WORD_WIDTH-1:0] alu_out_multiplexer;
  wire [1:0] cu_alu_op;
  wire [WORD_WIDTH-1:0] icache_data_out;

  reg [4:0] rf_write_idx_test;
  reg rf_write_enable_test;

  parameter CLK_PERIOD = 1;
  parameter RESET_PERIOD = 5;
  parameter WORD_WIDTH = 32;
  parameter PROGRAM = "../../../programs/load_add.o";

  // Print parameters
  parameter ARRAY_LENGTH = 32;

  Abejaruco #(.PROGRAM(PROGRAM)) uut (
              .reset(reset),
              .clk(clk),
              .rm0_initial(32'b1000),
              .alu_out_multiplexer_test(alu_out_multiplexer),
              .cu_alu_op_test(cu_alu_op),
              .icache_data_out_test(icache_data_out),

              .rf_write_enable_test(rf_write_enable_test),
              .rf_write_idx_test(rf_write_idx_test)
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

      test_3(err);
      check_err(err, "3");

      test_4(err);
      check_err(err, "4");

      $display("Done");
    end
  endtask

  task automatic print_tb_info;
    input string test_name;
    input string test_description;
    input [WORD_WIDTH-1:0] icache_data_out_expected;
    input [1:0] cu_alu_op_expected;
    input [WORD_WIDTH-1:0] alu_out_multiplexer_expected;
    begin
      $display("Test case %s: %s", test_name, test_description);
      $display("-- icache_data_out should be %h, got %h", icache_data_out_expected, icache_data_out);
      $display("-- cu_alu_op should be %h, got %h", cu_alu_op_expected, cu_alu_op);
      $display("-- alu_out_multiplexer should be %h, got %h", alu_out_multiplexer_expected, alu_out_multiplexer);
    end
  endtask

  // Test 1: Fetch immediate of 2 on register 1
  task automatic test_1;
    output integer err;
    reg [CACHE_LINE_SIZE-1:0] icache_data_out_expected;
    reg [1:0] cu_alu_op_expected;
    reg [WORD_WIDTH-1:0] alu_out_multiplexer_expected;

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

      icache_data_out_expected = 32'h00201083;
      cu_alu_op_expected = 2'b00;
      alu_out_multiplexer_expected = 32'h0;

      print_tb_info("1", "Load first instruction", icache_data_out_expected,
                    cu_alu_op_expected,
                    alu_out_multiplexer_expected);

      err = (icache_data_out !== icache_data_out_expected);
    end
  endtask

  // Test 2: Fetch an add and decode the previous li
  task automatic test_2;
    output integer err;
    reg [CACHE_LINE_SIZE-1:0] icache_data_out_expected;
    reg [1:0] cu_alu_op_expected;
    reg [WORD_WIDTH-1:0] alu_out_multiplexer_expected;

    begin
      #CLK_PERIOD clk = 1'b0;
      #CLK_PERIOD clk = 1'b1;

      #CLK_PERIOD;

      icache_data_out_expected = 32'h0000033;
      cu_alu_op_expected = 2'b00;
      alu_out_multiplexer_expected = 32'h0;

      print_tb_info("2", "Load second instruction", icache_data_out_expected,
                    cu_alu_op_expected,
                    alu_out_multiplexer_expected);

      err = ({icache_data_out, cu_alu_op} !== {icache_data_out_expected, cu_alu_op_expected});
    end
  endtask

  // Test 3:
  // -- F li of -4 /*miss*/, ID add, EX li of 2 M -, WB -
  // -- Check that the result of the execute stage is the value to be loaded in R1.
  task automatic test_3;
    output integer err;
    reg [CACHE_LINE_SIZE-1:0] icache_data_out_expected;
    reg [1:0] cu_alu_op_expected;
    reg [WORD_WIDTH-1:0] alu_out_multiplexer_expected;

    begin
      #CLK_PERIOD clk = 1'b0;
      #CLK_PERIOD clk = 1'b1;

      #CLK_PERIOD;

      icache_data_out_expected = 32'h0000033; /*icache miss, same as b4*/
      cu_alu_op_expected = 2'b10;
      alu_out_multiplexer_expected = 32'h00000002;

      print_tb_info("3", "Load third instruction", icache_data_out_expected,
                    cu_alu_op_expected,
                    alu_out_multiplexer_expected);

      err = ({icache_data_out, cu_alu_op, alu_out_multiplexer} !==
             {icache_data_out_expected, cu_alu_op_expected, alu_out_multiplexer_expected});
    end
  endtask

  // Test 4:
  // -- F li of -4 /*miss*/, ID add, EX add, M li of 2 WB -.
  // -- F li of -4 /*miss*/, ID add, EX add, M add,    WB li of 2.
  // -- Check that registers update correctly after writeback.
  task automatic test_4;
    output integer err;
    reg [CACHE_LINE_SIZE-1:0] icache_data_out_expected;
    reg [1:0] cu_alu_op_expected;
    reg [WORD_WIDTH-1:0] alu_out_multiplexer_expected;

    begin
      // Skip memory stage as we don't have anything in there yet
      #CLK_PERIOD clk = 1'b0;
      #CLK_PERIOD clk = 1'b1;

      #CLK_PERIOD clk = 1'b0;
      #CLK_PERIOD clk = 1'b1;

      #CLK_PERIOD;

      icache_data_out_expected = 32'h0000033; /*icache miss, same as b4*/
      cu_alu_op_expected = 2'b10;
      alu_out_multiplexer_expected = 32'h0;

      print_tb_info("5", "Load fourth&fifth instructions", icache_data_out_expected,
                    cu_alu_op_expected,
                    alu_out_multiplexer_expected);
      $display("-- register_file.r[1] should be %h, got %h", 32'h00000002, uut.register_file.r[1]);


      err = ({icache_data_out, cu_alu_op, alu_out_multiplexer, uut.register_file.r[1'b1]} !==
             {icache_data_out_expected, cu_alu_op_expected,
              alu_out_multiplexer_expected, 32'h00000002 /*r1_expected*/});
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
