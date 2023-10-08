`default_nettype none

module and_gate_tb (a, b, y);
    input wire a;
    input wire b;

    output wire y;

    and_gate test_and_gate (a, b, y);
endmodule
