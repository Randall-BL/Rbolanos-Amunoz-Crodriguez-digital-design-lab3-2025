

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo encargado controlar como se modifica la matriz (botones, asignaciones segun estados y demas)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module matrixTableroControl (
    input  logic        clk,         // Señal de reloj
    input  logic        rst_n,       // Señal de reset activo bajo
    input  logic        I,           // Botón del jugador 1 para marcar posición
    input  logic        W,           // Botón para moverse a través de las posiciones
    input  logic        B,           // Botón del jugador 2 para marcar posición
    input  logic [3:0]  current_state, // Estado actual del juego
    input  logic [8:0]  matrix_in,   // Matriz de entrada de 9 bits (representa el tablero)
    output logic [8:0]  matrix_out,  // Matriz de salida modificada
    output logic        load         // Señal de carga para indicar un cambio
);

    logic [3:0] index;            // Índice para moverse por las posiciones de la matriz (0-8)
    logic [8:0] temp_matrix;      // Matriz temporal para almacenar los valores modificados

    // Lógica para moverse por las posiciones de la matriz (usando el botón W)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            index <= 4'd8; // Empezar en la posición 8 (esquina superior izquierda) al resetear
        end
        else if (!W) begin
            if (index == 4'd0)
                index <= 4'd8;  // Regresar a 8 después de llegar a 0
            else
                index <= index - 4'd1; // Moverse a la siguiente posición
        end
    end

    // Lógica para confirmar la posición y modificar la matriz dependiendo del turno
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            temp_matrix <= matrix_in; // Inicializar la matriz temporal con la matriz de entrada
            load <= 1'b0;             // No hay cambio en la carga al resetear
        end
        // Turno del jugador 1 (estado 0010), usar botón I para marcar
        else if (!I && (current_state == 4'b0010)) begin
            if (!matrix_in[index]) begin
                temp_matrix[index] <= 1'b1; // Marcar la posición para el jugador 1
                load <= 1'b1;               // Indicar que se ha realizado un cambio
            end else begin
                load <= 1'b0;               // No hay cambio si la posición ya está ocupada
            end
        end
        // Turno del jugador 2 (estado 0011), usar botón B para marcar
        else if (!B && (current_state == 4'b0011)) begin
            if (!matrix_in[index]) begin
                temp_matrix[index] <= 1'b1; // Marcar la posición para el jugador 2
                load <= 1'b1;               // Indicar que se ha realizado un cambio
            end else begin
                load <= 1'b0;               // No hay cambio si la posición ya está ocupada
            end
        end
        else begin
            load <= 1'b0; // No hay carga si no se presionan los botones o el estado es incorrecto
        end
    end

    // Asignar la matriz modificada a la salida
    assign matrix_out = temp_matrix;

endmodule
