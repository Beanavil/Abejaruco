// GNU General Public License
//
// Copyright : (c) 2023-2024 Javier Beiro Piñón
//           : (c) 2023-2024 Beatriz Navidad Vilches
//           : (c) 2023-2024 Stefano Petrili
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

module Memory #(parameter ADDRESS_SIZE = 12,
                   CACHE_LINE_SIZE = 128,
                   MEMORY_LOCATIONS = 4096,
                   OP_DELAY_CYCLES = 3,
                   PROGRAM = "../../programs/random_binary.o")
  (input wire clk,
   input wire enable,
   input wire op,
   input wire [ADDRESS_SIZE-1:0] address,
   input wire [CACHE_LINE_SIZE-1:0] data_in,
   input wire op_done,
   output reg [CACHE_LINE_SIZE-1:0] data_out,
   output reg data_ready);

  reg [7:0] memory [0:MEMORY_LOCATIONS-1];

  initial
  begin
    for(integer i = 0; i < MEMORY_LOCATIONS; i = i + 1)
    begin
      memory[i] = 0;
    end
    // $readmemh(PROGRAM, memory);
  end

  // State definitions
  reg [1:0] state = 2'b00;
  reg [2:0] counter = 0; // 3-bit counter for 5-cycle delay

  always @(negedge op_done) begin
    data_ready = 1'b0;
  end

  always @(posedge clk)
  begin
    if (enable)
    begin
      case (state)
      2'b00: /*IDLE*/
      begin
          state = 2'b01;
          counter = 0;
      end

      2'b01: /*WAIT*/
      begin
          $display("Entra en wait %d", counter);
          if (counter < OP_DELAY_CYCLES-1)
          begin
          counter = counter + 1;
          end
          else
          begin
          state = 2'b10;
          end
      end

      2'b10: /*WRITE or READ*/
      begin
          $display("op = %b", op);
          if (op) /*write*/
          begin
            $display("Entra en write");
            for (integer i = 0; i < CACHE_LINE_SIZE / 8; i = i + 1)
            begin
                memory[address + i] = data_in[i*8 +: 8];
            end
          end
          else /*read*/
          begin
            $display("Entra en read");
            for (integer i = 0; i < CACHE_LINE_SIZE / 8; i = i + 1)
            begin
                data_out[i*8 +: 8] = memory[address + i];
            end
          end
          data_ready = 1'b1;
          state = 2'b00;
      end
      endcase
    // $display("Address: %h", address);
    // $display("Data written: %h", data_in);
    // $display("Data read: %h", data_out);
    end

    // End memory op
    if (op_done)
    begin
      data_ready = 1'0;
    end
  end
endmodule
