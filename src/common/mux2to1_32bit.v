// Purpose: 32-bit 2:1 mux with 1-bit selection input.
module mux2to1_32bit(
    input [31:0] in0,        // 32-bit input
    input [1:0] sel,         // Two-bit selection input
    output [31:0] in1,       // First 32-bit output
    output reg [31:0] out    // Second 32-bit output
);

//When any of the inputs change, the output will be updated
always @(in0, in1, sel) begin
    case(sel)
        1'b0: out = in0;     // Select input in0
        1'b1: out = in1;     // Select input in1
        default: out = 32'b0;   // Default case or you can also define as don't care
    endcase
end

endmodule

