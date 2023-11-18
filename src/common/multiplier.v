`default_nettype none

module Multiplier #(parameter WIDTH = 4) 
  (input [WIDTH - 1:0] a, 
  input [WIDTH - 1:0] b, 
  output [WIDTH * 2 - 1:0] result);

initial begin 
  if (WIDTH > 4) begin 
    $display("\033[31mMultiplier instantiated with WIDTH > 4. WIDTH = %0d\033[0m", WIDTH); 
    end 
  end

wire [WIDTH - 1:0] previous_stage; 
wire carry_out; 

genvar i; 
generate 
  for (i = 0; i < WIDTH - 2; i = i + 1) 
  begin : bit_loop 
  Adder #(.WIDTH(4)) 
    adder_instance ( 
      .a(i == 0 ? a & b[i] >> 1 : previous_stage), 
      .b(a & b[i + 1]), 
      .carry_in(1'b0), 
      .sum({carry_out, previous_stage[WIDTH - 1:1]}), 
      .carry_out(carry_out) 
    );
end
assign result = {carry_out, previous_stage, result[WIDTH - 2:0]}; 
endgenerate

endmodule
