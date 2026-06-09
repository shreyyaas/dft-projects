module alu (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [1:0] op,
    output reg  [3:0] result,
    output reg        carry
);
    always @(*) begin
        carry = 0;
        case (op)
            2'b00: {carry, result} = a + b;
            2'b01: {carry, result} = a - b;
            2'b10: begin result = a & b; carry = 0; end
            2'b11: begin result = a | b; carry = 0; end
            default: begin result = 4'b0000; carry = 0; end
        endcase
    end
endmodule
