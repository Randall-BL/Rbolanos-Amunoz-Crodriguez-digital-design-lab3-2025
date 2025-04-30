////////////////////////////////////////////////////////////////////////
// Modulo Debounce Simple Basado en Contador
////////////////////////////////////////////////////////////////////////
module Button_debounce #(
    parameter CLK_FREQ      = 50_000_000, // Frecuencia del reloj de entrada (Hz)
    parameter STABLE_TIME_MS = 10          // Tiempo de estabilidad deseado (ms)
) (
    input  logic clk,          // Reloj del sistema
    input  logic rst,          // Reset (activo alto)
    input  logic button_in,    // Entrada directa del botón (ruidosa)
    output logic button_out    // Salida estable del botón
);

    localparam COUNTER_BITS = $clog2(STABLE_TIME_MS * (CLK_FREQ / 1000));
    localparam MAX_COUNT    = STABLE_TIME_MS * (CLK_FREQ / 1000) - 1;

    logic [COUNTER_BITS-1:0] count;
    logic sync_ff1, sync_ff2; // Sincronizadores de entrada
    logic debounced_state_reg;
    logic next_debounced_state;

    // Sincronizar la entrada asíncrona del botón con el reloj del sistema
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
        end else begin
            sync_ff1 <= button_in;
            sync_ff2 <= sync_ff1;
        end
    end

    // Lógica del Debounce
    assign next_debounced_state = debounced_state_reg; // Por defecto, mantener estado

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            debounced_state_reg <= 1'b0; // Estado inicial (asume botón no presionado)
            count <= '0;
        end else begin
            if (sync_ff2 != debounced_state_reg) begin
                // La entrada sincronizada difiere del estado estable -> Iniciar/Continuar conteo
                if (count < MAX_COUNT) begin
                    count <= count + 1;
                end else begin
                    // Contador llegó al máximo -> Señal estable, actualizar estado
                    debounced_state_reg <= sync_ff2;
                    count <= '0; // Reiniciar contador
                end
            end else begin
                // La entrada coincide con el estado estable -> Reiniciar contador
                count <= '0;
            end
        end
    end

    assign button_out = debounced_state_reg;

endmodule