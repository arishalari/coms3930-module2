const int POT_PIN = 36;
const int JX_PIN  = 39;
const int JY_PIN  = 32;
const int BTN_PIN = 2;

void setup() {
  Serial.begin(115200);
  pinMode(BTN_PIN, INPUT_PULLUP);
}

void loop() {
  int pot = analogRead(POT_PIN);
  int jx  = analogRead(JX_PIN);
  int jy  = analogRead(JY_PIN);
  int btn = (digitalRead(BTN_PIN) == LOW) ? 1 : 0;

  Serial.println(String(pot) + "," + String(jx) + "," + String(jy) + "," + String(btn));
  delay(16);
}
