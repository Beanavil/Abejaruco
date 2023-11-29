`default_nettype none

`include "src/execution/multiplier.v"

module Multiplier_tb();
    
    reg [31:0] a, b, clock;
    wire [31:0] result;

    // Multiplier #(.WIDTH(4)) multiplier (
    // .a(a),
    // .b(b),
    // .result(result)
    // .clock(clock)
    // );
    
    initial begin
        $display("Testing multiple stage Multiplier");
        $display("-------------------------------");
        
        $finish;
    end
endmodule
