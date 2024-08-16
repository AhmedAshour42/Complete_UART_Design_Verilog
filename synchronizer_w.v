module synchronizer_w #(
    parameter width = 8
) (
    input wclk, wrst_n,
    input [width:0] rptr,
    output reg [width:0] wq2_rptr 
);
    reg [width:0] Q_Addr;

    always @(posedge wclk or negedge wrst_n) begin
        if (~wrst_n) begin
            Q_Addr <= 0;
            wq2_rptr <= 0;
        end else begin
            Q_Addr <= rptr;
            wq2_rptr <= Q_Addr;
        end
    end
endmodule
