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
                WORD_SIZE = 32) ();
    reg clock;
    reg write_enable;
    reg read_enable;
    reg byte_enable;
    reg half_word_enable;
    reg word_enable;
    reg [ADDRESS_SIZE:0] address;
    reg [WORD_SIZE:0] data_in;
    wire [WORD_SIZE-1:0] data_out;
    
    Memory #(MEMORY_LOCATIONS, ADDRESS_SIZE, WORD_SIZE) uut (
    .clock(clock),
    .write_enable(write_enable),
    .read_enable(read_enable),
    .byte_enable(byte_enable),
    .half_word_enable(half_word_enable),
    .word_enable(word_enable),
    .address(address),
    .data_in(data_in),
    .data_out(data_out)
    );

    initial begin
        $display("Testing memory");
        $display("-------------------------------");
        clock = 0;
        write_enable = 0;
        read_enable = 0;
        byte_enable = 0;
        half_word_enable = 0;
        word_enable = 0;
        address = 0;
        data_in = 0;
        #1;     

        $display("Test case 1: Load 32'h000000FF into memory location 0 and then read it");
        clock = 1;
        write_enable = 1;
        byte_enable = 1;
        data_in = 32'h000000FF;
        address = 0;
        #1;

        clock = 0;
        write_enable = 0;
        #1;

        clock = 1;
        read_enable = 1;
        #1;

        clock = 0;
        read_enable = 0;
        byte_enable = 0;
        #1;

        if (data_out !== 32'hxxxxxxFF) $display("Failed. Expected result: 32'hxxxxxxFF, Actual: %h", data_out);
        else $display("Passed. Expected result: 32'hxxxxxxFF, Actual: %h", data_out);

        $display("Test case 2: Load 32'hxxxxFFFF into memory location 0 and then read it");
        clock = 1;
        write_enable = 1;
        half_word_enable = 1;
        data_in = 32'hF000FFFF;
        address = 0;
        #1;

        clock = 0;
        write_enable = 0;
        #1;

        clock = 1;
        read_enable = 1;
        #1;

        clock = 0;
        read_enable = 0;
        half_word_enable = 0;
        #1;

        if (data_out !== 32'hxxxxFFFF) $display("Failed. Expected result: 32'hxxxxFFFF, Actual: %h", data_out);
        else $display("Passed. Expected result: 32'hxxxxFFFF, Actual: %h", data_out);

        $display("Test case 3: Load 32'hFFFFFFFF into memory location 0 and then read it");
        clock = 1;
        write_enable = 1;
        word_enable = 1;
        data_in = 32'hFFFFFFFF;
        address = 0;
        #1;

        clock = 0;
        write_enable = 0;
        #1;

        clock = 1;
        read_enable = 1;
        #1;

        clock = 0;
        read_enable = 0;
        word_enable = 0;
        #1;

        if (data_out !== 32'hFFFFFFFF) $display("Failed. Expected result: 32'hFFFFFFFF, Actual: %h", data_out);
        else $display("Passed. Expected result: 32'hFFFFFFFF, Actual: %h", data_out); 
    end
endmodule
