// GNU General Public License
//
// Copyright : (c) 2024 Javier Beiro Piñón
//           : (c) 2024 Beatriz Navidad Vilches
//           : (c) 2024 Stefano Petrilli
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

`include "tests/utils/tb_utils.v"
`include "src/abejaruco.v"

module Hazards_tb();
`include "src/parameters.v"

  reg clk;
  reg reset;
  reg [WORD_WIDTH-1:0] rm0_initial [];

  parameter PROGRAM = "../../../programs/hazards.o";

  Abejaruco #(.PROGRAM(PROGRAM)) uut (
              .reset(reset),
              .clk(clk),
              .rm0_initial(32'b0100)
            );

  task automatic reset_input;
    begin
      $display("*** Resetting input ***");
      clk = 0;
      reset = 1;
      #CLK_PERIOD reset = 0;
      clk = 1;
      $display("Done");
    end
  endtask

  task automatic run_tests;
    begin
      integer err;
      $display("*** Run tests ***");

      test_nop(err);
      check_err(err, "test_nop");

      test_data_haz(err);
      check_err(err, "test_data_haz");

      // test_load_haz(err);
      // check_err(err, "test_load_haz");

      // test_store_haz(err);
      // check_err(err, "test_store_haz");

      // test_no_haz(err);
      // check_err(err, "test_no_haz");

      $display("Done");
    end
  endtask

  task automatic print_tb_info;
    input string test_name;
    input stall_expected;
    begin
      $display("Test %s", test_name);
      $display("-- stall should be %h, got %h",
               stall_expected, uut.stall);
    end
  endtask

  // Test that in case of nops the stall is not set to 1
  // -- add $r0 <- $r0, $r0 F F F F F D E M W
  // -- add $r0 <- $r0, $r0           F D E M
  task automatic test_nop;
    output integer err;
    reg stall_expected;
    begin
      stall_expected = 0;

      // 5 cycles to fetch the first nop
      for (integer i = 0; i < 5; i = i + 1)
      begin
        #CLK_PERIOD clk = 1'b0;
        #CLK_PERIOD clk = 1'b1;
        print_tb_info("test_nop", stall_expected);
      end

      // 4 cycles to execute the instructions
      for (integer i = 0; i < 4; i = i + 1)
      begin
        #CLK_PERIOD clk = 1'b0;
        #CLK_PERIOD clk = 1'b1;
        print_tb_info("test_nop", stall_expected);
      end

      #CLK_PERIOD;
      print_tb_info("test_nop", stall_expected);
      err = uut.stall != stall_expected;

      // // 5 cycles to execute the instructions
      // for (integer i = 0; i < 5; i = i + 1)
      // begin
      //   #CLK_PERIOD clk = 1'b0;
      //   #CLK_PERIOD clk = 1'b1;
      //   print_tb_info("test_nop", stall_expected);
      // end
    end
  endtask

  // Test hazard detection between ALU ops
  // -- add $r0 <- $r0, $r0   F D E M /*from previous test*/
  // -- add $r2 <- $r1, $r1     F F F F F D E M W
  // -- add $r3 <- $r2, $r2               F D D E
  // -- add $r0 <- $r0, $r0                 F F D
  // -- add $r0 <- $r0, $r0                     F
  task automatic test_data_haz;
    output integer err;
    reg stall_expected;
    begin
      stall_expected = 0;

      // 2 cycles to fetch the line
      for (integer i = 0; i < 2; i = i + 1)
      begin
        #CLK_PERIOD clk = 1'b0;
        #CLK_PERIOD clk = 1'b1;
        print_tb_info("test_data_haz: fetch", stall_expected);
      end

      // 2 cycles without stall
      for (integer i = 0; i < 2; i = i + 1)
      begin
        #CLK_PERIOD clk = 1'b0;
        #CLK_PERIOD clk = 1'b1;
        print_tb_info("test_data_haz", stall_expected);
      end

      // 1 cycle where it stalls
      #CLK_PERIOD clk = 1'b0;
      #CLK_PERIOD clk = 1'b1;
      #CLK_PERIOD;
      stall_expected = 1;
      #CLK_PERIOD;
      print_tb_info("test_data_haz", stall_expected);

      #CLK_PERIOD clk = 1'b0;
      #CLK_PERIOD clk = 1'b1;
    end
  endtask

  // Test hazard detection when add uses loaded value
  // -- ldw  $r4 <- 0($r1)   F F F F F F D E M W
  // -- add $r5 <- $r4, $r4              F D D E
  // -- add $r0 <- $r0, $r0                F F D
  // -- add $r0 <- $r0, $r0                    F
  task automatic test_load_haz;
    output integer err;
    reg stall_expected;

    begin
      // 5 cycles to fetch the line
      for (integer i = 0; i < 5; i = i + 1)
      begin
        #CLK_PERIOD clk = 1'b0;
        #CLK_PERIOD clk = 1'b1;
        print_tb_info("test_load_haz: fetch", stall_expected);
      end

      // 2 cycles without stall
      stall_expected = 0;
      for (integer i = 0; i < 2; i = i + 1)
      begin
        #CLK_PERIOD clk = 1'b0;
        #CLK_PERIOD clk = 1'b1;
        print_tb_info("test_load_haz", stall_expected);
      end

      // 1 cycle where it stalls
      #CLK_PERIOD clk = 1'b0;
      #CLK_PERIOD clk = 1'b1;
      #CLK_PERIOD;
      stall_expected = 1;
      #CLK_PERIOD;
      print_tb_info("test_load_haz", stall_expected);

      #CLK_PERIOD clk = 1'b0;
      #CLK_PERIOD clk = 1'b1;
    end
  endtask

  initial
  begin
    print_info("Testing data hazards");

    reset_input();
    run_tests();

    print_info("Testing finised");

    $finish;
  end

endmodule
