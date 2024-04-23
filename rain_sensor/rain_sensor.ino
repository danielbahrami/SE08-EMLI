#include <Servo.h>

Servo servo;
bool wiping = false;

void setup() {
  servo.attach(15);
}

void loop() {
  if (BOOTSEL) {
    if (!wiping) {
      for (int i = 0; i < 3; i++) {
        wipe();
      }
      wiping = true;
    }
    delay(10);
  } else {
    wiping = false;
  }
}

void wipe() {
  for (int angle = 0; angle <= 180; angle++) {
    servo.write(angle);
    delay(5);
  }
  for (int angle = 180; angle >= 0; angle--) {
    servo.write(angle);
    delay(5);
  }
}
