
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo encargado de contar 15 segundo, segun el estado, realizando varias instancias de Timer 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module Full_Timer (
    input logic clk_in,       // Señal de reloj
    input logic rst_in,       // Señal de reinicio
    output logic done,        // Señal de finalización de 15 segundos
    output logic [3:0] count_out // Salida del contador de 4 bits
);

    logic [15:0] t_signals;   // Array para almacenar las señales de t0
    logic [3:0] time_counter; // Contador para los pulsos t0 (4 bits)
    logic reset_signal;       // Señal para reiniciar el proceso después de 15 segundos

    // Se hacen 16 instancias (0-F)
    genvar index;
    generate
        for (index = 0; index < 16; index = index + 1) begin : timer_blocks
            Timer timer_inst (
                .clk_in(clk_in),
                .rst_in(reset_signal),   // Reiniciamos cuando se completa el ciclo
                .pulse_out(t_signals[index])  // Cada temporizador genera su propia señal t0
            );
        end
    endgenerate

    // Lógica de control del contador
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            time_counter <= 0;
            //done <= 0;
            reset_signal <= 1; // Activamos la señal de reset al inicio
        end else begin
            // Cuando se detecta una señal t0 activa, incrementamos el contador
            if (|t_signals) begin
                time_counter <= time_counter + 1;
            end
            
            // Si llegamos a 15, reseteamos los contadores y señalizamos el fin del proceso
            if (time_counter == 16) begin
                time_counter <= 0;
                //done <= 1;          // Señal de que se alcanzaron los 15 segundos
                reset_signal <= 1;  // Reinicio general
            end else begin
                //done <= 0;
                reset_signal <= 0;  // Seguimos el conteo normal
            end
        end
    end

    // Asignamos el valor actual del contador a la salida
    assign count_out = time_counter;
	 assign done = (count_out == 4'd15);

endmodule
