module lfsr (
    input  wire       clk,
    input  wire       rst,
    output reg  [3:0] q
);
    wire feedback;
    assign feedback = q[3] ^ q[2];

    always @(posedge clk) begin
        if (rst)
            q <= 4'b0001;
        else
            q <= {q[2:0], feedback};
    end
endmodule
