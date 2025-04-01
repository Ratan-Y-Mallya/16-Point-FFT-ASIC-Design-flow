module multiplier_tb;
reg [15:0] in1, in2;
wire [15:0] final;

multiplier dut (.in1(in1), .in2(in2), .final(final));

initial begin
    // Monitor results
    $monitor("Time=%0t in1=%b in2=%b final=%b", $time, in1, in2, final);

    // Test Case 1: 1.0 * 2.0
    in1 = 16'b0011110000000000; // 1.0
    in2 = 16'b0100000000000000; // 2.0
    #10;  // Expected: 2.0 (0100000000000000)

    // Test Case 2: -2.0 * 2.0
    in1 = 16'b1100000000000000; // -2.0
    in2 = 16'b0100000000000000; // 2.0
    #10;  // Expected: -4.0 (1100100000000000)

    // Test Case 3: 3.0 * 3.0
    in1 = 16'b0100001000000000; // 3.0
    in2 = 16'b0100001000000000; // 3.0
    #10;  // Expected: 9.0 (0100110000000000)

    // Test Case 4: 1.0 * 0.0
    in1 = 16'b0011110000000000; // 1.0
    in2 = 16'b0000000000000000; // 0.0
    #10;  // Expected: 0.0 (0000000000000000)

    // Test Case 5: Infinity * 1.0
    in1 = 16'b0111110000000000; // Infinity
    in2 = 16'b0011110000000000; // 1.0
    #10;  // Expected: Infinity (0111110000000000)

    // Test Case 6: Infinity * Infinity
    in1 = 16'b0111110000000000; // Infinity
    in2 = 16'b0111110000000000; // Infinity
    #10;  // Expected: Infinity (0111110000000000)

    // Test Case 7: Infinity * -Infinity
    in1 = 16'b0111110000000000; // Infinity
    in2 = 16'b1111110000000000; // -Infinity
    #10;  // Expected: -Infinity (1111110000000000)

    // Test Case 8: NaN * 1.0
    in1 = 16'b1111111111111111; // NaN
    in2 = 16'b0011110000000000; // 1.0
    #10;  // Expected: NaN (1111111111111111)

    // End simulation
    $finish;
end

initial begin
    $dumpfile("top_dump.vcd");
    $dumpvars(0);
end

endmodule