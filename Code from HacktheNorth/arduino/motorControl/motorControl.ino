const int stepPin = 7;
const int dirPin = 8;
const int motorEnablePin1 = 9;

const int forcePin1 = 2;
const int forcePin2 = 3;
const int forcePin3 = 4;
const int forcePin4 = 5;

const int maxUpMovements = 5;

int upCounter = 0;

void setup() {
  Serial.begin(9600);

  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  pinMode(motorEnablePin1, OUTPUT);

  pinMode(forcePin1, INPUT);
  pinMode(forcePin2, INPUT);
  pinMode(forcePin3, INPUT);
  pinMode(forcePin4, INPUT);

  pinMode(13, OUTPUT);


  // LOW means ENABLED
  digitalWrite(motorEnablePin1, LOW);
}

void loop() {

  int val1 = digitalRead(forcePin1);
  int val2 = digitalRead(forcePin2);
  int val3 = digitalRead(forcePin3);
  int val4 = digitalRead(forcePin4);
//
//  if (val2 == 0) {
//    digitalWrite(dirPin, HIGH);
//    for (int i = 0; i < incrementalSteps; i++) {
//      digitalWrite(stepPin, HIGH);
//      delayMicroseconds(1000);
//      digitalWrite(stepPin, LOW);
//      delayMicroseconds(1000);
//    }
//  }
//  else if (val2 == 1) { // up
//
//    digitalWrite(dirPin, LOW);
//    for (int i = 0; i < incrementalSteps; i++) {
//      digitalWrite(stepPin, HIGH);
//      delayMicroseconds(1000);
//      digitalWrite(stepPin, LOW);
//      delayMicroseconds(1000);
//    }
//
//  }

 
    int shouldGoUp = 0;
    int delayMicro = 1000;
    if (val1 == 0) {
      delayMicro = 1100;

      // HIGH means arm going down
      digitalWrite(dirPin, HIGH);
      if (upCounter > 0) {
        digitalWrite(stepPin, HIGH);
        delayMicroseconds(delayMicro);
        digitalWrite(stepPin, LOW);
        delayMicroseconds(delayMicro);

        upCounter -= 1;
      }
      return;

    } else if (val2 == 0) {

      //do nothing
      return;

    } else if (val3 == 0) {
      delayMicro = 3000;
      shouldGoUp = 1;
    } else if (val4 == 0) {
      delayMicro = 2000;
      shouldGoUp = 1;
    } else if (val4 == 1) {
      delayMicro = 1100;
      shouldGoUp = 1;
    }

    if (shouldGoUp == 1) {
      // Arm going up
      digitalWrite(dirPin, LOW);

      digitalWrite(stepPin, HIGH);
      delayMicroseconds(delayMicro);
      digitalWrite(stepPin, LOW);
      delayMicroseconds(delayMicro);
      upCounter += 1;

      //Serial.print("Pos: ");
      //Serial.println(upCounter);
      return;
    }

  }
 
}
