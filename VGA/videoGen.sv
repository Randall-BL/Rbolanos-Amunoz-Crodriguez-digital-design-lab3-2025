
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo encargado de generar la vista del Tablero del juego y sus distintivos marcas (circulo o cuadrado)
///////////////////////////////////////////////////////////////////////////////////////////////////////////

module videoGen (
    input logic clk,           // Señal de reloj
    input logic rst_n,         // Señal de reinicio activo bajo
    input logic [9:0] x_pos, y_pos,  // Coordenadas de píxeles
    input logic [8:0] grid_state,    // Matriz de estado para las casillas
    input logic [3:0] current_state, // Estado actual del juego

    output logic [7:0] red, green, blue // Salida de color RGB
);

    // Variables para las líneas del tablero
    logic vLine1, vLine2, hLine1, hLine2;
    logic [10:0] boxSize = 10'd40;
    logic [10:0] gap = 10'd10;
    logic [10:0] verticalOffset = 10'd150;  // Desplazamiento vertical
    logic [10:0] horizontalOffset = 10'd230; // Desplazamiento horizontal
    logic lines; // Variable combinada para las líneas

    // Variables para los círculos en las casillas
    logic [8:0] circleDraw;
	 logic [8:0] squareDraw;
    logic [10:0] radius = 10'd15; // Radio del círculo

    // Líneas del tablero de 3x3
    assign vLine1 = (x_pos >= horizontalOffset + boxSize + gap && x_pos <= horizontalOffset + boxSize + gap + 2 && 
                     y_pos >= verticalOffset && y_pos <= verticalOffset + 3 * boxSize + 2 * gap);
    assign vLine2 = (x_pos >= horizontalOffset + 2 * (boxSize + gap) && x_pos <= horizontalOffset + 2 * (boxSize + gap) + 2 && 
                     y_pos >= verticalOffset && y_pos <= verticalOffset + 3 * boxSize + 2 * gap);

    assign hLine1 = (y_pos >= verticalOffset + boxSize + gap && y_pos <= verticalOffset + boxSize + gap + 2 && 
                     x_pos >= horizontalOffset && x_pos <= horizontalOffset + 3 * boxSize + 2 * gap);
    assign hLine2 = (y_pos >= verticalOffset + 2 * (boxSize + gap) && y_pos <= verticalOffset + 2 * (boxSize + gap) + 2 && 
                     x_pos >= horizontalOffset && x_pos <= horizontalOffset + 3 * boxSize + 2 * gap);

    // Dibujar los círculos según el estado del tablero en la Matriz 3x3
    assign circleDraw[0] = (grid_state[0] == 1'b1) && 
                           ((x_pos - (horizontalOffset + boxSize / 2)) * (x_pos - (horizontalOffset + boxSize / 2)) + 
                           (y_pos - (verticalOffset + boxSize / 2)) * (y_pos - (verticalOffset + boxSize / 2)) <= radius * radius);
    assign circleDraw[1] = (grid_state[1] == 1'b1) && 
                           ((x_pos - (horizontalOffset + boxSize + gap + boxSize / 2)) * (x_pos - (horizontalOffset + boxSize + gap + boxSize / 2)) + 
                           (y_pos - (verticalOffset + boxSize / 2)) * (y_pos - (verticalOffset + boxSize / 2)) <= radius * radius);
    assign circleDraw[2] = (grid_state[2] == 1'b1) && 
                           ((x_pos - (horizontalOffset + 2 * (boxSize + gap) + boxSize / 2)) * (x_pos - (horizontalOffset + 2 * (boxSize + gap) + boxSize / 2)) + 
                           (y_pos - (verticalOffset + boxSize / 2)) * (y_pos - (verticalOffset + boxSize / 2)) <= radius * radius);

    assign circleDraw[3] = (grid_state[3] == 1'b1) && 
                           ((x_pos - (horizontalOffset + boxSize / 2)) * (x_pos - (horizontalOffset + boxSize / 2)) + 
                           (y_pos - (verticalOffset + boxSize + gap + boxSize / 2)) * (y_pos - (verticalOffset + boxSize + gap + boxSize / 2)) <= radius * radius);
    assign circleDraw[4] = (grid_state[4] == 1'b1) && 
                           ((x_pos - (horizontalOffset + boxSize + gap + boxSize / 2)) * (x_pos - (horizontalOffset + boxSize + gap + boxSize / 2)) + 
                           (y_pos - (verticalOffset + boxSize + gap + boxSize / 2)) * (y_pos - (verticalOffset + boxSize + gap + boxSize / 2)) <= radius * radius);
    assign circleDraw[5] = (grid_state[5] == 1'b1) && 
                           ((x_pos - (horizontalOffset + 2 * (boxSize + gap) + boxSize / 2)) * (x_pos - (horizontalOffset + 2 * (boxSize + gap) + boxSize / 2)) + 
                           (y_pos - (verticalOffset + boxSize + gap + boxSize / 2)) * (y_pos - (verticalOffset + boxSize + gap + boxSize / 2)) <= radius * radius);

    assign circleDraw[6] = (grid_state[6] == 1'b1) && 
                           ((x_pos - (horizontalOffset + boxSize / 2)) * (x_pos - (horizontalOffset + boxSize / 2)) + 
                           (y_pos - (verticalOffset + 2 * (boxSize + gap) + boxSize / 2)) * (y_pos - (verticalOffset + 2 * (boxSize + gap) + boxSize / 2)) <= radius * radius);
    assign circleDraw[7] = (grid_state[7] == 1'b1) && 
                           ((x_pos - (horizontalOffset + boxSize + gap + boxSize / 2)) * (x_pos - (horizontalOffset + boxSize + gap + boxSize / 2)) + 
                           (y_pos - (verticalOffset + 2 * (boxSize + gap) + boxSize / 2)) * (y_pos - (verticalOffset + 2 * (boxSize + gap) + boxSize / 2)) <= radius * radius);
    assign circleDraw[8] = (grid_state[8] == 1'b1) && 
                           ((x_pos - (horizontalOffset + 2 * (boxSize + gap) + boxSize / 2)) * (x_pos - (horizontalOffset + 2 * (boxSize + gap) + boxSize / 2)) + 
                           (y_pos - (verticalOffset + 2 * (boxSize + gap) + boxSize / 2)) * (y_pos - (verticalOffset + 2 * (boxSize + gap) + boxSize / 2)) <= radius * radius);
	 
	 // Dibujar los cuadrados según el estado del tablero en la Matriz 3x3
	 assign squareDraw[0] = (grid_state[0] == 1'b1) && 
                       (x_pos >= horizontalOffset && x_pos <= horizontalOffset + boxSize) && 
                       (y_pos >= verticalOffset && y_pos <= verticalOffset + boxSize);

	 assign squareDraw[1] = (grid_state[1] == 1'b1) && 
                       (x_pos >= horizontalOffset + boxSize + gap && x_pos <= horizontalOffset + 2 * boxSize + gap) && 
                       (y_pos >= verticalOffset && y_pos <= verticalOffset + boxSize);

	 assign squareDraw[2] = (grid_state[2] == 1'b1) && 
                       (x_pos >= horizontalOffset + 2 * (boxSize + gap) && x_pos <= horizontalOffset + 3 * boxSize + 2 * gap) && 
                       (y_pos >= verticalOffset && y_pos <= verticalOffset + boxSize);

	 assign squareDraw[3] = (grid_state[3] == 1'b1) && 
                       (x_pos >= horizontalOffset && x_pos <= horizontalOffset + boxSize) && 
                       (y_pos >= verticalOffset + boxSize + gap && y_pos <= verticalOffset + 2 * boxSize + gap);

	 assign squareDraw[4] = (grid_state[4] == 1'b1) && 
                       (x_pos >= horizontalOffset + boxSize + gap && x_pos <= horizontalOffset + 2 * boxSize + gap) && 
                       (y_pos >= verticalOffset + boxSize + gap && y_pos <= verticalOffset + 2 * boxSize + gap);

	 assign squareDraw[5] = (grid_state[5] == 1'b1) && 
                       (x_pos >= horizontalOffset + 2 * (boxSize + gap) && x_pos <= horizontalOffset + 3 * boxSize + 2 * gap) && 
                       (y_pos >= verticalOffset + boxSize + gap && y_pos <= verticalOffset + 2 * boxSize + gap);

	 assign squareDraw[6] = (grid_state[6] == 1'b1) && 
                       (x_pos >= horizontalOffset && x_pos <= horizontalOffset + boxSize) && 
                       (y_pos >= verticalOffset + 2 * (boxSize + gap) && y_pos <= verticalOffset + 3 * boxSize + 2 * gap);

	 assign squareDraw[7] = (grid_state[7] == 1'b1) && 
                       (x_pos >= horizontalOffset + boxSize + gap && x_pos <= horizontalOffset + 2 * boxSize + gap) && 
                       (y_pos >= verticalOffset + 2 * (boxSize + gap) && y_pos <= verticalOffset + 3 * boxSize + 2 * gap);

	 assign squareDraw[8] = (grid_state[8] == 1'b1) && 
                       (x_pos >= horizontalOffset + 2 * (boxSize + gap) && x_pos <= horizontalOffset + 3 * boxSize + 2 * gap) && 
                       (y_pos >= verticalOffset + 2 * (boxSize + gap) && y_pos <= verticalOffset + 3 * boxSize + 2 * gap);


    // Combinamos todas las líneas y círculos para determinar el color de los píxeles
    assign lines = vLine1 | vLine2 | hLine1 | hLine2;

    // Determinamos el color de los círculos segun el estado
	 
    assign red = ((circleDraw[0] && (current_state == 4'b0010)) || (circleDraw[1] && (current_state == 4'b0010)) || 
                  (circleDraw[2] && (current_state == 4'b0010)) || (circleDraw[3] && (current_state == 4'b0010)) || 
                  (circleDraw[4] && (current_state == 4'b0010)) || (circleDraw[5] && (current_state == 4'b0010)) || 
                  (circleDraw[6] && (current_state == 4'b0010)) || (circleDraw[7] && (current_state == 4'b0010)) || 
                  (circleDraw[8] && (current_state == 4'b0010))) ? 8'hFF : 8'h00;  // Rojo si hay un círculo rojo
						
	// Determinamos el color de los cuadrados segun el estado

    assign green = ((squareDraw[0] && (current_state == 4'b0011)) || (squareDraw[1] && (current_state == 4'b0011)) || 
                    (squareDraw[2] && (current_state == 4'b0011)) || (squareDraw[3] && (current_state == 4'b0011)) || 
                    (squareDraw[4] && (current_state == 4'b0011)) || (squareDraw[5] && (current_state == 4'b0011)) || 
                    (squareDraw[6] && (current_state == 4'b0011)) || (squareDraw[7] && (current_state == 4'b0011)) || 
                    (squareDraw[8] && (current_state == 4'b0011))) ? 8'hFF : 8'h00;  // Verde si hay un círculo verde

    assign blue = (lines) ? 8'hFF : 8'h00;    // Líneas del tablero en azul


endmodule


