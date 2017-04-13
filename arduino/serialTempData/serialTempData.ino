#include "max6675.h"

// Global variable initialization
// Pins
int ENA = 5;  // PWM
int IN1 = 4;  // H-Bridge input 1
int IN2 = 3;  // H-Bridge input 2
int thermo_DO = 10;
int thermoA_CS = 8;
int thermoB_CS = 9;
int thermo_CLK = 12;
int ledPin = 13;
int relayPin = 6;

// Values
int u = 0;
float tempA = 0;
float tempB = 0;
char k = 0;
int serialVal = 0;
boolean logActive = 0;
volatile int countVal = 0;

// Objects
MAX6675 thermocoupleA(thermo_CLK, thermoA_CS, thermo_DO);
MAX6675 thermocoupleB(thermo_CLK, thermoB_CS, thermo_DO);

void setup() 
  {
    // Encoder interrupt
    attachInterrupt(0, encoderPulse, RISING);
    
    // Setup serial handshake
    Serial.begin(9600);
    Serial.println('F');              
    while(k != 'F')
      {
        k = Serial.read();
      }
    
    // Pin modes
    pinMode(relayPin, OUTPUT);
    analogWrite(relayPin, 0);
    pinMode(ledPin, OUTPUT);
    pinMode(ENA, OUTPUT);
    pinMode(IN1, OUTPUT);
    pinMode(IN2, OUTPUT);
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, LOW);
    analogWrite(ENA, 0);
    
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
            default:
              if (serialVal >= 0 and serialVal <= 255)
                {
                  u = serialVal;
                }
              break;
          }
      }
    
    if (logActive)
      {
        sendTempData();
        analogWrite(relayPin, u);
      }
    else
      {
        analogWrite(relayPin, 0);
      }
    
  }
  
void sendTempData()
  {
    tempA = thermocoupleA.readFahrenheit();
    //tempB = thermocoupleB.readFahrenheit();  // Commented out until attach sensor
    tempB = thermocoupleB.readFahrenheit();
    Serial.println(9998);
    Serial.println(tempA);
    Serial.println(tempB);
    Serial.println(9999);
    delay(250);
  }
  
void encoderPulse()
    {
      countVal = countVal + 1;
    }
