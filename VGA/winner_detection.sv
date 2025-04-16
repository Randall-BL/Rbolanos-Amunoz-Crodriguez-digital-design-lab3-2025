////////////////////////////////////////////////////////////////////////////////////////////////////////
// Módulo para detectar 4 en línea en cualquier dirección (Versión completamente corregida)
////////////////////////////////////////////////////////////////////////////////////////////////////////

module winner_detection (
    input [83:0] grid,       // Matriz de 6x7 celdas (2 bits por celda) [41:0]
    output reg winner_found,
    output reg player_won,
    output reg [23:0] winning_line
);

    // Función para obtener el valor de una celda (compatible con Quartus)
    function automatic [1:0] get_cell(input [2:0] row, input [2:0] col);
        begin
            // Cálculo seguro del índice (row 0-5, col 0-6)
            if (row > 5 || col > 6) begin
                get_cell = 2'b00; // Fuera de rango retorna vacío
            end else begin
                get_cell = grid[(row * 7 + col) * 2 +: 2];
            end
        end
    endfunction

    // Variables temporales para los bucles
    integer row, col;
    reg [1:0] cell1, cell2, cell3, cell4;

    always @(*) begin
        // Valores por defecto
        winner_found = 0;
        player_won = 0;
        winning_line = 0;
        
        // Buscar para ambos jugadores (1 y 2)
        for (int player = 1; player <= 2; player = player + 1) begin
            // Buscar horizontalmente (—)
            for (row = 0; row < 6; row = row + 1) begin
                for (col = 0; col < 4; col = col + 1) begin
                    cell1 = get_cell(row, col);
                    cell2 = get_cell(row, col+1);
                    cell3 = get_cell(row, col+2);
                    cell4 = get_cell(row, col+3);
                    
                    if (cell1 == player && cell2 == player &&
                        cell3 == player && cell4 == player) begin
                        winner_found = 1;
                        player_won = player - 1;
                        winning_line = {3'b0, row, 3'b0, col, 3'b0, row, 3'b0, col+3};
                    end
                end
            end
            
            // Buscar verticalmente (|)
            for (col = 0; col < 7; col = col + 1) begin
                for (row = 0; row < 3; row = row + 1) begin
                    cell1 = get_cell(row, col);
                    cell2 = get_cell(row+1, col);
                    cell3 = get_cell(row+2, col);
                    cell4 = get_cell(row+3, col);
                    
                    if (cell1 == player && cell2 == player &&
                        cell3 == player && cell4 == player) begin
                        winner_found = 1;
                        player_won = player - 1;
                        winning_line = {3'b0, row, 3'b0, col, 3'b0, row+3, 3'b0, col};
                    end
                end
            end
            
            // Buscar diagonal descendente (\)
            for (row = 0; row < 3; row = row + 1) begin
                for (col = 0; col < 4; col = col + 1) begin
                    cell1 = get_cell(row, col);
                    cell2 = get_cell(row+1, col+1);
                    cell3 = get_cell(row+2, col+2);
                    cell4 = get_cell(row+3, col+3);
                    
                    if (cell1 == player && cell2 == player &&
                        cell3 == player && cell4 == player) begin
                        winner_found = 1;
                        player_won = player - 1;
                        winning_line = {3'b0, row, 3'b0, col, 3'b0, row+3, 3'b0, col+3};
                    end
                end
            end
            
            // Buscar diagonal ascendente (/)
            for (row = 3; row < 6; row = row + 1) begin
                for (col = 0; col < 4; col = col + 1) begin
                    cell1 = get_cell(row, col);
                    cell2 = get_cell(row-1, col+1);
                    cell3 = get_cell(row-2, col+2);
                    cell4 = get_cell(row-3, col+3);
                    
                    if (cell1 == player && cell2 == player &&
                        cell3 == player && cell4 == player) begin
                        winner_found = 1;
                        player_won = player - 1;
                        winning_line = {3'b0, row, 3'b0, col, 3'b0, row-3, 3'b0, col+3};
                    end
                end
            end
        end
    end
endmodule