///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo encargado de generar la vista del Tablero Connect 4
// MODIFICADO para invertir mapeo vertical (datos[0] -> pantalla[abajo])
///////////////////////////////////////////////////////////////////////////////////////////////////////////

module videoGen (
    input logic clk,             // Señal de reloj (¿Usada?)
    input logic rst_n,           // Señal de reinicio activo bajo (¿Usada?)
    input logic [9:0] x_pos, y_pos, // Coordenadas de píxeles actuales
    input logic [83:0] grid_state,  // Matriz de estado (datos fila 0 = fondo)
    input logic [3:0] current_state,// Estado actual del juego (FSM)
    input logic [2:0] selected_col, // Columna seleccionada por el jugador
    input logic [23:0] winning_line,// Coords línea ganadora (formato asumido: data coords)

    output logic [7:0] red, green, blue // Salida de color RGB
);

    // Parámetros del tablero y celdas
    localparam logic [10:0] cell_size = 11'd50;
    localparam logic [10:0] gap = 11'd5;
    localparam logic [10:0] board_width = 7 * cell_size + 6 * gap;
    localparam logic [10:0] board_height = 6 * cell_size + 5 * gap;
    localparam logic [10:0] start_x = 11'd100;
    localparam logic [10:0] start_y = 11'd50; // Coordenada Y superior del tablero

    // Variables para el dibujo
    logic board_area;
    logic [2:0] current_col; // Columna VISUAL (0-6) calculada desde x_pos
    logic [2:0] visual_row;  // Fila VISUAL (0-5, 0=arriba) calculada desde y_pos
    logic [2:0] data_row;    // Fila en los DATOS (0-5, 0=abajo en datos) ***INVERTIDA***
    logic cell_area;
    logic player1_chip, player2_chip;
    logic winning_chip;
    logic highlight_col;
    logic preview_chip;
    logic board_frame;

    // Calcular posición VISUAL actual en la matriz (0,0 es esquina superior izquierda VISUAL)
    assign current_col = (x_pos >= start_x && x_pos < start_x + board_width) ?
                         (x_pos - start_x) / (cell_size + gap) : 3'bxxx; // Indeterminado si fuera
    assign visual_row  = (y_pos >= start_y && y_pos < start_y + board_height) ?
                         (y_pos - start_y) / (cell_size + gap) : 3'bxxx; // Indeterminado si fuera

    // *** INVERSIÓN VERTICAL ***
    // Calcular la fila correspondiente en los DATOS (0=abajo, 5=arriba)
    // Fila visual 0 (arriba) -> Fila datos 5
    // Fila visual 5 (abajo)  -> Fila datos 0
    assign data_row = 5 - visual_row;

    // Determinar si el píxel actual está dentro del área VISUAL de una celda válida
    // Usa visual_row y current_col para chequear coordenadas X, Y
    assign cell_area = (visual_row < 6) && (current_col < 7) && // Índice visual válido
                       (x_pos >= start_x + current_col*(cell_size + gap)) &&
                       (x_pos < start_x + current_col*(cell_size + gap) + cell_size) &&
                       (y_pos >= start_y + visual_row*(cell_size + gap)) &&
                       (y_pos < start_y + visual_row*(cell_size + gap) + cell_size);

    // Marco azul alrededor del tablero
    assign board_frame = (x_pos >= start_x - gap) && (x_pos < start_x + board_width + gap) &&
                         (y_pos >= start_y - gap) && (y_pos < start_y + board_height + gap) &&
                         !cell_area; // Solo dibujar si NO está dentro de una celda

    // Determinar contenido de la celda USANDO data_row para indexar grid_state
    // Índice = (fila_de_datos * 7 + columna_visual) * 2
    assign player1_chip = cell_area && (grid_state[(data_row*7 + current_col)*2 +: 2] == 2'b01);
    assign player2_chip = cell_area && (grid_state[(data_row*7 + current_col)*2 +: 2] == 2'b10);

    // Previsualización de ficha (encima del tablero) - Usa coordenadas VISUALES
    assign preview_chip = (current_state == 4'b0011 || current_state == 4'b0101) && //ESPERANDO_P1 o ESPERANDO_P2 
                          (x_pos >= start_x + selected_col * (cell_size + gap)) &&
                          (x_pos <  start_x + selected_col * (cell_size + gap) + cell_size) &&
                          (y_pos >= start_y - cell_size) && // Área encima del tablero
                          (y_pos <  start_y);

    // Resaltar columna seleccionada (flecha verde encima) - Usa coordenadas VISUALES
    assign highlight_col = (x_pos >= start_x + selected_col * (cell_size + gap)) &&
                           (x_pos <  start_x + selected_col * (cell_size + gap) + cell_size) &&
                           (y_pos >= start_y - 10) && // Pequeña área encima
                           (y_pos < start_y);


    // Detectar fichas ganadoras USANDO data_row para comparar con winning_line
    // ASUME que winning_line usa coordenadas de DATOS (0=abajo, 5=arriba)
    // Adapta esta lógica si el formato de winning_line es diferente.
    // Ejemplo Asumiendo: [5:3]=row_start, [2:0]=col_start, [17:15]=row_end, [14:12]=col_end
    assign winning_chip = cell_area && (
        // Horizontal (—)
        (winning_line[5:3] == data_row && winning_line[2:0] <= current_col && current_col <= winning_line[14:12]) ||
        // Vertical (|)
        (winning_line[2:0] == current_col && winning_line[5:3] <= data_row && data_row <= winning_line[17:15]) ||
        // Diagonal (\) Pendiente +1 (data_row aumenta si current_col aumenta)
        (data_row - winning_line[5:3] == current_col - winning_line[2:0] && winning_line[5:3] <= data_row && data_row <= winning_line[17:15]) ||
        // Diagonal (/) Pendiente -1 (data_row disminuye si current_col aumenta)
        (data_row - winning_line[5:3] == winning_line[2:0] - current_col && winning_line[5:3] >= data_row && data_row >= winning_line[17:15])
        // Nota: La comprobación del rango en diagonales podría necesitar ajuste según cómo winnerDetect define start/end.
    );


    // Generación de colores
    always_comb begin
        // Fondo negro por defecto
        red = 8'h00;
        green = 8'h00;
        blue = 8'h00;

        // Marco del tablero (azul)
        if (board_frame) begin
            blue = 8'h7F; // Azul medio
        end

        // Celdas vacías (blanco) - Leído usando data_row
        // Usa data_row para indexar grid_state
        if (cell_area && grid_state[(data_row*7 + current_col)*2 +: 2] == 2'b00) begin
            red = 8'hFF; 
            green = 8'hFF;
            blue = 8'h40;
        end

        // Fichas del jugador 1 (rojo) - Leído usando data_row
        if (player1_chip) begin // player1_chip ya usa data_row
            red = 8'hFF; // Rojo
            green = 8'h00;
            blue = 8'h00;
            // Resaltar si es parte de línea ganadora (amarillo)
            if (winning_chip) begin // winning_chip ya usa data_row
                green = 8'hFF; // Rojo + Verde = Amarillo
            end
        end

        // Fichas del jugador 2 (Berde) - Leído usando data_row
        // Nota: Puesto que es un juego de 1 jugador, esto no debería mostrarse.
        // Si P2 es 2'b10.
        if (player2_chip) begin // player2_chip ya usa data_row
             red = 8'h00; 
             green = 8'hFF; // Verde
             blue = 8'h00;
            // Resaltar si es parte de línea ganadora (blanco brillante?)
             if (winning_chip) begin // winning_chip ya usa data_row
                 red = 8'hFF; // Amarillo
             end
        end

        // Resaltar columna seleccionada (verde claro encima) - Usa coords visuales
        // Debe dibujarse "encima" de otras cosas si el píxel coincide
        if (highlight_col) begin
			 red = 8'h80;
			 green = 8'hFF;
			 blue = 8'h80;
        end

        // Previsualización de ficha (color del jugador 1 tenue?) - Usa coords visuales
        // Debe dibujarse "encima" de otras cosas si el píxel coincide
        if (preview_chip) begin
           red = 8'h80;
           green = 8'h80;
           blue = 8'h80;
        end

    end // always_comb

endmodule
