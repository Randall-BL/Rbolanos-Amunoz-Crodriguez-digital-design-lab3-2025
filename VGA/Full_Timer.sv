/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo encargado de contar 10 segundos
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module Full_Timer (
    input logic clk_in,       // Señal de reloj
    input logic rst_in,       // Señal de reinicio
    output logic done,        // Señal de finalización de 10 segundos
    output logic [3:0] count_out // Salida del contador de 4 bits (0-9)
);

    logic [26:0] counter;     // Contador para 10 segundos a 50MHz (500,000,000 ciclos)
    logic [3:0] sec_counter;  // Contador de segundos (0-9)

    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            counter <= 0;
            sec_counter <= 0;
            done <= 0;
        end else begin
            if (counter == 49999999) begin // 1 segundo a 50MHz
                counter <= 0;
                if (sec_counter == 9) begin
                    sec_counter <= 0;
                    done <= 1;
                end else begin
                    sec_counter <= sec_counter + 1;
                    done <= 0;
                end
            end else begin
                counter <= counter + 1;
                done <= 0;
            end
        end
    end

    assign count_out = sec_counter;
endmodule