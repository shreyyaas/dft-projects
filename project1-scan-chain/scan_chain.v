// =============================================
// Module: scan_chain
// Description: 8 scan FFs chained in series
//   - SI enters at FF0, exits at FF7 as SO
//   - All FFs share CLK, RST, SE
// =============================================
module scan_chain (
    input  wire clk,
    input  wire rst,
    input  wire se,       // Scan enable
    input  wire si,       // Scan input (enters FF0)
    input  wire [7:0] d,  // Functional data inputs
    output wire so,       // Scan output (exits FF7)
    output wire [7:0] q   // All FF outputs
);

    wire [7:0] chain; // Internal scan chain wires

    // FF0: scan_in = si (primary scan input)
    scan_ff ff0 (.clk(clk),.rst(rst),.se(se),.d(d[0]),
                 .scan_in(si),       .q(q[0]),.scan_out(chain[0]));

    // FF1–FF7: each FF's scan_in = previous FF's scan_out
    scan_ff ff1 (.clk(clk),.rst(rst),.se(se),.d(d[1]),
                 .scan_in(chain[0]), .q(q[1]),.scan_out(chain[1]));
    scan_ff ff2 (.clk(clk),.rst(rst),.se(se),.d(d[2]),
                 .scan_in(chain[1]), .q(q[2]),.scan_out(chain[2]));
    scan_ff ff3 (.clk(clk),.rst(rst),.se(se),.d(d[3]),
                 .scan_in(chain[2]), .q(q[3]),.scan_out(chain[3]));
    scan_ff ff4 (.clk(clk),.rst(rst),.se(se),.d(d[4]),
                 .scan_in(chain[3]), .q(q[4]),.scan_out(chain[4]));
    scan_ff ff5 (.clk(clk),.rst(rst),.se(se),.d(d[5]),
                 .scan_in(chain[4]), .q(q[5]),.scan_out(chain[5]));
    scan_ff ff6 (.clk(clk),.rst(rst),.se(se),.d(d[6]),
                 .scan_in(chain[5]), .q(q[6]),.scan_out(chain[6]));
    scan_ff ff7 (.clk(clk),.rst(rst),.se(se),.d(d[7]),
                 .scan_in(chain[6]), .q(q[7]),.scan_out(chain[7]));

    // SO = last FF's output
    assign so = chain[7];

endmodule
