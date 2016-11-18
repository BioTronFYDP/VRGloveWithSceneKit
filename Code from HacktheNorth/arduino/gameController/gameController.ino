const int stepPin = 7;
const int dirPin = 8;
const int motorEnablePin1 = 9;

const int incrementalSteps = 50;

void setup() {
  Serial.begin(9600);
  
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  pinMode(motorEnablePin1, OUTPUT);

  // LOW means ENABLED
  digitalWrite(motorEnablePin1, LOW);
}

void loop() {

  if (Serial.available() > 0) {

    int incomingByte = Serial.read();

    if (incomingByte == 97) {
      digitalWrite(dirPin, HIGH);
      for(int i=0; i< incrementalSteps; i++) {
        digitalWrite(stepPin, HIGH);
        delayMicroseconds(1000);
        digitalWrite(stepPin, LOW);
        delayMicroseconds(1000);
      }
    }
    else if (incomingByte == 121) { // up

      digitalWrite(dirPin, LOW);
      for(int i=0; i< incrementalSteps; i++) {
        digitalWrite(stepPin, HIGH);
        delayMicroseconds(1000);
        digitalWrite(stepPin, LOW);
        delayMicroseconds(1000);
      }
   
    }
      
  }

}

