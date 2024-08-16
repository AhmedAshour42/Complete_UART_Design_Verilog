module synchronizer_r #(
    parameter width = 8
) (
    input rclk, rrst_n,
    input [width:0] wptr,
    output reg [width:0] rq2_wptr 
);
    reg [width:0] Q_Addr;

    always @(posedge rclk or negedge rrst_n) begin
        if (~rrst_n) begin
            Q_Addr <= 0;
            rq2_wptr <= 0;
        end else begin
            Q_Addr <= wptr;
            rq2_wptr <= Q_Addr;
        end
    end
endmodule
