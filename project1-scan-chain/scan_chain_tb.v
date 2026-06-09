// =============================================
// Testbench: scan_chain_tb
// Tests the complete shift-capture-shift cycle
// Target pattern: FF0=1,FF1=0,FF2=1,FF3=1,
//                 FF4=0,FF5=0,FF6=1,FF7=1
// =============================================
`timescale 1ns/1ps

module scan_chain_tb;

    reg        clk, rst, se, si;
    reg  [7:0] d;
    wire       so;
    wire [7:0] q;

    // Instantiate scan chain
    scan_chain uut (
        .clk(clk), .rst(rst), .se(se),
        .si(si), .d(d), .so(so), .q(q)
    );

    // 10ns clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Waveform dump
    initial begin
        $dumpfile("scan_chain.vcd");
        $dumpvars(0, scan_chain_tb);
    end

    // Target pattern (FF0 to FF7)
    // Load in REVERSE: FF7's bit first into SI
    // Pattern: 8'b11001101 → FF0=1,FF1=0,FF2=1,FF3=1,FF4=0,FF5=0,FF6=1,FF7=1
    // Shift order (SI first): FF7..FF0 = 1,1,0,0,1,1,0,1
    reg [7:0] shift_pattern = 8'b10110011; // reversed

    integer i;

    initial begin
        // ---- RESET ----
        rst=1; se=0; si=0; d=8'b0;
        @(posedge clk); #1;
        rst=0;
        $display("=== RESET DONE: Q=%b ===", q);

        // =====================
        // PHASE 1: SHIFT IN
        // SE=1, clock 8 times
        // =====================
        se = 1;
        $display("\n--- PHASE 1: SHIFT IN (SE=1) ---");
        for (i = 7; i >= 0; i = i-1) begin
            si = shift_pattern[i];
            @(posedge clk); #1;
            $display("Clk %0d: SI=%b → Q=%b", 8-i, si, q);
        end
        $display(">> After shift-in: Q=%b (expect 10110011 reversed = 11001101)", q);

        // =====================
        // PHASE 2: CAPTURE
        // SE=0, one clock pulse
        // Functional D inputs applied
        // =====================
        se = 0;
        d  = 8'b10101010; // functional values to capture
        $display("\n--- PHASE 2: CAPTURE (SE=0, D=%b) ---", d);
        @(posedge clk); #1;
        $display(">> After capture: Q=%b (should match D=%b)", q, d);

        // =====================
        // PHASE 3: SHIFT OUT
        // SE=1, clock 8 times
        // Read SO each cycle
        // =====================
        se = 1;
        si = 0; // don't care during shift-out
        $display("\n--- PHASE 3: SHIFT OUT (SE=1) ---");
        for (i = 0; i < 8; i = i+1) begin
            @(posedge clk); #1;
            $display("Clk %0d: SO=%b, Q=%b", i+1, so, q);
        end

        $display("\n=== SCAN CHAIN TEST COMPLETE ===");
        $finish;
    end

endmodule
