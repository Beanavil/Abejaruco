// GNU General Public License
//
// Copyright : (c) 2023-2024 Javier Beiro Piñón
//           : (c) 2023-2024 Beatriz Navidad Vilches
//           : (c) 2023-2024 Stefano Petrilli
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

module Memory #(parameter PROGRAM = "../../programs/zero.o")

  (input wire clk,
   input wire enable,
   input wire op,
   input wire [MEMORY_ADDRESS_SIZE-1:0] address,
   input wire [CACHE_LINE_SIZE-1:0] data_in,
   input wire op_init,
   input wire op_done,                        // The module finished reading the returned data
   output reg [CACHE_LINE_SIZE-1:0] data_out,
   output reg data_ready,
   output reg memory_in_use                   // Memory is use by another module
  );
`include "src/parameters.v"

  reg [7:0] memory [0:MEMORY_LOCATIONS-1];

  initial
  begin
    $readmemh(PROGRAM, memory);
    data_ready = 1'b0;
  end

  // State definitions
  reg [1:0] state = 2'b00;
  reg [2:0] counter = 0; // 3-bit counter for 5-cycle delay


  //TODO: Added the op_init, to distinguish if a memory operation is started by other module
  always @(posedge op_init)
  begin
    memory_in_use = 1'b1;
  end

  // always @(posedge op_done) begin
  //   data_ready = 1'b0;
  // end

  // always @(posedge op_done, negedge op_init) begin
  //   memory_in_use = 1'b0;
  // end

  always @(posedge clk)
  begin
    `MEMORY_DISPLAY($sformatf("The address is %h, the state is %h", address, enable));

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
          `MEMORY_DISPLAY($sformatf("Enter in wait %d", counter));
          if (counter < MEMORY_OP_DELAY_CYCLES-1)
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
          `MEMORY_DISPLAY($sformatf("op = %b", op));
          if (op) /*write*/
          begin
            `MEMORY_DISPLAY("Enter in write");
            for (integer i = 0; i < CACHE_LINE_SIZE / 8; i = i + 1)
            begin
              memory[address + i] = data_in[i*8 +: 8];
            end
          end
          else /*read*/
          begin
            `MEMORY_DISPLAY("Enter in read");
            for (integer i = 0; i < CACHE_LINE_SIZE / 8; i = i + 1)
            begin
              data_out[i*8 +: 8] = memory[address + i];
            end
          end
          data_ready = 1'b1;
          state = 2'b00;
        end
      endcase
    end


    // End memory op
    if (op_done)
    begin
      data_ready = 1'b0;
    end
  end
endmodule
