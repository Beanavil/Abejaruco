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
  reg write_enable;
  reg read_enable;
  reg [ADDRESS_SIZE-1:0] address;
  reg [CACHE_LINE_SIZE-1:0] data_in;
  wire [CACHE_LINE_SIZE-1:0] data_out;

  Memory #(MEMORY_LOCATIONS, ADDRESS_SIZE, CACHE_LINE_SIZE) uut (
           .clk(clk),
           .write_enable(write_enable),
           .read_enable(read_enable),
           .address(address),
           .data_in(data_in),
           .data_out(data_out)
         );


  initial
  begin
    $display("Testing memory");
    $display("-------------------------------");
    clk = 0;
    write_enable = 0;
    read_enable = 0;
    address = 0;
    data_in = 0;
    #1;

    $display("Test case 1: Load 128'h00FF00FF 00FF00FF 00FF00FF 00FF00FF into memory location 0 and then read it");
    clk = 1;
    write_enable = 1;
    data_in = 128'h00FF00FF00FF00FF00FF00FF00FF00FF;
    address = 0;
    #1;

    clk = 0;
    write_enable = 0;
    #1;

    clk = 1;
    read_enable = 1;
    #1;

    clk = 0;
    read_enable = 0;
    #1;

    if (data_out !== 128'h00FF00FF00FF00FF00FF00FF00FF00FF)
    begin
      $display("Failed. Expected result: 128'h00FF00FF 00FF00FF 00FF00FF 00FF00FF, Actual: %h", data_out);
    end
    else
    begin
      $display("Passed. Expected result: 128'h00FF00FF 00FF00FF 00FF00FF 00FF00FF, Actual: %h", data_out);
    end

    $display("Test case 1: Read cache line starting from address 1");

    address = 1;
    clk = 1;
    read_enable = 1;
    #1;

    clk = 0;
    read_enable = 0;
    #1;

    if (data_out !== 128'hxx00FF00FF00FF00FF00FF00FF00FF00)
    begin
      $display("Failed. Expected result: 128'hxx00FF00 FF00FF00 FF00FF00 FF00FF00, Actual: %h", data_out);
    end
    else
    begin
      $display("Passed. Expected result: 128'hxx00FF00 FF00FF00 FF00FF00 FF00FF00, Actual: %h", data_out);
    end
  end
endmodule
