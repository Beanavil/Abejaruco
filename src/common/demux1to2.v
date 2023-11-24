module demux1to2 #(
    parameter N = 32          // Default bit width
)(
    input [N-1:0] in,
    input sel,                // Selection input
    output reg [N-1:0] out0,
    output reg [N-1:0] out1
);

// Always block to update outputs based on selection
always @(in or sel) begin
    if (sel == 1'b0) begin
        out0 = in;           // Route input to out0
        out1 = {N{1'b0}};    // Set out1 to 0 (N bits)
    end else begin
        out0 = {N{1'b0}};    // Set out0 to 0 (N bits)
        out1 = in;           // Route input to out1
    end
end

endmodule

