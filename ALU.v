module ALU #(
    parameter width_data = 8,            // Width of the data bus
    parameter width_fun = 4              // Width of the function select bus
) (
    input  wire  clk,                    // Clock signal
    input  wire  rst,                    // Reset signal, active low
    input wire  Enable,                 // ALU enable signal
    input  [width_data-1:0] A,           // Operand A
    input  [width_data-1:0] B,           // Operand B
    input  [width_fun-1:0] ALU_FUN,      // ALU function selector
    output  reg [2*width_data-1:0] ALU_OUT,// ALU output
    output reg  OUT_VALID              // Output valid flag

);

    // Sequential block triggered by clock or reset signal
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset condition: Initialize outputs
            OUT_VALID <= 0;
            ALU_OUT <= 0;
        end
        else begin
            if (Enable) begin
                OUT_VALID <= 1;
                case (ALU_FUN)
                    0: ALU_OUT <= A + B;         // Addition
                    1: ALU_OUT <= A - B;         // Subtraction
                    2: ALU_OUT <= A * B;         // Multiplication
                    3: ALU_OUT <= A / B;         // Division
                    4: ALU_OUT <= A & B;         // Bitwise AND
                    5: ALU_OUT <= A | B;         // Bitwise OR
                    6: ALU_OUT <= !(A & B);      // Bitwise NAND
                    7: ALU_OUT <= !(A | B);      // Bitwise NOR
                    8: ALU_OUT <= A ^ B;         // Bitwise XOR
                    9: begin
                        // Equality comparison
                        if (A == B) begin
                            ALU_OUT <= 1;
                        end else begin
                            ALU_OUT <= 0;
                        end
                    end
                    10: begin
                        // Greater than comparison
                        if (A > B) begin
                            ALU_OUT <= 1;
                        end else begin
                            ALU_OUT <= 0;
                        end
                    end
                    11: ALU_OUT <= (A >> 1);     // Logical right shift
                    12: ALU_OUT <= (A << 1);     // Logical left shift
                    default: ALU_OUT <= 0;   // Default operation: Addition
                endcase
            end else begin
                // Disable ALU operation
                OUT_VALID <= 0;
                 ALU_OUT  <=0;
            end
        end
    end

endmodule
