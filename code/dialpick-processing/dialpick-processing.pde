import processing.serial.*;

Serial port;
int pot, jx, jy, btn;
int dial = 0;

//game
int[] secret = new int[3];
boolean[] locked = new boolean[3];
int idx = 0;
String state = "START";
String message = "";

//timer
int TIME_LIMIT = 45000;
int PENALTY = 5000;
int startTime = 0;
int penalty = 0;
int timeLeft = 45000;

// remember the last frame, so one press counts once
int prevBtn = 0;
boolean prevRight = false;

// confetti
int confettiY = 0;
int[] confX = {12, 150, 60, 180, 95, 30, 130, 170, 75, 110, 45, 160, 20, 140, 100, 185, 55, 125, 85, 165};

void setup() {
  size(800, 800);
  noSmooth();
  printArray(Serial.list());
  port = new Serial(this, Serial.list()[2], 115200);
  port.bufferUntil('\n');
  newRound();
  state = "START";
}

void serialEvent(Serial p) {
  String line = p.readStringUntil('\n');
  if (line == null) return;
  int[] v = int(split(trim(line), ','));
  if (v.length == 4) {
    pot = v[0];
    jx = v[1];
    jy = v[2];
    btn = v[3];
  }
}

void draw() {
  dial = int(map(pot, 0, 4095, 0, 99));

  // the timer only runs while you're playing
  if (state.equals("PLAY")) {
    timeLeft = TIME_LIMIT - (millis() - startTime) - penalty;
    if (timeLeft <= 0) {
      timeLeft = 0;
      state = "LOSE";
    }
  }

  // joystick right = next number
  boolean right = jy > 3000;
  if (right && !prevRight && state.equals("PLAY")) nextNumber();
  prevRight = right;

  // button: lock in a number while playing, otherwise (re)start the game
  if (btn == 1 && prevBtn == 0) {
    if (state.equals("PLAY")) pressButton();
    else newRound();
  }
  prevBtn = btn;

  // draw everything
  background(20, 20, 40);
  scale(4);
  drawBorder();
  drawBar();
  drawSafe();
  if (state.equals("WIN")) drawGold();
  else drawDoor();
  drawText();
  if (state.equals("WIN")) drawConfetti();
  if (state.equals("START")) drawInstructions();
}

//game rules
void newRound() {
  for (int i = 0; i < 3; i++) {
    secret[i] = int(random(100));
    locked[i] = false;
  }
  idx = 0;
  penalty = 0;
  timeLeft = TIME_LIMIT;
  startTime = millis();
  state = "PLAY";
  message = "";
  confettiY = 0;
  println("Secret: " + secret[0] + ", " + secret[1] + ", " + secret[2]);
}

void pressButton() {
  if (locked[idx]) return;
  if (dial == secret[idx]) {
    locked[idx] = true;
    message = "CORRECT";
    if (locked[0] && locked[1] && locked[2]) state = "WIN";
  } else {
    message = "WRONG -5s";
    penalty = penalty + PENALTY;
  }
}

void nextNumber() {
  if (locked[idx] && idx < 2) {
    idx = idx + 1;
    message = "";
  }
}

//drawing (the picture is 200 x 200)
void drawBorder() {
  noFill();
  strokeWeight(3);
  stroke(90);
  if (state.equals("LOSE") && frameCount % 20 < 10) stroke(255, 0, 0);
  rect(2, 2, 196, 196);
  noStroke();
}

void drawBar() {
  // five color blocks, hot on the left and cold on the right
  noStroke();
  fill(230, 30, 30);   rect(50, 12, 20, 10);
  fill(255, 130, 0);   rect(70, 12, 20, 10);
  fill(255, 220, 0);   rect(90, 12, 20, 10);
  fill(0, 190, 230);   rect(110, 12, 20, 10);
  fill(30, 60, 200);   rect(130, 12, 20, 10);

  // how far is the dial from the secret number?
  int d = abs(dial - secret[idx]);
  if (locked[idx]) d = 0;

  // the white marker sits on the block that matches the distance
  int markerX = 139;
  if (d <= 16) markerX = 119;
  if (d <= 10) markerX = 99;
  if (d <= 6) markerX = 79;
  if (d <= 3) markerX = 59;
  fill(255);
  rect(markerX, 8, 3, 18);

  // green outline when you are within 2 numbers
  if (d <= 2) {
    noFill();
    stroke(0, 255, 0);
    strokeWeight(1);
    rect(49, 11, 102, 12);
    noStroke();
  }
}

void drawSafe() {
  noStroke();
  fill(130, 135, 150);
  quad(40, 50, 60, 38, 160, 38, 140, 50);
  fill(70, 75, 90);
  quad(140, 50, 160, 38, 160, 148, 140, 160);
  fill(100, 105, 120);
  rect(40, 50, 100, 110);
}

void drawDoor() {
  noStroke();
  fill(85, 90, 105);
  rect(48, 58, 84, 94);
  fill(40);
  rect(126, 75, 6, 10);
  rect(126, 125, 6, 10);

  // the dial and its needle
  fill(40);
  ellipse(72, 125, 38, 38);
  fill(190);
  ellipse(72, 125, 30, 30);
  float angle = map(dial, 0, 99, 0, TWO_PI);
  stroke(230, 30, 30);
  strokeWeight(2);
  line(72, 125, 72 + 13 * sin(angle), 125 - 13 * cos(angle));
  noStroke();
  fill(255, 200, 0);
  triangle(69, 102, 75, 102, 72, 107);

  // three number windows
  for (int i = 0; i < 3; i++) {
    int x = 54 + i * 24;
    fill(15, 15, 25);
    rect(x, 68, 20, 28);

    if (i == idx) {
      noFill();
      stroke(255, 200, 0);
      strokeWeight(1);
      rect(x, 68, 20, 28);
      noStroke();
    }

    textSize(11);
    if (locked[i]) {
      fill(0, 255, 0);
      text(secret[i], x + 3, 86);
    } else if (i == idx) {
      fill(255);
      text(dial, x + 3, 86);
    }
  }
}

void drawGold() {
  noStroke();
  fill(25, 20, 30);
  rect(46, 56, 88, 98);
  for (int row = 0; row < 4; row++) {
    for (int i = 0; i < 4; i++) {
      fill(255, 200, 0);
      rect(48 + i * 22, 62 + row * 24, 20, 10);
      fill(255, 235, 130);
      rect(48 + i * 22, 62 + row * 24, 20, 2);
    }
  }
}

void drawText() {
  noStroke();
  fill(255, 200, 0);
  rect(10, 185, timeLeft / 250, 5);

  fill(255);
  textSize(8);
  text(message, 8, 180);
  text(timeLeft / 1000 + "s", 170, 180);

  if (state.equals("WIN") || state.equals("LOSE")) {
    fill(255);
    textSize(8);
    text("Press the button to play again", 45, 172);
  }
  if (state.equals("LOSE")) {
    fill(0);
    rect(40, 88, 120, 24);
    fill(255, 0, 0);
    textSize(16);
    text("GAME OVER", 50, 107);
  }
}

void drawConfetti() {
  confettiY = confettiY + 2;
  if (confettiY > 260) confettiY = 0;
  noStroke();
  for (int i = 0; i < 20; i++) {
    fill(255, 80 + i * 8, 255 - i * 10);
    rect(confX[i], confettiY - i * 10, 4, 4);
  }
}

void drawInstructions() {
  fill(15, 15, 25);
  stroke(255, 200, 0);
  strokeWeight(2);
  rect(15, 30, 170, 140);
  noStroke();

  fill(255);
  textSize(8);
  text("HOW TO PLAY\n\n"
     + "Find the 3 secret numbers.\n"
     + "Turn the dial, then press the button to lock a number in.\n"
     + "The bar shows how close you are: red is hot, blue is cold.\n"
     + "Push the joystick right for the next number.\n"
     + "Wrong guesses cost 5 seconds.\n\n"
     + "Press the button to start", 23, 38, 154, 128);
}
