/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo encargado controlar como se modifica la matriz (Versión final verificada)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module matrixTableroControl (
    input clk,
    input rst_n,
    input col_left,
    input col_right,
    input confirm,
	 input logic random_move_valid,
	 input logic [2:0] random_col,
    input arduino_move,
    input [2:0] arduino_col,
    input [3:0] current_state,
    input [83:0] matrix_in,
    output reg [83:0] matrix_out,
    output reg [2:0] selected_col,
    output reg load,
    output reg move_valid
);

    reg [2:0] col_ptr;
    reg [41:0] temp_matrix;
    reg column_full;
    
    // Lógica para moverse entre columnas
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            col_ptr <= 3'd3;
        end
        else if (current_state == 4'b0010) begin // Turno jugador 1
            if (col_left && col_ptr > 3'd0) begin // Cambiado a detección de flanco positivo
                col_ptr <= col_ptr - 3'd1;
            end
            else if (col_right && col_ptr < 3'd6) begin // Cambiado a detección de flanco positivo
                col_ptr <= col_ptr + 3'd1;
            end
        end
    end

    // Lógica para confirmar la posición
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            temp_matrix <= matrix_in;
            load <= 1'b0;
            move_valid <= 1'b0;
            selected_col <= 3'b0;
        end
        else begin
            // Valores por defecto
            load <= 1'b0;
            move_valid <= 1'b0;
            temp_matrix <= matrix_in;
            selected_col <= col_ptr;
            
            // Verificar si la columna está llena
            column_full = 1'b1;
            for (int i = 0; i < 6; i++) begin
                if (matrix_in[(i*7 + col_ptr)*2 +: 2] == 2'b00) begin
                    column_full = 1'b0;
                    break;
                end
            end
            
            // Turno del jugador 1 (FPGA)
            if (current_state == 4'b0010 && confirm && !column_full) begin // Cambiado a detección de flanco positivo
                load <= 1'b1;
                move_valid <= 1'b1;
            end
            // Turno del jugador 2 (Arduino)
            else if (current_state == 4'b0100 && arduino_move && arduino_col < 7) begin
                // Verificar si la columna del Arduino está llena
                column_full = 1'b1;
                for (int i = 0; i < 6; i++) begin
                    if (matrix_in[(i*7 + arduino_col)*2 +: 2] == 2'b00) begin
                        column_full = 1'b0;
                        break;
                    end
                end
                
                if (!column_full) begin
                    load <= 1'b1;
                    move_valid <= 1'b1;
                    selected_col <= arduino_col;
                end
            end
				else if (current_state == 4'b0010 && random_move_valid) begin
				load <= 1'b1;
				move_valid <= 1'b1;
				selected_col <= random_col;
end
        end
    end

    assign matrix_out = temp_matrix;
	 
endmodule