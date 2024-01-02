// GNU General Public License
//
// Copyright : (c) 2023-2024 Javier Beiro Piñón
//           : (c) 2023-2024 Beatriz Navidad Vilches
//           : (c) 2023-2024 Stefano Petrili
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

`include "src/common/tag_comparator.v"
`include "src/common/priority_encoder.v"

//TODO add half word operations
module Cache (
    // In wires (from CPU)
    input wire clk,
    input wire access,
    input wire reset,
    input wire [ADDRESS_WIDTH-1:0] address,
    input wire [WORD_WIDTH-1:0] data_in,        // Data to be written in the cache
    input wire op,
    input wire byte_op,

    // In wires (from memory)
    input wire mem_data_ready,
    input wire [LINE_SIZE-1:0] mem_data_out,
    input wire memory_in_use,

    // Out wires (to CPU)
    output reg [WORD_WIDTH-1:0] data_out,       // Data returned by the cache
    output wire data_ready,                     // Data in the output is valid or write operation finished

    // Out wires (to memory)
    output reg mem_enable,                      // Enable the memory module to read/write
    output reg mem_op,                          // Select read/write operation
    output reg mem_op_init,                     // Tell memory that we are going to use it
    output reg mem_op_done,                     // The caché finished reading the returned data
    output reg [LINE_SIZE-1:0] mem_data_in,     // Data to be written in memory
    output reg [ADDRESS_WIDTH-1:0] mem_address  // Address to be read/written in memory
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
  reg hit;
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

  //TODO do we need to use <= instead of = in the following lines?
  // Function to update LRU counters
  task update_lru;
    input [1:0] accessed_line; // Updated the size to match line_number
    integer i;
    begin
      for (i = 0; i < NUM_LINES; i = i + 1)
      begin
        if (lru_counters[i] >= lru_counters[accessed_line])
        begin
          lru_counters[i] = lru_counters[i] - 1;
        end
      end
      lru_counters[accessed_line] = NUM_LINES - 1;  // Most recently used
    end
  endtask

  integer i;
  integer j, replace_index;

  initial
  begin
    for (i = 0; i < NUM_LINES; i = i + 1)
    begin
      valid_array[i] = 0;
      lru_counters[i] = i;
      dirty_array[i] = 0;
    end

    mem_op_init = 0;
    mem_op_done = 0;
    mem_enable = 0;
    mem_op = 0;
  end


  always @(posedge clk or posedge reset)
  begin
    if (access)
    begin
      // FOR TESTING --- Print input values
      $display("In values: clk=%b, reset=%b, address=%b, data_in=%h, op=%b, miss=%d, mem_data_ready=%d", clk, reset, address, data_in, op, ~hit, mem_data_ready);

      if (reset)
      begin
        for (i = 0; i < NUM_LINES; i = i + 1)
        begin
          valid_array[i] = 0;
          lru_counters[i] = i;
          dirty_array[i] = 0;
        end
        mem_op_init = 0;
        mem_op_done = 0;
        mem_enable = 0;
        mem_op = 0;
      end
      else if (op == 1'b0) /*write*/
      begin
        hit = |hit_signals;

        if (hit)
        begin
          if (byte_op)
          begin
            data_array[line_number][address[INIT_WORD_OFFSET:END_WORD_OFFSET]][address[INIT_BYTE_OFFSET:END_BYTE_OFFSET]*8 +: 8] = data_in[7:0];
          end
          else
          begin
            data_array[line_number][address[INIT_WORD_OFFSET:END_WORD_OFFSET]] = data_in;
          end
          update_lru(line_number);

        end
        else /*miss*/
        begin
          $display("----> Miss");
          // Find the line to replace based on LRU
          replace_index = 0;
          for (j = 0; j < NUM_LINES; j = j + 1)
          begin
            if (lru_counters[j] < lru_counters[replace_index])
            begin
              replace_index = j;
            end
          end

          $display("----> Valid: %b", valid_array[replace_index]);
          $display("----> Dirty: %b", dirty_array[replace_index]);

          if (valid_array[replace_index] && dirty_array[replace_index])
          begin
            $display("----> Memory access to write");
            // Tell memory to write the line
            if(memory_in_use == 0) //Wait until memory is available
            begin
              mem_op_init = 1;
              mem_data_in[31:0] = data_array[replace_index][0];
              mem_data_in[63:32] = data_array[replace_index][1];
              mem_data_in[95:64] = data_array[replace_index][2];
              mem_data_in[127:96] = data_array[replace_index][3];

              mem_address[INIT_TAG:END_TAG] = tag_array[replace_index];
              mem_address[INIT_WORD_OFFSET:END_BYTE_OFFSET] = 0;
              mem_op = 1'b1;
              mem_enable = 1'b1;
            end
            /*If this module inited a memory op and the memory module tell us that it finished
            we can now read the data of the writen line*/
            else if (mem_op_init && mem_data_ready)
            begin
              //Finish the write operation
              mem_op_done = 1;
              valid_array[replace_index] = 0;
              mem_enable = 1'b0;
            end
          end
          else if (valid_array[replace_index] == 0 && dirty_array[replace_index])
          begin
            $display("----> Memory access to read");
            //Init the read operation
            mem_op_done = 0;
            mem_address = address;
            mem_op = 1'b0;
            mem_enable = 1'b1;

            if(mem_op_init && mem_data_ready)
            begin
              data_array[replace_index][0] = mem_data_out[31:0];
              data_array[replace_index][1] = mem_data_out[63:32];
              data_array[replace_index][2] = mem_data_out[95:64];
              data_array[replace_index][3] = mem_data_out[127:96];

              // Unblock memory module
              mem_enable = 0;
              mem_op_init = 0;
              mem_op_done = 1;
              dirty_array[replace_index] = 0;
            end
          end
          else if(valid_array[replace_index] == 0 &&  dirty_array[replace_index] == 0)
          begin
            $display("----> Write");
            if (byte_op)
            begin
              data_array[replace_index][address[INIT_WORD_OFFSET:END_WORD_OFFSET]][address[INIT_BYTE_OFFSET:END_BYTE_OFFSET]*8 +: 8] = data_in[7:0];
            end
            else
            begin
              data_array[replace_index][address[INIT_WORD_OFFSET:END_WORD_OFFSET]] = data_in;
            end

            // Update line control information
            tag_array[replace_index] = address[INIT_TAG:END_TAG];
            valid_array[replace_index] = 1;
            dirty_array[replace_index] = 1;
            update_lru(replace_index);
          end
        end
      end
      else if (op == 1'b1) /* read*/
      begin
        hit = |hit_signals;

        if (hit)
        begin
          if (byte_op)
          begin
            data_out[WORD_WIDTH:8] = 0;
            data_out[7:0] = data_array[line_number][address[INIT_WORD_OFFSET:END_WORD_OFFSET]][address[INIT_BYTE_OFFSET:END_BYTE_OFFSET]*8 +: 8];
          end
          else
          begin
            data_out = data_array[line_number][address[INIT_WORD_OFFSET:END_WORD_OFFSET]];
          end
          update_lru(line_number);
        end
        else /*miss*/
        begin
          mem_enable = 1;
          mem_op = 0;
          $display("The cache address is: %b", address);
          $display("The cache address value is: %h", data_out);

          $display("The memory address is: %b", mem_address);
          $display("The memory address value is: %h", mem_data_out);

          // Find the line to replace based on LRU
          replace_index = 0;
          for (j = 0; j < NUM_LINES; j = j + 1)
          begin
            if (lru_counters[j] < lru_counters[replace_index])
            begin
              replace_index = j;
            end
          end

          // When memory returns data, store it in the cache
          if(mem_data_ready)
          begin
            data_array[replace_index][0] = mem_data_out[31:0];
            data_array[replace_index][1] = mem_data_out[63:32];
            data_array[replace_index][2] = mem_data_out[95:64];
            data_array[replace_index][3] = mem_data_out[127:96];

            // Update line control information
            tag_array[replace_index] = address[INIT_TAG:END_TAG];
            valid_array[replace_index] = 1;
            update_lru(replace_index);
            mem_op_done = 1;

            data_out = data_array[replace_index][tag_array[replace_index]];
          end
        end
      end

      // FOR TESTING --- Print cache contents
      $display("Printing Cache Contents at Time: %0d", $time);
      for (i = 0; i < NUM_LINES; i = i + 1)
      begin
        $display("Line %0d: Valid = %0b, Tag = %h, Data =", i, valid_array[i], tag_array[i]);
        for (j = 0; j < WORDS_PER_LINE; j = j + 1)
        begin
          $write("%h ", data_array[i][j]);
        end
        $display(" ");
      end
      $display("\n");
    end
  end
endmodule
