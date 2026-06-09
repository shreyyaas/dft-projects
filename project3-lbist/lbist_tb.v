`timescale 1ns/1ps

module lbist_tb;

    reg        clk, rst;
    wire [3:0] lfsr_out;
    wire [3:0] cut_out;
    wire [3:0] sig;
    reg  [3:0] a_in, b_in;

    lfsr u_lfsr (.clk(clk), .rst(rst), .q(lfsr_out));
    cut  u_cut  (.a(a_in),  .b(b_in),  .out(cut_out));
    misr u_misr (.clk(clk), .rst(rst), .response(cut_out), .signature(sig));

    initial clk = 0;
    always #5 clk = ~clk;

    // Update a_in and b_in combinationally from lfsr_out
    always @(*) begin
        a_in = lfsr_out;
        b_in = {lfsr_out[1:0], lfsr_out[3:2]};
    end

    integer i;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, lbist_tb);

        $display("=== LBIST SIMULATION ===");
        $display("Cycle  LFSR     A        B        CUT      SIG");
        $display("------------------------------------------------");

        // Reset
        rst = 1;
        repeat(4) @(posedge clk); #1;
        rst = 0;

        // Run 15 cycles
      for (i = 0; i < 16; i = i + 1) begin
            @(posedge clk); #1;
            $display("%-6d %-8b %-8b %-8b %-8b %-8b",
                i, lfsr_out, a_in, b_in, cut_out, sig);
        end

        $display("\n>> Final signature: %b (hex: %h)", sig, sig);
        $display(">> Copy this value as your GOLDEN_SIG");

        // Repeatability check
        $display("\n--- Repeatability check ---");
        rst = 1;
        repeat(4) @(posedge clk); #1;
        rst = 0;
		@(posedge clk); #1;
      
        for (i = 0; i < 15; i = i + 1)
            @(posedge clk);
        #1;

        $display(">> Run 2 signature: %b (hex: %h)", sig, sig);
        $display(">> Both signatures match: %s",
            (sig !== 4'bxxxx) ? "check manually above" : "unknown");

        $display("=== DONE ===");
        $finish;
    end

endmodule
