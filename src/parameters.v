// GNU General Public License
//
// Copyright : (c) 2024 Javier Beiro Piñón
//           : (c) 2024 Beatriz Navidad Vilches
//           : (c) 2024 Stefano Petrili
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

`ifndef PARAMETERS_VPetrilli
`define PARAMETERS_V

parameter CLK_PERIOD = 1;

parameter NUM_REGS = 32;
parameter REGISTER_INDEX_WIDTH = $clog2(NUM_REGS);

parameter ADDRESS_WIDTH = 32;
parameter WORD_WIDTH = 32;

parameter MEMORY_ADDRESS_SIZE = 12;
parameter MEMORY_LOCATIONS = 4096;
parameter MEMORY_OP_DELAY_CYCLES = 3;
parameter MEMORY_TB_DELAY_PERIOD = 6;

parameter CACHE_LINE_SIZE = 128;
parameter CACHE_NUM_LINES = 4;
parameter CACHE_WORDS_PER_LINE = CACHE_LINE_SIZE / (WORD_WIDTH);
parameter FULL_OFFSET_WIDTH = $clog2(CACHE_WORDS_PER_LINE) + $clog2(WORD_WIDTH/8);
parameter TAG_WIDTH = ADDRESS_WIDTH - FULL_OFFSET_WIDTH;
parameter INIT_TAG = ADDRESS_WIDTH - 1;
parameter END_TAG = ADDRESS_WIDTH - TAG_WIDTH; // FULL_OFFSET_WIDTH
parameter INIT_WORD_OFFSET = END_TAG - 1;
parameter END_WORD_OFFSET = INIT_WORD_OFFSET - ($clog2(CACHE_WORDS_PER_LINE)-1);
parameter INIT_BYTE_OFFSET = END_WORD_OFFSET - 1;
parameter END_BYTE_OFFSET = 0;

parameter SIGN_EXTENDER_INPUT_SIZE = 12;

parameter OFFSET_SIZE = 12;

parameter NIBBLE_WIDTH = 4;

`define ABEJARUCO_VERBOSE
`define ALU_VERBOSE
`define MEMORY_VERBOSE
// `define CACHE_VERBOSE

`define F_REGS_VERBOSE
`define D_REGS_VERBOSE
`define EX_REGS_VERBOSE

`ifdef CACHE_VERBOSE
`define CACHE_DISPLAY(str) $display("[ CACHE ] %s", str)
`define CACHE_WRITE(str) $write("%s", str)
`else
`define CACHE_DISPLAY(str)
`define CACHE_WRITE(str)
`endif

`ifdef ABEJARUCO_VERBOSE
`define ABEJARUCO_DISPLAY(str) $display("[ ABEJARUCO ] %s", str)
`define ABEJARUCO_WRITE(str) $write("%s", str)
`else
`define ABEJARUCO_VERBOSE(str)
`define ABEJARUCO_WRITE(str)
`endif

`ifdef ALU_VERBOSE
`define ALU_DISPLAY(str) $display("[ ALU ] %s", str)
`define ALU_WRITE(str) $write("%s", str)
`else
`define ALU_VERBOSE(str)
`define ALU_WRITE(str)
`endif

`endif
