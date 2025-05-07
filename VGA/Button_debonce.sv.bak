module Button_debounce(
    input logic pb_1, clk,
    output logic pb_out
);
    logic slow_clk_en;
    logic Q1, Q2, Q2_bar, Q0;

    // Instanciamos el generador de reloj lento
    clock_enable u1 (.Clk_100M(clk), .slow_clk_en(slow_clk_en));

    // Flip-flops con habilitación de reloj
    my_dff_en d0 (.DFF_CLOCK(clk), .clock_enable(slow_clk_en), .D(pb_1), .Q(Q0));
    my_dff_en d1 (.DFF_CLOCK(clk), .clock_enable(slow_clk_en), .D(Q0), .Q(Q1));
    my_dff_en d2 (.DFF_CLOCK(clk), .clock_enable(slow_clk_en), .D(Q1), .Q(Q2));

    // Inversión de la señal Q2 y cálculo de la salida debounced
    assign Q2_bar = ~Q2;
    assign pb_out = Q1 & Q2_bar;
endmodule

// Generador de habilitación de reloj lento para el botón
module clock_enable(
    input logic Clk_100M,
    output logic slow_clk_en
);
    logic [26:0] counter = 0;

    // Contador para generar el reloj lento
    always_ff @(posedge Clk_100M) begin
        if (counter >= 249999)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    assign slow_clk_en = (counter == 249999) ? 1'b1 : 1'b0;
endmodule

// D flip-flop con habilitación de reloj para el módulo de debouncing
module my_dff_en(
    input logic DFF_CLOCK, clock_enable, D,
    output logic Q = 0
);
    // Flip-flop que captura el valor D solo cuando clock_enable está activado
    always_ff @(posedge DFF_CLOCK) begin
        if (clock_enable)
            Q <= D;
    end
endmodule
