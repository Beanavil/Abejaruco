`timescale 1ns / 1ps

`include "src/memory/cache.v"

module cache_tb;

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
  reg byteOP;
  wire [WORD_WIDTH-1:0] data_out;
  wire hit, data_ready;
  reg [LINE_SIZE-1:0] mem_data_out;
  reg [LINE_SIZE-1:0] mem_data_in;
  reg mem_enable;
  reg mem_op;

  Cache uut (
          .clk(clk),
          .reset(reset),
          .address(address),
          .op(op),
          .byte_op(byteOP),
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
  always #1 clk = ~clk;  // Generate a clock with a period of 10ns

  initial
  begin

    // Apply reset
    $display("\n------Inital values: Resetting cache-----");
    access = 1;
    clk = 0;
    reset = 1;
    address = 32'h0;
    data_in = 0;
    op = 0;
    byteOP = 0;
    #2;

    // Start the test

    // Test Case 1: Write to an address
    $display("\n------Test Case 1: Write to an address then read----");
    address = 32'h00000004;
    data_in = 32'h00000011;
    op = 1'b0;  // Write operation
    access = 1;
    reset = 0;
    byteOP = 0;
    #2;

    op = 1'b1;  // Read operation
    byteOP = 1;
    #2;

    if (data_out !== 32'h00000011)
    begin
      $display("Failed. Expected result: 32'h00000011, Actual: %h", data_out);
    end
    else
    begin
      $display("Passed. Expected result: 32'h00000011, Actual: %h", data_out);
    end
    #2;
    access = 0;

    // Test Case 2: Write to the same memory address
    // #80;
    // $display("\n------Test Case 2: Write to same address----");
    // address = 32'h00000004;
    // data_in = 32'h11111111;
    // op = 1'b0;  // Write operation
    // access = 1;
    // #80;
    // access = 0;

    // // Test Case 4: Write to the follow memory address
    // #80;
    // $display("\n------Test Case 4: Write to another word in the same address----");
    // address = 32'h00000002;
    // data_in = 32'h11111111;
    // op = 1'b0;  // Write operation
    // access = 1;
    // #80;
    // access = 0;

    // // Test Case 5: Write to another memory address
    // #80;
    // $display("\n------Test Case 5: Write new address----");
    // address = 32'h00000004;
    // data_in = 32'h22222222;
    // op = 1'b0;  // Write operation
    // access = 1;
    // #80;
    // access = 0;

    // // Test Case 6: Full cache and write in a new address
    // #80;
    // $display("\n------Test Case 6: Line replacement----");
    // //IMPORTANT: If there is no memory access the line is not replaced only the written word
    // address = 32'h00000008;
    // data_in = 32'h33333333;
    // op = 1'b0;  // Write operation
    // access = 1;
    // #80;
    // access = 0;

    // #80;
    // address = 32'h000000C;
    // data_in = 32'h44444444;
    // op = 1'b0;  // Write operation
    // access = 1;
    // #80;
    // access = 0;

    // #80;
    // address = 32'h00000010;
    // data_in = 32'h55555555;
    // op = 1'b0;  // Write operation
    // access = 1;
    // #80;
    // access = 0;


    // // Test Case 7: Read line and write in a new address
    // #80;
    // $display("\nTest Case 7: Read from existing line");
    // op = 1'b1;  // Read operation
    // address = 32'h00000004;
    // access = 1;
    // #80;
    // $display("Data in memory: %h", data_out);
    // #80;
    // access = 0;


    // // Test Case 8: Write after the effect of read
    // #80;
    // $display("\n------Test Case 8: Line replacement----");
    // //IMPORTANT: If there is no memory access the line is not replaced only the written word
    // address = 32'h00000014;
    // data_in = 32'h66666666;
    // op = 1'b0;  // Write operation
    // access = 1;
    // #80;
    // access = 0;

    // End of Test
    $display("\nEnd of Test at time %0d", $time);
    $finish;
  end

endmodule
