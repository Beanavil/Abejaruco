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
`include "src/memory/memory.v"

module Memory_tb();
  reg clk;
  reg enable;
  reg op;
  reg [MEMORY_ADDRESS_SIZE-1:0] address;
  reg [CACHE_LINE_SIZE-1:0] data_in;
  reg memory_in_use;
  wire [CACHE_LINE_SIZE-1:0] data_out;
  wire data_ready;

  Memory uut (
           .clk(clk),
           .enable(enable),
           .op(op),
           .address(address),
           .data_in(data_in),
           .data_out(data_out),
           .data_ready(data_ready),
           .memory_in_use(memory_in_use)
         );

  // Clock generation
  always #1 clk = ~clk;

  task automatic reset_input;
    begin
      $display("*** Resetting input ***");
      clk = 0;
      enable = 0;
      address = 0;
      data_in = 0;
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

      $display("Done");
    end
  endtask

  task automatic print_tb_info;
    input string test_name;
    input string test_description;
    input [CACHE_LINE_SIZE-1:0] data_out_expected;
    begin
      $display("Test case %s: %s", test_name, test_description);
      $display("-- data_out should be %h, got %h", data_out_expected, data_out);
    end
  endtask

  // Test Case 1: Write data with delay and read data
  task automatic test_1;
    output integer err;
    reg [CACHE_LINE_SIZE-1:0] data_out_expected;

    begin
      data_in = 128'h00FF00FF00FF00FF00FF00FF00FF00FF;
      address = 0;
      op = 1'b1;
      enable = 1;

      #CLK_PERIOD;
      #MEMORY_TB_DELAY_PERIOD;
      #CLK_PERIOD;

      enable = 0;

      #CLK_PERIOD;

      op = 0;
      enable = 1;

      #CLK_PERIOD;
      #MEMORY_TB_DELAY_PERIOD;
      #CLK_PERIOD;

      data_out_expected = 128'h00FF00FF00FF00FF00FF00FF00FF00FF;

      print_tb_info("1", "Writing data with 5-cycle delay and reading", data_out_expected);

      err = (data_out !== data_out_expected);
    end
  endtask

  initial
  begin
    print_info("Testing Memory");

    reset_input();
    run_tests();

    print_info("Testing finised");

    $finish;
  end
endmodule
