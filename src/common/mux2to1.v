module mux2to1 #(
    parameter N = 32          // Default bit
)(
    input [1:0] sel,          // Two-bit selection input
    input [N-1:0] in0,
    input [N-1:0] in1,
    output reg [N-1:0] out
);

// When any of the inputs change, the output will be updated
always @(in0, in1, sel) begin
    case(sel)
        2'b00: out = in0;           // Select input in0
        2'b01: out = in1;           // Select input in1
        default: out = {N{1'b0}};   // Default case (N-bit 0)
    endcase
end

endmodule
