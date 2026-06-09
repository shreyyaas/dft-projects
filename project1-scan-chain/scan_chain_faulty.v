// =============================================
// Module: scan_chain_faulty
// Identical to scan_chain EXCEPT:
//   FF0 is replaced with scan_ff_faulty
//   Models SA1 on d[0] (SFF1's functional input)
// =============================================
module scan_chain_faulty (
    input  wire clk,
    input  wire rst,
    input  wire se,
    input  wire si,
    input  wire [7:0] d,
    output wire so,
    output wire [7:0] q
);

    wire [7:0] chain;

    // FF0 is FAULTY — d[0] stuck at 1
    scan_ff_faulty ff0 (
        .clk(clk), .rst(rst), .se(se),
        .d(d[0]),             // driven to 0 in test — but ignored!
        .scan_in(si),
        .q(q[0]), .scan_out(chain[0])
    );

    // FF1–FF7 are normal
    scan_ff ff1 (.clk(clk),.rst(rst),.se(se),.d(d[1]),
                 .scan_in(chain[0]),.q(q[1]),.scan_out(chain[1]));
    scan_ff ff2 (.clk(clk),.rst(rst),.se(se),.d(d[2]),
                 .scan_in(chain[1]),.q(q[2]),.scan_out(chain[2]));
    scan_ff ff3 (.clk(clk),.rst(rst),.se(se),.d(d[3]),
                 .scan_in(chain[2]),.q(q[3]),.scan_out(chain[3]));
    scan_ff ff4 (.clk(clk),.rst(rst),.se(se),.d(d[4]),
                 .scan_in(chain[3]),.q(q[4]),.scan_out(chain[4]));
    scan_ff ff5 (.clk(clk),.rst(rst),.se(se),.d(d[5]),
                 .scan_in(chain[4]),.q(q[5]),.scan_out(chain[5]));
    scan_ff ff6 (.clk(clk),.rst(rst),.se(se),.d(d[6]),
                 .scan_in(chain[5]),.q(q[6]),.scan_out(chain[6]));
    scan_ff ff7 (.clk(clk),.rst(rst),.se(se),.d(d[7]),
                 .scan_in(chain[6]),.q(q[7]),.scan_out(chain[7]));

    assign so = chain[7];

endmodule
