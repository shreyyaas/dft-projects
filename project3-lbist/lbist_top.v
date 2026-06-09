module lbist_top (
    input  wire clk,
    input  wire rst,
    input  wire bist_start,
    output reg  bist_done,
    output reg  bist_pass
);
    parameter GOLDEN_SIG  = 4'b0000;
    parameter TEST_CYCLES = 15;

    wire [3:0] lfsr_out;
    wire [3:0] cut_out;
    wire [3:0] signature;
    wire [3:0] a_in, b_in;

    reg        running;
    reg  [4:0] cycle_count;

    assign a_in = lfsr_out;
    assign b_in = {lfsr_out[1:0], lfsr_out[3:2]};

    // COMBINATIONAL misr_rst — goes low the same cycle running goes high
    wire misr_rst_w;
    assign misr_rst_w = rst | ~running;

    lfsr u_lfsr (
        .clk(clk),
        .rst(rst),
        .q(lfsr_out)
    );

    cut u_cut (
        .a(a_in),
        .b(b_in),
        .out(cut_out)
    );

    misr u_misr (
        .clk(clk),
        .rst(misr_rst_w),
        .response(cut_out),
        .signature(signature)
    );

    always @(posedge clk) begin
        if (rst) begin
            running     <= 0;
            cycle_count <= 0;
            bist_done   <= 0;
            bist_pass   <= 0;
        end
        else if (bist_start && !running) begin
            running     <= 1;
            cycle_count <= 0;
            bist_done   <= 0;
        end
        else if (running) begin
            cycle_count <= cycle_count + 1;
            if (cycle_count == TEST_CYCLES - 1) begin
                running   <= 0;
                bist_done <= 1;
                bist_pass <= (signature == GOLDEN_SIG);
            end
        end
    end

endmodule
