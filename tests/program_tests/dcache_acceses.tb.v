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

`include "src/abejaruco.v"
`include "tests/utils/tb_utils.v"

module DCacheOps_tb();
`include "src/parameters.v"

  reg clk;
  reg reset;

  parameter PROGRAM = "../../../programs/dcache_ops.o";

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
      clk = 1;
      $display("Done");
    end
  endtask

  task automatic run_tests;
    begin
      integer err;
      $display("*** Run tests ***");
      test_sw(err);
      check_err(err, "sw");

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

  // Test sw: load two immediates and multiply them
  // -- li $r1 <- 2         | F F F F F F D E M W
  // -- li $r2 <- 1         |             F D E M W
  // --------------------------------------------------------
  // -- stw 0(r2) <- r1     |               F D E M W
  // --------------------------------------------------------

  task automatic test_sw;
    output integer err;
    reg [CACHE_LINE_SIZE-1:0] icache_data_out_expected;
    reg [1:0] cu_alu_op_expected;
    reg [WORD_WIDTH-1:0] alu_out_multiplexer_expected;

    begin
      // 5 cycles to fetch li (icache miss)
      for (integer i = 0; i < 5; i = i + 1)
      begin
        #CLK_PERIOD;// clk = 1'b1;
        #CLK_PERIOD;// clk = 1'b0;
        $display("c---------------------------");
      end

      // 1 cycle to decode li
      #CLK_PERIOD;// clk = 1'b1;
      #CLK_PERIOD;// clk = 1'b0;
      $display("c---------------------------");

      // 
      // icache_data_out_expected = 32'h00201083;
      // cu_alu_op_expected = 2'b00;
      // alu_out_multiplexer_expected = 32'h0; // 0 cause no inst went through ALU yet

      // print_tb_info("MUL", "Load first immediate",
      //               icache_data_out_expected,
      //               cu_alu_op_expected,
      //               alu_out_multiplexer_expected);

      // // 1 cycle to fetch second li (icache hit)
      // #CLK_PERIOD clk = 1'b0;
      // #CLK_PERIOD clk = 1'b1;
      // $display("c---------------------------");

      // #CLK_PERIOD;

      // icache_data_out_expected = 32'h00110013;
      // cu_alu_op_expected = 2'b00;
      // alu_out_multiplexer_expected = 32'h0; // idem

      // print_tb_info("MUL", "Load second immediate",
      //               icache_data_out_expected,
      //               cu_alu_op_expected,
      //               alu_out_multiplexer_expected);

      // // 5 cycles to fetch mul (icache miss)
      // for (integer i = 0; i < 5; i = i + 1)
      // begin
      //   #CLK_PERIOD clk = 1'b0;
      //   #CLK_PERIOD clk = 1'b1;
      //   $display("c---------------------------");
      // end

      // #CLK_PERIOD;

      // icache_data_out_expected = 32'h00110233; // next inst (add) has been already fetched, but we check register in next cycle (so sub has been fetched)
      // cu_alu_op_expected = 2'b10;
      // alu_out_multiplexer_expected = 32'h1; // 1 from loading it into $r2

      // print_tb_info("MUL", "Load mul",
      //               icache_data_out_expected,
      //               cu_alu_op_expected,
      //               alu_out_multiplexer_expected);
      // $display("-- register_file.r[1] should be %h, got %h", 32'h00000002, uut.register_file.r[1]);
      // $display("-- register_file.r[2] should be %h, got %h", 32'h00000001, uut.register_file.r[2]);

      // err = ({uut.icache_data_out, uut.cu_alu_op, uut.rf_write_data,
      //         uut.register_file.r[1], uut.register_file.r[2]} !==
      //        {icache_data_out_expected, cu_alu_op_expected, alu_out_multiplexer_expected,
      //         32'h00000002, 32'h00000001});
    end
  endtask

  initial
  begin
    print_info("Testing DCACHE instructions (sw)");

    $dumpfile("dcache_accesses.vcd");
    $dumpvars(0, uut);

    reset_input();
    run_tests();

    #100;

    print_info("Testing finised");

    $finish;
  end

  always
  begin
    #CLK_PERIOD clk = ~clk;
  end


endmodule
