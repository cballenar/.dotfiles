#include "HomeSpan.h"

// RELAY CONFIGURATION
// Most 3-pin modules are 'Active Low' (0V = Trigger). 
// If your relay stays ON all the time, swap HIGH and LOW below.
#define RELAY_ON  HIGH
#define RELAY_OFF LOW
const int RELAY_PIN = 9;
const int PULSE_LENGTH = 600;

struct GateBuzzer : Service::LockMechanism { 
  
  SpanCharacteristic *lockCurrentState;
  SpanCharacteristic *lockTargetState;

  GateBuzzer() : Service::LockMechanism() {
    pinMode(RELAY_PIN, OUTPUT);
    digitalWrite(RELAY_PIN, RELAY_OFF); 

    // 0 = Unlocked, 1 = Locked
    lockCurrentState = new Characteristic::LockCurrentState(1); 
    lockTargetState = new Characteristic::LockTargetState(1);
    
    Serial.printf("S3 Gate Buzzer initialized on GPIO %d\n", RELAY_PIN);
  }

  boolean update() override {
    if(lockTargetState->getNewVal() == 0) {
      Serial.println("Gate Buzzing...");

      digitalWrite(RELAY_PIN, RELAY_ON);
      lockCurrentState->setVal(0); 

      // Pulse
      delay(PULSE_LENGTH);

      digitalWrite(RELAY_PIN, RELAY_OFF);
      
      // Auto-reset the lock icon in HomeKit
      lockTargetState->setVal(1);
      lockCurrentState->setVal(1);
      Serial.println("Buzzer Reset.");
    }
    return true;
  }
};

void setup() {
  Serial.begin(115200);

  // OPTIONAL: Uncomment and fill these if you want to skip the setup process
  // homeSpan.setWifiCredentials("SSID", "PASSWORD");

  homeSpan.begin(Category::Locks, "Gate Opener");

  new SpanAccessory();
    new Service::AccessoryInformation();
      new Characteristic::Identify();
      new Characteristic::Name("Main Gate");
    
    new GateBuzzer(); 
}

void loop() {
  homeSpan.poll();
}
