`timescale 1ns / 1ps

module demux1to2_32bit_tb;

reg [31:0] in;
reg sel;
wire [31:0] out0, out1;

// Instantiate the Demultiplexer module (Unit Under Test (UUT))
demux1to2_32bit uut (
    .in(in),
    .sel(sel),
    .out0(out0),
    .out1(out1)
);

initial begin
    // Monitor changes (each time one of the values changes it will be printed)
    $monitor("Time=%0d, sel=%b, in=%h, out0=%h, out1=%h", $time, sel, in, out0, out1);

    // Initialize Inputs
    in = 0;
    sel = 0;

    // Test Case 1: Select output 0
    #10;
    $display("Test Case 1: Select output 0");
    in = 32'hA5A5A5A5;
    sel = 1'b0;
    #10;
    if (out0 !== in || out1 !== 0) $display("Error in Test Case 1 at time %0d", $time);

    // Test Case 2: Select output 1
    #10;
    $display("Test Case 2: Select output 1");
    sel = 1'b1;
    #10;
    if (out1 !== in || out0 !== 0) $display("Error in Test Case 2 at time %0d", $time);

    // End of Test
    #10;
    $display("End of Test at time %0d", $time);
    $finish;
end

endmodule
