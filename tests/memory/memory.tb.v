// GNU General Public License
//
// Copyright : (c) 2023 Javier Beiro Piñón
//           : (c) 2023 Beatriz Navidad Vilches
//           : (c) 2023 Stefano Petrili
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

`default_nettype none

`timescale 1ns / 1ps

`include "src/memory/memory.v"

module Memory_tb#(parameter MEMORY_LOCATIONS = 4096,
                    ADDRESS_SIZE = 12,
                    CACHE_LINE_SIZE = 128) ();
  reg clk;
  reg enable;
  reg op;
  reg [ADDRESS_SIZE-1:0] address;
  reg [CACHE_LINE_SIZE-1:0] data_in;
  wire [CACHE_LINE_SIZE-1:0] data_out;
  wire data_ready;

  Memory #(.MEMORY_LOCATIONS(MEMORY_LOCATIONS), .ADDRESS_SIZE(ADDRESS_SIZE), .CACHE_LINE_SIZE(CACHE_LINE_SIZE)) uut (
            .clk(clk),
            .enable(enable),
            .op(op),
            .address(address),
            .data_in(data_in),
            .data_out(data_out),
            .data_ready(data_ready)
          );

  always #1 clk = ~clk;

  initial
  begin
    $display("Testing memory");
    $display("-------------------------------");
    clk = 0;
    enable = 0;
    address = 0;
    data_in = 0;
    #2;

    // Test Case 1: Write data with delay
    $display("Test case 1: Writing data with 5-cycle delay");
    data_in = 128'h00FF00FF00FF00FF00FF00FF00FF00FF;
    address = 0;
    op = 1'b1;
    enable = 1;
    #2;
    #6;
    #2;
    enable = 0;
    #2;

    // Test Case 2: Read the written data
    $display("Test case 2: Reading the written data");
    op = 0;
    enable = 1;
    #2;
    #6;
    #2;
    if (data_out !== 128'h00FF00FF00FF00FF00FF00FF00FF00FF)
    begin
      $display("Test 2 Failed. Expected 128'h00FF00FF00FF00FF00FF00FF00FF00FF, Actual: %h", data_out);
    end
    else
    begin
      $display("Test 2 Passed. Data read correctly.");
    end
    // read_enable = 0;
    $finish;
  end
endmodule
