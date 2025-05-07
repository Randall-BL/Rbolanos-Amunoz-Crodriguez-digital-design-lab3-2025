////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo encargado de modificar la matriz del Tablero de juego (6x7) - CORREGIDO
////////////////////////////////////////////////////////////////////////////////////////////////////////

module matrixTablero (
    input logic clk,           // Señal de reloj
    input logic rst_n,         // Señal de reset activo bajo
    // input logic [83:0] data_in, // Esta entrada no parece usarse, se puede eliminar si no se necesita cargar externamente
    input logic load,          // Señal de control para colocar ficha (pulso)
    input logic [2:0] column,  // Columna seleccionada (0-6) donde colocar
    input logic player,        // Jugador actual (1'b1 para P1 según conexión actual)
    output logic [83:0] matrix // Registro que representa la matriz (tablero)
);

    // Lógica para encontrar la posición vacía más baja en la columna seleccionada
    // Devuelve 0-5 si hay espacio, 6 si está llena.
    function automatic [2:0] find_empty_slot(input [83:0] mat, input [2:0] col);
        for (int row = 0; row < 6; row++) begin // Revisa desde abajo (fila 0) hacia arriba (fila 5)
            // Chequea si la celda (row, col) está vacía (00)
            if (mat[(row * 7 + col) * 2 +: 2] == 2'b00) begin
                return row; // Devuelve la primera fila vacía encontrada
            end
        end
        return 3'd6; // Ninguna fila vacía encontrada -> columna llena
    endfunction

    // Proceso síncrono para actualizar el tablero
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix <= 84'b0; // Restablecer la matriz a 0 (tablero vacío)
        end
        // Solo actualizar si llega la señal 'load' (pulso desde matrixCtrl)
        else if (load) begin
            logic [2:0] empty_row;

            // Encuentra dónde colocar la ficha en la columna dada
            empty_row = find_empty_slot(matrix, column); // Usa el estado actual de la matrix

            // Asegurarse de que la columna no esté llena (find_empty_slot devuelve 0-5)
            if (empty_row < 6) begin
                // ---- CORRECCIÓN AQUÍ ----
                // Asignar el código correcto basado en la entrada 'player'
                // Si player=1'b1 (viene de current_player[0] para P1), escribir 2'b01 (P1)
                // Si player=1'b0 (sería P2 si existiera), escribir 2'b10 (P2)
                matrix[(empty_row * 7 + column) * 2 +: 2] <= (player == 1'b1) ? 2'b01 : 2'b10;
                // ---- FIN CORRECCIÓN ----
            end
            // Si empty_row es 6 (columna llena), no se modifica la matriz (la señal 'load'
            // no debería haberse generado por matrixCtrl en primer lugar, pero esto es seguro).
        end
        // Si no hay load ni reset, la matriz mantiene su valor anterior (comportamiento de registro)
    end

    // La entrada data_in original no se usa en esta lógica de colocar ficha.
    // Si necesitas una forma de cargar un estado completo del tablero, necesitarías otra lógica.

endmodule