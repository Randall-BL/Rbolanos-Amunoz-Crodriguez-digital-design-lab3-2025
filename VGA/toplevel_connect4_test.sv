/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo PRINCIPAL para Connect 4 en modo automático para pruebas
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module toplevel_connect4_test (
    input clk, 
    input rst,
    // Comunicación con Arduino (no usado aquí)
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
    logic [41:0] matrix_in;

    // Señales de prueba
    logic fake_player1_start;
    logic fake_player2_start;
    logic fake_confirm;
    logic fake_col_left, fake_col_right;

    // Colores intermedios
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

    // FSM automática
    connect4_fsm fsm(
        .clk(clk),
        .rst(rst),
        .player1_start(fake_player1_start),
        .player2_start(fake_player2_start),
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

    // Control de matriz
    matrixTableroControl matrixCtrl(
        .clk(clk),
        .rst_n(~rst),
        .col_left(fake_col_left),
        .col_right(fake_col_right),
        .confirm(fake_confirm),
        .arduino_move(arduino_move_ready),
        .arduino_col(arduino_col),
        .current_state(estado),
        .matrix_in(matrix),
        .matrix_out(matrix_in),
        .selected_col(selected_col),
        .load(load_matrix),
        .move_valid(move_valid),
        .random_move_valid(random_move_valid),
        .random_col(random_col)
    );

    // Registro de la matriz
    matrixTablero matrixReg(
        .clk(clk),
        .rst_n(~rst),
        .data_in(matrix_in),
        .load(load_matrix),
        .column(random_move_valid ? random_col : selected_col),
        .player(current_player[0]),
        .matrix(matrix)
    );

    // Detector de ganador
    winner_detection winnerDetect(
        .grid(matrix),
        .winner_found(winner_found),
        .player_won(player_won),
        .winning_line(winning_line)
    );

    // Timer
    Full_Timer timer(
        .clk_in(clk),
        .rst_in(reset_timer),
        .done(timer_done),
        .count_out(timer_count)
    );

    // Visualizador BCD
    BCD_Visualizer segDisplay(
        .bin(timer_count),
        .seg(segments)
    );

    // Comunicación con Arduino
    arduino_interface arduino(
        .clk(clk),
        .rst_n(~rst),
        .rx_data(arduino_rx),
        .column(arduino_col),
        .move_ready(arduino_move_ready),
        .error()
    );

    // Movimiento aleatorio
    random_selector randomSel(
        .clk(clk),
        .rst_n(~rst),
        .valid_cols(valid_columns),
        .generate_move(random_move),
        .random_col(random_col),
        .valid_move(random_move_valid)
    );

    assign valid_columns = {
        (matrix[(5*7 + 6)*2 +: 2] == 2'b00),
        (matrix[(5*7 + 5)*2 +: 2] == 2'b00),
        (matrix[(5*7 + 4)*2 +: 2] == 2'b00),
        (matrix[(5*7 + 3)*2 +: 2] == 2'b00),
        (matrix[(5*7 + 2)*2 +: 2] == 2'b00),
        (matrix[(5*7 + 1)*2 +: 2] == 2'b00),
        (matrix[(5*7 + 0)*2 +: 2] == 2'b00)
    };

    // Video del juego
    videoGen vgaGen(
        .clk(clk),
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

    // Splash de inicio
    startScreen splash(
        .x(x),
        .y(y),
        .r(red_start),
        .g(green_start),
        .b(blue_start)
    );

    // Selección de colores según el estado
    assign r = (estado == 4'b0000) ? red_start   : red_game;
    assign g = (estado == 4'b0000) ? green_start : green_game;
    assign b = (estado == 4'b0000) ? blue_start  : blue_game;

    // Tablero lleno
    assign board_full = &matrix;

    /////////////////////
    // Entradas forzadas
    /////////////////////
    assign fake_player1_start = 1'b1;    // siempre activado
    assign fake_player2_start = 1'b0;
    assign fake_confirm = 1'b1;           // siempre confirmar
    assign fake_col_left = 1'b0;
    assign fake_col_right = 1'b0;

endmodule
