module RAM #(
    parameter width = 8,   // Width of data
    parameter depth = 8    // Depth of the memory
) (
    input wrclk,            // Write clock
    input rclk,             // Read clock
    input wfull,            // Write full flag
    input empty,            // Read empty flag
    input winc,             // Write enable
    input rinc,             // Read enable
    input [width-1:0] wdata, // Write data
    input [width-1:0] waddr, // Write address
    input [width-1:0] raddr, // Read address
    output reg [width-1:0] rdata // Read data
);

    reg [width-1:0] mem [depth-1:0]; // Memory array
    wire wclken, rclken;             // Write and read clock enable signals

    // Write clock enable signal is high when write enable is high and FIFO is not full
    assign wclken = winc & (!wfull);
    // Read clock enable signal is high when read enable is high and FIFO is not empty
    assign rclken = rinc & (!empty);

    // Always block for writing data to memory
    always @(posedge wrclk) begin
        if (wclken) begin
            mem[waddr] <= wdata;
        end
    end

    // Always block for reading data from memory
    always @(posedge rclk) begin
        if (rclken) begin
            rdata <= mem[raddr];
        end
    end

endmodule
