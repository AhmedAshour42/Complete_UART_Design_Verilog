module top_fifo #(
    parameter WIDTH = 8,       // Data width
    parameter DEPTH = 256        // Depth of the memory
) (
    input wrclk,               // Write clock
    input rclk,                // Read clock
    input wrst_n,              // Write reset (active low)
    input rrst_n,              // Read reset (active low)
    input winc,                // Write enable
    input rinc,                // Read enable
    input [WIDTH-1:0] wdata,   // Write data
    output [WIDTH-1:0] rdata,  // Read data
    output wfull,              // Full flag
    output empty               // Empty flag
);

    // Internal signals
    wire [WIDTH-1:0] waddr, raddr;
    wire [WIDTH:0] wptr, wq2_rptr;
    wire [WIDTH:0] rptr, rq2_wptr;

    // Synchronizers
    synchronizer_r #(.width(WIDTH)) sync_w2r (
        .rclk(rclk),
        .rrst_n(rrst_n),
        .wptr(wptr),
        .rq2_wptr(rq2_wptr)
    );

    synchronizer_w #(.width(WIDTH)) sync_r2w (
        .wclk(wrclk),
        .wrst_n(wrst_n),
        .rptr(rptr),
        .wq2_rptr(wq2_rptr)
    );

    // Write pointer and full flag
    Fifo_wptr #(.width(WIDTH)) fifo_wptr (
        .wrclk(wrclk),
        .wrst_n(wrst_n),
        .winc(winc),
        .wq2_rptr(wq2_rptr),
        .waddr(waddr),
        .wptr(wptr),
        .wfull(wfull)
    );

    // Read pointer and empty flag
    Fifo_Rptr #(.width(WIDTH)) fifo_rptr (
        .rclk(rclk),
        .rrst_n(rrst_n),
        .rinc(rinc),
        .rq2_wptr(rq2_wptr),
        .raddr(raddr),
        .rptr(rptr),
        .empty(empty)
    );

    // RAM
    RAM #(.width(WIDTH), .depth(DEPTH)) ram (
        .wrclk(wrclk),
        .rclk(rclk),
        .wfull(wfull),
        .empty(empty),
        .winc(winc),
        .rinc(rinc),
        .wdata(wdata),
        .waddr(waddr),
        .raddr(raddr),
        .rdata(rdata)
    );

endmodule
