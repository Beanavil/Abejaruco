`timescale 1ns / 1ps

`include "src/common/cache/cache.v"

module cache_tb;

    parameter ADDRESS_WIDTH = 32;
    parameter WORD_WIDTH = 32;
    parameter WORDS_PER_LINE = 4; // 4 words per line, 32 bits each

    reg clk;
    reg reset;
    reg access;
    reg [ADDRESS_WIDTH-1:0] address;
    reg [WORD_WIDTH-1:0] data_in;
    reg op;  // 0 for write, 1 for read
    reg byteOP;
    wire [WORD_WIDTH-1:0] data_out;
    wire hit, miss;

    // Instantiate the cache module
    cache uut (
        .clk(clk),
        .reset(reset),
        .access(access),
        .address(address),
        .byteOP(byteOP),
        .data_in(data_in),
        .op(op),
        .data_out(data_out),
        .hit(hit),
        .miss(miss)
    );

    // Clock generation
    always #20 clk = ~clk;  // Generate a clock with a period of 10ns

    initial begin

        // Apply reset
        $display("\n------Inital values: Resetting cache-----");
        access = 1;
        clk = 0;
        reset = 1;
        address = 32'h0;
        data_in = 0;
        op = 0;
        byteOP = 0;

        // Start the test
        #40;
        access = 0;
        reset = 0;

        // Test Case 1: Write to an address
        #80;
        $display("\n------Test Case 1: Write to an address----");
        address = 32'h00000004;
        data_in = 32'h00000011;
        op = 1'b0;  // Write operation
        access = 1;
        byteOP = 0;
        #80;
        access = 0;

        // // Test Case 2: Read from the same address
        // $display("\n------Test Case 2: Read from the same address-----");
        // op = 1'b1;  // Read operation
        // access = 1;
        // byteOP = 1;
        // #80;
        // $display("Data in memory: %h", data_out);
        // #80;
        // access = 0;


        // #80;
        // $display("\n------Test Case 1: Write to an address----");
        // address = 32'h00000002;
        // data_in = 32'h00000022;
        // op = 1'b0;  // Write operation
        // access = 1;
        // byteOP = 1;
        // #80;
        // access = 0;

        // // Test Case 2: Read from the same address
        // #80;
        // $display("\nTest Case 2: Read from the same address");
        // op = 1'b1;  // Read operation
        // access = 1;
        // #80;
        // if (hit !== 1'b1 || data_out !== 32'hDEADBEEF)
        // begin
        //     $display("Error in Test Case 2 at time %0d", $time);
        // end else begin
        //     $display("Data in memory: %h", data_out);
        // end
        // #80;
        // access = 0;

        // // Test Case 3: Write to the same memory address
        // #80;
        // $display("\n------Test Case 3: Write to same address----");
        // address = 32'h00000001;
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
