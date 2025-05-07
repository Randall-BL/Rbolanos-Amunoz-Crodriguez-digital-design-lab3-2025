/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo Controlador de Matriz - Versión Dos Jugadores con Controles COMPARTIDOS (Sintaxis Corregida)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module matrixTableroControl (
    input logic clk,
    input logic rst_n, // Reset activo bajo

    // Entradas DEBOUNCED COMPARTIDAS
    input logic col_left,
    input logic col_right,
    input logic confirm,

    // Entradas de otros módulos
    input logic random_move_valid, // Desde random selector
    input logic [2:0] random_col,  // Desde random selector
    input logic [3:0] current_state, // Desde FSM (para saber si escuchar botones)
    input logic [83:0] matrix_in,    // Estado actual del tablero

    // Salidas
    output logic [2:0] selected_col, // Columna seleccionada actualmente
    output logic load,               // Pulso para matrixTablero (cargar ficha)
    output logic move_valid          // Pulso para FSM (movimiento confirmado)
);

    // --- Lógica de Detección de Flanco (para botones compartidos) ---
    logic col_left_prev, col_right_prev, confirm_prev;
    wire col_left_posedge, col_right_posedge, confirm_posedge;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            col_left_prev  <= 1'b0; col_right_prev <= 1'b0; confirm_prev <= 1'b0;
        end else begin
            col_left_prev  <= col_left;
            col_right_prev <= col_right;
            confirm_prev   <= confirm;
        end
    end

    assign col_left_posedge  = col_left  & ~col_left_prev;
    assign col_right_posedge = col_right & ~col_right_prev;
    assign confirm_posedge   = confirm   & ~confirm_prev;
    // --- Fin Detección de Flanco ---

    // --- Registros Internos ---
    logic [2:0] selected_col_reg;
    logic load_reg;
    logic move_valid_reg;

    // --- Señales Combinacionales Intermedias --- << CAMBIO: Definidas fuera del always_ff >>
    logic is_col_valid;     // Columna seleccionada no está llena
    logic is_waiting_p1;    // FSM está en estado ESPERANDO_P1
    logic is_waiting_p2;    // FSM está en estado ESPERANDO_P2

    // Calcular estado de espera (combinacional)
    assign is_waiting_p1 = (current_state == 4'b0011); // ESPERANDO_P1
    assign is_waiting_p2 = (current_state == 4'b0101); // ESPERANDO_P2

    // Chequear si la columna seleccionada actual es válida (combinacional)
    // Chequea la fila superior VISIBLE (fila 5 en datos, ya que videoGen invierte)
    assign is_col_valid = (matrix_in[(5 * 7 + selected_col_reg) * 2 +: 2] == 2'b00);


    // --- Lógica Principal de Control (Síncrona) ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            selected_col_reg <= 3'd3; // Default centro
            load_reg         <= 1'b0;
            move_valid_reg   <= 1'b0;
        end else begin
            // Limpiar pulsos por defecto CADA CICLO
            load_reg       <= 1'b0;
            move_valid_reg <= 1'b0;

            // Solo reaccionar a botones si estamos esperando a P1 o P2
            // Usa las señales combinacionales precalculadas
            if (is_waiting_p1 || is_waiting_p2) begin
                // Mover selección
                if (col_right_posedge) begin
                    selected_col_reg <= (selected_col_reg == 6) ? 0 : selected_col_reg + 1;
                end else if (col_left_posedge) begin
                    selected_col_reg <= (selected_col_reg == 0) ? 6 : selected_col_reg - 1;
                end
                // Confirmar
                else if (confirm_posedge && is_col_valid) begin // Usa is_col_valid precalculada
                    load_reg       <= 1'b1;
                    move_valid_reg <= 1'b1;
                end
            end // Fin if(is_waiting...)

            // Manejar movimiento aleatorio (solo si también estamos esperando)
            // Usa las señales combinacionales precalculadas
            if (random_move_valid && (is_waiting_p1 || is_waiting_p2)) begin
                 load_reg         <= 1'b1;
                 move_valid_reg   <= 1'b1;
                 selected_col_reg <= random_col;
            end // Fin if(random_move...)

        end // Fin else (!rst_n)
    end // Fin always_ff

    // Asignar salidas desde los registros internos
    assign selected_col = selected_col_reg;
    assign load         = load_reg;
    assign move_valid   = move_valid_reg;

endmodule