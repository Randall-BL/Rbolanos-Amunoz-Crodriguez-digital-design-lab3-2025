////////////////////////////////////////////////////////////////////////////////////////////////////////
// Módulo que dibuja la pantalla de Inicio (START) (Versión corregida)
////////////////////////////////////////////////////////////////////////////////////////////////////////

module startScreen(
    input logic [9:0] x, y,
    input logic visible,
    output logic [7:0] r, g, b
);

logic letter_S, letter_T1, letter_A, letter_R, letter_T2;

// Coordenadas y tamaños de las letras en píxeles
logic [10:0] letter_width, letter_height;
logic [10:0] S_left, S_right, T1_left, T1_right, A_left, A_right, R_left, R_right, T2_left, T2_right;
logic [10:0] letter_top, letter_bottom;

// Asignación constante de tamaños y posiciones
initial begin
    letter_width = 10'd40;
    letter_height = 10'd80;

    // Posiciones iniciales de las letras
    S_left = 10'd200;
    T1_left = S_left + letter_width + 10;
    A_left = T1_left + letter_width + 10;
    R_left = A_left + letter_width + 10;
    T2_left = R_left + letter_width + 10;

    letter_top = 10'd100;
    letter_bottom = letter_top + letter_height;
end

// Asignación de posiciones derivadas
always_comb begin
    S_right = S_left + letter_width;
    T1_right = T1_left + letter_width;
    A_right = A_left + letter_width;
    R_right = R_left + letter_width;
    T2_right = T2_left + letter_width;
end

// Funciones para definir cada letra
always_comb begin
    // Letra S
    letter_S = ((x >= S_left && x <= S_right) && (y >= letter_top && y <= letter_bottom)) &&
               ((y == letter_top) || (y == letter_bottom) || (y == letter_top + 40) ||
                (x == S_left && y <= letter_top + 40) ||
                (x == S_right && y >= letter_top + 40));

    // Primera letra T
    letter_T1 = ((x >= T1_left && x <= T1_right) && (y >= letter_top && y <= letter_bottom)) &&
                ((y == letter_top) || (x == T1_left + letter_width / 2));

    // Letra A
    letter_A = ((x >= A_left && x <= A_right) && (y >= letter_top && y <= letter_bottom)) &&
               ((y == letter_top) || (x == A_left || x == A_right) ||
                (y == letter_top + 40 && x >= A_left + 10 && x <= A_right - 10));

    // Letra R
    letter_R = ((x >= R_left && x <= R_right) && (y >= letter_top && y <= letter_bottom)) &&
               ((y == letter_top) || (x == R_left) ||
                (y == letter_top + 40 && x <= R_right) ||
                (x == R_right && y >= letter_top + 40));

    // Segunda letra T
    letter_T2 = ((x >= T2_left && x <= T2_right) && (y >= letter_top && y <= letter_bottom)) &&
                ((y == letter_top) || (x == T2_left + letter_width / 2));
end

// Asignar color SOLO si visible == 1
always_comb begin
    if (visible) begin
        r = (letter_S || letter_T1 || letter_A || letter_R || letter_T2) ? 8'h00 : 8'h00; // Sin rojo
        g = (letter_S || letter_T1 || letter_A || letter_R || letter_T2) ? 8'hFF : 8'h00; // Verde
        b = (letter_S || letter_T1 || letter_A || letter_R || letter_T2) ? 8'h00 : 8'h00; // Sin azul
    end else begin
        r = 8'h00;
        g = 8'h00;
        b = 8'h00;
    end
end

endmodule
