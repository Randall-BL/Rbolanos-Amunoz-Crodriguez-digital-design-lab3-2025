///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo encargado de generar la vista del Tablero Connect 4
// Muestra "WIN" con 'W' y 'N' diagonal en GAME_OVER, y pantalla de inicio.
///////////////////////////////////////////////////////////////////////////////////////////////////////////

module videoGen (
    input logic clk,             // Señal de reloj (¿Usada internamente?)
    input logic rst_n,           // Señal de reinicio activo bajo (¿Usada internamente?)
    input logic [9:0] x_pos, y_pos, // Coordenadas de píxeles actuales
    input logic [83:0] grid_state,  // Matriz de estado (datos fila 0 = fondo visual, fila 5 = tope visual)
    input logic [3:0] current_state,// Estado actual del juego (FSM)
    input logic [2:0] selected_col, // Columna seleccionada por el jugador
    input logic [23:0] winning_line,// Coords línea ganadora

    output logic [7:0] red, green, blue // Salida de color RGB
);

    // Parámetros del tablero y celdas
    localparam logic [10:0] cell_size = 11'd50;
    localparam logic [10:0] gap = 11'd5;
    localparam logic [10:0] board_width = 7 * cell_size + 6 * gap;
    localparam logic [10:0] board_height = 6 * cell_size + 5 * gap;
    localparam logic [10:0] start_x = 11'd100;
    localparam logic [10:0] start_y = 11'd50; // Coordenada Y superior visual del tablero

    // --- Parámetros para el texto "WIN" ---
    localparam TEXT_LETTER_WIDTH   = 10'd20;
    localparam TEXT_LETTER_HEIGHT  = 10'd30;
    localparam TEXT_LETTER_SPACING = 10'd5;
    localparam STROKE_THICKNESS    = 3;      // Grosor de los trazos de las letras "WIN"

    localparam TEXT_Y_TOP          = start_y - TEXT_LETTER_HEIGHT - 15; // Un poco más de espacio arriba
    localparam TEXT_Y_BOTTOM       = TEXT_Y_TOP + TEXT_LETTER_HEIGHT;

    localparam WIN_TEXT_TOTAL_WIDTH = 3 * TEXT_LETTER_WIDTH + 2 * TEXT_LETTER_SPACING;
    localparam WIN_TEXT_START_X     = start_x + (board_width - WIN_TEXT_TOTAL_WIDTH) / 2;

    localparam W_LEFT_WIN  = WIN_TEXT_START_X;
    localparam W_RIGHT_WIN  = W_LEFT_WIN + TEXT_LETTER_WIDTH;
    localparam I_LEFT_WIN  = W_RIGHT_WIN  + TEXT_LETTER_SPACING;
    localparam I_RIGHT_WIN  = I_LEFT_WIN + TEXT_LETTER_WIDTH;
    localparam N_LEFT_WIN  = I_RIGHT_WIN  + TEXT_LETTER_SPACING;
    localparam N_RIGHT_WIN  = N_LEFT_WIN + TEXT_LETTER_WIDTH;

    // --- Parámetros para dibujar la W con diagonales ---
    localparam W_QTR_WIDTH = TEXT_LETTER_WIDTH / 4;
    localparam W_X0 = W_LEFT_WIN;
    localparam W_X1 = W_LEFT_WIN + W_QTR_WIDTH;
    localparam W_X2 = W_LEFT_WIN + 2 * W_QTR_WIDTH;
    localparam W_X3 = W_LEFT_WIN + 3 * W_QTR_WIDTH;
    localparam W_X4 = W_RIGHT_WIN -1; // -1 porque el rango es < W_RIGHT_WIN

    localparam W_DX_SEG = W_QTR_WIDTH;
    localparam W_DY_SEG_EFFECTIVE = TEXT_LETTER_HEIGHT -1;
    localparam W_LINE_THRESHOLD = ((W_DY_SEG_EFFECTIVE > W_DX_SEG) ? W_DY_SEG_EFFECTIVE : W_DX_SEG) * STROKE_THICKNESS / 2;

    // --- Parámetros para la diagonal de la N ---
    localparam N_DIAG_X_START = N_LEFT_WIN + STROKE_THICKNESS -1;
    localparam N_DIAG_Y_START = TEXT_Y_TOP;
    localparam N_DIAG_X_END   = N_RIGHT_WIN - STROKE_THICKNESS;
    localparam N_DIAG_Y_END   = TEXT_Y_BOTTOM -1;

    localparam N_DIAG_DX = N_DIAG_X_END - N_DIAG_X_START;
    localparam N_DIAG_DY = N_DIAG_Y_END - N_DIAG_Y_START;
    localparam N_DIAG_THRESHOLD = (((N_DIAG_DY > N_DIAG_DX) ? N_DIAG_DY : N_DIAG_DX) > 0 ? ((N_DIAG_DY > N_DIAG_DX) ? N_DIAG_DY : N_DIAG_DX) * STROKE_THICKNESS / 2 : STROKE_THICKNESS);


    // Variables para el dibujo
    logic board_area;
    logic [2:0] current_col, visual_row, data_row;
    logic cell_area;
    logic player1_chip, player2_chip;
    logic winning_chip;
    logic highlight_col;
    logic preview_chip;
    logic board_frame;

    // Señales para control de pantalla y texto
    logic is_initial_screen;
    logic in_title_area_start_screen;
    logic show_win_text;
    logic pixel_is_W, pixel_is_I, pixel_is_N_win;

    // --- Coordenadas y Lógica de Pantalla de Inicio (Ejemplo de área) ---
    localparam TITLE_RECT_X_START = start_x + board_width/4;
    localparam TITLE_RECT_X_END   = start_x + 3*board_width/4;
    localparam TITLE_RECT_Y_START = start_y + board_height/3; // Un poco más abajo
    localparam TITLE_RECT_Y_END   = start_y + 2*board_height/3;

    assign is_initial_screen = (current_state == 4'b0000); // P_INICIO
    assign in_title_area_start_screen = is_initial_screen &&
                                        (x_pos >= TITLE_RECT_X_START && x_pos < TITLE_RECT_X_END) &&
                                        (y_pos >= TITLE_RECT_Y_START && y_pos < TITLE_RECT_Y_END);

    // --- Lógica de cálculo de coordenadas visuales y de datos ---
    assign current_col = (x_pos >= start_x && x_pos < start_x + board_width) ? (x_pos - start_x) / (cell_size + gap) : 3'bxxx;
    assign visual_row  = (y_pos >= start_y && y_pos < start_y + board_height) ? (y_pos - start_y) / (cell_size + gap) : 3'bxxx;
    assign data_row = 5 - visual_row;

    // --- Lógica de áreas y detección de fichas/líneas ---
    assign cell_area = (visual_row < 6) && (current_col < 7) && (x_pos >= start_x + current_col*(cell_size + gap)) && (x_pos < start_x + current_col*(cell_size + gap) + cell_size) && (y_pos >= start_y + visual_row*(cell_size + gap)) && (y_pos < start_y + visual_row*(cell_size + gap) + cell_size);
    assign board_frame = (x_pos >= start_x - gap) && (x_pos < start_x + board_width + gap) && (y_pos >= start_y - gap) && (y_pos < start_y + board_height + gap) && !cell_area;
    assign player1_chip = cell_area && (grid_state[(data_row*7 + current_col)*2 +: 2] == 2'b01);
    assign player2_chip = cell_area && (grid_state[(data_row*7 + current_col)*2 +: 2] == 2'b10);
    assign preview_chip = (current_state == 4'b0011 || current_state == 4'b0101) && (x_pos >= start_x + selected_col * (cell_size + gap)) && (x_pos <  start_x + selected_col * (cell_size + gap) + cell_size) && (y_pos >= start_y - cell_size) && (y_pos <  start_y);
    assign highlight_col = (x_pos >= start_x + selected_col * (cell_size + gap)) && (x_pos <  start_x + selected_col * (cell_size + gap) + cell_size) && (y_pos >= start_y - 10) && (y_pos < start_y);
    assign winning_chip = cell_area && ((winning_line[5:3] == data_row && winning_line[2:0] <= current_col && current_col <= winning_line[14:12]) || (winning_line[2:0] == current_col && winning_line[5:3] <= data_row && data_row <= winning_line[17:15]) || (data_row - winning_line[5:3] == current_col - winning_line[2:0] && winning_line[5:3] <= data_row && data_row <= winning_line[17:15]) || (data_row - winning_line[5:3] == winning_line[2:0] - current_col && winning_line[5:3] >= data_row && data_row >= winning_line[17:15]));

    // --- Lógica para texto "WIN" ---
    assign show_win_text = (current_state == 4'b1000); // GAME_OVER

    // Variables para las ecuaciones de línea de cada segmento de la W
    logic signed [15:0] err_w1, err_w2, err_w3, err_w4;
    logic signed [15:0] abs_err_w1, abs_err_w2, abs_err_w3, abs_err_w4;
    logic on_segment1, on_segment2, on_segment3, on_segment4;

    // Segmento 1 de W: \ desde (W_X0, TEXT_Y_TOP) hasta (W_X1, TEXT_Y_BOTTOM-1)
    assign err_w1 = (y_pos - TEXT_Y_TOP)  * W_DX_SEG - (x_pos - W_X0) * W_DY_SEG_EFFECTIVE;
    assign abs_err_w1 = (err_w1 < 0) ? -err_w1 : err_w1;
    assign on_segment1 = (x_pos >= W_X0 && x_pos <= W_X1) &&
                         (y_pos >= TEXT_Y_TOP && y_pos < TEXT_Y_BOTTOM) &&
                         (abs_err_w1 < W_LINE_THRESHOLD);

    // Segmento 2 de W: / desde (W_X1, TEXT_Y_BOTTOM-1) hasta (W_X2, TEXT_Y_TOP)
    assign err_w2 = (y_pos - (TEXT_Y_BOTTOM-1)) * W_DX_SEG - (x_pos - W_X1) * (-W_DY_SEG_EFFECTIVE);
    assign abs_err_w2 = (err_w2 < 0) ? -err_w2 : err_w2;
    assign on_segment2 = (x_pos >= W_X1 && x_pos <= W_X2) &&
                         (y_pos >= TEXT_Y_TOP && y_pos < TEXT_Y_BOTTOM) &&
                         (abs_err_w2 < W_LINE_THRESHOLD);

    // Segmento 3 de W: \ desde (W_X2, TEXT_Y_TOP) hasta (W_X3, TEXT_Y_BOTTOM-1)
    assign err_w3 = (y_pos - TEXT_Y_TOP)  * W_DX_SEG - (x_pos - W_X2) * W_DY_SEG_EFFECTIVE;
    assign abs_err_w3 = (err_w3 < 0) ? -err_w3 : err_w3;
    assign on_segment3 = (x_pos >= W_X2 && x_pos <= W_X3) &&
                         (y_pos >= TEXT_Y_TOP && y_pos < TEXT_Y_BOTTOM) &&
                         (abs_err_w3 < W_LINE_THRESHOLD);

    // Segmento 4 de W: / desde (W_X3, TEXT_Y_BOTTOM-1) hasta (W_X4, TEXT_Y_TOP)
    assign err_w4 = (y_pos - (TEXT_Y_BOTTOM-1)) * W_DX_SEG - (x_pos - W_X3) * (-W_DY_SEG_EFFECTIVE);
    assign abs_err_w4 = (err_w4 < 0) ? -err_w4 : err_w4;
    assign on_segment4 = (x_pos >= W_X3 && x_pos <= W_X4) &&
                         (y_pos >= TEXT_Y_TOP && y_pos < TEXT_Y_BOTTOM) &&
                         (abs_err_w4 < W_LINE_THRESHOLD);

    assign pixel_is_W = show_win_text &&
                        (x_pos >= W_LEFT_WIN && x_pos < W_RIGHT_WIN && y_pos >= TEXT_Y_TOP && y_pos < TEXT_Y_BOTTOM) &&
                        (on_segment1 || on_segment2 || on_segment3 || on_segment4);

    // Lógica para 'I'
    assign pixel_is_I = show_win_text &&
                        (x_pos >= I_LEFT_WIN && x_pos < I_RIGHT_WIN && y_pos >= TEXT_Y_TOP && y_pos < TEXT_Y_BOTTOM) &&
                        (x_pos >= I_LEFT_WIN + TEXT_LETTER_WIDTH/2 - STROKE_THICKNESS/2 &&
                         x_pos <  I_LEFT_WIN + TEXT_LETTER_WIDTH/2 + STROKE_THICKNESS/2 + (STROKE_THICKNESS%2));

    // Lógica para 'N'
    logic signed [15:0] err_n_diag;
    logic signed [15:0] abs_err_n_diag;
    logic on_n_vertical_left, on_n_vertical_right, on_n_diagonal;

    assign on_n_vertical_left  = (x_pos >= N_LEFT_WIN && x_pos < N_LEFT_WIN + STROKE_THICKNESS);
    assign on_n_vertical_right = (x_pos >= N_RIGHT_WIN - STROKE_THICKNESS && x_pos < N_RIGHT_WIN);

    assign err_n_diag = (y_pos - N_DIAG_Y_START) * N_DIAG_DX - (x_pos - N_DIAG_X_START) * N_DIAG_DY;
    assign abs_err_n_diag = (err_n_diag < 0) ? -err_n_diag : err_n_diag;
    assign on_n_diagonal = (x_pos >= N_DIAG_X_START && x_pos <= N_DIAG_X_END) &&
                           (y_pos >= N_DIAG_Y_START && y_pos <= N_DIAG_Y_END) && // y_pos <= N_DIAG_Y_END para incluir el último punto
                           (abs_err_n_diag < N_DIAG_THRESHOLD);

    assign pixel_is_N_win = show_win_text &&
                            (x_pos >= N_LEFT_WIN && x_pos < N_RIGHT_WIN && y_pos >= TEXT_Y_TOP && y_pos < TEXT_Y_BOTTOM) &&
                            (on_n_vertical_left || on_n_vertical_right || on_n_diagonal);


    // --- Generación de colores REESTRUCTURADA ---
// --- Generación de colores REESTRUCTURADA (Intento 2) ---
    always_comb begin
        // Paso 1: Establecer color de fondo base por defecto
        red   = 8'h00; // Negro por defecto
        green = 8'h00;
        blue  = 8'h00;

        // Paso 2: Determinar si es pantalla de inicio y aplicar su fondo/elementos
        if (is_initial_screen) begin // current_state == P_INICIO
            red   = 8'h10; // Fondo azul oscuro para pantalla de inicio
            green = 8'h10;
            blue  = 8'h40;
            if (in_title_area_start_screen) begin // Área del título en pantalla de inicio
                red   = 8'hDD; // Naranja claro
                green = 8'h8C;
                blue  = 8'h31;
            end
        end
        // Paso 3: Si NO es pantalla de inicio, dibujar elementos del juego y/o pantalla de Game Over
        else begin
            // A. Dibujar elementos base del juego (tablero, fichas)
            if (board_frame) begin
                red   = 8'h00;
                green = 8'h00;
                blue  = 8'h7F; // Marco azul
            end

            if (cell_area) begin // Si estamos dentro de una celda del tablero
                if (grid_state[(data_row*7 + current_col)*2 +: 2] == 2'b00) begin // Celda vacía
                    red   = 8'hFF;
                    green = 8'hFF;
                    blue  = 8'hFF; // Celda vacía blanca
                end
                else if (grid_state[(data_row*7 + current_col)*2 +: 2] == 2'b01) begin // Ficha P1
                    if (winning_chip) begin
                        red   = 8'hFF; // Amarillo (P1 ganadora)
                        green = 8'hFF;
                        blue  = 8'h00;
                    end else begin
                        red   = 8'hFF; // Rojo (P1 normal)
                        green = 8'h00;
                        blue  = 8'h00;
                    end
                end
                else if (grid_state[(data_row*7 + current_col)*2 +: 2] == 2'b10) begin // Ficha P2
                    if (winning_chip) begin
                        red   = 8'hFF; // Amarillo (P2 ganadora)
                        green = 8'hFF;
                        blue  = 8'h00;
                    end else begin
                        red   = 8'h00; // Verde (P2 normal)
                        green = 8'hFF;
                        blue  = 8'h00;
                    end
                end
            end // Fin if (cell_area)

            // B. Superponer highlight y preview (si no es Game Over o si quieres que se vean debajo del texto WIN)
            //    Si current_state NO es GAME_OVER, entonces dibuja highlight y preview.
            if (current_state != 4'b1000) begin // No es GAME_OVER
                 if (highlight_col) begin
                    red   = 8'h00;
                    green = 8'hC0; // Verde claro para highlight
                    blue  = 8'h00;
                end
                if (preview_chip) begin // preview_chip ya chequea estado ESPERANDO_Px
                   red   = 8'hA0; // Preview gris tenue
                   green = 8'hA0;
                   blue  = 8'hA0;
                end
            end

            // C. Superponer texto "WIN" si es GAME_OVER
            if (show_win_text) begin // show_win_text es true si current_state == GAME_OVER
                // Opcional: si quieres un fondo diferente DETRÁS del texto "WIN" pero encima del tablero
                // if (! (pixel_is_W || pixel_is_I || pixel_is_N_win) ) begin
                //     red = red >> 1; green = green >> 1; blue = blue >> 1; // Oscurece el tablero
                // end

                if (pixel_is_W || pixel_is_I || pixel_is_N_win) begin
                    red   = 8'hFF; // Texto "WIN" Amarillo Brillante
                    green = 8'hFF;
                    blue  = 8'h30;
                end
            end // Fin if (show_win_text)
        end // Fin else (no es pantalla de inicio)
    end // always_comb

endmodule