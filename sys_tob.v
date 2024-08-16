module sys_tob #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4,
    parameter FIFO_DEPTH = 16,
    parameter PRESCALE_WIDTH = 6,
    parameter DIV_RATIO_WIDTH = 4,
    parameter width_fun = 4,
    parameter NUM_STAGES = 2,
    parameter num_registers = 8
) (
    input wire REF_CLK,            // Reference clock input
    input wire RST,                // Reset input
    input wire UART_CLK,           // UART clock input
    input wire RX_IN,              // UART RX input
    output wire TX_OUT             // UART TX output
);

    /* -------------------------------------------------------------------------- */
    /*                             // Internal signals                            */
    /* -------------------------------------------------------------------------- */
    wire [ADDR_WIDTH-1:0] address;            // Address bus for register file
    wire [DATA_WIDTH-1:0] Wr_D, Rd_D;         // Write and read data buses
    wire WrEn, RdEn, RdData_Valid;            // Control signals for read/write operations
    wire [DATA_WIDTH-1:0] REG0, REG1, REG2, REG3; // Register outputs
    wire Enable, OUT_VALID, ALU_Clk;          // ALU control and clock signals
    wire SYNC_RST_1, SYNC_RST_2;              // Synchronized reset signals
    wire [width_fun-1:0] ALU_FUN;             // ALU function select
    wire [2*DATA_WIDTH-1:0] ALU_OUT;          // ALU output bus
    wire ALU_OUT_Valid, RX_D_VLD;             // ALU output and RX data valid flags

    wire [DATA_WIDTH-1:0] RX_OUT_P, RX_P_DATA, Rd_Data; // RX output buses
    wire RX_OUT_V, parity_error, framing_error, Busy;   // Status and error flags
    wire F_Empt, RD_INC, Gate_EN, clk_div_en;           // FIFO and clock control signals
    wire RX_CLK, WR_INC, TX_CLK;                        // Clock signals for RX and TX
    wire [PRESCALE_WIDTH-1:0] Prescale;                 // Prescaler value for UART
    wire [DATA_WIDTH-1:0] Wr_Data;                      // Write data bus for FIFO
    wire [7:0] DIV_Ratio;                               // Division ratio for clock divider

    /* -------------------------------------------------------------------------- */
    /*                           // Reset Synchronizers                           */
    /* -------------------------------------------------------------------------- */
    RST_SYNC RST_SYNC_1 (
        .CLK(REF_CLK),              // Clock input
        .RST(RST),                  // Asynchronous reset input
        .SYNC_RST(SYNC_RST_1)       // Synchronized reset output
    );

    RST_SYNC RST_SYNC_2 (
        .CLK(UART_CLK),             // Clock input
        .RST(RST),                  // Asynchronous reset input
        .SYNC_RST(SYNC_RST_2)       // Synchronized reset output
    );

    /* -------------------------------------------------------------------------- */
    /*                               // Clock Gating                              */
    /* -------------------------------------------------------------------------- */
    CLK_GATE CLOCK_GATING (
        .clk(REF_CLK),              // Clock input
        .CLK_EN(Gate_EN),           // Clock enable signal
        .GATED_CLK(ALU_Clk)         // Gated clock output
    );

    /* -------------------------------------------------------------------------- */
    /*                       // Clock Dividers for RX and TX                      */
    /* -------------------------------------------------------------------------- */
    mux_prescal div_rx (
        .prescale(REG2[7:2]),       // Prescaler value from register
        .DIV_Ratio(DIV_Ratio)       // Division ratio output
    );

    ClkDiv #(.RATIO_WD(DATA_WIDTH)) CLOCK_DIVIDER_RX (
        .i_ref_clk(UART_CLK),       // Reference clock input
        .i_div_ratio(DIV_Ratio),    // Division ratio input
        .o_div_clk(RX_CLK),         // Divided clock output
        .i_rst(SYNC_RST_2),         // Synchronized reset input
        .i_clk_en(clk_div_en)       // Clock enable input
    );

    ClkDiv #(.RATIO_WD(DATA_WIDTH)) CLOCK_DIVIDER_TX (
        .i_ref_clk(UART_CLK),       // Reference clock input
        .i_div_ratio(REG3),         // Division ratio input from register
        .o_div_clk(TX_CLK),         // Divided clock output
        .i_rst(SYNC_RST_2),         // Synchronized reset input
        .i_clk_en(clk_div_en)       // Clock enable input
    );

    /* -------------------------------------------------------------------------- */
    /*                            // Data Synchronizer                            */
    /* -------------------------------------------------------------------------- */
    DATA_SYNC #(
        .BUS_WIDTH(DATA_WIDTH),     // Data bus width
        .NUM_STAGES(NUM_STAGES)     // Number of synchronization stages
    ) data_sync_inst (
        .CLK(REF_CLK),              // Clock input
        .RST(SYNC_RST_1),           // Synchronized reset input
        .unsync_bus(RX_OUT_P),      // Unsynchronized bus input
        .bus_enable(RX_OUT_V),      // Bus enable signal
        .sync_bus(RX_P_DATA),       // Synchronized bus output
        .enable_pulse_d(RX_D_VLD)   // Enable pulse output
    );

    /* -------------------------------------------------------------------------- */
    /*                             // Pulse Generator                             */
    /* -------------------------------------------------------------------------- */
    PULSE_GEN pulse_gen_inst (
        .clk(UART_CLK),             // Clock signal input
        .rst(SYNC_RST_2),           // Synchronized reset input
        .lvl_sig(Busy),             // Level signal to trigger the pulse
        .pulse_sig(RD_INC)          // Output pulse signal
    );

    /* -------------------------------------------------------------------------- */
    /*                            // System Controller                            */
    /* -------------------------------------------------------------------------- */
    CTRL SYS_CTRL_INST (
        .clk(REF_CLK),              // Clock input
        .rst(SYNC_RST_1),           // Synchronized reset input
        .RdEn(RdEn),                // Read enable signal
        .WrEn(WrEn),                // Write enable signal
        .address(address),          // Address bus input
        .WrData(Wr_D),              // Write data input
        .RdData(Rd_D),              // Read data output
        .RdData_Valid(RdData_Valid),// Read data valid output
        .ALU_FUN(ALU_FUN),          // ALU function select input
        .EN(Enable),                // Enable signal
        .ALU_OUT(ALU_OUT),          // ALU output bus
        .OUT_Valid(OUT_VALID),      // ALU output valid signal
        .fifo_full(FIFO_FULL),      // FIFO full flag
        .TX_P_DATA(Wr_Data),        // Transmit data input
        .TX_D_VLD(WR_INC),          // Transmit data valid signal
        .RX_P_DATA(RX_P_DATA),      // Receive data input
        .RX_D_VLD(RX_D_VLD),        // Receive data valid signal
        .CLK_EN(Gate_EN),           // Clock enable signal
        .clk_div_en(clk_div_en)     // Clock divider enable signal
    );

    /* -------------------------------------------------------------------------- */
    /*                              // Register File                              */
    /* -------------------------------------------------------------------------- */
    RegFile #(
        .width_data(DATA_WIDTH),    // Data width
        .width_address(ADDR_WIDTH), // Address width
        .num_registers(num_registers) // Number of registers
    ) REGFILE_INST (
        .clk(REF_CLK),              // Clock input
        .rst(SYNC_RST_1),           // Synchronized reset input
        .WrEn(WrEn),                // Write enable signal
        .RdEn(RdEn),                // Read enable signal
        .address(address),          // Address bus input
        .WrData(Wr_D),              // Write data input
        .RdData(Rd_D),              // Read data output
        .RdData_Valid(RdData_Valid),// Read data valid signal
        .REG0(REG0),                // Register 0 output
        .REG1(REG1),                // Register 1 output
        .REG2(REG2),                // Register 2 output
        .REG3(REG3)                 // Register 3 output
    );

    /* -------------------------------------------------------------------------- */
    /*                                   // ALU                                   */
    /* -------------------------------------------------------------------------- */
    ALU #(
        .width_data(DATA_WIDTH),    // Data width
        .width_fun(width_fun)       // Function width
    ) ALU_INST (
        .clk(ALU_Clk),              // Clock input
        .rst(SYNC_RST_1),           // Synchronized reset input
        .A(REG0),                   // Operand A input
        .B(REG1),                   // Operand B input
        .ALU_FUN(ALU_FUN),          // ALU function select input
        .Enable(Enable),            // ALU enable signal
        .ALU_OUT(ALU_OUT),          // ALU output bus
        .OUT_VALID(OUT_VALID)       // ALU output valid signal
    );

    /* -------------------------------------------------------------------------- */
    /*                            // Asynchronous FIFO                            */
    /* -------------------------------------------------------------------------- */
    top_fifo #(
        .WIDTH(DATA_WIDTH),         // Data width
        .DEPTH(FIFO_DEPTH)          // FIFO depth
    ) ASYNC_FIFO_INST (
        .wrclk(REF_CLK),            // Write clock input
        .wrst_n(SYNC_RST_1),        // Synchronized write reset input
        .rclk(UART_CLK),            // Read clock input
        .rrst_n(SYNC_RST_2),        // Synchronized read reset input
        .wdata(Wr_Data),            // Write data input
        .rdata(Rd_Data),            // Read data output
        .winc(WR_INC),              // Write increment signal
        .rinc(RD_INC),              // Read increment signal
        .wfull(FIFO_FULL),          // FIFO full flag
        .empty(F_Empt)              // FIFO empty flag
    );

    /* -------------------------------------------------------------------------- */
    /*                                   // UART                                  */
    /* -------------------------------------------------------------------------- */
    UART #(
        .DATA_WIDTH(DATA_WIDTH)     // Data width
    ) UART_INST (
        .RST(SYNC_RST_2),           // Synchronized reset input
        .TX_CLK(TX_CLK),            // Transmit clock input
        .RX_CLK(RX_CLK),            // Receive clock input
        .RX_IN_S(RX_IN),            // UART RX input signal
        .RX_OUT_P(RX_OUT_P),        // UART RX output bus
        .RX_OUT_V(RX_OUT_V),        // UART RX output valid flag
        .TX_IN_P(Rd_Data),          // UART TX input data
        .TX_IN_V(!F_Empt),          // UART TX input valid signal
        .TX_OUT_S(TX_OUT),          // UART TX output signal
        .TX_OUT_V(Busy),            // UART TX output valid flag
        .Prescale(REG2[7:2]),       // UART prescaler value
        .parity_enable(REG2[0]),    // Parity enable flag
        .parity_type(REG2[1]),      // Parity type select
        .parity_error(parity_error),// Parity error flag
        .framing_error(framing_error) // Framing error flag
    );

endmodule
