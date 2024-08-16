module Fifo_wptr #(
    parameter width = 8  // Width of the address and pointer
) (
    input  [width:0] wq2_rptr,  // Read pointer synchronized to write clock domain
    input  wire wrclk,           // Write clock
    input  wire wrst_n,          // Write reset (active low)
    input  wire winc,            // Write enable
    output reg [width-1:0] waddr,  // Write address
    output reg [width:0] wptr,   // Write pointer
    output reg wfull             // Full flag
);

    always @(posedge wrclk or negedge wrst_n) begin
        if (!wrst_n) begin
            // Reset write address and write pointer to 0
            waddr <= 0;
            wptr <= 0;
        end else begin
            if (winc && !wfull) begin
                // Increment write address and write pointer when write enable is asserted and FIFO is not full
                waddr <= waddr + 1;
                wptr <= wptr + 1;
            end
        end
    end

    always @(*) begin
        
            // Set full flag if the write address has reached the read pointer with the MSB inverted
            if ((wptr[width] != wq2_rptr[width]) && (wptr[width-1:0] == wq2_rptr[width-1:0])) begin
                wfull = 1;
            end else begin
                // Clear full flag otherwise
                wfull = 0;
            end

    end
endmodule
