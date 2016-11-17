
int currentPin = A5;
int currentVal = 0;
int avgVal = 0;

int avgElements = 10;
int runningAvg[10] = {0};
int index = 0;

void setup() {
  
  Serial.begin(9600);

  pinMode(currentPin, INPUT);
  
}

void loop() {
  currentVal = analogRead(currentPin);
  
  index++;
  index = index % avgElements;
  runningAvg[index] = currentVal;

  int currTotal = 0;
  for(int i=0; i< avgElements; i++) {
    currTotal += runningAvg[i];
  }
  avgVal = currTotal/(float)avgElements;

  Serial.println(avgVal);
  delay(5);
}
