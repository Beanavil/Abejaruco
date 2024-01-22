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



`include "tests/utils/tb_utils.v"

`include "src/memory/d_cache.v"

`include "src/parameters.v"

// module Cache_tb;
//   // In wires (from CPU)
//   reg clk;
//   reg access;
//   reg reset;
//   reg [ADDRESS_WIDTH-1:0] address;
//   reg [WORD_WIDTH-1:0] data_in;
//   reg op;
//   reg byte_op;
//   // In wires (from memory)
//   reg mem_data_ready;
//   reg [CACHE_LINE_SIZE-1:0] mem_data_out;
//   reg memory_in_use;

//   // Out wires (to CPU)
//   wire [WORD_WIDTH-1:0] data_out;
//   wire data_ready;

//   // Out wires (to memory)
//   wire mem_enable;
//   wire mem_op;
//   wire mem_op_init;
//   wire mem_op_done;
//   wire [CACHE_LINE_SIZE-1:0] mem_data_in;
//   wire [MEMORY_ADDRESS_SIZE-1:0] mem_address;

// //TODO revisar estas pruebas
//   DCache uut (
//           .clk(clk),
//           .access(access),
//           .reset(reset),
//           .address(address),
//           .data_in(data_in),
//           .op(op),
//           .byte_op(byte_op),
//           .mem_data_ready(mem_data_ready),
//           .mem_data_out(mem_data_out),
//           .memory_in_use(memory_in_use),
//           .data_out(data_out),
//           .data_ready(data_ready),
//           .mem_enable(mem_enable),
//           .mem_op(mem_op),
//           .mem_op_init(mem_op_init),
//           .mem_op_done(mem_op_done),
//           .mem_data_in(mem_data_in),
//           .mem_address(mem_address)
//         );

//   // Clock generation
//   always #CLK_PERIOD clk = ~clk;

//   task automatic reset_input;
//     begin
//       $display("*** Resetting input ***");
//       clk = 1'b0;
//       reset = 1'b0;
//       access = 1'b0;
//       address = 32'h0;
//       data_in = 0;
//       op = 1'b0;
//       byte_op = 0;
//       mem_data_ready = 1'b0;
//       mem_data_out = 0;
//       memory_in_use = 1'b0;
//       #CLK_PERIOD;
//       $display("Done");
//     end
//   endtask

//   task automatic run_tests;
//     begin
//       integer err;
//       $display("*** Run tests ***");
//       test_1(err);
//       check_err(err, "1");

//       test_2(err);
//       check_err(err, "2");

//       test_3(err);
//       check_err(err, "3");

//       test_4(err);
//       check_err(err, "4");

//       $display("Done");
//     end
//   endtask

//   task automatic print_tb_info;
//     input string test_name;
//     input string test_description;
//     input [31:0] data_out_expected;
//     begin
//       $display("Test case %s: %s", test_name, test_description);
//       $display("-- data_out should be %h, got %h", data_out_expected, data_out);
//     end
//   endtask

//   // Test Case 1: Write to an address
//   task automatic test_1;
//     output integer err;
//     reg [31:0] data_out_expected;

//     begin
//       #CLK_PERIOD;
//       address = 32'h00000004;
//       data_in = 32'h00000011;
//       op = 1'b0;  /*write*/
//       access = 1;
//       reset = 0;
//       byte_op = 0;

//       #CLK_PERIOD;

//       op = 1'b1; /*read*/
//       byte_op = 1;

//       #CLK_PERIOD;
//       #10

//        data_out_expected = 32'h00000011;
//       print_tb_info("1", "Write to an address then read", data_out_expected);

//       err = (data_out !== data_out_expected);

//       #CLK_PERIOD;
//       access = 0;
//     end
//   endtask

//   // Test Case 2: Write to the same memory address
//   task automatic test_2;
//     output integer err;
//     reg [31:0] data_out_expected;

//     begin
//       #CLK_PERIOD;
//       address = 32'h00000004;
//       data_in = 32'h11111111;
//       op = 1'b0;  /*write*/
//       access = 1;
//       reset = 0;
//       byte_op = 0;

//       #CLK_PERIOD;

//       op = 1'b1; /*read*/

//       #CLK_PERIOD;

//       data_out_expected = 32'h11111111;
//       print_tb_info("2", "Write to the same memory address", data_out_expected);

//       err = (data_out !== data_out_expected);

//       #CLK_PERIOD;
//       access = 0;
//     end
//   endtask

//   // Test Case 3: Write to the following memory address
//   task automatic test_3;
//     output integer err;
//     reg [31:0] data_out_expected;

//     begin
//       #CLK_PERIOD;
//       address = 32'h00000002;
//       data_in = 32'h11111111;
//       op = 1'b0;  /*write*/
//       access = 1;
//       reset = 0;
//       byte_op = 0;

//       #CLK_PERIOD;

//       op = 1'b1; /*read*/

//       #CLK_PERIOD;

//       data_out_expected = 32'h11111111;
//       print_tb_info("3", "Write to another word in the same address", data_out_expected);

//       err = (data_out !== data_out_expected);

//       #CLK_PERIOD;
//       access = 0;
//     end
//   endtask

//   // Test Case 4: Write and read byte
//   task automatic test_4;
//     output integer err;
//     reg [31:0] data_out_expected;

//     begin
//       #CLK_PERIOD;
//       address = 32'h00000008;
//       data_in = 32'h00000333;
//       op = 1'b0;  /*write*/
//       access = 1;
//       reset = 0;
//       byte_op = 1;

//       #CLK_PERIOD;

//       op = 1'b1; /*read*/

//       #CLK_PERIOD;

//       data_out_expected = 32'h00000033;
//       print_tb_info("4", "Write and read byte", data_out_expected);

//       err = (data_out !== data_out_expected);

//       #CLK_PERIOD;
//       access = 0;
//     end
//   endtask

//   //TODO Test Case 5: Write and read hlf-word

//   initial
//   begin
//     print_info("Testing Cache");

//     reset_input();
//     run_tests();

//     print_info("Testing finised");

//     $finish;
//   end
// endmodule
