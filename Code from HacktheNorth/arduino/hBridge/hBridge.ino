#include <Stepper.h>

#define STEPS 100

Stepper stepper(STEPS, 8, 9, 10, 11);

const int stepPin = 7;
const int dirPin = 8;
const int motorEnablePin1 = 9;
const int motorEnablePin2 = 2;

const int motor2PinA = 3;
const int motor2PinB = 4;
const int motor2PinC = 5;
const int motor2PinD = 6;

const int totalSteps = 380;
const int incrementalSteps = 50;

void setup() {
  Serial.begin(9600);
  
  stepper.setSpeed(10);
}

void loop() {

  if (Serial.available() > 0) {

    int incomingByte = Serial.read();

    if (incomingByte == 97) {
      digitalWrite(dirPin, HIGH);
      for(int i=0; i< incrementalSteps; i++) {
        stepper.step(30);
      }
    }
    else if (incomingByte == 121) { // up

      digitalWrite(dirPin, LOW);
      for(int i=0; i< incrementalSteps; i++) {
        stepper.step(-30);
      }
   
    }
      
  }

}

