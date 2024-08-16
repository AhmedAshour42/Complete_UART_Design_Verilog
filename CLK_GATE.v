module CLK_GATE (
    input clk,                // Input clock signal
    input CLK_EN,             // Clock enable signal
    output wire GATED_CLK      // Gated clock output
);

// Internal signal
reg Latch_Out;               // Holds the clock enable signal when CLK is low

// Latch (Level Sensitive Device)
// The latch is sensitive to both clk and CLK_EN
always @(clk or CLK_EN) begin
    if (!clk) begin          // When the clock is low (active low condition)
        Latch_Out <= CLK_EN; // Capture the CLK_EN value in the latch
    end
end

// Gated Clock Generation
// The gated clock is the logical AND of the clock signal and the latched enable signal
assign GATED_CLK = clk && Latch_Out;

endmodule
