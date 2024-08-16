module serializer #(parameter width = 8)  (
    input clk,               // Clock input
    input rst,               // Reset input
    input Data_valid,        // Data validity input
    input [width-1:0] P_data,      // Input data
    input ser_en, idle_data,          // Serializer enable input and idle data
    output ser_done,         // Serializer done output
    output reg ser_data      // Serialized data output
);

    // Internal variables
    integer counter;            // Counter for serialization
    reg [7:0] parrllel_data;    // Parallel data input buffer
    reg valid_reg;              // Flag to indicate valid data in parallel_data buffer

    // Main logic for serializing data
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset condition: Initialize variables
            ser_data <= 1;      // Initial value for serialized data
            counter <= 0;       // Reset counter
            valid_reg <= 0;     // Reset valid flag
            parrllel_data<=0;
        end
        else begin
            // If new data is valid, store it in the parallel_data buffer
            if (Data_valid) begin
                valid_reg <= 1;
                parrllel_data <= P_data;
            end
            // If data is valid and serializer is enabled, serialize the data
            else if (valid_reg && ser_en) begin
                // Output serialized data and increment counter
                ser_data <= parrllel_data[counter];
                counter <= counter + 1;
            end
            // after the stop case it will be idle state so retuen the output to 1
            else if (idle_data) begin
                            ser_data <= 1;    
            end
            // Reset counter if serialization is completed
            if (counter == 8) begin
                counter <= 0;
            end
        end
    end

    // Output signal indicating serialization completion
    assign ser_done = (counter == 8) ? 1 : 0;

endmodule
