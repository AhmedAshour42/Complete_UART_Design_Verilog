module top_tx #(parameter width = 8) (
  input clk,               // Clock input
  input rst,               // Reset input
  input Data_valid,        // Valid data input
  input wire[width-1:0] P_data,  // Data input
  input Par_type,           // Parity type input
  input Par_en,             // Parity enable input
  output wire Busy,         // Busy signal output
  output wire TX_out        // Output data signal
);
  wire ser_en;              // Serializer enable wire
  wire ser_done;            // Serializer done wire
  wire ser_data;            // Serializer data wire
  wire Par_bit;             // Parity bit wire
  wire [1:0] mux_sel;       // Mux selector wire
  wire start_bit;           // Start bit wire
  wire stop_bit;    // Stop bit wire
  wire idle_data;        // idle_data wire 
  
  assign start_bit = 0;     // Assign start bit to 0
  assign stop_bit = 1;      // Assign stop bit to 1
  
  /* ---------------------- // Instantiate Parity module ---------------------- */
  Parity #(.width(width)) DUT_2 (
    .clk(clk),
    .rst(rst),
    .Data_valid(Data_valid),
    .P_data(P_data),
    .Par_type(Par_type),
    .Par_bit(Par_bit)
  );

  /* ------------------------ // Instantiate FSM module ----------------------- */
  FSM  DUT_3 (
    .clk(clk),
    .rst(rst),
    .Data_valid(Data_valid),
    .ser_done(ser_done),
    .Par_en(Par_en),
    .mux_sel(mux_sel),
    .ser_en(ser_en),
    .Busy(Busy),
    .idle_data(idle_data)
  );

  /* ------------------------ // Instantiate Mux module ----------------------- */
  mux DUT_4(
    .start_bit(start_bit),
    .stop_bit(stop_bit),
    .mux_sel(mux_sel),
    .Par_bit(Par_bit),
    .ser_data(ser_data),
    .TX_out(TX_out)
  );


  /* -------------------- // Instantiate Serializer module -------------------- */
  serializer  #(.width(width)) DUT_1 (
    .clk(clk),
    .rst(rst),
    .Data_valid(Data_valid),
    .P_data(P_data),
    .ser_en(ser_en),
    .ser_done(ser_done),
    .ser_data(ser_data),
    .idle_data(idle_data)
  );

endmodule
