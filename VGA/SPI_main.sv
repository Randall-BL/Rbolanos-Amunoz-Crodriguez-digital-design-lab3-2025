module SPI_main (
    input wire clk,            // Reloj del sistema
    input wire rst_n,          // Reset activo bajo
    input wire data_in,        // Bit de dato a enviar
    output reg mosi,           
    input wire miso,          
    output reg sclk,          
    output reg ss,             
    input wire start,          // Señal de inicio de transmisión (activo bajo)
    output reg done            // Señal de finalización de transmisión
);

    reg [1:0] state;           // Estado del SPI
    reg [3:0] clk_div;         // Divisor de reloj para el SPI

    // Definir los diferentes estados
    localparam IDLE = 2'b00,   // Espera a que comience la transmisión
               START = 2'b01,  // Inicia la transmisión, selecciona al esclavo
               TRANSFER = 2'b10, // Envío del bit
               COMPLETE = 2'b11; // Finalización de la transmisión

    // Generación de reloj SPI
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div <= 0;
            sclk <= 0;
        end else if (state == TRANSFER) begin
            clk_div <= clk_div + 1;   // Incrementar divisor de reloj
            if (clk_div == 4'b1000) begin
                sclk <= ~sclk;        // Invertir sclk después de dividir el reloj
                clk_div <= 0;         // Reiniciar el divisor
            end
        end else begin
            sclk <= 0;                // Mantener sclk en 0 si no está en transferencia
        end
    end

    // Máquina de estados
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            ss <= 1;
            done <= 0;
            mosi <= 0;
        end else begin
            case (state)
                IDLE: begin
                    ss <= 1;          // No seleccionar al esclavo
                    done <= 0;        // Transmisión no completada
                    if (!start) begin
                        state <= START; // Pasar al estado de inicio si 'start' es bajo
                    end
                end

                START: begin
                    ss <= 0;          // Seleccionar al esclavo (activo bajo)
                    mosi <= data_in;  // Asignar el dato a enviar en MOSI
                    state <= TRANSFER; // Pasar al estado de transferencia
                end

                TRANSFER: begin
                    if (sclk == 1'b0 && clk_div == 0) begin
                        state <= COMPLETE; // Pasar al estado de finalización después de la transferencia
                    end
                end

                COMPLETE: begin
                    ss <= 1;          // Deseleccionar al esclavo
                    done <= 1;        // Indicar que la transmisión ha terminado
                    state <= IDLE;    // Volver al estado de espera
                end
            endcase
        end
    end
endmodule