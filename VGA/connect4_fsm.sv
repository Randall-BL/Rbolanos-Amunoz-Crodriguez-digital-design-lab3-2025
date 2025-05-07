////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo FSM para Connect 4 - Versión Dos Jugadores con Botones FPGA
////////////////////////////////////////////////////////////////////////////////////////////////////////
module connect4_fsm (
    input logic clk, rst,           // Reloj y Reset (activo alto)
    // Entradas de inicio (DEBOUNCED)
    input logic player1_start,
    input logic player2_start,
    // Señales de estado del juego
    input logic move_valid,     // Movimiento válido confirmado (desde matrixCtrl)
    input logic winner_found,   // Hay un ganador (desde winnerDetect)
    input logic board_full,     // Tablero lleno (¡NECESITA LÓGICA EXTERNA!)
    input logic timer_done,     // Temporizador de turno terminado

    // Salidas de control y estado
    output logic reset_timer,   // Resetear temporizador
    output logic p1_turn,       // LED/Indicador turno Jugador 1
    output logic p2_turn,       // LED/Indicador turno Jugador 2
    output logic game_over,     // LED/Indicador juego terminado
    output logic [3:0] estado,  // Estado actual para otros módulos/debug
    output logic random_move,   // Solicitar movimiento aleatorio (si timer expira)
    output logic [1:0] player   // Jugador actual (01=P1, 10=P2) para matrixTablero
);

    // Definición de los estados
    typedef enum logic [3:0] {
        P_INICIO          = 4'b0000, // Pantalla Inicial
        SELECCION_JUGADOR = 4'b0001, // Esperando P1 o P2 para iniciar
        TURNO_P1          = 4'b0010, // Turno del jugador 1 (FPGA)
        ESPERANDO_P1      = 4'b0011, // Esperando confirmación de jugador 1
        TURNO_P2          = 4'b0100, // Turno del jugador 2 (FPGA)
        ESPERANDO_P2      = 4'b0101, // Esperando confirmación de jugador 2
        // FICHA_CAYENDO ahora se asume instantáneo o manejado por la duración del pulso 'load'
        VERIFICAR_GANADOR = 4'b0111, // Revisión del ganador/empate
        GAME_OVER         = 4'b1000  // Juego terminado
        // Otros estados no usados
    } state_t;

    state_t current_state, next_state;
    logic whose_turn; // 0 = P1, 1 = P2 - Para alternar turnos

    // Detectar si alguien quiere iniciar
    wire start_game = player1_start || player2_start;

    // Actualización de estado síncrona y registro de turno
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= P_INICIO;
            whose_turn    <= 1'b0; // P1 empieza por defecto si ambos presionan
        end else begin
            current_state <= next_state;
            // Actualizar de quién es el turno DESPUÉS de verificar ganador
            if (current_state == VERIFICAR_GANADOR && next_state != GAME_OVER) begin
                whose_turn <= ~whose_turn; // Alternar turno
            end
            // Capturar quién empezó si estamos en SELECCION_JUGADOR
            // (Si P2 empieza, el primer turno será de P2)
             else if (current_state == P_INICIO && next_state == SELECCION_JUGADOR) begin
                 if (player2_start && !player1_start) begin // Si SOLO P2 presiona start
                     whose_turn <= 1'b1; // Empieza P2
                 end else begin
                     whose_turn <= 1'b0; // Empieza P1 (si presiona P1 o ambos)
                 end
            end
        end
    end

    // Lógica de transición de estados combinacional
    always_comb begin
        next_state = current_state; // Por defecto, mantener estado

        case (current_state)
            P_INICIO:
                if (start_game)
                    next_state = SELECCION_JUGADOR; // Pasar a determinar turno inicial

            SELECCION_JUGADOR: // Este estado es muy breve, solo para establecer el primer turno
                if (whose_turn == 1'b0) // Si va a empezar P1
                    next_state = TURNO_P1;
                else // Si va a empezar P2
                    next_state = TURNO_P2;

            TURNO_P1:
                next_state = ESPERANDO_P1; // Pasa a esperar input de P1

            ESPERANDO_P1:
                if (move_valid) // Si P1 (o random por timer) confirmó movimiento
                    next_state = VERIFICAR_GANADOR;
                // Si no, sigue esperando

            TURNO_P2:
                next_state = ESPERANDO_P2; // Pasa a esperar input de P2

            ESPERANDO_P2:
                if (move_valid) // Si P2 (o random por timer) confirmó movimiento
                    next_state = VERIFICAR_GANADOR;
                // Si no, sigue esperando

            VERIFICAR_GANADOR:
                if (winner_found || board_full) // Si hay ganador o empate
                    next_state = GAME_OVER;
                else if (whose_turn == 1'b0) // Si el último turno fue de P1 (whose_turn aún no cambia)
                    next_state = TURNO_P2;   // El siguiente es P2
                else // Si el último turno fue de P2
                    next_state = TURNO_P1;   // El siguiente es P1

            GAME_OVER:
                if (start_game) // Permite reiniciar desde GAME_OVER con cualquier botón start
                   next_state = P_INICIO;
                // El reset maestro (rst) también lleva a P_INICIO

            default: next_state = P_INICIO;
        endcase
    end

    // Lógica de salida combinacional
    always_comb begin
        // Valores por defecto EXPLÍCITOS al inicio
        reset_timer = 1'b0;
        p1_turn     = 1'b0;
        p2_turn     = 1'b0;
        game_over   = 1'b0;
        random_move = 1'b0;
        player      = 2'b00; // <<-- Valor por defecto MUY IMPORTANTE

        // Asignaciones específicas por estado
        case (current_state)
            TURNO_P1: begin
                p1_turn     = 1'b1;
                player      = 2'b01; // P1 activo
                reset_timer = 1'b1;
            end
            ESPERANDO_P1: begin
                p1_turn     = 1'b1;
                player      = 2'b01; // P1 activo
                if (timer_done)
                    random_move = 1'b1;
            end

            TURNO_P2: begin
                p2_turn     = 1'b1;
                player      = 2'b10; // P2 activo
                reset_timer = 1'b1;
            end
            ESPERANDO_P2: begin
                p2_turn     = 1'b1;
                player      = 2'b10; // P2 activo
                if (timer_done)
                    random_move = 1'b1;
            end

            GAME_OVER: begin
                game_over = 1'b1;
                // NO se cambia 'player'. Se queda en el default '2'b00'.
                // NO se cambia 'p1_turn' ni 'p2_turn'. Se quedan en 0.
            end

            // Otros estados (P_INICIO, SELECCION, VERIFICAR) usan los defaults.
            default: ;
        endcase
    end

    // Asignar estado a la salida (para debug o visualización)
    assign estado = current_state;

endmodule