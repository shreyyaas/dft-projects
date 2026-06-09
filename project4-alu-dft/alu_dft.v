module alu_dft (
    input  wire       clk,
    input  wire       rst,
    input  wire       se,         // scan enable
    input  wire       si,         // scan input
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [1:0] op,
    output wire       so,         // scan output
    output wire [3:0] result_q,   // registered result
    output wire       carry_q     // registered carry
);
    wire [3:0] alu_result;
    wire       alu_carry;
    wire [4:0] chain;             // internal scan chain wires

    // ALU — purely combinational
    alu u_alu (
        .a(a), .b(b), .op(op),
        .result(alu_result),
        .carry(alu_carry)
    );

    // 5 scan FFs — result[0..3] + carry
    // Chain: SI → FF0 → FF1 → FF2 → FF3 → FF4 → SO
    scan_ff ff0 (.clk(clk),.rst(rst),.se(se),
                 .d(alu_result[0]),.scan_in(si),
                 .q(result_q[0]),.scan_out(chain[0]));

    scan_ff ff1 (.clk(clk),.rst(rst),.se(se),
                 .d(alu_result[1]),.scan_in(chain[0]),
                 .q(result_q[1]),.scan_out(chain[1]));

    scan_ff ff2 (.clk(clk),.rst(rst),.se(se),
                 .d(alu_result[2]),.scan_in(chain[1]),
                 .q(result_q[2]),.scan_out(chain[2]));

    scan_ff ff3 (.clk(clk),.rst(rst),.se(se),
                 .d(alu_result[3]),.scan_in(chain[2]),
                 .q(result_q[3]),.scan_out(chain[3]));

    scan_ff ff4 (.clk(clk),.rst(rst),.se(se),
                 .d(alu_carry),.scan_in(chain[3]),
                 .q(carry_q),.scan_out(chain[4]));

    assign so = chain[4];
