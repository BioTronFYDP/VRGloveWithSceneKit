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
  
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  pinMode(motorEnablePin1, OUTPUT);
  pinMode(motorEnablePin2, OUTPUT);

  // LOW means ENABLED
  digitalWrite(motorEnablePin1, LOW);
  digitalWrite(motorEnablePin2, HIGH);
}

void loop() {

  // back and forth
  digitalWrite(dirPin, HIGH);
  
  for(int i=0; i< totalSteps; i++) {
    digitalWrite(stepPin, HIGH);
    delayMicroseconds(1000);
    digitalWrite(stepPin, LOW);
    delayMicroseconds(1000);
  }

  digitalWrite(dirPin, LOW);
  
  for(int i=0; i< totalSteps; i++) {
    digitalWrite(stepPin, HIGH);
    delayMicroseconds(1000);
    digitalWrite(stepPin, LOW);
    delayMicroseconds(1000);
  }

}

