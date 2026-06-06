// =============================================
// Testbench: fault_injection_tb
// Runs IDENTICAL test on both:
//   - scan_chain       (fault-free / golden)
//   - scan_chain_faulty (SA1 on d[0])
// Compares shift-out results and flags detection
// =============================================
`timescale 1ns/1ps

module fault_injection_tb;

    reg        clk, rst, se, si;
    reg  [7:0] d;

    // Fault-free chain
    wire       so_good;
    wire [7:0] q_good;

    // Faulty chain
    wire       so_bad;
    wire [7:0] q_bad;

    // Instantiate BOTH chains side by side
    scan_chain uut_good (
        .clk(clk),.rst(rst),.se(se),
        .si(si),.d(d),.so(so_good),.q(q_good)
    );

    scan_chain_faulty uut_bad (
        .clk(clk),.rst(rst),.se(se),
        .si(si),.d(d),.so(so_bad),.q(q_bad)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Waveform dump
    initial begin
        $dumpfile("fault_injection.vcd");
        $dumpvars(0, fault_injection_tb);
    end

    // Shift-in pattern (reversed for FF7..FF0)
    // We want: FF0=0,FF1=1,FF2=0,FF3=1,FF4=0,FF5=1,FF6=0,FF7=1
    // Shift order: 1,0,1,0,1,0,1,0
    reg [7:0] shift_pat = 8'b01010101;

    // Capture pattern: d = 8'b00000000
    // SA1 on d[0] means FF0 will capture 1 instead of 0
    // So faulty response = 8'b00000001, good = 8'b00000000

    integer i;
    reg [7:0] shiftout_good, shiftout_bad;

    initial begin
        rst=1; se=0; si=0; d=8'b0;
        @(posedge clk); #1;
        rst = 0;

        // ==========================================
        // PHASE 1: SHIFT IN — load test pattern
        // ==========================================
        se = 1;
        $display("\n========================================");
        $display("PHASE 1: SHIFT IN");
        $display("========================================");
        for (i = 7; i >= 0; i = i-1) begin
            si = shift_pat[i];
            @(posedge clk); #1;
        end
        $display("After shift-in:");
        $display("  Good chain Q = %b", q_good);
        $display("  Faulty chain Q = %b", q_bad);
        $display("  (Should be identical — fault is on D, not scan path)");

        // ==========================================
        // PHASE 2: CAPTURE — apply D=0 to all FFs
        // ==========================================
        se = 0;
        d  = 8'b00000000;  // Drive d[0]=0 — SA1 fault will override this!
        @(posedge clk); #1;

        $display("\n========================================");
        $display("PHASE 2: CAPTURE (D = 00000000)");
        $display("========================================");
        $display("  Good chain Q  = %b  (expected: 00000000)", q_good);
        $display("  Faulty chain Q = %b  (expected: 00000001 — bit 0 stuck!)",
                  q_bad);

        if (q_good[0] !== q_bad[0])
            $display("  >> FAULT DETECTED at FF0! Good=%b Faulty=%b",
                      q_good[0], q_bad[0]);
        else
            $display("  >> Fault NOT detected at capture (masked)");

        // ==========================================
        // PHASE 3: SHIFT OUT — read the response
        // ==========================================
        se = 1;
        si = 0;
        shiftout_good = 0;
        shiftout_bad  = 0;

        $display("\n========================================");
        $display("PHASE 3: SHIFT OUT");
        $display("========================================");
        for (i = 0; i < 8; i = i+1) begin
            @(posedge clk); #1;
            shiftout_good = {shiftout_good[6:0], so_good};
            shiftout_bad  = {shiftout_bad[6:0],  so_bad};
            $display("  Clk %0d: SO_good=%b  SO_faulty=%b  %s",
                i+1, so_good, so_bad,
                (so_good !== so_bad) ? "<-- DIFFERENCE DETECTED" : "");
        end

        $display("\n========================================");
        $display("FAULT DETECTION SUMMARY");
        $display("========================================");
        $display("  Shifted-out (good)   = %b", shiftout_good);
        $display("  Shifted-out (faulty) = %b", shiftout_bad);

        if (shiftout_good !== shiftout_bad) begin
            $display("  >> FAULT DETECTED ✓");
            $display("  >> SA1 on d[0] caught by comparing shift-out responses");
            $display("  >> This is exactly what ATE does at the fab!");
        end else begin
            $display("  >> Fault escaped — pattern did not sensitize the fault");
        end

        $display("========================================\n");
        $finish;
    end

endmodule
