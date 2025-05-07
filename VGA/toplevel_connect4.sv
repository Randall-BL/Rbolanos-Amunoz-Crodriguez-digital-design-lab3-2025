/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo PRINCIPAL para Connect 4 - Con startScreen y Controles Compartidos
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module toplevel_connect4 (
    input clk,
    input rst, // Reset activo alto

    // --- Entradas RAW Controles Compartidos ---
    input col_left_raw,
    input col_right_raw,
    input confirm_raw,
    // --- Entradas RAW Inicio Separadas ---
    input p1_start_raw,
    input p2_start_raw,

    // --- Salidas VGA ---
    output vgaclk,
    output hsync,
    output vsync,
    output sync_b,
    output blank_b,
    output [7:0] r, // << Salidas finales multiplexadas
    output [7:0] g,
    output [7:0] b,
    // ... (otras salidas: segments, p1_led, p2_led, game_over_led, estado) ...
    output [6:0] segments,
    output p1_led,
    output p2_led,
    output game_over_led,
    output [3:0] estado
);

    // --- PARÁMETROS GLOBALES ---
    localparam CLK_FREQUENCY = 50_000_000; // ¡AJUSTA ESTO!
    localparam DEBOUNCE_MS = 10;

    // --- Señales Internas ---
    wire [9:0] x, y; // Coordenadas desde vgaController
    wire [83:0] matrix;
    wire [2:0] selected_col;
    wire load_matrix;
    wire move_valid;
    wire [3:0] timer_count;
    wire timer_done;
    wire winner_found;
    wire board_full;
    wire [23:0] winning_line;
    wire random_move;
    wire random_move_valid;
    wire [2:0] random_col;
    wire [6:0] valid_columns;
    wire reset_timer;
    wire [1:0] current_player;

    // Señales DEBOUNCED
    wire col_left_debounced;
    wire col_right_debounced;
    wire confirm_debounced;
    wire p1_start_debounced;
    wire p2_start_debounced;

    // --- Señales RGB intermedias para los dos generadores de video ---
    wire [7:0] game_r, game_g, game_b;     // RGB desde videoGen (tablero del juego)
    wire [7:0] start_r, start_g, start_b; // RGB desde startScreen

    logic is_initial_state_active; // Para controlar el multiplexor de video
	 logic is_game_over_state_active; // << NUEVO >>

    // --- Instanciación Anti-Rebote (sin cambios respecto a la última versión) ---
    Button_debounce #(.CLK_FREQ(CLK_FREQUENCY), .STABLE_TIME_MS(DEBOUNCE_MS))
        debounce_shared_left (.clk(clk), .rst(rst), .button_in(col_left_raw), .button_out(col_left_debounced));
    Button_debounce #(.CLK_FREQ(CLK_FREQUENCY), .STABLE_TIME_MS(DEBOUNCE_MS))
        debounce_shared_right(.clk(clk), .rst(rst), .button_in(col_right_raw), .button_out(col_right_debounced));
    Button_debounce #(.CLK_FREQ(CLK_FREQUENCY), .STABLE_TIME_MS(DEBOUNCE_MS))
        debounce_shared_confirm(.clk(clk), .rst(rst), .button_in(confirm_raw), .button_out(confirm_debounced));
    Button_debounce #(.CLK_FREQ(CLK_FREQUENCY), .STABLE_TIME_MS(DEBOUNCE_MS))
        debounce_p1_start(.clk(clk), .rst(rst), .button_in(p1_start_raw), .button_out(p1_start_debounced));
    Button_debounce #(.CLK_FREQ(CLK_FREQUENCY), .STABLE_TIME_MS(DEBOUNCE_MS))
        debounce_p2_start(.clk(clk), .rst(rst), .button_in(p2_start_raw), .button_out(p2_start_debounced));

    // --- Instancia PLL (Sin cambios) ---
    pll vgapll(.inclk0(clk), .c0(vgaclk));

    // --- Instancia Controlador VGA (Sin cambios) ---
    // Genera vgaclk, hsync, vsync, sync_b, blank_b, x, y
    vgaController vgaCont(
        .vgaclk(vgaclk), .hsync(hsync), .vsync(vsync), .sync_b(sync_b),
        .blank_b(blank_b), .x(x), .y(y)
    );

    // --- Instancia FSM (Usa connect4_fsm_2player_fpga) ---
    connect4_fsm fsm(
        .clk(clk), .rst(rst), .player1_start(p1_start_debounced), .player2_start(p2_start_debounced),
        .move_valid(move_valid), .winner_found(winner_found), .board_full(board_full), .timer_done(timer_done),
        .reset_timer(reset_timer), .p1_turn(p1_led), .p2_turn(p2_led), .game_over(game_over_led),
        .estado(estado), .random_move(random_move), .player(current_player)
    );

    // --- Instancia Controlador Matriz (Para controles compartidos) ---
    matrixTableroControl matrixCtrl(
         .clk(clk), .rst_n(~rst), .col_left(col_left_debounced), .col_right(col_right_debounced), .confirm(confirm_debounced),
         .random_move_valid(random_move_valid), .random_col(random_col), .current_state(estado), .matrix_in(matrix),
         .selected_col(selected_col), .load(load_matrix), .move_valid(move_valid)
    );

    // --- Instancia Matriz (Usa gravedad datos 0->5) ---
    matrixTablero matrixReg(
        .clk(clk), .rst_n(~rst), .load(load_matrix), .column(selected_col),
        .player(current_player[0]), .matrix(matrix)
    );

    // --- Instancia Detector Ganador (Sin cambios) ---
    winner_detection winnerDetect(
        .grid(matrix), .winner_found(winner_found), .winning_line(winning_line)
    );

    // --- Instancias Timer, BCD, RandomSel (Sin cambios) ---
    Full_Timer timer(.clk_in(clk), .rst_in(reset_timer), .done(timer_done), .count_out(timer_count));
    BCD_Visualizer segDisplay(.bin(timer_count), .seg(segments));
    random_selector randomSel(.clk(clk), .rst_n(~rst), .valid_cols(valid_columns), .generate_move(random_move), .random_col(random_col), .valid_move(random_move_valid));

    // --- Lógica Columnas Válidas (Sin cambios) ---
    assign valid_columns[6] = (matrix[(5*7 + 6)*2 +: 2] == 2'b00); // Col 6, Fila Datos 5 (VISUALMENTE ARRIBA)
    assign valid_columns[5] = (matrix[(5*7 + 5)*2 +: 2] == 2'b00); // Col 5, Fila Datos 5
    assign valid_columns[4] = (matrix[(5*7 + 4)*2 +: 2] == 2'b00); // Col 4, Fila Datos 5
    assign valid_columns[3] = (matrix[(5*7 + 3)*2 +: 2] == 2'b00); // Col 3, Fila Datos 5
    assign valid_columns[2] = (matrix[(5*7 + 2)*2 +: 2] == 2'b00); // Col 2, Fila Datos 5
    assign valid_columns[1] = (matrix[(5*7 + 1)*2 +: 2] == 2'b00); // Col 1, Fila Datos 5
    assign valid_columns[0] = (matrix[(5*7 + 0)*2 +: 2] == 2'b00); // Col 0, Fila Datos 5


    // --- Instancia Generador Video VGA para el JUEGO ---
    // (Este es tu videoGen.sv que dibuja el tablero, fichas, etc., e invierte visualización)
    videoGen gameBoardDrawer ( // Renombrado para claridad
        .clk(clk),       // O vgaclk, según necesite tu videoGen para su propia lógica interna
        .rst_n(~rst),
        .x_pos(x),
        .y_pos(y),
        .grid_state(matrix),
        .current_state(estado), // Para que videoGen sepa si es P_INICIO, GAME_OVER, etc.
        .selected_col(selected_col),
        .winning_line(winning_line),
        .red(game_r),    // Salida R del dibujador del juego
        .green(game_g),  // Salida G del dibujador del juego
        .blue(game_b)    // Salida B del dibujador del juego
    );

    // --- INSTANCIAR TU MÓDULO startScreen ---
    assign is_initial_state_active = (estado == 4'b0000); // P_INICIO desde FSM
	 assign is_game_over_state_active = (estado == 4'b1000); // GAME_OVER

    startScreen initialScreenDrawer (
        .x(x),                         // Coordenada X desde vgaController
        .y(y),                         // Coordenada Y desde vgaController
        .visible(is_initial_state_active), // Se muestra solo si la FSM está en P_INICIO
        .r(start_r),                   // Salida R de la pantalla de inicio
        .g(start_g),                   // Salida G de la pantalla de inicio
        .b(start_b)                    // Salida B de la pantalla de inicio
    );

    // --- Multiplexor de Salida RGB Final ---
    // Si es el estado inicial, usa los colores de startScreen, si no, los de videoGen (juego)
    assign r = is_initial_state_active ? start_r : game_r;
    assign g = is_initial_state_active ? start_g : game_g;
    assign b = is_initial_state_active ? start_b : game_b;

    // --- Lógica Combinacional: Tablero Lleno (Sin cambios) ---
    assign board_full = (valid_columns == 7'b0) && !winner_found;

endmodule