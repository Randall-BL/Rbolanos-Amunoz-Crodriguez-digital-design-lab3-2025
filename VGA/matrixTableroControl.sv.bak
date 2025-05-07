module matrixControl (
    input  logic        clk,         // Clock signal
    input  logic        rst_n,       // Active low reset signal
    input  logic        I,  // Button to select matrix position (8 to 0)
    input  logic        W, // Button to confirm and set selected position to 1
    input  logic [8:0]  matrix_in,   // Input 9-bit matrix
    output logic [8:0]  matrix_out,  // Output 9-bit matrix with modified value
    output logic        load         // Load signal to indicate a change
);

    logic [3:0] index;  // 4-bit index to count from 8 to 0 (positions in the 9-bit matrix)
    logic [8:0] temp_matrix; // Temporary matrix to store the modified values

    // Button select logic to cycle through matrix positions
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            index <= 4'd8; // Start at the 8th bit (top-left) when reset
        end
        else if (!W) begin
            if (index == 4'd0)
                index <= 4'd8;  // Loop back to 8 after reaching 0
            else
                index <= index - 4'd1; // Move to the next position
        end
    end

    // Button confirm logic to modify the matrix
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            temp_matrix <= matrix_in; // Initialize temp_matrix with input matrix
            load <= 1'b0;             // No load when reset
        end
        else if (!I) begin
            temp_matrix <= matrix_in | (9'b1 << index); // Set the selected position to 1
            load <= 1'b1; // Indicate that a change has been made
        end
        else begin
            load <= 1'b0; // No load when confirm button is not pressed
        end
    end

    // Assign the modified matrix to the output
    assign matrix_out = temp_matrix;

endmodule