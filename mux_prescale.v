module mux_prescal (
    input [5:0] prescale,
    output reg [7:0] DIV_Ratio  // Updated output width to 8 bits
);

always @ (*) begin
    case (prescale)
        6'd32: DIV_Ratio = 8'd1;  // Adjusted case values to match input and output width
        6'd16: DIV_Ratio = 8'd2;
        6'd8:  DIV_Ratio = 8'd4;
        6'd4:  DIV_Ratio = 8'd8;
        default: DIV_Ratio = 8'd1; // Default case set to 8 bits
    endcase
end

endmodule
