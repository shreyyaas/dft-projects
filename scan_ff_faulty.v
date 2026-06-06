// =============================================
// Module: scan_ff_faulty
// Identical to scan_ff EXCEPT:
//   d_final is FORCED to 1 always (SA1 fault)
//   This models a wire shorted to VDD
// =============================================
module scan_ff_faulty (
    input  wire clk,
    input  wire rst,
    input  wire se,
    input  wire d,         // This input is IGNORED (stuck-at-1)
    input  wire scan_in,
    output reg  q,
    output wire scan_out
);

    wire d_mux;
    wire d_final;

    // SA1 fault: d_final is always 1, no matter what d is
    assign d_final = 1'b1;  // <-- THIS IS THE FAULT

    // MUX: scan mode uses scan_in, functional mode uses d_final (faulty)
    assign d_mux = (se) ? scan_in : d_final;

    always @(posedge clk) begin
        if (rst)
            q <= 1'b0;
        else
            q <= d_mux;
    end

    assign scan_out = q;

endmodule
