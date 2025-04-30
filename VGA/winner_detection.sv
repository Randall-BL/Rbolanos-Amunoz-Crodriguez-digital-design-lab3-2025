////////////////////////////////////////////////////////////////////////////////////////////////////////
// Módulo para detectar 4 en línea (Corrección Sintaxis v4)
////////////////////////////////////////////////////////////////////////////////////////////////////////
module winner_detection (
    input  logic [83:0] grid,       // Matriz de 6x7 celdas (2 bits por celda)
    output reg winner_found,        // Salida reg
    output reg player_won,          // Salida reg
    output reg [23:0] winning_line  // Salida reg
);

    // Función para obtener el valor de una celda
    function automatic [1:0] get_cell(input [2:0] row_idx, input [2:0] col_idx); // Renombrado para claridad
        begin
            if (row_idx > 5 || col_idx > 6) begin
                get_cell = 2'b00; // Fuera de rango retorna vacío
            end else begin
                get_cell = grid[(row_idx * 7 + col_idx) * 2 +: 2];
            end
        end
    endfunction

    // Lógica combinacional para detectar ganador
    always_comb begin
        // --- Declaraciones locales PRIMERO ---
        integer row, col; // Para los bucles
        logic [1:0] cell1, cell2, cell3, cell4; // Para almacenar valores de celda
        logic [2:0] r0,r1,r2,r3; // Variables lógicas intermedias para filas
        logic [2:0] c0,c1,c2,c3; // Variables lógicas intermedias para columnas

        // --- Valores por defecto ---
        winner_found = 1'b0;
        player_won = 1'b0;
        winning_line = 24'b0;

        // Buscar para ambos jugadores (1 y 2) - SALIR TAN PRONTO SE ENCUENTRE UN GANADOR
        for (int player = 1; player <= 2; player = player + 1) begin
            if (winner_found) break; // Optimización

            // Buscar horizontalmente (—)
            for (row = 0; row < 6; row = row + 1) begin
                 if (winner_found) break;
                 r0 = row; // Asignar integer a logic[2:0] (toma bits bajos)
                 for (col = 0; col < 4; col = col + 1) begin
                    // Calcular y asignar índices a variables logic[2:0]
                    c0 = col;
                    c1 = col + 1;
                    c2 = col + 2;
                    c3 = col + 3;
                    // Usar las variables logic[2:0] en get_cell
                    cell1 = get_cell(r0, c0);
                    cell2 = get_cell(r0, c1);
                    cell3 = get_cell(r0, c2);
                    cell4 = get_cell(r0, c3);
                    if (cell1 == player && cell2 == player && cell3 == player && cell4 == player) begin
                        winner_found = 1'b1;
                        player_won = player - 1;
                        // Usar las variables logic[2:0] en la concatenación
                        winning_line = {3'b0, r0, 3'b0, c0, 3'b0, r0, 3'b0, c3};
                        break;
                    end
                end
            end

            // Buscar verticalmente (|)
            for (col = 0; col < 7; col = col + 1) begin
                 if (winner_found) break;
                 c0 = col;
                 for (row = 0; row < 3; row = row + 1) begin
                    r0 = row;
                    r1 = row + 1;
                    r2 = row + 2;
                    r3 = row + 3;
                    cell1 = get_cell(r0, c0);
                    cell2 = get_cell(r1, c0);
                    cell3 = get_cell(r2, c0);
                    cell4 = get_cell(r3, c0);
                    if (cell1 == player && cell2 == player && cell3 == player && cell4 == player) begin
                        winner_found = 1'b1;
                        player_won = player - 1;
                        winning_line = {3'b0, r0, 3'b0, c0, 3'b0, r3, 3'b0, c0};
                        break;
                    end
                end
            end

            // Buscar diagonal descendente (\)
            for (row = 0; row < 3; row = row + 1) begin
                 if (winner_found) break;
                 r0 = row;
                 r1 = row + 1;
                 r2 = row + 2;
                 r3 = row + 3;
                 for (col = 0; col < 4; col = col + 1) begin
                    c0 = col;
                    c1 = col + 1;
                    c2 = col + 2;
                    c3 = col + 3;
                    cell1 = get_cell(r0, c0);
                    cell2 = get_cell(r1, c1);
                    cell3 = get_cell(r2, c2);
                    cell4 = get_cell(r3, c3);
                    if (cell1 == player && cell2 == player && cell3 == player && cell4 == player) begin
                        winner_found = 1'b1;
                        player_won = player - 1;
                        winning_line = {3'b0, r0, 3'b0, c0, 3'b0, r3, 3'b0, c3};
                        break;
                    end
                end
            end

            // Buscar diagonal ascendente (/)
            for (row = 3; row < 6; row = row + 1) begin
                 if (winner_found) break;
                 // Calcular índices intermedios para filas
                 r0 = row;
                 r1 = row - 1;
                 r2 = row - 2;
                 r3 = row - 3;
                 for (col = 0; col < 4; col = col + 1) begin
                     // Calcular índices intermedios para columnas
                    c0 = col;
                    c1 = col + 1;
                    c2 = col + 2;
                    c3 = col + 3;
                    // Usar índices intermedios en get_cell
                    cell1 = get_cell(r0, c0);
                    cell2 = get_cell(r1, c1);
                    cell3 = get_cell(r2, c2);
                    cell4 = get_cell(r3, c3);
                     if (cell1 == player && cell2 == player && cell3 == player && cell4 == player) begin
                        winner_found = 1'b1;
                        player_won = player - 1;
                        // Usar índices intermedios (ya calculados) en concatenación
                        winning_line = {3'b0, r0, 3'b0, c0, 3'b0, r3, 3'b0, c3};
                        break;
                    end
                end
            end
        end // Fin del for 'player'

    end // Fin always_comb

endmodule