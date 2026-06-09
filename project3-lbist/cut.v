module cut (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [3:0] out
);
    assign out[3] = a[3] & b[3];
    assign out[2] = a[2] & b[2];
    assign out[1] = a[1] | b[1];
    assign out[0] = a[0] | b[0];
endmodule
