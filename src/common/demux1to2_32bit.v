// Purpose: 32-bit 1:2 demux with 1-bit selection input.
module demux1to2_32bit(
    input [31:0] in,         // 32-bit input
    input sel,               // Single-bit selection input
    output reg [31:0] out0,  // First 32-bit output
    output reg [31:0] out1   // Second 32-bit output
);

// Always block to update outputs based on selection
always @(in or sel) begin
    // Based on selection, route input to one of the outputs
    if (sel == 1'b0) begin
        out0 = in;           // Route input to out0
        out1 = 32'b0;        // Set out1 to 0
    end else begin
        out0 = 32'b0;        // Set out0 to 0
        out1 = in;           // Route input to out1
    end
end

endmodule
