// =============================================
// Module: dff
// Description: Standard D flip-flop
//   - Positive edge triggered
//   - Synchronous active-high reset
// =============================================
module dff (
    input  wire clk,    // Clock
    input  wire rst,    // Synchronous reset (active high)
    input  wire d,      // Data input
    output reg  q       // Data output
);

always @(posedge clk) begin
    if (rst)
        q <= 1'b0;      // Reset output to 0
    else
        q <= d;         // Capture D on rising clock edge
end

endmodule
