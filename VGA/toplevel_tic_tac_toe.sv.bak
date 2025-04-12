module toplevel_tic_tac_toe (
    input logic CLOCK_50,        // Reloj de la FPGA (50 MHz)
    input logic [1:0] SW,        // Switches para el modo de juego
    input logic [3:0] KEY,       // Botones (KEY[0]: Reset, KEY[1]: Jugada)
    output logic [9:0] LEDR,     // LEDs para visualizar el tablero y turno
    output logic [6:0] HEX0      // 7 segmentos para el temporizador
);

    // Señales internas
    logic clk;
    logic reset;
    logic move_made;
    logic time_expired;
    logic victory;
    logic full_board;
    
    // Señales de salida de la MEF
    logic [2:0] state;
    logic player_turn;
    logic [8:0] board;
    logic game_over;
    logic random_move;

    // Instanciar la máquina de estados finita (FSM)
    tic_tac_toe_fsm fsm_inst (
        .clk(clk),
        .reset(reset),
        .mode(SW),
        .move_made(move_made),
        .time_expired(time_expired),
        .victory(victory),
        .full_board(full_board),
        .state(state),
        .player_turn(player_turn),
        .board(board),
        .game_over(game_over),
        .random_move(random_move)
    );

    // Generar un reloj más lento a partir del reloj de 50 MHz
    reg [25:0] clk_div;
    always_ff @(posedge CLOCK_50) begin
        clk_div <= clk_div + 1;
    end
    assign clk = clk_div[24];  // Reloj de aproximadamente 1 Hz (lento)

    // Mapeo de los botones
    assign reset = ~KEY[0];        // KEY[0] como señal de reset
    assign move_made = ~KEY[1];    // KEY[1] como señal de jugada

    // Visualización del tablero en los LEDs
    assign LEDR[8:0] = board;
    assign LEDR[9] = player_turn;  // Turno actual (Jugador 1: apagado, Jugador 2/PC: encendido)

    // Temporizador en HEX0 (simulación del temporizador de 15 segundos)
    reg [3:0] counter;
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            counter <= 4'd15;  // Reiniciar el contador a 15 segundos
        else if (move_made)
            counter <= 4'd15;  // Reiniciar cada vez que se hace una jugada
        else if (counter > 0)
            counter <= counter - 1;
    end

    // Decodificación del contador para mostrar en 7 segmentos
    always_comb begin
        case (counter)
            4'd0: HEX0 = 7'b1000000; // 0
            4'd1: HEX0 = 7'b1111001; // 1
            4'd2: HEX0 = 7'b0100100; // 2
            4'd3: HEX0 = 7'b0110000; // 3
            4'd4: HEX0 = 7'b0011001; // 4
            4'd5: HEX0 = 7'b0010010; // 5
            4'd6: HEX0 = 7'b0000010; // 6
            4'd7: HEX0 = 7'b1111000; // 7
            4'd8: HEX0 = 7'b0000000; // 8
            4'd9: HEX0 = 7'b0010000; // 9
            default: HEX0 = 7'b1111111; // Apagado
        endcase
    end

    // Simulación de las señales de victoria y empate (esto se cambiará con la lógica del juego)
    assign victory = (board[0] & board[1] & board[2]);  // Ganar en fila superior (Ejemplo)
    assign full_board = &board;  // Si todas las casillas están ocupadas

endmodule