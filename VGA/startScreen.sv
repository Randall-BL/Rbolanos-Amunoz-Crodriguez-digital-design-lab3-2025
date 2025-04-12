
////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo que dibuja la pantalla de Inicio (START)
////////////////////////////////////////////////////////////////////////////////////////////////////////


module startScreen(
    input logic [9:0] x, y,
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

    // Asignar top y bottom para las letras
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
               (
                (y == letter_top) || // Borde superior de la S
                (y == letter_bottom) || // Borde inferior de la S
                (y == letter_top + 40) || // Línea central
                (x == S_left && y <= letter_top + 40) || // Borde izquierdo en la parte superior
                (x == S_right && y >= letter_top + 40) // Borde derecho en la parte inferior
               );

    // Primera letra T
    letter_T1 = ((x >= T1_left && x <= T1_right) && (y >= letter_top && y <= letter_bottom)) &&
               (
                (y == letter_top) || // Borde superior de la T
                (x == T1_left + letter_width / 2) // Línea vertical en el centro de la T
               );

    // Letra A
    letter_A = ((x >= A_left && x <= A_right) && (y >= letter_top && y <= letter_bottom)) &&
               (
                (y == letter_top) || // Borde superior de la A
                (x == A_left || x == A_right) || // Bordes laterales de la A
                (y == letter_top + 40 && x >= A_left + 10 && x <= A_right - 10) // Línea horizontal en el centro
               );

    // Letra R
    letter_R = ((x >= R_left && x <= R_right) && (y >= letter_top && y <= letter_bottom)) &&
               (
                (y == letter_top) || // Borde superior de la R
                (x == R_left) || // Borde izquierdo de la R
                (y == letter_top + 40 && x <= R_right) || // Línea horizontal en el centro
                (x == R_right && y >= letter_top + 40) // Curva en la parte inferior derecha
               );

    // Segunda letra T
    letter_T2 = ((x >= T2_left && x <= T2_right) && (y >= letter_top && y <= letter_bottom)) &&
               (
                (y == letter_top) || // Borde superior de la T
                (x == T2_left + letter_width / 2) // Línea vertical en el centro de la T
               );
end

// Asignar el color verde a las letras
assign r = (letter_S || letter_T1 || letter_A || letter_R || letter_T2) ? 8'h00 : 8'h00; // Sin rojo
assign g = (letter_S || letter_T1 || letter_A || letter_R || letter_T2) ? 8'hFF : 8'h00; // Verde para "START"
assign b = (letter_S || letter_T1 || letter_A || letter_R || letter_T2) ? 8'h00 : 8'h00; // Sin azul

endmodule

