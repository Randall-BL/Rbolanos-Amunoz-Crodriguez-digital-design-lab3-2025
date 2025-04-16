////////////////////////////////////////////////////////////////////////////////////////////////////////
// Módulo para selección aleatoria de columnas válidas
////////////////////////////////////////////////////////////////////////////////////////////////////////

module random_selector (
    input logic clk,          // Reloj del sistema
    input logic rst_n,        // Reset activo bajo
    input logic [6:0] valid_cols, // Bitmask de columnas válidas (0=llena, 1=válida)
    input logic generate_move,// Señal para generar movimiento
    output logic [2:0] random_col, // Columna seleccionada aleatoriamente
    output logic valid_move   // Señal de movimiento válido generado
);

    // Registro LFSR para generación pseudoaleatoria
    logic [15:0] lfsr;
    logic [2:0] col_candidate;
    logic found_valid;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr <= 16'hACE1; // Semilla inicial
            random_col <= 3'b0;
            valid_move <= 1'b0;
        end else begin
            // Actualizar LFSR
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
            
            // Generar movimiento cuando se solicite
            if (generate_move) begin
                found_valid = 1'b0;
                // Probar 8 columnas empezando por la posición aleatoria
                for (int i = 0; i < 7; i++) begin
                    col_candidate = (lfsr[2:0] + i) % 7;
                    if (valid_cols[col_candidate]) begin
                        random_col <= col_candidate;
                        found_valid = 1'b1;
                        break;
                    end
                end
                
                valid_move <= found_valid;
            end else begin
                valid_move <= 1'b0;
            end
        end
    end
endmodule