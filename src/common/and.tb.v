`default_nettype none

module tb_and_gate();

  // Define signals for test bench
  reg a, b;
  wire y;

  // Instantiate the module under test
  and_gate dut(
    .a(a),
    .b(b),
    .y(y)
  );

  // Stimulus generation
  initial begin
    $display("Testing AND gate functionality");
    $display("-------------------------------");
    
    // Test case 1: a = 0, b = 0
    a = 0; b = 0;
    #1 $display("a = %b, b = %b, y = %b", a, b, y);

    // Test case 2: a = 0, b = 1
    a = 0; b = 1;
    #1 $display("a = %b, b = %b, y = %b", a, b, y);

    // Test case 3: a = 1, b = 0
    a = 1; b = 0;
    #1 $display("a = %b, b = %b, y = %b", a, b, y);

    // Test case 4: a = 1, b = 1
    a = 1; b = 1;
    #1 $display("a = %b, b = %b, y = %b", a, b, y);

    // End simulation
    $finish;
  end

endmodule
