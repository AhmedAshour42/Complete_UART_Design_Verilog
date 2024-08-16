module RegFile #(
  parameter width_data = 8,             // Width of data bus
  parameter width_address = 4,          // Width of address bus
  parameter num_registers = 16           // Number of registers in the register file
) (
  input wire clk, rst,                  // Clock and reset signals
  input wire [width_address-1:0] address, // Address input to access the register file
  input wire WrEn, RdEn,                // Write enable and read enable signals
  input wire [width_data-1:0] WrData,   // Data input for writing to the register file
  output reg [width_data-1:0] RdData,   // Data output for reading from the register file
  output reg RdData_Valid,              // Valid signal to indicate read data is valid
  output wire [width_data-1:0] REG0,     // Output register 0 for debugging or other purposes
  output wire [width_data-1:0] REG1,     // Output register 1 for debugging or other purposes
  output wire [width_data-1:0] REG2,     // Output register 2 for debugging or other purposes
  output wire [width_data-1:0] REG3      // Output register 3 for debugging or other purposes
);

  integer i;                            // Loop variable for initialization
  reg [width_data-1:0] reg_mem_file[num_registers-1:0]; // Register file memory array

  // Sequential block triggered by clock or reset signal
  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      // Reset condition: Initialize outputs and register file
      RdData_Valid <= 0;
      RdData <= 0;
      
      // Initialize register file with specific values or zerooooooooooooooo
      for (i = 0; i < num_registers; i = i + 1) begin
        if (i == 2) begin
          reg_mem_file[i] <='b100000_01; // Initialize register 2 with specific value
        end else if (i == 3) begin
          reg_mem_file[i] <= 'b00100000;     // Initialize register 3 with specific value
        end else begin
          reg_mem_file[i] <= 0; // Initialize other registers to zero
        end
      end
    end else begin
      // Normal operation
      if (WrEn & !RdEn) begin
        // Write operation
        reg_mem_file[address] <= WrData;
      end else if (RdEn & !WrEn) begin
        // Read operation
        RdData_Valid <= 1;
        RdData <= reg_mem_file[address];
      end else begin
        // No operation: Invalidate read data
        RdData_Valid <= 0;
      end
    end
  end

  // Continuous assignments to output registers for debugging or observation
  assign REG0 = reg_mem_file[0];
  assign REG1 = reg_mem_file[1];
  assign REG2 = reg_mem_file[2];
  assign REG3 = reg_mem_file[3];

endmodule
