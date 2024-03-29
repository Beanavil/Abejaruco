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

module DCache (
    // In wires (from CPU)
    input wire clk,
    input wire access,
    input wire reset,
    input wire [ADDRESS_WIDTH-1:0] address,
    input wire [REGISTER_INDEX_WIDTH-1:0] destination_register_in,
    input wire [WORD_WIDTH-1:0] data_in,        // Data to be written in the cache
    input wire op,
    input wire byte_op,
    input wire cu_reg_write_in,

    // In wires (from arbitrer)
    input wire mem_data_ready,
    input wire [CACHE_LINE_SIZE-1:0] mem_data_out,
    input wire allow_op,

    // Out wires (to CPU)
    output reg [WORD_WIDTH-1:0] data_out,       // Data returned by the cache
    output reg data_ready,                      // Data in the output is valid or write operation finished
    output reg [REGISTER_INDEX_WIDTH-1:0] destination_register_out,
    output reg cu_reg_write_out,

    // Out wires (to arbiter)
    output reg mem_op_init,                             // Tell arbiter we want to access memory
    output reg mem_op_done,                             // Tell arbiter we finish doing the memory access
    output reg [MEMORY_ADDRESS_SIZE-1:0] mem_address,   // Address to be read/written in memory
    output reg mem_op,                                  //read/write
    output reg [CACHE_LINE_SIZE-1:0] mem_data_in,        // Data to be written in memory
    output reg start_access
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
    hit = 0;
    start_access = 0;
  end


  always @(negedge clk)
  begin
    if (mem_op_done)
    begin
      mem_op_done = 0;
    end

  end

  always @(posedge clk or posedge reset)
  begin
    destination_register_out <= destination_register_in;
    cu_reg_write_out <= cu_reg_write_in;

    `CACHE_DISPLAY($sformatf("The access is: %b", access));
    if (data_ready)
    begin
      data_ready = 0;
    end
    if (access)
    begin
      if (reset)
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
        hit = 0;
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
          else if (~byte_op)
          begin
            data_array[line_number][address[INIT_WORD_OFFSET:END_WORD_OFFSET]] = data_in;
          end
          else
          begin
            `CACHE_DISPLAY($sformatf("Warning: byte_op is not 0 or 1"));
          end
          data_ready = 1;
          update_lru(line_number);
        end
        else /*miss*/
        begin
          //1. Ask arbiter for memory access
          mem_op_init = 1;

          //2. If arbiter allows operation continues writing the ejected
          if(allow_op)
          begin
            // Find the line to replace based on LRU
            replace_index = 0;
            for (j = 0; j < CACHE_NUM_LINES; j = j + 1)
            begin
              if (lru_counters[j] < lru_counters[replace_index])
              begin
                replace_index = j;
              end
            end

            //If we have to evict
            if (valid_array[replace_index] && dirty_array[replace_index])
            begin
              // Tell memory to write the line
              mem_op_init = 1;
              mem_data_in[31:0] = data_array[replace_index][0];
              mem_data_in[63:32] = data_array[replace_index][1];
              mem_data_in[95:64] = data_array[replace_index][2];
              mem_data_in[127:96] = data_array[replace_index][3];

              mem_address[INIT_TAG:END_TAG] = tag_array[replace_index];
              mem_address[INIT_WORD_OFFSET:END_BYTE_OFFSET] = 0;

              mem_op = 1'b1;
              start_access = 1;

              if(mem_data_ready)
              begin
                // Finish the write operation
                dirty_array[replace_index] = 0;
                valid_array[replace_index] = 0;
                start_access = 0;
              end
            end
            else if(valid_array[replace_index] == 0)
            begin
              mem_address = address;
              mem_op = 1'b0;

              start_access = 1;
              if(mem_data_ready)
              begin
                //Get memory line
                data_array[replace_index][0] = mem_data_out[31:0];
                data_array[replace_index][1] = mem_data_out[63:32];
                data_array[replace_index][2] = mem_data_out[95:64];
                data_array[replace_index][3] = mem_data_out[127:96];
                dirty_array[replace_index] = 0;

                //Write new data
                `CACHE_DISPLAY("----> Write");
                if (byte_op)
                begin
                  data_array[replace_index][address[INIT_WORD_OFFSET:END_WORD_OFFSET]][address[INIT_BYTE_OFFSET:END_BYTE_OFFSET]*8 +: 8] = data_in[7:0];
                end
                else if (~byte_op)
                begin
                  data_array[replace_index][address[INIT_WORD_OFFSET:END_WORD_OFFSET]] = data_in;
                end
                else
                begin
                  `CACHE_DISPLAY("Warning: byte_op is not 0 or 1");
                end

                // Unblock memory module
                start_access = 0;
                mem_op_done = 1;
                data_ready = 1;

                // Update line control information
                tag_array[replace_index] = address[INIT_TAG:END_TAG];
                valid_array[replace_index] = 1;
                dirty_array[replace_index] = 1;
                update_lru(replace_index);
                mem_op_init = 0;
              end
            end
          end
        end
      end
      else if (op == 1'b1) /* read*/
      begin
        hit = |hit_signals;
        if (hit)
        begin
          `CACHE_DISPLAY("----> Hit");
          `CACHE_DISPLAY($sformatf("Hit values: clk=%b, reset=%b, address=%b, data_in=%h, op=%b, byte_op=%b, miss=%d, mem_data_ready=%d", clk, reset, address, data_in, op, byte_op, ~hit, mem_data_ready));

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
          //1. Ask arbiter for memory access
          mem_op_init = 1;

          //2. If arbiter allow operation continues
          if (allow_op) //CLOSE THIS
          begin
            mem_address = {address[31:4], 4'b0000};

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
            mem_op = 1'b0;
            start_access = 1;
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

              if (byte_op)
              begin
                data_out[WORD_WIDTH:8] = 0;
                data_out[7:0] = data_array[replace_index][address[INIT_WORD_OFFSET:END_WORD_OFFSET]][address[INIT_BYTE_OFFSET:END_BYTE_OFFSET]*8 +: 8];
              end
              else if (~byte_op)
              begin
                data_out = data_array[replace_index][address[INIT_WORD_OFFSET:END_WORD_OFFSET]];
              end
              else
              begin
                `CACHE_DISPLAY("Warning: byte_op is not 0 or 1");
              end

              start_access = 0;
              mem_op_done = 1;
              data_ready = 1;
              mem_op_init = 0;
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
    end
  end
endmodule
