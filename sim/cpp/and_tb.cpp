#include <verilated.h>
#include <verilated_vcd_c.h>

#include <stdio.h>
#include <stdlib.h>

#include "Vand_gate_tb.h"

int main (int argc, char* argv[])
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    vluint64_t num_ticks = 4;
    vluint64_t sim_tick = 1;

    Vand_gate_tb and_gate_tb;

    VerilatedVcdC vcd;

    and_gate_tb.trace(&vcd, 99);
    and_gate_tb.a = 0;
    and_gate_tb.b = 0;

    vcd.open("counter.vcd");

    printf("Started verilator simulation of and_gate\n");  

    and_gate_tb.eval();
    if (and_gate_tb.y != 0) return EXIT_FAILURE;
    
    and_gate_tb.a = 1;
    and_gate_tb.eval();
    if (and_gate_tb.y != 0) return EXIT_FAILURE;

    and_gate_tb.b = 1;;
    and_gate_tb.eval();
    if (and_gate_tb.y != 1) return EXIT_FAILURE;

    and_gate_tb.b = 0;
    and_gate_tb.eval();
    if (and_gate_tb.y != 0) return EXIT_FAILURE;
    printf("Exited simulation\n");

    and_gate_tb.final();

    vcd.close();

    return EXIT_SUCCESS;
}
