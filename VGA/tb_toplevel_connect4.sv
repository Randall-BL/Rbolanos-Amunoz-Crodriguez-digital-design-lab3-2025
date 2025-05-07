`timescale 1ns / 1ps

module tb_toplevel_connect4;

    // Inputs
    reg clk;
    reg rst;
    reg raw_col_left;
    reg raw_col_right;
    reg raw_confirm;
    reg raw_start_game;
    reg raw_player1_start;
    reg raw_player2_start;
    reg arduino_rx;

    // Outputs
    wire vgaclk;
    wire hsync;
    wire vsync;
    wire sync_b;
    wire blank_b;
    wire [7:0] r;
    wire [7:0] g;
    wire [7:0] b;
    wire [6:0] segments;
    wire p1_led;
    wire p2_led;
    wire game_over_led;
    wire [3:0] estado;

    // --- Variables Esperadas para Verificación ---
    logic [3:0] expected_estado;
    logic expected_p1_led;
    logic expected_p2_led;
    logic expected_winner_found; // Añadido para verificar winner_found
    string test_step_name; // Para saber qué paso estamos verificando

    // Instantiate the Unit Under Test (UUT)
    toplevel_connect4 uut (
        .clk(clk),
        .rst(rst),
        .raw_col_left(raw_col_left),
        .raw_col_right(raw_col_right),
        .raw_confirm(raw_confirm),
        .raw_start_game(raw_start_game),
        .raw_player1_start(raw_player1_start),
        .raw_player2_start(raw_player2_start),
        .arduino_rx(arduino_rx),
        .vgaclk(vgaclk),
        .hsync(hsync),
        .vsync(vsync),
        .sync_b(sync_b),
        .blank_b(blank_b),
        .r(r),
        .g(g),
        .b(b),
        .segments(segments),
        .p1_led(p1_led),
        .p2_led(p2_led),
        .game_over_led(game_over_led),
        .estado(estado)
    );

    // Clock generation (e.g., 50 MHz -> 20ns period)
    parameter CLK_PERIOD = 20;
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

	 // --- Tarea de Verificación ---
    task check_signals;
        logic check_ok; // Declaración al principio
        begin
            $display("--------------------------------------------------");
            $display("Verificando Paso: %s (T=%0t)", test_step_name, $time);
            $display("  Esperado: estado=%h, p1_led=%b, p2_led=%b", expected_estado, expected_p1_led, expected_p2_led);
            if (test_step_name == "Verificando Ganador P1") begin
                 $display("            winner_found=%b", expected_winner_found);
            end
            // *** Añadir uut.matrix[13:0] ***
            $display("  Obtenido: estado=%h, p1_led=%b, p2_led=%b, uut.player1_start=%b, uut.winner_found=%b, uut.matrix[13:0]=%h",
                     estado, p1_led, p2_led, uut.player1_start, uut.winner_found, uut.matrix[13:0]); // Muestra la primera fila (bits 0 a 13)

            // Comprobaciones individuales
            if (estado !== expected_estado) $display("  ERROR: estado incorrecto!");
            if (p1_led !== expected_p1_led) $display("  ERROR: p1_led incorrecto!");
            if (p2_led !== expected_p2_led) $display("  ERROR: p2_led incorrecto!");

            // Verificaciones específicas
            if (test_step_name == "Despues de P1 Start" && uut.player1_start !== 1'b1) begin
                 $display("  ERROR: uut.player1_start deberia ser 1 aqui!");
            end
            if (test_step_name == "Verificando Ganador P1" && uut.winner_found !== expected_winner_found) begin
                 $display("  ERROR: uut.winner_found incorrecto!");
            end
             // *** Añadir verificación de 'x' en matrix si es necesario ***
             if (test_step_name == "Verificando Ganador P1" && $isunknown(uut.matrix)) begin
                 $display("  ERROR: uut.matrix contiene valores 'x'!");
             end

            // Comprobación general de éxito
            check_ok = (estado === expected_estado && p1_led === expected_p1_led && p2_led === expected_p2_led);
            if (test_step_name == "Despues de P1 Start") begin
                check_ok = check_ok && (uut.player1_start === 1'b1);
            end
            if (test_step_name == "Verificando Ganador P1") begin
                 check_ok = check_ok && (uut.winner_found === expected_winner_found);
                 check_ok = check_ok && (!$isunknown(uut.matrix)); // Añadir comprobación de 'x' en matrix
            end

            if (check_ok) begin
                 $display("  OK: Todas las señales verificadas coinciden.");
            end
            $display("--------------------------------------------------");
        end
    endtask

    // Initial block for test sequence
    initial begin
        // Initialize Inputs
        rst = 1; // Assert reset
        raw_col_left = 0;
        raw_col_right = 0;
        raw_confirm = 0;
        raw_start_game = 0;
        raw_player1_start = 0;
        raw_player2_start = 0;
        arduino_rx = 1; // Idle state for UART

        // Wait for global reset
        #(CLK_PERIOD * 5);
        rst = 0; // Deassert reset
        $display("T=%0t: Reset Deasserted", $time);

        // ** Verificación 0: Estado después del Reset **
        test_step_name = "Despues de Reset";
        expected_estado = 4'b0000; // P_INICIO
        expected_p1_led = 1'b0;
        expected_p2_led = 1'b0;
        #(CLK_PERIOD); // Esperar un ciclo para que se estabilice
        check_signals();


        // --- Test Scenario ---

        // ** 1. Start Game (Press player 1 start) **
        test_step_name = "Presionando P1 Start";
        #(CLK_PERIOD * 10);
        $display("T=%0t: %s", $time, test_step_name);
        raw_player1_start = 1;
        #(CLK_PERIOD * 600000); // Pulso largo P1 Start
        raw_player1_start = 0;
        $display("T=%0t: Soltando P1 Start", $time);
        #(CLK_PERIOD * 50); // Wait for debounce and FSM

        // ** Verificación 1: Estado después de iniciar P1 **
        test_step_name = "Despues de P1 Start";
        expected_estado = 4'b0011; // Esperando P1 (Ajustado)
        expected_p1_led = 1'b1;
        expected_p2_led = 1'b0;
        check_signals();


        // ** 2. Player 1 Turn: Select column 3 (default) and confirm **
        test_step_name = "P1 confirma Columna 3";
        #(CLK_PERIOD * 100); // Wait some time
        if (estado == 4'b0010 || estado == 4'b0011) begin
            $display("T=%0t: %s", $time, test_step_name);
            raw_confirm = 1;
            #(CLK_PERIOD * 600000); // Pulso largo de confirmación
            raw_confirm = 0;
            // Esperar suficiente tiempo para pasar por FICHA_CAYENDO y llegar a VERIFICAR_GANADOR
            #(CLK_PERIOD * 10); // Dar tiempo a que la FSM avance

             // ** Verificación 2: Estado y winner_found al verificar **
             test_step_name = "Verificando Ganador P1";
             expected_estado = 4'b0111; // VERIFICAR_GANADOR
             expected_p1_led = 1'b0; // p1_led deberia estar apagado aqui
             expected_p2_led = 1'b0;
             expected_winner_found = 1'b0; // No debería haber ganador aún
             check_signals();

             // Esperar un ciclo más para la transición a TURNO_P2
             #(CLK_PERIOD);

             // ** Verificación 2.1: Estado final después de verificar P1 **
             test_step_name = "Despues de Verificar P1";
             expected_estado = 4'b0100; // TURNO_P2
             expected_p1_led = 1'b0;
             expected_p2_led = 1'b1;
             check_signals();

        end else begin
            $display("T=%0t: ERROR - No se puede ejecutar '%s' - Estado incorrecto (%h)", $time, test_step_name, estado);
        end

        // ** 3. Player 2 Turn (Simulate Arduino sending column '4' = ASCII 52) **
        test_step_name = "Simulando movida Arduino (Col 4)";
        #(CLK_PERIOD * 100);
        if (estado == 4'b0100 || estado == 4'b0101) begin // If in P2 turn/wait state
             $display("T=%0t: %s", $time, test_step_name);
             // Send Start Bit (low)
             arduino_rx = 0;
             #(5208 * 1000 / (CLK_PERIOD/2)); // Wait 1 bit time

             // Send '4' (ASCII 52 = 00110100), LSB first = 00101100
             arduino_rx = 0; #(5208 * 1000 / (CLK_PERIOD/2)); // Bit 0
             arduino_rx = 0; #(5208 * 1000 / (CLK_PERIOD/2)); // Bit 1
             arduino_rx = 1; #(5208 * 1000 / (CLK_PERIOD/2)); // Bit 2
             arduino_rx = 0; #(5208 * 1000 / (CLK_PERIOD/2)); // Bit 3
             arduino_rx = 1; #(5208 * 1000 / (CLK_PERIOD/2)); // Bit 4
             arduino_rx = 1; #(5208 * 1000 / (CLK_PERIOD/2)); // Bit 5
             arduino_rx = 0; #(5208 * 1000 / (CLK_PERIOD/2)); // Bit 6
             arduino_rx = 0; #(5208 * 1000 / (CLK_PERIOD/2)); // Bit 7

             // Send Stop Bit (high)
             arduino_rx = 1;
             #(5208 * 1000 / (CLK_PERIOD/2));

             #(CLK_PERIOD * 100); // Wait for processing and FSM to advance

             // ** Verificación 3: Estado después de movida Arduino **
             // Debería estar en VERIFICAR_GANADOR (7) y winner_found=0
             test_step_name = "Verificando Ganador P2";
             expected_estado = 4'b0111; // VERIFICAR_GANADOR
             expected_p1_led = 1'b0;
             expected_p2_led = 1'b0; // p2_led debería apagarse aquí
             expected_winner_found = 1'b0;
             check_signals();

             #(CLK_PERIOD); // Esperar transición a TURNO_P1

             // ** Verificación 3.1: Estado final después de verificar P2 **
             test_step_name = "Despues de Verificar P2";
             expected_estado = 4'b0011; // De vuelta a ESPERANDO_P1 (o 0010 TURNO_P1)
             expected_p1_led = 1'b1;
             expected_p2_led = 1'b0;
             check_signals();

        end else begin
             $display("T=%0t: ERROR - No se puede ejecutar '%s' - Estado incorrecto (%h)", $time, test_step_name, estado);
        end

        // ** 4. Player 1 Turn: Move right, confirm column 4 **
         // ... (Añadir lógica y verificaciones similares para este paso) ...


        #(CLK_PERIOD * 200);
        $display("======================================");
        $display("         FIN DE LA SIMULACION         ");
        $display("======================================");
        $finish;
    end

endmodule