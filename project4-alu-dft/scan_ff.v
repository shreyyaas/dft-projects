module scan_ff (
    input  wire clk,
    input  wire rst,
    input  wire se,
    input  wire d,
    input  wire scan_in,
    output reg  q,
    output wire scan_out
);
    wire d_mux;
    assign d_mux = se ? scan_in : d;

    always @(posedge clk) begin
        if (rst) q <= 1'b0;
        else     q <= d_mux;
    end

    assign scan_out = q;
endmodule
