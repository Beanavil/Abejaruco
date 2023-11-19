// Purpose: calculate the two's complement of a 32-bit number.
module complement2_32bit(
    input [31:0] in,        // 32-bit input
    output [31:0] out       // 32-bit output representing two's complement
);

// Calculate the two's complement
assign out = ~in + 1;

endmodule
