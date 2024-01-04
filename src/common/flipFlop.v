module flipFlop #(
    parameter N = 32    // Default bit width
)(
    input clk,
    input reset,
    input [N-1:0] d,
    output reg [N-1:0] q
);

// Sequential logic for the register
/*
    1. Sensitive to posedge of clock
    2. Sensitive to posedge of reset (asynchronous reset)
*/
always @(posedge clk or posedge reset) begin
    if (reset) begin
        q <= {N{1'b0}};  // Reset the register to 0 (N bits)
    end else begin
        q <= d;          // On each clock cycle, store the input data in the register
    end
end

endmodule
