

////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo encargado de modificar la matriz del Tablero de juego
////////////////////////////////////////////////////////////////////////////////////////////////////////

module matrixTablero (
    input logic clk,           // Señal de reloj
    input logic rst_n,         // Señal de reset activo bajo
    input logic [8:0] data_in, // Entrada de 9 bits para cargar la matriz
    input logic load,          // Señal de control para cargar nuevos datos
    output logic [8:0] matrix  // Registro de 9 bits que representa la matriz
);

    // Registro de 9 bits para almacenar la matriz
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix <= 9'b0;  // Restablecer la matriz a 0 cuando rst_n está activo bajo
        end
        else if (load) begin
            matrix <= data_in;  // Cargar nuevos datos cuando la señal load está alta
        end
    end
endmodule


