///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo encargado de generar la vista del Tablero Connect 4 con previsualización de ficha
///////////////////////////////////////////////////////////////////////////////////////////////////////////

module videoGen (
    input logic clk,           // Señal de reloj
    input logic rst_n,         // Señal de reinicio activo bajo
    input logic [9:0] x_pos, y_pos,  // Coordenadas de píxeles
    input logic [83:0] grid_state,   // Matriz de estado para las casillas (6x7)
    input logic [3:0] current_state, // Estado actual del juego
    input logic [2:0] selected_col,  // Columna seleccionada
    input logic [23:0] winning_line, // Línea ganadora (row_start, col_start, row_end, col_end)
    
    output logic [7:0] red, green, blue // Salida de color RGB
);

    // Parámetros del tablero
    localparam logic [10:0] cell_size = 11'd50;  // Tamaño de cada celda
    localparam logic [10:0] gap = 11'd5;         // Espacio entre celdas
    localparam logic [10:0] board_width = 7 * cell_size + 6 * gap;  // Ancho total del tablero
    localparam logic [10:0] board_height = 6 * cell_size + 5 * gap; // Alto total del tablero
    localparam logic [10:0] start_x = 11'd100;    // Posición X inicial del tablero
    localparam logic [10:0] start_y = 11'd50;    // Posición Y inicial del tablero

    // Variables para el dibujo
    logic board_area;
    logic [2:0] current_row, current_col; // Fila y columna actual (0-5 y 0-6)
    logic cell_area;
    logic player1_chip, player2_chip;     // Fichas de los jugadores
    logic winning_chip;                   // Ficha parte de línea ganadora
    logic highlight_col;                  // Resaltado de columna seleccionada
    logic preview_chip;                   // Previsualización de ficha
    logic board_frame;                    // Marco del tablero
    
    // Calcular posición actual en la matriz
    assign current_col = (x_pos >= start_x && x_pos < start_x + board_width) ? 
                       (x_pos - start_x) / (cell_size + gap) : 3'b000;
    assign current_row = (y_pos >= start_y && y_pos < start_y + board_height) ? 
                       (y_pos - start_y) / (cell_size + gap) : 3'b000;

    // Determinar si el píxel actual está dentro de una celda
    assign cell_area = (current_row < 6) && (current_col < 7) &&
                      (x_pos >= start_x + current_col*(cell_size + gap)) && 
                      (x_pos < start_x + current_col*(cell_size + gap) + cell_size) &&
                      (y_pos >= start_y + current_row*(cell_size + gap)) && 
                      (y_pos < start_y + current_row*(cell_size + gap) + cell_size);

    // Marco azul alrededor del tablero
    assign board_frame = (x_pos >= start_x - gap) && (x_pos < start_x + board_width + gap) &&
                        (y_pos >= start_y - gap) && (y_pos < start_y + board_height + gap) &&
                        !cell_area;

    // Determinar contenido de la celda
    assign player1_chip = cell_area && (grid_state[(current_row*7 + current_col)*2 +: 2] == 2'b01);
    assign player2_chip = cell_area && (grid_state[(current_row*7 + current_col)*2 +: 2] == 2'b10);
    
    // Previsualización de ficha (amarillo semitransparente)
	 assign preview_chip = (current_state == 4'b0010) &&
								  (x_pos >= start_x + selected_col * (cell_size + gap)) &&
								  (x_pos <  start_x + selected_col * (cell_size + gap) + cell_size) &&
								  (y_pos >= start_y - cell_size) &&
								  (y_pos <  start_y);

    
    // Resaltar columna seleccionada (flecha verde arriba del tablero)
	 assign highlight_col = (x_pos >= start_x + selected_col * (cell_size + gap)) &&
									(x_pos <  start_x + selected_col * (cell_size + gap) + cell_size) &&
									(y_pos >= start_y - 10) && (y_pos < start_y);



    // Detectar fichas ganadoras (resaltar en amarillo)
    assign winning_chip = cell_area && (
        // Horizontal (—)
        (winning_line[5:3] == current_row && winning_line[2:0] == current_col && 
         winning_line[5:3] == winning_line[17:15] && 
         winning_line[2:0] <= current_col && current_col <= winning_line[14:12]) ||
        
        // Vertical (|)
        (winning_line[2:0] == current_col && winning_line[5:3] == current_row && 
         winning_line[2:0] == winning_line[14:12] && 
         winning_line[5:3] <= current_row && current_row <= winning_line[17:15]) ||
        
        // Diagonal (\)
        (winning_line[5:3] - winning_line[17:15] == winning_line[2:0] - winning_line[14:12] &&
         current_row - winning_line[5:3] == current_col - winning_line[2:0] &&
         current_row >= winning_line[5:3] && current_row <= winning_line[17:15]) ||
        
        // Diagonal (/)
        (winning_line[5:3] - winning_line[17:15] == winning_line[14:12] - winning_line[2:0] &&
         current_row - winning_line[5:3] == winning_line[2:0] - current_col &&
         current_row >= winning_line[5:3] && current_row <= winning_line[17:15])
    );

    // Generación de colores
    always_comb begin
        // Fondo negro por defecto
        red = 8'h00;
        green = 8'h00;
        blue = 8'h00;
        
        // Marco del tablero (azul)
        if (board_frame) begin
            blue = 8'h7F;
        end
        
        // Previsualización de ficha (amarillo semitransparente)
		  if (preview_chip) begin
		  red = 8'h80;
		  green = 8'h80;
		  blue = 8'h80;
		  end

        // Fichas del jugador 1 (rojo)
        if (player1_chip) begin
            red = 8'hFF;
            // Resaltar si es parte de línea ganadora (amarillo)
            if (winning_chip) begin
                green = 8'hFF;
                blue = 8'h00;
            end
        end
        
        // Fichas del jugador 2 (verde)
        if (player2_chip) begin
            green = 8'hFF;
            // Resaltar si es parte de línea ganadora (amarillo)
            if (winning_chip) begin
                red = 8'hFF;
                blue = 8'h00;
            end
        end
        
        // Celdas vacías (blanco)
        if (cell_area && grid_state[(current_row*7 + current_col)*2 +: 2] == 2'b00) begin
            red = 8'hFF;
            green = 8'hFF;
            blue = 8'hFF;
        end
		  
		  // Pintar previsualización
		  if (highlight_col) begin
			 red = 8'h80;
			 green = 8'hFF;
			 blue = 8'h80;
		  end
    end
	 
endmodule