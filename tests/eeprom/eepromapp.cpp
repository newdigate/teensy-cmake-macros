#include <Arduino.h>
#include <EEPROM.h>

void loop() {
    delay(1000);
    Serial.println("heelo");
}

void setup() {
    Serial.begin(9600);
}