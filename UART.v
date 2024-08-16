module UART # (parameter DATA_WIDTH = 8) (
    input wire                          RST,
    input wire                          TX_CLK,
    input wire                          RX_CLK,
    input wire                          RX_IN_S,
    output wire  [DATA_WIDTH-1:0]       RX_OUT_P, 
    output wire                         RX_OUT_V,
    input wire   [DATA_WIDTH-1:0]       TX_IN_P, 
    input wire                          TX_IN_V, 
    output wire                         TX_OUT_S,
    output wire                         TX_OUT_V,  
    input wire   [5:0]                  Prescale, 
    input wire                          parity_enable,
    input wire                          parity_type,
  output wire                         parity_error,
  output wire                         framing_error
);

    /* ------------------------ UART Transmitter (Tx) ------------------------ */
    top_tx #(.width(DATA_WIDTH)) U0_UART_TX (
        .clk(TX_CLK),
        .rst(RST),
        .P_data(TX_IN_P),
        .Data_valid(TX_IN_V),
        .Par_en(parity_enable),
        .Par_type(parity_type), 
        .TX_out(TX_OUT_S),
        .Busy(TX_OUT_V)
    );

    /* ------------------------ UART Receiver (Rx) ------------------------ */
    Top U0_UART_RX (
        .clk(RX_CLK),
        .rst(RST),
        .RX_IN(RX_IN_S),
        .Prescale(Prescale),
        .PAR_EN(parity_enable),
        .PAR_TYP(parity_type),
        .P_DATA(RX_OUT_P), 
        .data_valid(RX_OUT_V)
     //   .Par_err(parity_error),
      //  .stp_err(framing_error)
    );
assign parity_error=U0_UART_RX.Par_err;
assign framing_error=U0_UART_RX.stp_err;

endmodule
