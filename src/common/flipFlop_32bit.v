// Purpose: 32-bit register (flip-flop) with asynchronous reset
module flipFlop_32bit(
    input clk,
    input reset,
    input  [31:0] d,      // Data input
    output reg [31:0] q   // Data output (register)
);

// Sequential logic for the register
/*
    1. Sesible to posedge of clock
    2. Sesible to posedge of reset (asynchronous reset)
*/
always @(posedge clk or posedge reset) begin
    if (reset) begin
        q <= 32'b0;  // Reset the register to 0
    end else begin
        q <= d;      // On each clock cycle, store the input data in the register
    end
end

endmodule
