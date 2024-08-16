`timescale 1ns/1ps

module tb_sys_tob;

    // Parameters for the SYS_TOP module
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;
    parameter FIFO_DEPTH = 16;
    parameter PRESCALE_WIDTH = 6;
    parameter DIV_RATIO_WIDTH = 4;
    parameter width_fun = 4;
    parameter NUM_STAGES = 2;
    parameter num_registers = 16;

    // Testbench signals
    reg REF_CLK;
    reg RST;
    reg UART_CLK;
    reg RX_IN;
    wire TX_OUT;

    reg [7:0] data_random, data_idle;
    wire PAR_TYP;

    assign PAR_TYP = dut.REGFILE_INST.REG2[1]; // Parity type from DUT register

    // Instantiate the DUT (Device Under Test)
    parameter ref_clk = 20;    // Reference clock period
    parameter Uart_clk = 271.267; // UART clock period

    sys_tob #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH),
        .PRESCALE_WIDTH(PRESCALE_WIDTH),
        .DIV_RATIO_WIDTH(DIV_RATIO_WIDTH),
        .width_fun(width_fun),
        .NUM_STAGES(NUM_STAGES),
        .num_registers(num_registers)
    ) dut (
        .REF_CLK(REF_CLK),
        .RST(RST),
        .UART_CLK(UART_CLK),
        .RX_IN(RX_IN),
        .TX_OUT(TX_OUT)
    );

    reg [DATA_WIDTH-1:0] data_cal_parity;
    localparam RF_Wr_CMD = 8'hAA;
    localparam RF_Rd_CMD = 8'hBB;
    localparam LU_OPER_W_OP_CMD = 8'hCC;
    localparam ALU_OPER_W_NOP_CMD = 8'hDD;

    integer count;

    /* ----------------------------------------------------------------------- */
    /*                           Clock Generation                                */
    /* ----------------------------------------------------------------------- */

    initial begin
        REF_CLK = 0;
        forever begin
            #(ref_clk/2) REF_CLK = ~REF_CLK; 
        end
    end

    initial begin
        UART_CLK = 0;
        forever begin
            #(Uart_clk/2) UART_CLK = ~UART_CLK; 
        end
    end

    /* ----------------------------------------------------------------------- */
    /*                         Testbench Initialization                          */
    /* ----------------------------------------------------------------------- */
    
    initial begin
        initialize();  
        
        // Simulate UART RX tasks
        UART_RX_Tasks_star(RF_Wr_CMD);
        data_random = 8'h69;
        UART_RX_Tasks_star(data_random);
        data_random = 8'h14;
        UART_RX_Tasks_star(data_random);
        data_random = RF_Rd_CMD;
        UART_RX_Tasks_star(data_random);

        // Continue UART RX tasks with different data
        data_random = 8'h69;
        UART_RX_Tasks_star(data_random);
        UART_RX_Tasks_star(RF_Wr_CMD);
        data_random = 8'h66;
        UART_RX_Tasks_star(data_random);
        data_random = 8'h18;
        UART_RX_Tasks_star(data_random);
        data_random = RF_Rd_CMD;
        UART_RX_Tasks_star(data_random);

        // Additional data for testing
        data_random = 8'h66;
        UART_RX_Tasks_star(data_random);
        UART_RX_Tasks_star(RF_Wr_CMD);
        data_random = 8'hA5;
        UART_RX_Tasks_star(data_random);
        data_random = 8'hc4;
        UART_RX_Tasks_star(data_random);
        data_random = RF_Rd_CMD;
        UART_RX_Tasks_star(data_random);

        data_random = 8'hA5;
        UART_RX_Tasks_star(data_random);
        UART_RX_Tasks_star(RF_Wr_CMD);
        data_random = 8'hFC;
        UART_RX_Tasks_star(data_random);
        data_random = 8'hcc;
        UART_RX_Tasks_star(data_random);
        data_random = RF_Rd_CMD;
        UART_RX_Tasks_star(data_random);

        data_random = 8'hFC;
        UART_RX_Tasks_star(data_random);
        UART_RX_Tasks_star(RF_Wr_CMD);
        data_random = 8'hFe;
        UART_RX_Tasks_star(data_random);
        data_random = 8'hac;
        UART_RX_Tasks_star(data_random);
        data_random = RF_Rd_CMD;
        UART_RX_Tasks_star(data_random);

        data_random = 8'hac;
        UART_RX_Tasks_star(data_random);
        UART_RX_Tasks_star(8'hcc);
        data_random = 8'h56;
        UART_RX_Tasks_star(data_random);
        data_random = 8'hec;
        UART_RX_Tasks_star(data_random);
        data_random = 8'h10;
        UART_RX_Tasks_star(data_random);
        data_random = 8'hac;
        UART_RX_Tasks_star(data_random);
display_registers();
        #10000;
        $stop;
    end

    /* ----------------------------------------------------------------------- */
    /*                         Task Definitions                                   */
    /* ----------------------------------------------------------------------- */

    task UART_RX_Tasks_star(input [DATA_WIDTH-1:0] RX_Data);
    begin
        start_RX();
        start_write_read_Fun(RX_Data);
        Parity_Rx(RX_Data);
        idle_Rx();
    end
    endtask

    task initialize;
    begin
        RST = 0;           // Deassert reset
        RX_IN = 1;         // Set RX_IN to 1 (idle state)
        #(Uart_clk * 32);  
        RST = 1;           // Assert reset and wait
    end
    endtask

    task start_RX;
    begin
        RX_IN = 0;        // Set RX_IN to 0 to simulate start bit
        #(Uart_clk * 32);  
    end
    endtask

    task start_write_read_Fun(input [DATA_WIDTH-1:0] data);
    begin
        for (count = 0; count < 8; count = count + 1) begin
            RX_IN = data[count];
            #(Uart_clk * 32);
        end
    end
    endtask

    task idle_Rx;
    begin
        RX_IN = 1;  
        #(Uart_clk * 32);
        RX_IN = 1;  
        #(Uart_clk * 32);
    end
    endtask

    task Parity_Rx(input [DATA_WIDTH-1:0] Parity_cal);
    begin
        RX_IN = calculate_parity(Parity_cal, PAR_TYP); // Calculate parity bit
        #(Uart_clk * 32);  
    end
    endtask

    // Function to calculate parity bit
    function integer calculate_parity;
        input [7:0] data;      // Input data
        input parity_type;     // Parity type (0 for even, 1 for odd)
        integer parity;
    begin
        // Calculate even parity using reduction XOR
        parity = ^data;
        // If odd parity is required, invert the result
        if (parity_type) begin
            parity = ~parity;
        end
        calculate_parity = parity; // Return calculated parity
    end
    endfunction

    task display_registers;
    begin
        for (count = 0; count < num_registers; count = count + 1) begin
            $display("Register[%0d]: %h", count, dut.REGFILE_INST.reg_mem_file[count]);
        end
    end
    endtask

endmodule
