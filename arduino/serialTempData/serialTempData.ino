// this example is public domain. enjoy!
// www.ladyada.net/learn/sensors/thermocouple

#include "max6675.h"

// Global variable initialization
// Pins
int thermo_DO = 10;
int thermoA_CS = 8;
int thermoB_CS = 9;
int thermo_CLK = 12;
int ledPin = 13;
int relayPin = 7;

// Values
float tempA = 0;
float tempB = 0;
char k = 0;
int serialVal = 0;
boolean logActive = 0;

// Objects
MAX6675 thermocoupleA(thermo_CLK, thermoA_CS, thermo_DO);
MAX6675 thermocoupleB(thermo_CLK, thermoB_CS, thermo_DO);

void setup() 
  {
    // Setup serial handshake
    Serial.begin(9600);
    Serial.println('F');              
    while(k != 'F')
      {
        k = Serial.read();
      }
      
    pinMode(relayPin, OUTPUT);
    digitalWrite(relayPin, LOW);
    pinMode(ledPin, OUTPUT);
    
  }

void loop() 
  {
    digitalWrite(ledPin, HIGH);
    
    if (Serial.available() > 0)
      {
        serialVal = Serial.parseInt();
        switch (serialVal)
          {
            case 1234:  // Start Logging Data
              Serial.println(1234);
              logActive = 1;
              break;
            case 4321:  // Stop Logging Data
              logActive = 0;
              break;
            case 5000:  // Turn Relay OFF
              digitalWrite(relayPin, LOW);
              break;
            case 5001:  // Turn Relay ON
              digitalWrite(relayPin, HIGH);
              break;
          }
      }
    
    if (logActive)
      {
        sendTempData();
      }
  }
  
void sendTempData()
  {
    tempA = thermocoupleA.readFahrenheit();
    //tempB = thermocoupleB.readFahrenheit();  // Commented out until attach sensor
    tempB = tempA - 1.5;
    Serial.println(9998);
    Serial.println(tempA);
    Serial.println(tempB);
    Serial.println(9999);
    delay(250);
  }
