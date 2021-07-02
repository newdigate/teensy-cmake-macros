#include <Arduino.h>
#include <vector>

std::vector<float> floats;

void loop() {
    delay(1000);
    floats.push_back(1.2345);
    Serial.println("heelo");
}

void setup() {
    Serial.begin(9600);
}