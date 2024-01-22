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

`default_nettype none

module MemArbiter (
    // In
    //--from DCache
    input wire dcache_mem_op_init,
    input wire dcache_op_done,
    input wire [MEMORY_ADDRESS_SIZE-1:0] dcache_mem_address,
    input wire dcache_mem_op,
    input wire [CACHE_LINE_SIZE-1:0] dcache_mem_data_in,
    input wire dcache_start_access,

    //--from ICache
    input wire icache_mem_op_init,
    input wire icache_op_done,
    input wire [MEMORY_ADDRESS_SIZE-1:0] icache_mem_address,
    input wire icache_start_access,

    //--from memory
    input wire mem_data_ready,
    input wire [CACHE_LINE_SIZE-1:0] mem_data_out,

    // Out
    //--To memory
    output reg mem_enable,
    output reg mem_op,
    output reg [MEMORY_ADDRESS_SIZE-1:0] mem_address,
    output reg [CACHE_LINE_SIZE-1:0] mem_data_in,

    //-To cache
    output reg [CACHE_LINE_SIZE-1:0] mem_data_out_to_cache,

    //-Dcache
    output reg dcache_allow_op,
    output reg dcache_mem_data_ready,
    //-ICache
    output reg icache_allow_op,
    output reg icache_mem_data_ready
  );

`include "src/parameters.v"

    reg dcache_in_exec;
    reg icache_in_exec;

    initial
    begin
      icache_mem_data_ready = 0;
      dcache_mem_data_ready = 0;
      mem_enable = 0;
      dcache_in_exec = 0;
      icache_in_exec = 0;
      icache_allow_op = 0;
      dcache_allow_op = 0;
    end

    always @(negedge icache_start_access)
    begin
      if(icache_mem_op_init)
      begin
        mem_enable = 0;
      end
    end

    always @(negedge dcache_start_access)
    begin
      if(dcache_mem_op_init)
      begin
        mem_enable = 0;
      end
    end

    always @(posedge dcache_op_done)
    begin
      dcache_in_exec = 0;
      dcache_allow_op = 0;
      dcache_mem_data_ready = 0;
    end

    always @(posedge icache_op_done)
    begin
      icache_in_exec = 0;
      icache_allow_op = 0;
      icache_mem_data_ready = 0;
    end

    //Memory finish op
    always @(posedge mem_data_ready)
    begin
      mem_data_out_to_cache = mem_data_out;

      if (icache_in_exec)
      begin
        icache_mem_data_ready = 1;
      end
      else if(dcache_in_exec & ~mem_op)
      begin
        dcache_mem_data_ready = 1;
      end
      mem_enable = 0;
    end

    //A memory petition comes form cache
    always @(*)
    begin
      //icache
      if(icache_mem_op_init & ~dcache_mem_op_init)
      begin
        
        icache_in_exec = 1;
        icache_allow_op = 1;
        if(icache_start_access)
        begin
          mem_address = icache_mem_address;
          mem_op = 0; //read
          mem_enable = 1;
        end 
      end

      //dcache
      if((~icache_mem_op_init & dcache_mem_op_init) |
        (icache_mem_op_init & dcache_mem_op_init & ~dcache_in_exec & ~icache_in_exec))
      begin
        dcache_in_exec = 1;
        dcache_allow_op = 1;
        
        if(dcache_start_access)
        begin
          mem_op = dcache_mem_op;
          mem_address = dcache_mem_address;
          mem_data_in = dcache_mem_data_in;
          mem_enable = 1;
        end
      end
    end
endmodule