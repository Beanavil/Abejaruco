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

`include "src/parameters.v"

`include "tests/utils/tb_utils.v"
`include "src/abejaruco.v"

module ALUOps_tb();
  reg clk;
  reg reset;
  reg [WORD_WIDTH-1:0] rm0_initial [];

  parameter PROGRAM = "../../../programs/alu_ops.o";

  Abejaruco #(.PROGRAM(PROGRAM)) uut (
              .reset(reset),
              .clk(clk),
              .rm0_initial(32'b1000)
            );

  task automatic reset_input;
    begin
      $display("*** Resetting input ***");
      clk = 0;
      reset = 1;
      #CLK_PERIOD reset = 0;
      #CLK_PERIOD;
      $display("Done");
    end
  endtask

  task automatic run_tests;
    begin
      integer err;
      $display("*** Run tests ***");
      test_mul(err);
      check_err(err, "mul");

      test_add(err);
      check_err(err, "add");

      test_sub(err);
      check_err(err, "sub");

      test_wb(err);
      check_err(err, "wb");

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
      $display("Test %s: %s", test_name, test_description);
      $display("-- icache_data_out should be %h, got %h", icache_data_out_expected, uut.icache_data_out);
      $display("-- cu_alu_op should be %h, got %h", cu_alu_op_expected, uut.cu_alu_op);
      $display("-- alu_out_multiplexer should be %h, got %h", alu_out_multiplexer_expected, uut.rf_write_data);
    end
  endtask

  // Test mul: load two immediates and multiply them
  task automatic test_mul;
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

      icache_data_out_expected = 32'h00208013;
      cu_alu_op_expected = 2'b00;
      alu_out_multiplexer_expected = 32'h0;

      print_tb_info("MUL", "Load first immediate",
                    icache_data_out_expected,
                    cu_alu_op_expected,
                    alu_out_multiplexer_expected);

      for (integer i = 0; i < 5; i = i + 1)
      begin
        #CLK_PERIOD clk = 1'b0;
        #CLK_PERIOD clk = 1'b1;
      end

      #CLK_PERIOD;

      icache_data_out_expected = 32'h00110013;
      cu_alu_op_expected = 2'b00;
      alu_out_multiplexer_expected = 32'h0; // TODO

      print_tb_info("MUL", "Load second immediate",
                    icache_data_out_expected,
                    cu_alu_op_expected,
                    alu_out_multiplexer_expected);

      for (integer i = 0; i < 5; i = i + 1)
      begin
        #CLK_PERIOD clk = 1'b0;
        #CLK_PERIOD clk = 1'b1;
      end

      #CLK_PERIOD;

      icache_data_out_expected = 32'h022081B3;
      cu_alu_op_expected = 2'b10;
      alu_out_multiplexer_expected = 32'h0; // TODO

      print_tb_info("MUL", "Load mul",
                    icache_data_out_expected,
                    cu_alu_op_expected,
                    alu_out_multiplexer_expected);

      err = ({uut.icache_data_out, uut.cu_alu_op, uut.rf_write_data} !==
             {icache_data_out_expected, cu_alu_op_expected, alu_out_multiplexer_expected});
    end
  endtask

  // Test add: add the previously loaded immediates
  task automatic test_add;
    output integer err;
    reg [CACHE_LINE_SIZE-1:0] icache_data_out_expected;
    reg [1:0] cu_alu_op_expected;
    reg [WORD_WIDTH-1:0] alu_out_multiplexer_expected;

    begin
      for (integer i = 0; i < 5; i = i + 1)
      begin
        #CLK_PERIOD clk = 1'b0;
        #CLK_PERIOD clk = 1'b1;
      end

      #CLK_PERIOD;

      icache_data_out_expected = 32'h00110233;
      cu_alu_op_expected = 2'b10;
      alu_out_multiplexer_expected = 32'h0; // TODO

      print_tb_info("ADD", "Add the previously loaded immediates",
                    icache_data_out_expected,
                    cu_alu_op_expected,
                    alu_out_multiplexer_expected);

      err = ({uut.icache_data_out, uut.cu_alu_op, uut.rf_write_data} !==
             {icache_data_out_expected, cu_alu_op_expected, alu_out_multiplexer_expected});
    end
  endtask

  // Test sub: substact the previously loaded immediates
  task automatic test_sub;
    output integer err;
    reg [CACHE_LINE_SIZE-1:0] icache_data_out_expected;
    reg [1:0] cu_alu_op_expected;
    reg [WORD_WIDTH-1:0] alu_out_multiplexer_expected;

    begin
      for (integer i = 0; i < 5; i = i + 1)
      begin
        #CLK_PERIOD clk = 1'b0;
        #CLK_PERIOD clk = 1'b1;
      end

      #CLK_PERIOD;

      icache_data_out_expected = 32'h402082B3;
      cu_alu_op_expected = 2'b10;
      alu_out_multiplexer_expected = 32'h00000002; // TODO

      print_tb_info("SUB", "Substact the previously loaded immediates",
                    icache_data_out_expected,
                    cu_alu_op_expected,
                    alu_out_multiplexer_expected);

      err = ({uut.icache_data_out, uut.cu_alu_op, uut.rf_write_data} !==
             {icache_data_out_expected, cu_alu_op_expected, alu_out_multiplexer_expected});
    end
  endtask

  // Test wb: check that registers update correctly after writeback
  task automatic test_wb;
    output integer err;
    reg [CACHE_LINE_SIZE-1:0] icache_data_out_expected;
    reg [1:0] cu_alu_op_expected;
    reg [WORD_WIDTH-1:0] alu_out_multiplexer_expected;

    begin
      // Wait until sub instruction finishes
     for (integer i = 0; i < 4; i = i + 1) // TODO: 3 cycles or 4?
      begin
        #CLK_PERIOD clk = 1'b0;
        #CLK_PERIOD clk = 1'b1;
      end

      #CLK_PERIOD;

      icache_data_out_expected = 32'h00000000; /*icache miss, same as b4*/
      cu_alu_op_expected = 2'b00;
      alu_out_multiplexer_expected = 32'h0;

      print_tb_info("WB", "Check writeback of registers",
                    icache_data_out_expected,
                    cu_alu_op_expected,
                    alu_out_multiplexer_expected);
      $display("-- register_file.r[3] should be %h, got %h", 32'h00000002, uut.register_file.r[3]);
      $display("-- register_file.r[4] should be %h, got %h", 32'h00000003, uut.register_file.r[4]);
      $display("-- register_file.r[5] should be %h, got %h", 32'h00000001, uut.register_file.r[5]);

      err = ({uut.register_file.r[3], uut.register_file.r[4], uut.register_file.r[5]} !==
             {32'h00000002, 32'h00000003, 32'h00000001});
    end
  endtask

  initial
  begin
    print_info("Testing ALU instructions (mul, add, sub)");

    reset_input();
    run_tests();

    print_info("Testing finised");

    $finish;
  end

endmodule