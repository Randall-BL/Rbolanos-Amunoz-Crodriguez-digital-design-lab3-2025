////////////////////////////////////////////////////////////////////////////////////////////////////////
// Módulo de interfaz UART para comunicación con Arduino
////////////////////////////////////////////////////////////////////////////////////////////////////////

module arduino_interface (
    input logic clk,          // Reloj del sistema (50MHz)
    input logic rst_n,        // Reset activo bajo
    input logic rx_data,      // Entrada serial del Arduino
    output logic [2:0] column,// Columna seleccionada (0-6)
    output logic move_ready,  // Señal de movimiento listo
    output logic error        // Señal de error en comunicación
);

    // Estados de la máquina de recepción UART
    typedef enum logic [2:0] {
        IDLE = 3'b000,
        START_BIT = 3'b001,
        DATA_BITS = 3'b010,
        STOP_BIT = 3'b011,
        PARITY_CHECK = 3'b100
    } uart_state_t;

    uart_state_t current_state, next_state;
    
    // Registros para la recepción
    logic [7:0] rx_shift_reg;
    logic [3:0] bit_counter;
    logic [15:0] baud_counter;
    logic sample_point;
    
    // Parámetros UART (9600 baudios a 50MHz)
    localparam BAUD_COUNT = 5208; // 50MHz / 9600 = 5208.33
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            baud_counter <= 0;
            bit_counter <= 0;
            rx_shift_reg <= 8'b0;
            column <= 3'b0;
            move_ready <= 1'b0;
            error <= 1'b0;
        end else begin
            // Contador de baudios
            if (baud_counter == BAUD_COUNT-1) begin
                baud_counter <= 0;
                sample_point <= 1'b1;
            end else begin
                baud_counter <= baud_counter + 1;
                sample_point <= 1'b0;
            end
            
            // Máquina de estados UART
            current_state <= next_state;
            
            case (current_state)
                IDLE: begin
                    if (!rx_data) begin // Detección de bit de inicio
                        next_state <= START_BIT;
                        baud_counter <= BAUD_COUNT/2; // Muestrear en medio del bit
                    end
                end
                
                START_BIT: begin
                    if (sample_point) begin
                        if (!rx_data) begin // Verificar bit de inicio
                            next_state <= DATA_BITS;
                            bit_counter <= 0;
                        end else begin
                            next_state <= IDLE; // Falso inicio
                            error <= 1'b1;
                        end
                    end
                end
                
                DATA_BITS: begin
                    if (sample_point) begin
                        rx_shift_reg <= {rx_data, rx_shift_reg[7:1]};
                        if (bit_counter == 7) begin
                            next_state <= STOP_BIT;
                        end else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end
                end
                
                STOP_BIT: begin
                    if (sample_point) begin
                        if (rx_data) begin // Bit de stop válido
                            // El Arduino envía valores ASCII '0'-'6' (48-54)
                            if (rx_shift_reg >= 8'd48 && rx_shift_reg <= 8'd54) begin
                                column <= rx_shift_reg - 8'd48;
                                move_ready <= 1'b1;
                                error <= 1'b0;
                            end else begin
                                error <= 1'b1;
                            end
                        end else begin
                            error <= 1'b1;
                        end
                        next_state <= IDLE;
                    end
                end
            endcase
            
            // Resetear move_ready después de un ciclo
            if (move_ready) begin
                move_ready <= 1'b0;
            end
        end
    end
endmodule