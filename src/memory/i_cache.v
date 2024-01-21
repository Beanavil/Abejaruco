// GNU General Public License
//
// Copyright : (c) 2023-2024 Javier Beiro Piñón
//           : (c) 2023-2024 Beatriz Navidad Vilches
//           : (c) 2023-2024 Stefano Petrilli
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


`include "src/common/priority_encoder.v"
`include "src/common/tag_comparator.v"

//TODO add half word operations

module ICache (
    // In wires (from CPU)
    input wire clk,
    input wire reset,
    input wire [ADDRESS_WIDTH-1:0] address,
    input wire byte_op,

    // In wires (from memory)
    input wire mem_data_ready,
    input wire [CACHE_LINE_SIZE-1:0] mem_data_out,
    input wire memory_in_use,

    // Out wires (to CPU)
    output reg [WORD_WIDTH-1:0] data_out,       // Data returned by the cache
    output reg data_ready,                     // Data in the output is valid or write operation finished

    // Out wires (to memory)
    output reg mem_enable,                      // Enable the memory module to read/write
    output reg mem_op,                          // Select read/write operation
    output reg mem_op_init,                     // Tell memory that we are going to use it
    output reg mem_op_done,                     // The caché finished reading the returned data
    output reg [CACHE_LINE_SIZE-1:0] mem_data_in,     // Data to be written in memory
    output reg [MEMORY_ADDRESS_SIZE-1:0] mem_address  // Address to be read/written in memory
  );
`include "src/parameters.v"

  // Internal signals for tag comparators
  reg hit;
  wire [3:0] hit_signals;
  wire hit0, hit1, hit2, hit3;

  // Memory arrays for tags, data, and LRU status
  reg [TAG_WIDTH-1:0] tag_array[CACHE_NUM_LINES-1:0];
  reg [WORD_WIDTH-1:0] data_array[CACHE_NUM_LINES-1:0][CACHE_WORDS_PER_LINE-1:0];
  reg [CACHE_NUM_LINES-1:0] valid_array;
  reg [CACHE_NUM_LINES-1:0] dirty_array;
  reg [1:0] lru_counters[CACHE_NUM_LINES-1:0];

  // Instantiate tag comparators
  tag_comparator comp0 (.input_tag(address[INIT_TAG:END_TAG]), .stored_tag(tag_array[0]), .valid(valid_array[0]), .hit(hit0));
  tag_comparator comp1 (.input_tag(address[INIT_TAG:END_TAG]), .stored_tag(tag_array[1]), .valid(valid_array[1]), .hit(hit1));
  tag_comparator comp2 (.input_tag(address[INIT_TAG:END_TAG]), .stored_tag(tag_array[2]), .valid(valid_array[2]), .hit(hit2));
  tag_comparator comp3 (.input_tag(address[INIT_TAG:END_TAG]), .stored_tag(tag_array[3]), .valid(valid_array[3]), .hit(hit3));

  // Combine hit signals
  assign hit_signals = {hit0, hit1, hit2, hit3};

  // Instantiate priority encoder
  wire [1:0] line_number;
  priority_encoder encoder(.hit(hit_signals), .line_number(line_number));

  // Function to update LRU counters
  task update_lru;
    input [1:0] accessed_line; // Updated the size to match line_number
    integer i;
    begin
      for (i = 0; i < CACHE_NUM_LINES; i = i + 1)
      begin
        if (lru_counters[i] >= lru_counters[accessed_line])
        begin
          lru_counters[i] = lru_counters[i] - 1;
        end
      end
      lru_counters[accessed_line] = CACHE_NUM_LINES - 1;  // Most recently used
    end
  endtask

  integer i;
  integer j, replace_index;

  initial
  begin
    for (i = 0; i < CACHE_NUM_LINES; i = i + 1)
    begin
      valid_array[i] = 0;
      lru_counters[i] = i;
      dirty_array[i] = 0;
    end
    data_ready = 0;
    mem_op_init = 0;
    mem_op_done = 0;
    mem_enable = 0;
    mem_op = 0;
  end

  //Reset data ready after i_cache data is taken by CPU
  always @(negedge clk) begin
    if (data_ready) begin
        data_ready = 0;
    end
  end

  //Main functionality
  always @(posedge clk or posedge reset)
  begin
    if (mem_op_done === 1'b1)
    begin
      mem_op_done = 1'b0;
    end

    if (reset)
    begin
      for (i = 0; i < CACHE_NUM_LINES; i = i + 1)
      begin
        valid_array[i] = 0;
        lru_counters[i] = i;
        dirty_array[i] = 0;
      end
      mem_op_init = 1'b0;
      mem_op_done = 1'b0;
      mem_enable = 1'b0;
      mem_op = 1'b0;
      data_ready = 1'b0;
    end
    else begin
      hit = |hit_signals;
      if (hit)
      begin
        `CACHE_DISPLAY("----> Hit");
        `CACHE_DISPLAY($sformatf("Hit values: clk=%b, reset=%b, address=%b, byte_op=%b, miss=%d, mem_data_ready=%d", clk, reset, address, byte_op, ~hit, mem_data_ready));
        mem_enable = 0;
        if (byte_op)
        begin
          data_out[WORD_WIDTH:8] = 0;
          data_out[7:0] = data_array[line_number][address[INIT_WORD_OFFSET:END_WORD_OFFSET]][address[INIT_BYTE_OFFSET:END_BYTE_OFFSET]*8 +: 8];
        end
        else if (~byte_op)
        begin
          data_out = data_array[line_number][address[INIT_WORD_OFFSET:END_WORD_OFFSET]];
        end
        else
        begin
          `CACHE_DISPLAY("Warning: byte_op is not 0 or 1");
        end

        data_ready = 1;
        update_lru(line_number);
      end
      else /*miss*/
      begin
        //If memory is not in use (by DCACHE)
        if (~mem_enable)
        begin
          `CACHE_DISPLAY("----> Miss");
          mem_address = {address[31:4], 4'b0000};
          mem_enable = 1;
          mem_op_done = 0;
          mem_op = 0;

          `CACHE_DISPLAY($sformatf("The cache address is: %b", address));
          `CACHE_DISPLAY($sformatf("The cache address value is: %h", data_out));
          `CACHE_DISPLAY($sformatf("The memory address is: %b", mem_address));
          `CACHE_DISPLAY($sformatf("The memory address value is: %h", mem_data_out));

          // Find the line to replace based on LRU
          replace_index = 0;
          for (j = 0; j < CACHE_NUM_LINES; j = j + 1)
          begin
            if (lru_counters[j] < lru_counters[replace_index])
            begin
              replace_index = j;
            end
          end

          // When memory returns data, store it in the cache
          if(mem_data_ready)
          begin
            `CACHE_DISPLAY("----> Load");
            data_array[replace_index][0] = mem_data_out[31:0];
            data_array[replace_index][1] = mem_data_out[63:32];
            data_array[replace_index][2] = mem_data_out[95:64];
            data_array[replace_index][3] = mem_data_out[127:96];

            // Update line control information
            tag_array[replace_index] = address[INIT_TAG:END_TAG];
            valid_array[replace_index] = 1;
            update_lru(replace_index);

            //Notify the memmory the operation if finished
            mem_op_done = 1;
            mem_enable = 0;

            data_ready = 1;
            data_out = data_array[replace_index][address[INIT_WORD_OFFSET:END_WORD_OFFSET]];
          end
        end
      end 
    end

    // FOR TESTING --- Print cache contents
    `CACHE_DISPLAY($sformatf("Printing Cache Contents at Time: %0d", $time));
    for (i = 0; i < CACHE_NUM_LINES; i = i + 1)
    begin
      `CACHE_DISPLAY($sformatf("Line %0d: Valid = %0b, Tag = %h, Data =", i, valid_array[i], tag_array[i]));
      `CACHE_WRITE($sformatf("\t"));
      for (j = 0; j < CACHE_WORDS_PER_LINE; j = j + 1)
      begin
        `CACHE_WRITE($sformatf("%h ", data_array[i][j]));
      end
      `CACHE_WRITE("\n");
    end
      `CACHE_DISPLAY("\n");


  end
endmodule
