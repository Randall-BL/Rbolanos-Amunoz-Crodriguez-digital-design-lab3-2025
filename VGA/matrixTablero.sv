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
	function automatic [2:0] find_empty_slot(input [41:0] mat, input [2:0] col);
		 for (int row = 5; row >= 0; row--) begin  // 6 filas (0 a 5)
			  if (mat[(row*7 + col)*2 +: 2] == 2'b00) // 7 columnas (0 a 6)
					return row;
		 end
		 return 3'b111; // Columna llena
    endfunction

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix <= 84'b0;  // Restablecer la matriz a 0 cuando rst_n está activo bajo
        end
        else if (load) begin
            // Implementar "gravedad" - colocar ficha en la posición más baja disponible
            logic [2:0] empty_row;
            empty_row = find_empty_slot(matrix, column);
            
            if (empty_row != 3'b111) begin // Si hay espacio en la columna
                matrix[(empty_row*7 + column)*2 +: 2] <= {1'b1, player}; // 01=P1, 10=P2
            end
        end
    end
endmodule