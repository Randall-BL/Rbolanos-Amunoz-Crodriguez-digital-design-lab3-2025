
////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo encargado de tener la declaracion y manejo de estados (Definicion de la FSM)
////////////////////////////////////////////////////////////////////////////////////////////////////////


module tic_tac_toe_fsm(
    input logic I, T, W, A, PLAYER_1, PLAYER_2, NEXT, TEST, rst, clk, finished, matrix_complete, 
	 output logic reset_timer, reset_done, 
    output logic [3:0] estado,  // Salida de estado
    output logic led_p1, led_p2  // LEDs para indicar turno de los jugadores
);

    // Definición de los estados
    typedef enum logic [3:0] {
        P_INICIO = 4'b0000,   // Pantalla Inicial
        TABLERO = 4'b0001,    // Pantalla del tablero
        TURNO_P1 = 4'b0010,   // Turno del jugador 1
        TURNO_P2 = 4'b0011,   // Turno del jugador 2
        CHECK_WIN = 4'b0100,  // Revisión del ganador
        GAME_OVER = 4'b0101   // Juego terminado
    } state_t;

    state_t current_state, next_state, prev_state;

    // Actualización de estado y control del temporizador
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= P_INICIO;
            reset_timer <= 1'b1; // Resetear el temporizador al iniciar
            reset_done <= 1'b0;  // Asegurarse de que no se ha completado el reset
        end else begin
            current_state <= next_state;

            case (next_state)
                // Reseteamos el temporizador en TABLERO
                TABLERO: begin
                    reset_timer <= 1'b1;
                    reset_done <= 1'b0;
                end
                // En TURNO_P1 y TURNO_P2, el temporizador cuenta hasta F y cambia de turno
                TURNO_P1, TURNO_P2: begin
                    if (!reset_done) begin
                        reset_timer <= 1'b1;  // Reseteamos el temporizador al cambiar de turno
                        reset_done <= 1'b1;
                    end else begin
                        reset_timer <= 1'b0;  // Permitimos que el temporizador cuente
                    end
                end
                default: begin
                    reset_timer <= 1'b0;
                    reset_done <= 1'b0;
                end
            endcase
        end
    end

    // Lógica de transición de estados
    always_comb begin
        next_state = current_state;
        case (current_state)
            P_INICIO: begin
                if (T)
                    next_state = TABLERO;
                else
                    next_state = P_INICIO;
            end
            TABLERO: begin
                if (PLAYER_1)
                    next_state = TURNO_P1;
                else if (PLAYER_2)
                    next_state = TURNO_P2;
            end
            TURNO_P1: begin
                if (finished)   // Cambiar de turno si el temporizador llega a F
                    next_state = TURNO_P2;
					 else
						  next_state = TURNO_P1;
            end
            TURNO_P2: begin
                if (finished) // Cambiar de turno si el temporizador llega a F
                    next_state = CHECK_WIN;
                else 
                    next_state = TURNO_P2;
            end
            CHECK_WIN: begin
                if (!NEXT)
                    next_state = TURNO_P1;
						  
                else if (matrix_complete)  //Condicion de finalizar juego (si el tablero esta lleno)
                    next_state = GAME_OVER;
            end
            GAME_OVER: begin
                if (A)
                    next_state = P_INICIO;
            end
            default: next_state = P_INICIO;
        endcase
    end

    // Lógica de salida (estado)
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            estado <= 4'b0000;
        else
            estado <= current_state;
    end
    
    // Control de los LEDs de los jugadores 
	 always_ff @(posedge clk or posedge rst) begin
		 if (rst) begin
			 led_p1 <= 1'b1;  // Inicializamos los LEDs encendidos
			 led_p2 <= 1'b1;
		 end else begin
			 case (current_state)
					 TURNO_P1: begin
						 led_p1 <= 1'b1;   // Encendemos el LED del Jugador 1
						 led_p2 <= 1'b0;   // Apagamos el LED del Jugador 2
					 end
					 TURNO_P2: begin
						 led_p1 <= 1'b0;   // Apagamos el LED del Jugador 1
						 led_p2 <= 1'b1;   // Encendemos el LED del Jugador 2
					 end
					 default: begin
						 led_p1 <= 1'b0;   // Apagamos ambos LEDs en cualquier otro estado
						 led_p2 <= 1'b0;
					 end
			 endcase
		 end
	 end

endmodule
