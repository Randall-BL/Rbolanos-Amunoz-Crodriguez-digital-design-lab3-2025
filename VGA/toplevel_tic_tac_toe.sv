
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo PRINCIPAL encargado de la creacion de intancias, variables y vista de pantallas dependiendo del estado
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module toplevel_tic_tac_toe (
    input logic PLAYER_1, PLAYER_2,I,T,W,A,B, NEXT, TEST, rst, clk, 
    output logic [3:0] estado, 		// Estados internos de la FSM
    output logic vgaclk, hsync, vsync, sync_b, blank_b, // Señales VGA
    output logic [7:0] r, g, b, // Color VGA
    output logic [8:0] matrix_out_MEF,  // Matriz actual
    output logic load,         // Carga en la matriz
    output logic [6:0] segments,  // Segmentos para display de 7 segmentos
    output logic led_p1, led_p2,  // LEDs para indicar turno de los jugadores
	 output logic reset_timer, //Condiciones del Timer
	 output logic reset_done
);

    logic [9:0] x, y; //Posiciones para el VGA
    logic [7:0] r_videoGen, g_videoGen, b_videoGen; // Colores TABLERO
	 logic [7:0] r_OVER, g_OVER, b_OVER; // Colores GAME_OVER
    logic [7:0] r_black, g_black, b_black; // Pantalla en Negro
	 logic [7:0] r_PantallaInicial, g_PantallaInicial, b_PantallaInicial; // Colores START
    logic finished;   // Señal que indica que el contador ha llegado a 15 segundos
	 logic [8:0] matrix_in; //Señales de la matriz
    logic [8:0] matrix_reg; 
    logic [3:0] count; // Cuenta del temporizador de 4 bits
	 

	 
// INSTANCIAS INICIALES
	 
	 // Instancia del Temporizador Completo
    Full_Timer timer_inst (
        .clk_in(clk),
        .rst_in(reset_timer),
        .done(finished),
        .count_out(count)
    );
	 
	 //Instancia del BCD (7segm)
	 	 
	 BCD_Visualizer segBCD_inst (
        .bin(count),
        .seg(segments)
    );
	 
	 // Instancia principal de la FSM
    tic_tac_toe_fsm mef (
        .I(I), .T(T), .W(W), .A(A), .PLAYER_1(PLAYER_1), .PLAYER_2(PLAYER_2),
        .NEXT(NEXT), .TEST(TEST), .rst(rst), .clk(clk),
        .estado(estado), .reset_timer(reset_timer), .reset_done(reset_done),
        .led_p1(led_p1), .led_p2(led_p2), .finished(finished), .matrix_complete(matrix_full)
    );
	 
//INSTANCIAS VGA

    // Instancia de PLL para generar la señal de 25.175 MHz para el VGA
    pll vgapll(.inclk0(clk), .c0(vgaclk));
    // Instancia del controlador VGA
    vgaController vgaCont(.vgaclk(vgaclk), .hsync(hsync), .vsync(vsync), .sync_b(sync_b), .blank_b(blank_b), .x(x), .y(y));	 
	     // Instancia del módulo videoGen
    videoGen vgagen(
        .x_pos(x), 
        .y_pos(y), 
        .grid_state(matrix_out_MEF),
		  .current_state(estado),
        .red(r_videoGen), 
        .green(g_videoGen), 
        .blue(b_videoGen)
    );
	 
	 // Instancia del módulo Pantalla_Inicial
    gameOverScreen pantallaFinal(
        .x(x), 
        .y(y), 
        .r(r_OVER), 
        .g(g_OVER), 
        .b(b_OVER)
    );

    // Instancia del módulo Pantalla_Inicial
    startScreen pantallaStart(
        .x(x), 
        .y(y), 
        .r(r_PantallaInicial), 
        .g(g_PantallaInicial), 
        .b(b_PantallaInicial)
    );
	 
//INSTANCIAS DE JUEGO
	 
    // Instancias de los Debounce para los botones
    Button_debounce boton1_inst (
        .button_in(I),
        .clk_in(clk),
        .button_stable(Idebounced)
    );
	 
	  Button_debounce boton2_inst (
        .button_in(B),
        .clk_in(clk),
        .button_stable(Bdebounced)
    );
    
    Button_debounce boton3_inst (
        .button_in(W),
        .clk_in(clk),
        .button_stable(Wdebounced)
    );

    // Instancia del módulo para Controlar la matriz
    matrixTableroControl matrixTableroControl_inst (
        .clk(clk),
        .rst_n(rst_n),
        .I(I),
		  .B(B), 
		  .current_state(estado),
        .W(!Wdebounced),
        .matrix_in(matrix_reg),
        .matrix_out(matrix_in),
        .load(load)
	);

    // Instancia del modulo para Actualizar la matriz
    matrixTablero matrixTablero_inst (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(matrix_in),
        .load(load),
        .matrix(matrix_reg)
    );
	 
	 
// CONSIDERACIONES DE LA MATRIZ

    initial begin
        matrix_reg = 9'b10;  // Inicializar la matriz
    end
    
    logic rst_n;
    assign rst_n = !rst;
    
    assign matrix_out_MEF = matrix_reg;
	 
	 //Condicional de la matriz llena (Tablero completo)
	 
	 logic matrix_full;

	 always_comb begin
		 if (matrix_reg == 9'b111111111) begin
			 matrix_full = 1;
		 end else begin
			 matrix_full = 0;
		 end
	 end
	 

// VISUALIZACION DE LAS DISTINTAS PANTALLAS	 

    // Pantalla en negro
    assign r_black = 8'b00000000;
    assign g_black = 8'b00000000;
    assign b_black = 8'b00000000;

    // MUX para indicar que imagen se debe mostrar segun sea el estado actual
    always_comb begin
        case (estado)
            4'b0000: begin // Pantalla START
                r = r_PantallaInicial;
                g = g_PantallaInicial;
                b = b_PantallaInicial;
            end
            4'b0001, 4'b0010, 4'b0011, 4'b0100 : begin //Pantalla TABLERO
                r = r_videoGen;
                g = g_videoGen;
                b = b_videoGen;
            end
				4'b0101: begin  //Pantalla GAME_OVER
					 r = r_OVER;
                g = g_OVER;
                b = b_OVER;
				
				end
            default: begin
                r = r_black;
                g = g_black;
                b = b_black;
            end
        endcase
    end
endmodule