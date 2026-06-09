module misr (
    input  wire       clk,
    input  wire       rst,
    input  wire [3:0] response,
    output reg  [3:0] signature
);
    wire feedback;
    assign feedback = signature[3];

    always @(posedge clk) begin
        if (rst)
            signature <= 4'b0000;
        else begin
            signature[3] <= signature[2] ^ response[3];
            signature[2] <= signature[1] ^ feedback ^ response[2];
            signature[1] <= signature[0] ^ response[1];
            signature[0] <= feedback ^ response[0];
        end
    end
endmodule
