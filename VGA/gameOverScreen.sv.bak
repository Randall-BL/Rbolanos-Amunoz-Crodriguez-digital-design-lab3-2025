module gameOverScreen(
    input logic [9:0] x, y,
    output logic [7:0] r, g, b
); 

logic letter_G, letter_A, letter_M, letter_E, letter_O, letter_V, letter_E2, letter_R;

// Coordenadas y tamaños de las letras en píxeles
logic [10:0] letter_width, letter_height;
logic [10:0] G_left, G_right, A_left, A_right, M_left, M_right, E_left, E_right;
logic [10:0] O_left, O_right, V_left, V_right, E2_left, E2_right, R_left, R_right;
logic [10:0] letter_top, letter_bottom;

// Asignación constante de tamaños y posiciones
initial begin
    letter_width = 10'd40;
    letter_height = 10'd80;

    // Posiciones iniciales de las letras para "GAME"
    G_left = 10'd100;
    A_left = G_left + letter_width + 10;
    M_left = A_left + letter_width + 10;
    E_left = M_left + letter_width + 10;

    // Posiciones iniciales de las letras para "OVER"
    O_left = 10'd100;
    V_left = O_left + letter_width + 10;
    E2_left = V_left + letter_width + 10;
    R_left = E2_left + letter_width + 10;

    // Asignar top y bottom para las letras
    letter_top = 10'd100;
    letter_bottom = letter_top + letter_height;
end

// Asignación de posiciones derivadas
always_comb begin
    G_right = G_left + letter_width;
    A_right = A_left + letter_width;
    M_right = M_left + letter_width;
    E_right = E_left + letter_width;

    O_right = O_left + letter_width;
    V_right = V_left + letter_width;
    E2_right = E2_left + letter_width;
    R_right = R_left + letter_width;
end

// Funciones para definir cada letra
always_comb begin
    // Letra G
    letter_G = ((x >= G_left && x <= G_right) && (y >= letter_top && y <= letter_bottom)) &&
               (
                (y == letter_top) || (y == letter_bottom) || // Bordes superior e inferior
                (x == G_left) || (y == letter_top + 40 && x >= G_left + 20) || // Borde izquierdo y línea horizontal
                (x == G_right && y >= letter_top + 40) // Borde derecho inferior
               );

    // Letra A
    letter_A = ((x >= A_left && x <= A_right) && (y >= letter_top && y <= letter_bottom)) &&
               (
                (y == letter_top) || // Borde superior de la A
                (x == A_left || x == A_right) || // Bordes laterales de la A
                (y == letter_top + 40 && x >= A_left + 10 && x <= A_right - 10) // Línea horizontal en el centro
               );

    // Letra M
    letter_M = ((x >= M_left && x <= M_right) && (y >= letter_top && y <= letter_bottom)) &&
               (
                (x == M_left || x == M_right) || // Bordes laterales
                (x == M_left + 20 && y >= letter_top + 20) || (x == M_right - 20 && y >= letter_top + 20) // V en el centro
               );

    // Letra E
    letter_E = ((x >= E_left && x <= E_right) && (y >= letter_top && y <= letter_bottom)) &&
               (
                (y == letter_top) || (y == letter_bottom) || (y == letter_top + 40) || // Líneas horizontales
                (x == E_left) // Borde izquierdo
               );

    // Letra O
    letter_O = ((x >= O_left && x <= O_right) && (y >= letter_top + 100 && y <= letter_bottom + 100)) &&
               (
                (y == letter_top + 100 || y == letter_bottom + 100) || // Bordes superior e inferior
                (x == O_left || x == O_right) // Bordes laterales
               );

    // Letra V
    letter_V = ((x >= V_left && x <= V_right) && (y >= letter_top + 100 && y <= letter_bottom + 100)) &&
               (
                (x == V_left + 10 && y <= letter_bottom + 60) || (x == V_right - 10 && y <= letter_bottom + 60) // V
               );

    // Letra E2
    letter_E2 = ((x >= E2_left && x <= E2_right) && (y >= letter_top + 100 && y <= letter_bottom + 100)) &&
               (
                (y == letter_top + 100) || (y == letter_bottom + 100) || (y == letter_top + 140) || // Líneas horizontales
                (x == E2_left) // Borde izquierdo
               );

    // Letra R
    letter_R = ((x >= R_left && x <= R_right) && (y >= letter_top + 100 && y <= letter_bottom + 100)) &&
               (
                (y == letter_top + 100) || // Borde superior de la R
                (x == R_left) || // Borde izquierdo
                (y == letter_top + 140 && x <= R_right) || // Línea horizontal en el centro
                (x == R_right && y >= letter_top + 140) // Curva en la parte inferior derecha
               );
end

// Asignar el color rojo a las letras
assign r = (letter_G || letter_A || letter_M || letter_E || letter_O || letter_V || letter_E2 || letter_R) ? 8'hFF : 8'h00; // Rojo
assign g = 8'h00; // Sin verde
assign b = 8'h00; // Sin azul

endmodule
