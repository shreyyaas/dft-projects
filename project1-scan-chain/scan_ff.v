// =============================================
// Module: scan_ff
// Description: Scan-enabled D flip-flop
//   - SE=0: normal mode, D captured
//   - SE=1: scan mode, scan_in captured
//   - This is the fundamental DFT building block
// =============================================
module scan_ff (
    input  wire clk,      // Clock
    input  wire rst,      // Synchronous reset (active high)
    input  wire se,       // Scan enable (1 = scan mode)
    input  wire d,        // Functional data input
    input  wire scan_in,  // Scan chain input
    output reg  q,        // Output (also drives next FF's scan_in)
    output wire scan_out  // Scan output (same as Q)
);

    wire d_mux;

    // 2:1 MUX: select between functional D and scan_in
    assign d_mux = (se) ? scan_in : d;

    // D flip-flop with muxed input
    always @(posedge clk) begin
        if (rst)
            q <= 1'b0;
        else
            q <= d_mux;
    end

    // scan_out is just Q
    assign scan_out = q;

endmodule
