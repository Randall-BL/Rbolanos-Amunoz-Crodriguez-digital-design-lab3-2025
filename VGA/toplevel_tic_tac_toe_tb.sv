

////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo encargado de probar cada uno de los estados de la MEF y sus variables (TESTBENCH)
////////////////////////////////////////////////////////////////////////////////////////////////////////


module tic_tac_toe_fsm_tb;
    // Señales de entrada y salida
    logic I, T, W, A, PLAYER_1, PLAYER_2, NEXT, TEST, rst, clk, finished, matrix_complete; 
    logic reset_timer, reset_done; 
    logic [3:0] estado;  // Salida de estado 
    logic led_p1, led_p2; 

    // Instancia del módulo a probar
    tic_tac_toe_fsm uut (
        .I(I), .T(T), .W(W), .A(A), .PLAYER_1(PLAYER_1), .PLAYER_2(PLAYER_2), 
        .NEXT(NEXT), .TEST(TEST), .rst(rst), .clk(clk), .finished(finished), 
        .matrix_complete(matrix_complete), .reset_timer(reset_timer), .reset_done(reset_done),
        .estado(estado), .led_p1(led_p1), .led_p2(led_p2)
    );

    // Generador de reloj
    always #5 clk = ~clk;

    // Tarea para inicializar señales
    task init_signals();
        I = 0;
        T = 0;
        W = 0;
        A = 0;
        PLAYER_1 = 0;
        PLAYER_2 = 0;
        NEXT = 0;
        TEST = 0;
        rst = 1;
        finished = 0;
        matrix_complete = 0;
        clk = 0;
        #20 rst = 0;  // Aumentamos el tiempo de reset
    endtask

    // Tarea para verificar el estado esperado
    task check_state(input logic [3:0] expected_state);
        $display("Estado actual: %b, Variables: T=%b, PLAYER_1=%b, PLAYER_2=%b, finished=%b, matrix_complete=%b", estado, T, PLAYER_1, PLAYER_2, finished, matrix_complete);
        if (estado != expected_state) 
            $display("Cambio de Estado realizado, esperado: %b, obtenido: %b", expected_state, estado);
        else 
            $display("Estado correcto: %b", estado);
    endtask

    // Tarea para probar transiciones de estado
    task test_transitions();
        // Reseteo inicial
        rst = 1;
        #20;
        rst = 0;

        // Transición de P_INICIO a TABLERO
        T = 1; 
        #20;  // Aumentamos el tiempo para dar margen a la transición
        $display("Transición a TABLERO. Estado esperado: TABLERO");
        check_state(4'b0001); // Debería ser TABLERO

        // Turno del Jugador 1
        PLAYER_1 = 1; 
        #20;  // Aumentamos tiempo
        PLAYER_1 = 0; 
        $display("Jugador 1 ha jugado. Estado esperado: TURNO_P1");
        check_state(4'b0010); // Debería ser TURNO_P1

        // Finalización del turno del Jugador 1
        finished = 1; 
        #20; 
        finished = 0; 
        $display("Finalizando turno de Jugador 1. Estado esperado: TURNO_P2");
        check_state(4'b0011); // Debería ser TURNO_P2

        // Turno del Jugador 2
        PLAYER_2 = 1; 
        #20; 
        PLAYER_2 = 0; 
        $display("Jugador 2 ha jugado. Estado esperado: TURNO_P2");
        check_state(4'b0011); // Debería seguir siendo TURNO_P2

        // Finalización del turno del Jugador 2
        finished = 1; 
        #20; 
        finished = 0; 
        $display("Finalizando turno de Jugador 2. Estado esperado: CHECK_WIN");
        check_state(4'b0100); // Debería ser CHECK_WIN

        // Comprobación de ganador
        NEXT = 0; 
        #20; 
        $display("Volviendo a TURNO_P1. Estado esperado: TURNO_P1");
        check_state(4'b0010); // Debería volver a TURNO_P1

        // Completando el juego
        matrix_complete = 1; 
        #20; 
        $display("Juego completado. Estado esperado: GAME_OVER");
        check_state(4'b0101); // Debería ser GAME_OVER

        // Reseteo a P_INICIO
        A = 1; 
        #20; 
        $display("Reiniciando el juego. Estado esperado: P_INICIO");
        check_state(4'b0000); // Debería ser P_INICIO
    endtask

    // Bloque inicial para ejecutar las pruebas
    initial begin
        init_signals();
        test_transitions();
        $display("Testbench Finalizado");
        $finish;
    end
endmodule
