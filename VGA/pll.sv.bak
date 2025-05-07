module pll (
    input logic inclk0,    // Señal de reloj de entrada
    output logic c0        // Señal de reloj de salida
);

    logic toggle;
	 
	 initial begin
		toggle = 0;
	 end


    // Flip-flop para dividir por 2
    always @(posedge inclk0) begin
        toggle <= ~toggle;
    end

    // Salida es el valor de toggle, que cambia con cada flanco de subida de inclk0
    assign c0 = toggle;

endmodule