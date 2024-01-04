`default_nettype none

`timescale 1ns / 1ps

`ifndef PARAMETERS_V
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
parameter INIT_TAG = ADDRESS_WIDTH - 1;
parameter END_TAG = ADDRESS_WIDTH - TAG_WIDTH; // TODO: FULL_OFFSET_WIDTH
parameter INIT_WORD_OFFSET = END_TAG - 1;
parameter END_WORD_OFFSET = INIT_WORD_OFFSET - ($clog2(CACHE_WORDS_PER_LINE)-1);
parameter INIT_BYTE_OFFSET = END_WORD_OFFSET - 1;
parameter END_BYTE_OFFSET = 0;
parameter TAG_WIDTH = ADDRESS_WIDTH - FULL_OFFSET_WIDTH;
  parameter FULL_OFFSET_WIDTH = $clog2(CACHE_WORDS_PER_LINE) + $clog2(WORD_WIDTH/8);    // Calculate offset width

`endif
