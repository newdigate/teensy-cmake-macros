#include <Arduino.h>

void loop() {
    delay(1000);
    Serial.println("hello");
}

void setup() {
    Serial.begin(9600);
    while(!Serial) { delay(1000); }
}