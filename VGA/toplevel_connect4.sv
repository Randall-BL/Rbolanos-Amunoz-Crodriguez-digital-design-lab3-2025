/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo PRINCIPAL para Connect 4 - Versión DOS Jugadores con Controles COMPARTIDOS y Anti-Rebote
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module toplevel_connect4 (
    input clk,
    input rst, // Reset activo alto

    // --- Entradas RAW Controles Compartidos ---
    input col_left_raw,    // Bbotón izquierdo para ambos
    input col_right_raw,   // Un solo botón derecho para ambos
    input confirm_raw,     // Un solo botón confirmar para ambos
    // --- Entradas RAW Inicio Separadas ---
    input p1_start_raw,    // Botón inicio Jugador 1
    input p2_start_raw,    // Botón inicio Jugador 2

    // --- Salidas VGA ---
    output vgaclk,
    output hsync,
    output vsync,
    output sync_b,
    output blank_b,
    output [7:0] r,
    output [7:0] g,
    output [7:0] b,
    // --- Salidas a displays BCD ---
    output [6:0] segments,
    // --- Indicadores de estado (LEDs) ---
    output p1_led,         // LED turno Jugador 1
    output p2_led,         // LED turno Jugador 2
    output game_over_led  // LED juego terminado
    // --- Debug ---
);

    // --- PARÁMETROS GLOBALES ---
    localparam CLK_FREQUENCY = 50_000_000; // ¡AJUSTA ESTO!
    localparam DEBOUNCE_MS = 10;

    // --- Señales Internas ---
    // (Sin cambios respecto a la versión anterior de 2 jugadores)
	 wire [3:0] estado;      // Estado actual de la FSM
    wire [9:0] x, y;
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

    // Señales DEBOUNCED Controles Compartidos << CAMBIO >>
    wire col_left_debounced;
    wire col_right_debounced;
    wire confirm_debounced;
    // Señales DEBOUNCED Inicio Separadas (Sin cambios)
    wire p1_start_debounced;
    wire p2_start_debounced;
    // Señales Debounced P2 eliminadas


    // --- Instanciación Anti-Rebote (Controles Compartidos) << CAMBIO >> ---
    Button_debounce #(.CLK_FREQ(CLK_FREQUENCY), .STABLE_TIME_MS(DEBOUNCE_MS))
        debounce_left (.clk(clk), .rst(rst), .button_in(col_left_raw), .button_out(col_left_debounced));
    Button_debounce #(.CLK_FREQ(CLK_FREQUENCY), .STABLE_TIME_MS(DEBOUNCE_MS))
        debounce_right(.clk(clk), .rst(rst), .button_in(col_right_raw), .button_out(col_right_debounced));
    Button_debounce #(.CLK_FREQ(CLK_FREQUENCY), .STABLE_TIME_MS(DEBOUNCE_MS))
        debounce_confirm(.clk(clk), .rst(rst), .button_in(confirm_raw), .button_out(confirm_debounced));

    // --- Instanciación Anti-Rebote (Inicios Separados - Sin cambios) ---
    Button_debounce #(.CLK_FREQ(CLK_FREQUENCY), .STABLE_TIME_MS(DEBOUNCE_MS))
        debounce_p1_start(.clk(clk), .rst(rst), .button_in(p1_start_raw), .button_out(p1_start_debounced));
    Button_debounce #(.CLK_FREQ(CLK_FREQUENCY), .STABLE_TIME_MS(DEBOUNCE_MS))
        debounce_p2_start(.clk(clk), .rst(rst), .button_in(p2_start_raw), .button_out(p2_start_debounced));

    // --- Instancias Anti-Rebote P2 Eliminadas ---


    // --- Instancia PLL (Sin cambios) ---
    pll vgapll(.inclk0(clk), .c0(vgaclk));

    // --- Instancia Controlador VGA (Sin cambios) ---
    vgaController vgaCont(
        .vgaclk(vgaclk), .hsync(hsync), .vsync(vsync), .sync_b(sync_b),
        .blank_b(blank_b), .x(x), .y(y)
    );


    // --- Instancia FSM (Usando la FSM de 2 Jugadores FPGA) << CAMBIO >> ---
    // Asegúrate que el nombre del módulo FSM sea el correcto que tienes definido
    connect4_fsm fsm( // <--- Nombre del módulo FSM de 2 jugadores
        .clk(clk),
        .rst(rst),
        .player1_start(p1_start_debounced), // Inicio P1
        .player2_start(p2_start_debounced), // Inicio P2
        .move_valid(move_valid),          // Pulso desde matrixCtrl
        .winner_found(winner_found),
        .board_full(board_full),
        .timer_done(timer_done),
        .reset_timer(reset_timer),
        .p1_turn(p1_led),               // LED P1
        .p2_turn(p2_led),               // LED P2
        .game_over(game_over_led),
        .estado(estado),
        .random_move(random_move),
        .player(current_player)
    );


    // --- Instancia Controlador Matriz (Usando la versión para controles compartidos) << CAMBIO >> ---
    // Asegúrate que el nombre del módulo sea el correcto y que su definición interna
    // coincida con la que te proporcioné antes (la que usa col_left, col_right, confirm)
    matrixTableroControl matrixCtrl( // <--- Nombre del módulo con controles compartidos
         .clk(clk),
         .rst_n(~rst),
         // Conectar controles compartidos << CAMBIO >>
         .col_left(col_left_debounced),
         .col_right(col_right_debounced),
         .confirm(confirm_debounced),
         // Otros (sin cambios)
         .random_move_valid(random_move_valid),
         .random_col(random_col),
         .current_state(estado),
         .matrix_in(matrix),
         .selected_col(selected_col),
         .load(load_matrix),
         .move_valid(move_valid)
         // Puertos p1_* y p2_* eliminados de la instancia
    );


    // --- Instancia Matriz (Registro Tablero - Sin cambios) ---
    // Usa la versión con gravedad de datos (busca 0->5) que funcionó
    matrixTablero matrixReg(
        .clk(clk),
        .rst_n(~rst),
        .load(load_matrix),
        .column(selected_col),
        .player(current_player[0]), // Conexión correcta
        .matrix(matrix)
    );


    // --- Instancia Detector Ganador (Sin cambios) ---
    winner_detection winnerDetect(
        .grid(matrix), .winner_found(winner_found), .winning_line(winning_line)
    );

    // --- Instancia Temporizador (Sin cambios) ---
    Full_Timer timer(
        .clk_in(clk), .rst_in(reset_timer), .done(timer_done), .count_out(timer_count)
    );

    // --- Instancia Display BCD (Sin cambios) ---
    BCD_Visualizer segDisplay(
        .bin(timer_count), .seg(segments)
    );

    // --- Instancia Selector Aleatorio (Sin cambios) ---
    random_selector randomSel(
        .clk(clk), .rst_n(~rst), .valid_cols(valid_columns),
        .generate_move(random_move), .random_col(random_col), .valid_move(random_move_valid)
    );

    // --- Lógica Columnas Válidas (Sin cambios) ---
    // Comprueba la fila superior VISIBLE (fila 5 de datos)
    assign valid_columns[6] = (matrix[(5*7 + 6)*2 +: 2] == 2'b00);
    assign valid_columns[5] = (matrix[(5*7 + 5)*2 +: 2] == 2'b00);
    assign valid_columns[4] = (matrix[(5*7 + 4)*2 +: 2] == 2'b00);
    assign valid_columns[3] = (matrix[(5*7 + 3)*2 +: 2] == 2'b00);
    assign valid_columns[2] = (matrix[(5*7 + 2)*2 +: 2] == 2'b00);
    assign valid_columns[1] = (matrix[(5*7 + 1)*2 +: 2] == 2'b00);
    assign valid_columns[0] = (matrix[(5*7 + 0)*2 +: 2] == 2'b00);


    // --- Instancia Generador Video VGA (Sin cambios) ---
    // Usa la versión que invierte el mapeo vertical
    videoGen vgaGen(
        .clk(clk), // ¿O necesita vgaclk?
        .rst_n(~rst),
        .x_pos(x), .y_pos(y), .grid_state(matrix), .current_state(estado),
        .selected_col(selected_col), .winning_line(winning_line),
        .red(r), .green(g), .blue(b)
    );


    // --- Lógica Combinacional: Tablero Lleno (Sin cambios) ---
    assign board_full = (valid_columns == 7'b0) && !winner_found;


endmodule