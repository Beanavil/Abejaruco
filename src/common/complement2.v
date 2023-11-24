module complement2 #(
    parameter N = 32  // Default bit width set to 32
)(
     input [N-1:0] in,        // N-bit input
    output [N-1:0] out       // N-bit output representing two's complement
);

// Calculate the two's complement
assign out = ~in + 1;

endmodule
