// GNU General Public License
//
// Copyright : (c) 2023 Javier Beiro Piñón
// : (c) 2023 Beatriz Navidad Vilches
// : (c) 2023 Stefano Petrili
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

`include "src/common/cache/tag_comparator.v"
`include "src/common/cache/priority_encoder.v"
`include "src/memory/memory.v"

module cache (
    input wire clk,
    input wire reset,
    input wire [ADDRESS_WIDTH-1:0] address,
    input wire [WORD_WIDTH-1:0] data_in,
    input wire op,
    input wire byteOP,
    input wire access,
    output reg [WORD_WIDTH-1:0] data_out,
    output reg hit,
    output reg miss
);

    // Parameter definitions
    parameter ADDRESS_WIDTH = 32;                                           // Memory address width
    parameter WORD_WIDTH = 32;                                              // Size of words
    parameter LINE_SIZE = 128;                                              // Size of each cache line in bytes
    parameter NUM_LINES = 4;                                                // Number of lines in the cache

    parameter WORDS_PER_LINE = LINE_SIZE / (WORD_WIDTH);                    // Number of words in each cache line
    parameter FULL_OFFSET_WIDTH = $clog2(WORDS_PER_LINE) + $clog2(WORD_WIDTH/8);    // Calculate offset width
    parameter TAG_WIDTH = ADDRESS_WIDTH - FULL_OFFSET_WIDTH;                // Calculate tag width

    // Auxiliar constants for address decoding based on parameters
    parameter INIT_TAG = ADDRESS_WIDTH - 1;
    parameter END_TAG = ADDRESS_WIDTH - TAG_WIDTH;
    parameter INIT_WORD_OFFSET = END_TAG - 1;
    parameter END_WORD_OFFSET = INIT_WORD_OFFSET - ($clog2(WORDS_PER_LINE)-1);
    parameter INIT_BYTE_OFFSET = END_WORD_OFFSET - 1;
    parameter END_BYTE_OFFSET = 0;

    // Declare internal signals for tag comparators
    wire [3:0] hit_signals;
    wire hit0, hit1, hit2, hit3;

    // Memory arrays for tags, data, and LRU status
    reg [TAG_WIDTH-1:0] tag_array[NUM_LINES-1:0];
    reg [WORD_WIDTH-1:0] data_array[NUM_LINES-1:0][WORDS_PER_LINE-1:0];
    reg [NUM_LINES-1:0] valid_array;
    reg [NUM_LINES-1:0] dirty_array;
    reg [1:0] lru_counters[NUM_LINES-1:0];

    // Instantiate tag comparators
    tag_comparator #(.TAG_WIDTH(TAG_WIDTH)) comp0 (.input_tag(address[INIT_TAG:END_TAG]), .stored_tag(tag_array[0]), .valid(valid_array[0]), .hit(hit0));
    tag_comparator #(.TAG_WIDTH(TAG_WIDTH)) comp1 (.input_tag(address[INIT_TAG:END_TAG]), .stored_tag(tag_array[1]), .valid(valid_array[1]), .hit(hit1));
    tag_comparator #(.TAG_WIDTH(TAG_WIDTH)) comp2 (.input_tag(address[INIT_TAG:END_TAG]), .stored_tag(tag_array[2]), .valid(valid_array[2]), .hit(hit2));
    tag_comparator #(.TAG_WIDTH(TAG_WIDTH)) comp3 (.input_tag(address[INIT_TAG:END_TAG]), .stored_tag(tag_array[3]), .valid(valid_array[3]), .hit(hit3));

    // Combine hit signals
    assign hit_signals = {hit0, hit1, hit2, hit3};

    // Instantiate priority encoder
    wire [1:0] line_number;
    priority_encoder encoder(.hit(hit_signals), .line_number(line_number));


    //Memory interface signals
    wire mem_read_enable, mem_write_enable;
    wire [ADDRESS_WIDTH-1:0] mem_address;
    wire [LINE_SIZE-1:0] mem_data_in, mem_data_out;

    // Instantiate the Memory module
    Memory #(.MEMORY_LOCATIONS(4096), .ADDRESS_SIZE(ADDRESS_WIDTH), .CACHE_LINE_SIZE(LINE_SIZE)) memory_instance (
        .clock(clk),
        .write_enable(mem_write_enable),
        .read_enable(mem_read_enable),
        .address(mem_address),
        .data_in(mem_data_in),
        .data_out(mem_data_out)
    );


    //Function to update LRU counters
    task update_lru;
        input [1:0] accessed_line; // Updated the size to match line_number
        integer i;
        begin
            for (i = 0; i < NUM_LINES; i = i + 1) begin
                if (lru_counters[i] >= lru_counters[accessed_line]) begin
                    lru_counters[i] <= lru_counters[i] - 1;
                end
            end
            lru_counters[accessed_line] <= NUM_LINES - 1;  // Most recently used
        end
    endtask

    // Tag comparison, read/write logic, and LRU update
    integer i;
    integer j, replace_index;
    always @(posedge clk or posedge reset) begin

        if (access) begin
            // FOR TESTING --- Print input values
            $display("In values: clk=%b, reset=%b, address=%h, data_in=%h, op=%b", clk, reset, address, data_in, op);

            if (reset) begin
                for (i = 0; i < NUM_LINES; i = i + 1) begin
                    valid_array[i] <= 0;
                    lru_counters[i] <= i;  // Initialize LRU
                    dirty_array[i] <= 0;
                end
            end else if (op == 1'b0) begin
                // Write word logic
                miss = ~|hit_signals; // Miss if all hit signals are 0
                hit = |hit_signals;   // Hit if any hit signal is 1

                if (hit) begin
                    if (byteOP) begin
                        // Use line_number to access the cache
                        data_array[line_number][address[INIT_WORD_OFFSET:END_WORD_OFFSET]][address[INIT_BYTE_OFFSET:END_BYTE_OFFSET]*8 +: 8] <= data_in[7:0];
                    end else begin
                        // Use line_number to access the cache
                        data_array[line_number][address[INIT_WORD_OFFSET:END_WORD_OFFSET]] <= data_in;
                    end

                    // Update LRU for line_number
                    update_lru(line_number);

                end else if (miss) begin
                    // Find the line to replace based on LRU
                    replace_index = 0;
                    for (j = 0; j < NUM_LINES; j = j + 1) begin
                        if (lru_counters[j] < lru_counters[replace_index]) begin
                            replace_index = j;
                        end
                    end

                    // If the line to replace is valid and dirty, write back to memory
                    if (valid_array[replace_index] && dirty_array[replace_index]) begin
                        // Write back logic
                        // Loop over each word in the line
                        // for (int k = 0; k < WORDS_PER_LINE; k++) begin
                        //     // Calculate the memory address to write back
                        //     mem_address = // calculate based on tag_array[replace_index] and offsets
                        //     mem_data_in = data_array[replace_index][k];
                        //     // Assert write signal to Memory module
                        //     // ...
                        // end
                    end

                    //TODO bring the line of address from memory to the cache
                    //...

                    if (byteOP) begin
                        // Byte access
                        data_array[replace_index][address[INIT_WORD_OFFSET:END_WORD_OFFSET]][address[INIT_BYTE_OFFSET:END_BYTE_OFFSET]*8 +: 8] <= data_in[7:0];
                    end else begin
                        // Full word access
                        data_array[replace_index][address[INIT_WORD_OFFSET:END_WORD_OFFSET]] <= data_in;
                    end

                    // Update line control information
                    tag_array[replace_index] <= address[INIT_TAG:END_TAG];
                    valid_array[replace_index] <= 1;
                    update_lru(replace_index);
                end

            end else if (op == 1'b1) begin
                // Read logic
                hit <= |hit_signals;   // Hit if any hit signal is 1
                miss <= ~|hit_signals; // Miss if all hit signals are 0

                if (hit) begin

                    if (byteOP) begin
                        // Implement the write logic for byte access
                        data_out[WORD_WIDTH:8] <= 0;
                        data_out[7:0] <= data_array[line_number][address[INIT_WORD_OFFSET:END_WORD_OFFSET]][address[INIT_BYTE_OFFSET:END_BYTE_OFFSET]*8 +: 8];
                    end else begin
                        // Use line_number to retrieve the cache data //TODO
                        data_out <= data_array[line_number][address[INIT_WORD_OFFSET:END_WORD_OFFSET]];
                    end
                    update_lru(line_number);

                end else if (miss) begin

                    //TODO: when ram is implemented
                    // 1. Bring the data from memory to the caches

                    // Find the line to replace based on LRU
                    replace_index = 0;
                    for (j = 0; j < NUM_LINES; j = j + 1) begin
                        if (lru_counters[j] < lru_counters[replace_index]) begin
                            replace_index = j;
                        end
                    end

                    //... (add byte logic too when ram is implemented)
                    valid_array[line_number] <= 0;
                end
            end

            // FOR TESTING --- Print cache contents
            $display("Printing Cache Contents at Time: %0d", $time);
            for (i = 0; i < NUM_LINES; i = i + 1) begin
                $display("Line %0d: Valid = %0b, Tag = %h, Data =", i, valid_array[i], tag_array[i]);
                for (j = 0; j < WORDS_PER_LINE; j = j + 1) begin
                    $write("%h ", data_array[i][j]);
                end
                $display(" ");
            end
            $display("\n");

        end
    end

endmodule
