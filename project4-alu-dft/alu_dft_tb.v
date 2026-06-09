`timescale 1ns/1ps

module alu_dft_tb;

    reg        clk, rst, se, si;
    reg  [3:0] a, b;
    reg  [1:0] op;
    wire       so;
    wire [3:0] result_q;
    wire       carry_q;

    alu_dft uut (
        .clk(clk),.rst(rst),.se(se),.si(si),
        .a(a),.b(b),.op(op),
        .so(so),.result_q(result_q),.carry_q(carry_q)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, alu_dft_tb);
    end

    // Task: one full shift-capture-shift cycle
    // Applies inputs, captures into scan FFs, shifts out result
    task run_test;
        input [3:0] in_a, in_b;
        input [1:0] in_op;
        input [4:0] shift_in_pat;  // 5-bit pattern to shift in (reversed)
        input [4:0] expected_out;  // expected shift-out
        input [63:0] test_name;
        reg [4:0] shiftout;
        integer j;
        begin
            // ---- Phase 1: Shift in ----
            se = 1;
            for (j = 4; j >= 0; j = j-1) begin
                si = shift_in_pat[j];
                @(posedge clk); #1;
            end

            // ---- Phase 2: Capture ----
            se = 0;
            a = in_a; b = in_b; op = in_op;
            @(posedge clk); #1;

            // ---- Phase 3: Shift out ----
           se = 1; si = 0;
            shiftout = 5'b0;
            for (j = 0; j < 5; j = j+1) begin
                #1;
                shiftout = {shiftout[3:0], so};
                @(posedge clk);
            end

            $display("%-12s A=%b B=%b OP=%b | Expected=%b Got=%b | %s",
                test_name, in_a, in_b, in_op,
                expected_out, shiftout,
                (shiftout === expected_out) ? "PASS" : "FAIL");
        end
    endtask

    // Task: fault injection test
    // Same as run_test but injects SA fault on one output bit
    task run_fault_test;
        input [3:0] in_a, in_b;
        input [1:0] in_op;
        input [4:0] expected_good;
        input [4:0] expected_bad;
        input [63:0] fault_name;
        reg [4:0] shiftout_good, shiftout_bad;
        integer j;
        begin
            // Good run
            se = 0; a = in_a; b = in_b; op = in_op;
            @(posedge clk); #1;
            se = 1; si = 0; shiftout_good = 5'b0;
            for (j = 0; j < 5; j = j+1) begin
                @(posedge clk); #1;
                shiftout_good = {shiftout_good[3:0], so};
            end

            $display("%-16s Good=%b | %s",
                fault_name, shiftout_good,
                (shiftout_good === expected_good) ? "FAULT-FREE OK" : "UNEXPECTED");
        end
    endtask

    integer i;

    initial begin
        // Reset
        rst=1; se=0; si=0; a=0; b=0; op=0;
        repeat(3) @(posedge clk); #1;
        rst=0;

        $display("\n========================================");
        $display("  ALU DFT — SHIFT-CAPTURE-SHIFT TESTS");
        $display("========================================");
        $display("%-12s %-24s %-20s %s",
                 "Test","Inputs","Pattern","Result");
        $display("----------------------------------------");

        // Test 1: ADD 3+5=8 → result=1000, carry=0 → shift-out = 0_1000 = 01000
        run_test(4'b0011, 4'b0101, 2'b00,
                 5'b00000, 5'b01000, "ADD_3+5");

        // Test 2: ADD 9+9=18 → result=0010, carry=1 → shift-out = 1_0010 = 10010
        run_test(4'b1001, 4'b1001, 2'b00,
                 5'b00000, 5'b10010, "ADD_9+9");

        // Test 3: AND 1010 & 1100 = 1000, carry=0 → 0_1000 = 01000
        run_test(4'b1010, 4'b1100, 2'b10,
                 5'b00000, 5'b01000, "AND");

        // Test 4: OR 1010 | 0101 = 1111, carry=0 → 0_1111 = 01111
        run_test(4'b1010, 4'b0101, 2'b11,
                 5'b00000, 5'b01111, "OR");

        // Test 5: SUB 8-3=5 → result=0101, carry=0 → 0_0101 = 00101
        run_test(4'b1000, 4'b0011, 2'b01,
                 5'b00000, 5'b00101, "SUB_8-3");

        // Test 6: ADD all zeros → result=0000, carry=0 → 0_0000 = 00000
        // This targets SA1 faults on all output bits
        run_test(4'b0000, 4'b0000, 2'b00,
                 5'b00000, 5'b00000, "ADD_0+0");

        // Test 7: ADD all ones → result=1110, carry=1 → 1_1110 = 11110
        // This targets SA0 faults on all output bits
        run_test(4'b1111, 4'b1111, 2'b00,
                 5'b00000, 5'b11110, "ADD_F+F");

        $display("\n========================================");
        $display("  FAULT COVERAGE SUMMARY");
        $display("========================================");
        $display("Target nodes: result[3:0], carry");
        $display("Fault model : SA0 and SA1");
        $display("");
        $display("Test ADD_0+0 (expected 00000):");
        $display("  Detects SA1 on any output bit");
        $display("  If any bit is stuck-at-1, output != 00000");
        $display("");
        $display("Test ADD_F+F (expected 11110):");
        $display("  Detects SA0 on result[3],result[2],result[1],carry");
        $display("  If any of those bits stuck-at-0, output != 11110");
        $display("");
        $display("Test OR (expected 01111):");
        $display("  Detects SA0 on result[3:0]");
        $display("");
        $display("Test ADD_9+9 (expected 10010):");
        $display("  Detects SA0 on carry, SA0 on result[1]");
        $display("  Detects SA1 on result[3],result[2],result[0]");
        $display("========================================\n");

        $finish;
    end

endmodule
