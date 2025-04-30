////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo encargado de modificar la matriz del Tablero de juego (6x7)
////////////////////////////////////////////////////////////////////////////////////////////////////////

module matrixTablero (
    input logic clk,           // Señal de reloj
    input logic rst_n,         // Señal de reset activo bajo
    input logic [83:0] data_in, // Entrada de 42 bits para cargar la matriz (6x7)
    input logic load,          // Señal de control para cargar nuevos datos
    input logic [2:0] column,  // Columna seleccionada (0-6)
    input logic player,        // Jugador actual (0=P1, 1=P2)
    output logic [83:0] matrix // Registro de 42 bits que representa la matriz
);

    // Lógica para encontrar la posición vacía más baja en la columna seleccionada
    function automatic [2:0] find_empty_slot(input [83:0] mat, input [2:0] col);
        for (int row = 0; row < 6; row++) begin // Revisa desde abajo hacia arriba (fila 0 a 5)
            if (mat[(row * 7 + col) * 2 +: 2] == 2'b00) begin
                return row; // Devuelve la primera fila vacía encontrada
            end
        end
        return 3'd6; // Devuelve 6 si la columna está llena
    endfunction

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix <= 84'b0; // Restablecer la matriz a 0 (tablero vacío)
        end
        else if (load) begin
            // Colocar ficha en la posición más baja disponible
            logic [2:0] empty_row;
            empty_row = find_empty_slot(matrix, column); // Usa el estado actual de la matrix

            if (empty_row < 6) begin // Si hay espacio (fila 0-5)
                // Coloca la ficha del jugador correcto (01=P1, 10=P2)
                matrix[(empty_row * 7 + column) * 2 +: 2] <= {1'b0, ~player}; // player 0 -> 01 (P1), player 1 -> 10 (P2)
            end
            // Si empty_row es 6 (llena), no se hace nada
        end
        // Si no hay load ni reset, la matriz mantiene su valor
    end
endmodule
