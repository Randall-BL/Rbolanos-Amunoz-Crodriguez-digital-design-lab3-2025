/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo PRINCIPAL para Connect 4 (Versión corregida)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module toplevel_connect4 (
    input clk, 
    input rst,
    // Entradas del jugador 1 (FPGA)
    input col_left, 
    input col_right, 
    input confirm,
    input player1_start, 
    input player2_start,
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

    // Señales internas
    wire [9:0] x, y;
    wire [83:0] matrix;
    wire [2:0] selected_col;
    wire load_matrix, move_valid;
    wire [3:0] timer_count;
    wire timer_done;
    wire winner_found, board_full;
    wire [23:0] winning_line;
    wire player_won;
    wire arduino_move_ready;
    wire [2:0] arduino_col;
    wire random_move, random_move_valid;
    wire [2:0] random_col;
    wire [6:0] valid_columns;
    wire reset_timer;
    wire [1:0] current_player;  // Cambiado a 2 bits explícitamente
    wire [41:0] matrix_in;      // Añadida declaración explícita
    
    // Generación de reloj VGA (25.175 MHz)
    pll vgapll(.inclk0(clk), .c0(vgaclk));
    
    // Instancia del controlador VGA
    vgaController vgaCont(
        .vgaclk(vgaclk),
        .hsync(hsync),
        .vsync(vsync),
        .sync_b(sync_b),
        .blank_b(blank_b),
        .x(x),
        .y(y)
    );
    
    // Instancia de la FSM
    connect4_fsm fsm(
        .clk(clk),
        .rst(rst),
        .player1_start(player1_start),
        .player2_start(player2_start),
        .move_valid(move_valid || random_move_valid),
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
    
    // Instancia del controlador de matriz
	matrixTableroControl matrixCtrl(
		 .clk(clk),
		 .rst_n(~rst),
		 .col_left(col_left),
		 .col_right(col_right),
		 .confirm(confirm),
		 .arduino_move(arduino_move_ready),
		 .arduino_col(arduino_col),
		 .current_state(estado),
		 .matrix_in(matrix),
		 .matrix_out(matrix_in),
		 .selected_col(selected_col),
		 .load(load_matrix),
		 .move_valid(move_valid),
		 // NUEVO:
		 .random_move_valid(random_move_valid),
		 .random_col(random_col)
	);

    
    // Instancia de la matriz
    matrixTablero matrixReg(
        .clk(clk),
        .rst_n(~rst),
        .data_in(matrix_in),
        .load(load_matrix),
        .column(random_move_valid ? random_col : selected_col),
        .player(current_player[0]), // Usar solo el bit 0
        .matrix(matrix)
    );
    
    // Instancia del detector de ganador
    winner_detection winnerDetect(
        .grid(matrix),
        .winner_found(winner_found),
        .player_won(player_won),
        .winning_line(winning_line)
    );
    
    // Instancia del temporizador
    Full_Timer timer(
        .clk_in(clk),
        .rst_in(reset_timer),
        .done(timer_done),
        .count_out(timer_count)
    );
    
    // Instancia del visualizador BCD
    BCD_Visualizer segDisplay(
        .bin(timer_count),
        .seg(segments)
    );
    
    // Instancia de la interfaz Arduino
    arduino_interface arduino(
        .clk(clk),
        .rst_n(~rst),
        .rx_data(arduino_rx),
        .column(arduino_col),
        .move_ready(arduino_move_ready),
        .error()
    );
    
    // Instancia del selector aleatorio
    random_selector randomSel(
        .clk(clk),
        .rst_n(~rst),
        .valid_cols(valid_columns),
        .generate_move(random_move),
        .random_col(random_col),
        .valid_move(random_move_valid)
    );
    
    // Calcular columnas válidas
    assign valid_columns = {
        (matrix[(5*7 + 6)*2 +: 2] == 2'b00),  // Columna 6
        (matrix[(5*7 + 5)*2 +: 2] == 2'b00),  // Columna 5
        (matrix[(5*7 + 4)*2 +: 2] == 2'b00),  // Columna 4
        (matrix[(5*7 + 3)*2 +: 2] == 2'b00),  // Columna 3
        (matrix[(5*7 + 2)*2 +: 2] == 2'b00),  // Columna 2
        (matrix[(5*7 + 1)*2 +: 2] == 2'b00),  // Columna 1
        (matrix[(5*7 + 0)*2 +: 2] == 2'b00)   // Columna 0
    };
    
    // Instancia del generador de video
    videoGen vgaGen(
        .clk(clk),
        .rst_n(~rst),
        .x_pos(x),
        .y_pos(y),
        .grid_state(matrix),
        .current_state(estado),
        .selected_col(selected_col),
        .winning_line(winning_line),
        .red(r),
        .green(g),
        .blue(b)
    );
    
    // Detectar tablero lleno (todas las celdas ocupadas)
    assign board_full = &matrix; // AND de todos los bits (si todos son 1, está lleno)
    
endmodule