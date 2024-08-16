module mux (
  input start_bit, stop_bit,
  input [1:0] mux_sel,
  input Par_bit, ser_data,
  output reg TX_out
);

  // Multiplexer logic based on mux_sel
  always @(*) begin
    case (mux_sel)
      2'b00: TX_out = start_bit;  // Select start bit when mux_sel is 00
      2'b01: TX_out = stop_bit;   // Select stop bit when mux_sel is 01
      2'b10: TX_out = ser_data;   // Select serialized data when mux_sel is 10
      2'b11: TX_out = Par_bit;    // Select parity bit when mux_sel is 11
    endcase
  end

endmodule
