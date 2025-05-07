const int botonIzquierda = 2;
const int botonDerecha = 3;
const int botonSeleccionar = 4;

int columnaActual = 0; // Rango 0 a 6

void setup() {
  Serial.begin(9600);
  pinMode(botonIzquierda, INPUT_PULLUP);
  pinMode(botonDerecha, INPUT_PULLUP);
  pinMode(botonSeleccionar, INPUT_PULLUP);

  // para dev
  Serial.println("Inicio. Columna actual: 0");
}

void loop() {
  static bool btnIzqAnterior = HIGH;
  static bool btnDerAnterior = HIGH;
  static bool btnSelAnterior = HIGH;

  bool btnIzq = digitalRead(botonIzquierda);
  bool btnDer = digitalRead(botonDerecha);
  bool btnSel = digitalRead(botonSeleccionar);

  // Movimiento izquierda
  if (btnIzq == LOW && btnIzqAnterior == HIGH) {
    columnaActual = (columnaActual == 0) ? 6 : columnaActual - 1;

    delay(200); // Antirrebound
  }

  // Movimiento derecha
  if (btnDer == LOW && btnDerAnterior == HIGH) {
    columnaActual = (columnaActual == 6) ? 0 : columnaActual + 1;
    delay(200); 

  }

  // Seleccionar columna actual
  if (btnSel == LOW && btnSelAnterior == HIGH) {
    Serial.write('0' + columnaActual); // Envía por UART como ASCII

    delay(200); 
  }

  btnIzqAnterior = btnIzq;
  btnDerAnterior = btnDer;
  btnSelAnterior = btnSel;
}
