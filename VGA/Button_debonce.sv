
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo encargado controlar el debounce de los botones independientemente
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module Button_debounce (
    input logic button_in, clk_in,         // Entrada del botón y señal de reloj
    output logic button_stable              // Salida estabilizada del botón
);
    logic enable_slow_clk;                  // Señal para habilitar el reloj lento
    logic FF1, FF2, FF2_inv, FF0;           // Flip-flops utilizados en el proceso de debounce

    // Generador de reloj más lento
    Slow_Clock_Enable slow_clk_gen (.clk_100MHz(clk_in), .enable_slow_clk(enable_slow_clk));

    // Flip-flops con habilitación de reloj para el debounce
    D_FF_with_Enable dff_0 (.clk(clk_in), .clk_enable(enable_slow_clk), .D(button_in), .Q(FF0));
    D_FF_with_Enable dff_1 (.clk(clk_in), .clk_enable(enable_slow_clk), .D(FF0), .Q(FF1));
    D_FF_with_Enable dff_2 (.clk(clk_in), .clk_enable(enable_slow_clk), .D(FF1), .Q(FF2));

    // Inversión de la señal FF2 y generación de la salida debounced
    assign FF2_inv = ~FF2;                  // Invertimos la salida del último flip-flop
    assign button_stable = FF1 & FF2_inv;   // La salida estabilizada se genera combinando FF1 y FF2 invertido
endmodule

// Generador de reloj lento habilitado para la señal del botón
module Slow_Clock_Enable (
    input logic clk_100MHz,                 // Reloj de entrada a 100MHz
    output logic enable_slow_clk            // Salida habilitadora para el reloj lento
);
    logic [26:0] clk_counter = 0;           // Contador para dividir la frecuencia del reloj

    // Contador para dividir la frecuencia del reloj y crear un enable de reloj lento
    always_ff @(posedge clk_100MHz) begin
        if (clk_counter >= 249999)           // Ajustar el límite del contador para obtener un reloj lento
            clk_counter <= 0;                 // Reiniciar el contador
        else
            clk_counter <= clk_counter + 1;   // Incrementar el contador
    end

    // Habilitar el reloj lento cuando el contador alcanza el límite
    assign enable_slow_clk = (clk_counter == 249999) ? 1'b1 : 1'b0;
endmodule

// D Flip-flop con habilitación de reloj para el proceso de debounce
module D_FF_with_Enable (
    input logic clk, clk_enable, D,         // Entradas de reloj, habilitación y dato
    output logic Q = 0                       // Salida del flip-flop inicializada a 0
);
    // Captura el valor D solo cuando el habilitador de reloj está activo
    always_ff @(posedge clk) begin
        if (clk_enable)
            Q <= D;                          // Actualiza la salida Q con el valor de D si clk_enable está activo
    end
endmodule
