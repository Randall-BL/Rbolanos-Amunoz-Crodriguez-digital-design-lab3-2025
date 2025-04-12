
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo encargado de contar 1 segundo 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module Timer (
    input logic clk_in, rst_in,  // Señales de reloj y reinicio
    output logic pulse_out       // Salida de la señal t0
);
    logic [26:0] cycle_counter;  // Contador de 27 bits para contar hasta 50 millones (aprox 1 segundo a 50MHz)

    // Bloque secuencial para el conteo de ciclos
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            cycle_counter <= 0;
            pulse_out <= 0;      // Reiniciamos el contador y la salida de pulso
        end else begin
            if (cycle_counter == 50000000 - 1) begin
                cycle_counter <= 0;  // Reiniciamos el contador cuando llega a 50 millones
                pulse_out <= 1;      // Activamos la señal de salida t0 cuando se cumple el ciclo
            end else begin
                cycle_counter <= cycle_counter + 1;  // Incrementamos el contador
                pulse_out <= 0;  // Mantenemos la señal de salida en bajo mientras no llegue al límite
            end
        end
    end
endmodule

