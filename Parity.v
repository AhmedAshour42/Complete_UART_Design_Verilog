module Parity  #(parameter width = 8) (
    input clk,           // Clock input
    input rst,           // Reset input
    input Data_valid,    // Data validity input
    input [width-1:0] P_data,  // Input data
    input Par_type,      // Parity type selection input
    output wire Par_bit    // Parity bit output
);
reg par;
    // Always block to compute parity bit
    always @(posedge clk or negedge rst) begin
        if (rst == 0) begin
            // Reset condition: Set parity bit to 0
            par <= 0;
        end
        else begin
            // If data is valid, compute parity bit based on selected parity type
            if (Data_valid) begin
                if (Par_type) begin
                    // Odd parity selected
                    par <= (^P_data) ? 0 : 1;
                end
                else begin
                    // Even parity selected
                    par <= (^P_data) ? 1 : 0;
                end
            end
        end
    end
assign Par_bit=par;

endmodule
