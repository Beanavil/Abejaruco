#include <verilated.h>
#include <verilated_vcd_c.h>
#include <iostream>

#include "Vand_gate_tb.h"

void test_and_gate(int a, int b, int expected_y) {
    Vand_gate_tb and_gate_tb;

    VerilatedVcdC vcd;
    and_gate_tb.trace(&vcd, 99);
    vcd.open("and_gate.vcd");

    std::cout << "Started Verilator simulation of and_gate" << std::endl;

    and_gate_tb.a = a;
    and_gate_tb.b = b;
    and_gate_tb.eval();
    if (and_gate_tb.y != expected_y) {
        std::cerr << "Test failed: a=" << a << ", b=" << b << ", y=" << and_gate_tb.y << std::endl;
        exit(EXIT_FAILURE);
    }

    std::cout << "Exited simulation" << std::endl;

    and_gate_tb.final();
    vcd.close();
}

int main(int argc, char* argv[]) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    test_and_gate(0, 0, 0);
    test_and_gate(1, 0, 0);
    test_and_gate(1, 1, 1);
    test_and_gate(1, 0, 0);

    return EXIT_SUCCESS;
}