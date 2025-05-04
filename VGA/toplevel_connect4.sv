/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo PRINCIPAL para Connect 4 (Versión corregida final con Debounce)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module toplevel_connect4 (
    input clk,
    input rst,
    // Entradas del jugador 1 (FPGA) - RAW inputs from physical buttons
    input raw_col_left,
    input raw_col_right,
    input raw_confirm,
    input raw_start_game,      // Botón para iniciar el juego
    input raw_player1_start,   // Botón para elegir jugador 1
    input raw_player2_start,   // Botón para elegir jugador 2
    // Comunicación con Arduino
    input arduino_rx,
    // Salidas VGA
    output vgaclk,
    output hsync,
    output vsync,
    output sync_b,
    output blank_b,
    output [7:0] r,
    output [7:0] g,
    output [7:0] b,
    // Salidas a displays
    output [6:0] segments,
    // Indicadores de estado
    output p1_led,
    output p2_led,
    output game_over_led,
    // Debug
    output [3:0] estado
);

    // --- Señales Debounced ---
    logic col_left;
    logic col_right;
    logic confirm;
    logic start_game;
    logic player1_start;
    logic player2_start;

    // --- Instancias de Debounce ---
    // Asume que tienes un clk base (e.g., 50MHz o 100MHz) para el debounce
    // Ajusta Slow_Clock_Enable si tu clk principal es diferente
    Button_debounce #( .CLK_FREQ(50_000_000), .STABLE_TIME_MS(10) ) debounce_left (
    .clk(clk),
    .rst(rst), // Conectar el reset (activo alto)
    .button_in(raw_col_left),
    .button_out(col_left) // Usar puerto de salida correcto
	 );
	 Button_debounce #( .CLK_FREQ(50_000_000), .STABLE_TIME_MS(10) ) debounce_right (
		 .clk(clk),
		 .rst(rst),
		 .button_in(raw_col_right),
		 .button_out(col_right)
	 );
	 Button_debounce #( .CLK_FREQ(50_000_000), .STABLE_TIME_MS(10) ) debounce_confirm (
	 	 .clk(clk),
	 	 .rst(rst),
	 	 .button_in(raw_confirm),
	 	 .button_out(confirm)
	 );
	 Button_debounce #( .CLK_FREQ(50_000_000), .STABLE_TIME_MS(10) ) debounce_start (
	 	 .clk(clk),
	 	 .rst(rst),
	 	 .button_in(raw_start_game),
	 	 .button_out(start_game) // Asegúrate que esta señal existe si usas un botón dedicado 'start_game'
	 );
	  Button_debounce #( .CLK_FREQ(50_000_000), .STABLE_TIME_MS(10) ) debounce_p1 (
	 	 .clk(clk),
	 	 .rst(rst),
	 	 .button_in(raw_player1_start),
	 	 .button_out(player1_start)
	 );
	 Button_debounce #( .CLK_FREQ(50_000_000), .STABLE_TIME_MS(10) ) debounce_p2 (
		 .clk(clk),
		 .rst(rst),
		 .button_in(raw_player2_start),
		 .button_out(player2_start)
	 );

    // --- Resto de señales internas ---
    logic [9:0] x, y;
    logic [83:0] matrix;
    logic [2:0] selected_col;
    logic load_matrix, move_valid;
    logic [3:0] timer_count;
    logic timer_done;
    logic winner_found, board_full;
    logic [23:0] winning_line;
    logic player_won;
    logic arduino_move_ready;
    logic [2:0] arduino_col;
    logic random_move, random_move_valid;
    logic [2:0] random_col;
    logic [6:0] valid_columns;
    logic reset_timer;
    logic [1:0] current_player;
    logic [83:0] matrix_in; // Cambiado a 84 bits
    logic [7:0] red_game, green_game, blue_game;
    logic [7:0] red_start, green_start, blue_start;

    // Reloj VGA
    pll vgapll(.inclk0(clk), .c0(vgaclk));

    // Controlador VGA
    vgaController vgaCont(
        .vgaclk(vgaclk),
        .hsync(hsync),
        .vsync(vsync),
        .sync_b(sync_b),
        .blank_b(blank_b),
        .x(x),
        .y(y)
    );

    // FSM - Ahora usa señales debounced
    connect4_fsm fsm(
        .clk(clk),
        .rst(rst),
        // .player1_start(start_game), // Si 'start_game' es el único botón de inicio
        .player1_start(player1_start), // Usa las señales debounced
        .player2_start(player2_start), // Usa las señales debounced
	.move_valid(move_valid || random_move_valid || arduino_move_ready),
        .arduino_ready(arduino_move_ready),
        .winner_found(winner_found),
        .board_full(board_full),
        .timer_done(timer_done),
        .reset_timer(reset_timer),
        .p1_turn(p1_led),
        .p2_turn(p2_led),
        .game_over(game_over_led),
        .estado(estado),
        .random_move(random_move),
        .player(current_player)
    );

    // Control de la matriz - Ahora usa señales debounced
    matrixTableroControl matrixCtrl(
        .clk(clk),
        .rst_n(~rst),
        .col_left(col_left),     // Usa señal debounced
        .col_right(col_right),   // Usa señal debounced
        .confirm(confirm),       // Usa señal debounced
        .arduino_move(arduino_move_ready),
        .arduino_col(arduino_col),
        .current_state(estado),
        .matrix_in(matrix),      // Conecta matrix (salida del registro) aquí
        .matrix_out(matrix_in),  // Salida hacia el registro
        .selected_col(selected_col),
        .load(load_matrix),
        .move_valid(move_valid),
        .random_move_valid(random_move_valid), // Necesita entrada para el control
        .random_col(random_col)                // Necesita entrada para el control
    );

    // Registro de la matriz
    matrixTablero matrixReg(
        .clk(clk),
        .rst_n(~rst),
        .data_in(matrix_in),  // Entrada desde matrixCtrl
        .load(load_matrix),
        // Determina la columna basada en si es movimiento aleatorio o seleccionado
        .column(random_move_valid ? random_col : (arduino_move_ready ? arduino_col : selected_col)),
        .player(current_player[0]), // player[0] es 0 para P1 (01), 1 para P2 (10)
        .matrix(matrix)       // Salida del estado actual de la matriz
    );

    // Detección de ganador
    winner_detection winnerDetect(
        .grid(matrix),
        .winner_found(winner_found),
        .player_won(player_won),
        .winning_line(winning_line)
    );

    // Temporizador
    Full_Timer timer(
        .clk_in(clk),
        .rst_in(reset_timer), // La FSM controla el reset del timer
        .done(timer_done),
        .count_out(timer_count)
    );

    // Display BCD
    BCD_Visualizer segDisplay(
        .bin(timer_count),
        .seg(segments)
    );

    // Interfaz Arduino
    arduino_interface arduino(
        .clk(clk),
        .rst_n(~rst),
        .rx_data(arduino_rx),
        .column(arduino_col),
        .move_ready(arduino_move_ready),
        .error() // Conectar si se necesita manejar errores UART
    );

    // Movimiento aleatorio
    random_selector randomSel(
        .clk(clk),
        .rst_n(~rst),
        .valid_cols(valid_columns),
        .generate_move(random_move), // Señal desde la FSM
        .random_col(random_col),
        .valid_move(random_move_valid)
    );

    // Lógica para determinar columnas válidas (basado en la fila superior)
    assign valid_columns = {
        (matrix[(5*7 + 6)*2 +: 2] == 2'b00), // Col 6
        (matrix[(5*7 + 5)*2 +: 2] == 2'b00), // Col 5
        (matrix[(5*7 + 4)*2 +: 2] == 2'b00), // Col 4
        (matrix[(5*7 + 3)*2 +: 2] == 2'b00), // Col 3
        (matrix[(5*7 + 2)*2 +: 2] == 2'b00), // Col 2
        (matrix[(5*7 + 1)*2 +: 2] == 2'b00), // Col 1
        (matrix[(5*7 + 0)*2 +: 2] == 2'b00)  // Col 0
    };

    // Video del juego
    videoGen vgaGen(
        .clk(clk), // Usar clk principal, no vgaclk para la lógica
        .rst_n(~rst),
        .x_pos(x),
        .y_pos(y),
        .grid_state(matrix),
        .current_state(estado),
        .selected_col(selected_col),
        .winning_line(winning_line),
        .red(red_game),
        .green(green_game),
        .blue(blue_game)
    );

    // Pantalla de inicio
    startScreen splash(
        .x(x),
        .y(y),
        .visible(estado == 4'b0000),  // Visible solo en P_INICIO
        .r(red_start),
        .g(green_start),
        .b(blue_start)
    );

    // Selección de color VGA según el estado
    assign r = (blank_b) ? ((estado == 4'b0000) ? red_start : red_game) : 8'h00;
    assign g = (blank_b) ? ((estado == 4'b0000) ? green_start : green_game) : 8'h00;
    assign b = (blank_b) ? ((estado == 4'b0000) ? blue_start : blue_game) : 8'h00;

    // Tablero lleno (Verifica si todas las celdas de la fila superior están ocupadas)
    assign board_full = &valid_columns; // Simplificado: si no hay columnas válidas, está lleno

endmodule
