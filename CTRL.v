module CTRL #(
    parameter in_width = 16,            // Width of the input data (e.g., ALU_OUT, RX_P_DATA)
    parameter alu_fun = 4,              // Width of the ALU function selector
    parameter address_width = 4,        // Width of the address bus
    parameter out_width = 8             // Width of the output data (e.g., WrData, TX_P_DATA)
) (
    input wire clk,                     // Clock signal
    input wire rst,                     // Reset signal, active low
    input wire fifo_full,               // FIFO full indicator
    input wire [in_width-1:0] ALU_OUT,  // ALU output data
    input wire OUT_Valid,               // Valid signal for ALU output
    input wire [out_width-1:0] RdData,  // Data read from the register file
    input wire RdData_Valid,            // Valid signal for read data
    input wire [out_width-1:0] RX_P_DATA, // Received data from RX path
    input wire RX_D_VLD,                // Valid signal for received data
    output reg [alu_fun-1:0] ALU_FUN,   // ALU function select
    output reg EN,                      // Enable signal for ALU or other operations
    output reg CLK_EN,                  // Clock enable signal
    output reg [address_width-1:0] address, // Address for register file operations
    output reg WrEn,                    // Write enable for register file
    output reg RdEn,                    // Read enable for register file
    output reg [out_width-1:0] WrData,  // Data to be written to the register file
    output reg [out_width-1:0] TX_P_DATA, // Data to be transmitted
    output reg TX_D_VLD,               // Valid signal for transmitted data
    output reg clk_div_en              // Clock divider enable signal
);
reg out_state;
    // Internal signals
    reg [out_width-1:0] WR_DATA_fifo;   // Register to store data to be transmitted
    reg [address_width-1:0] address_saved;                       // Internal write enable signal
reg [3:0] save ;
    // State encoding for the finite state machine (FSM)
  parameter [3:0]  IDLE               = 4'b0000,
                 RF_Wr_Addr         = 4'b0001,
                 RF_Wr_Data         = 4'b0010,
                 RF_Rd_Addr         = 4'b0011,
                 Operand_A          = 4'b0100,
                 Operand_B          = 4'b0101,
                 ALU_FUN_STATE      = 4'b0110,
                 ALU_OPER_W_NOP_CMD = 4'b0111;


    // Registers for storing the current and next state of the FSM
    reg [3:0] current_state, next_state;

    // State register update logic
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            current_state <= IDLE; // Reset to IDLE state
        end else begin
            current_state <= next_state; // Transition to the next state
        end
    end

    // State transition logic based on the current state and inputs
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (RX_D_VLD) begin
                    case (RX_P_DATA)
                        8'hAA: next_state = RF_Wr_Addr;
                        8'hBB: next_state = RF_Rd_Addr;
                        8'hCC: next_state = Operand_A;
                        8'hDD: next_state = ALU_FUN_STATE;
                        default: next_state = IDLE;
                    endcase
                end else begin
                    next_state = IDLE;
                end
            end
            RF_Wr_Addr: begin   ///  1
                if (RX_D_VLD ) begin
                    next_state = RF_Wr_Data;
                end else begin
                    next_state = RF_Wr_Addr;
                end
            end
            RF_Wr_Data: ////  2
                if (RX_D_VLD) begin
                  next_state=IDLE;
                end else begin
                    next_state = RF_Wr_Data;
                end
           
            RF_Rd_Addr: begin
                if (RdData_Valid) begin
                      next_state=IDLE;
                end else begin
                    next_state = RF_Rd_Addr;
                end
            end
           
            Operand_A: begin
                if (RX_D_VLD) begin
                    next_state = Operand_B;
                end else begin
                    next_state = Operand_A;
                end
            end
            Operand_B: begin
                if (RX_D_VLD) begin
                    next_state = ALU_FUN_STATE;
                end else begin
                    next_state = Operand_B;
                end
            end
            ALU_FUN_STATE: begin
                if (RX_D_VLD) begin
                    next_state=IDLE;
                end else begin
                    next_state = ALU_FUN_STATE;
                end
            end
           
            default: begin
                next_state = IDLE;
            end
        endcase
    end

// Combinational output logic based on the current state and RX_D_VLD signal
always @(*) begin

      TX_D_VLD=0;
    clk_div_en=1;
      WrEn=0;
    case (current_state)
IDLE:
begin
      
    EN=0;
    CLK_EN=0;

    WrEn=0;
    RdEn=0;
      TX_D_VLD=0;

    clk_div_en=1;
    save=0;
end
RF_Wr_Addr:
begin
    if (RX_D_VLD) begin
        begin
           address=RX_P_DATA[address_width-1:0];
        end
    end
end

RF_Wr_Data:
begin
if (RX_D_VLD) begin
        begin
          WrEn=1;
          WrData=RX_P_DATA;
         
        end
    end
end
RF_Rd_Addr:
begin
    if (RX_D_VLD) begin
        RdEn=1;
    end
   else if(RdData_Valid)
    begin
        TX_P_DATA=RdData;
        TX_D_VLD=1;
    end

end
Operand_A:
begin
    if (RX_D_VLD) begin
      WrEn=1;
      WrData=RX_P_DATA;
      address=0;
    end
end

Operand_B:begin
    if (RX_D_VLD) begin
      WrEn=1;
      WrData=RX_P_DATA;
      address=1;
    end
end
ALU_FUN_STATE:
begin
    if (RX_D_VLD) begin
        ALU_FUN = RX_P_DATA[alu_fun-1:0];
        EN = 1;
        CLK_EN = 1;
        TX_P_DATA=ALU_OUT;
        TX_D_VLD=1;
    end
 if(OUT_Valid)
begin
     CLK_EN = 1;
      TX_P_DATA=ALU_OUT;
       ALU_FUN = RX_P_DATA[alu_fun-1:0];
        TX_D_VLD=1;
end

    end
endcase
end
endmodule