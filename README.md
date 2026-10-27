# Dialpick
 
A safe-cracking game played with a physical dial. Turn a potentiometer to find three secret numbers, using a hot-to-cold indicator as the clue.
 
Blog post: [xxxx]
 
ADD GIF
 
The ESP32 reads a potentiometer (the dial), a joystick (next number), and a button (lock in answer), and sends them to a laptop over serial. A Processing sketch reads that data and runs the game.
 
## What you need
 
- ESP32 LilyGO T-Display
- Potentiometer, joystick module, push button
- Breadboard and jumper wires
- Arduino IDE with ESP32
- Processing
  
## Setup
 
Wire everything to the ESP32 on a breadboard:

- Potentiometer: outer pins to 3V and GND, middle pin to GPIO 36
- Joystick: GND to GND, VCC to 3V, VRx to GPIO 39, VRy to GPIO 32
- Button: one side to GPIO 2, the other side to GND
 
ADD FRITZ DIAGRAM

## Running it
 
1. Upload `code/dialpick-esp32/dialpick-esp32.ino` to the board from the Arduino IDE.
2. Make sure the Serial Monitor is closed. 
3. Open `code/dialpick-processing/dialpick-processing.pde` in Processing and run it.
4. The sketch prints the available serial ports in the console. In `setup()`, change the number in `Serial.list()[2]` to match your board's port.

## Playing it
- Turn the dial to find each secret number, press the button to lock it in, and push the joystick right for the next one.
- You have 45 seconds, and a wrong number costs -5 seconds.
