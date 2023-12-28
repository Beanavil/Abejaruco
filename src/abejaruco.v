// GNU General Public License
//
// Copyright : (c) 2023 Javier Beiro Piñón
//           : (c) 2023 Beatriz Navidad Vilches
//           : (c) 2023 Stefano Petrili
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

`timescale 1ns / 1ps

`include "src/decode/control_unit.v"
`include "src/common/cache/cache.v"

module Abejaruco();

reg [31:0] r [0:31];
reg [31:0] rm0 = 32'h1000;
reg [31:0] rm1;
reg [31:0] rm2;
wire clock = 0;

always #1 clock = ~clock;

// wire instruction_cache_reset = 0;
// wire [31:0] instruction_cache_address = 32'h1000;
// wire [31:0] instruction_cache_data_in = 32'h1000;
// wire instruction_cache_op = 0;
// wire instruction_cache_byteOP = 0;
// wire instruction_cache_access = 0;
// wire [31:0] instruction_cache_data_out;
// wire instruction_cache_hit;
// wire instruction_cache_miss

// cache instruction_cache(
//     .clk(clock),
//     .reset(1'b0),
//     .address(32'h1000),
//     .data_in(32'h1000),
//     .op(1'b1),
//     .byteOP(1'b0),
//     .access(1'b1),
//     .data_out(instruction_cache_data_out),
//     .hit(instruction_cache_hit),
//     .miss(instruction_cache_miss)
// );

always @(posedge clock) begin

end
endmodule
