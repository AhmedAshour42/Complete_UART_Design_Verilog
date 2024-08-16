module Fifo_Rptr #(
    parameter width = 8  // Width of the address and pointer
) (
    input rclk,            // Read clock
    input rrst_n,          // Read reset (active low)
    input rinc,            // Read enable
    input [width:0] rq2_wptr,  // Write pointer synchronized to read clock domain
    output reg [width:0] rptr,  // Read pointer
    output reg [width-1:0] raddr, // Read address
    output reg empty          // Empty flag
);

    // Always block for updating read address and read pointer
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            // Reset read pointer and read address to 0
            rptr <= 0;
            raddr <= 0;
        end else begin
            if (rinc && !empty) begin
                // Increment read pointer and read address when read enable is asserted and FIFO is not empty
                rptr <= rptr + 1;
                raddr <= raddr + 1;
            end
        end
    end
    
    // Always block for updating the empty flag
    always @(*) begin
        
            // Set empty flag if the read address equals the write pointer
            if (rq2_wptr == rptr) begin
                empty = 1;
            end else begin
                // Clear empty flag otherwise
                empty = 0;
            end
        end


endmodule
