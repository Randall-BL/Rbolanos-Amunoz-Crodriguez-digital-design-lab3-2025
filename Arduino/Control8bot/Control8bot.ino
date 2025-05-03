const uint8_t botones[] = {2, 3, 4, 5, 6, 7, 8};  
const size_t N = sizeof(botones) / sizeof(botones[0]);
void setup() {
  Serial.begin(9600);  // Comunicación UART con la FPGA
  for (size_t i = 0; i < N; ++i) {
    pinMode(botones[i], INPUT_PULLUP);  // Activa resistencia interna
  }
}
uint8_t leer_columna() {
  for (uint8_t i = 0; i < N; ++i) {
    if (digitalRead(botones[i]) == LOW) {  // Botón presionado (LOW por INPUT_PULLUP)
      delay(30);  // Debounce
      if (digitalRead(botones[i]) == LOW) {
        // Esperar a que se suelte
        while (digitalRead(botones[i]) == LOW);
        return i;  // Retorna el número de columna (0 a 6)
      }
    }
  }
  return 0xFF;  // Ninguno presionado
}
void loop() {
  uint8_t columna = leer_columna();
  if (columna != 0xFF) {
    //formto: A+columna+ \n
    Serial.print('A');             // Inicio msj
    Serial.print(columna);         // Número de columna char ASCII)
    Serial.print('\n');            // Fin msje
  }
}
