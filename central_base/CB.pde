/* Arquivo: CB.pde */
#include <RADIUINO.h>
#include <EEPROM.h>
#include <SPI.h>

#include "Headers.h"

// Firmware version
#define FIRMWARE_VERSION = 1.0;    // 1.0 Firmware version
byte int_rx = 0;                   // Initialization of Receive Interrupt - RFBee generates an interrupt at startup that cannot be treated
byte int_buff = 0;                 // Initialization of Buffer Overflow Interrupt - RFBee generates an interrupt at startup that cannot be treated

// Setup function. Run once at startup
void setup(){
  
  // Physic layer initialization
  Phy.initialize();

  // Mac layer initialization
  Mac.initialize();
  
  // Network layer initialization
  Net.initialize();
  
  // Attaching interruption for RF transmissions
  attachInterrupt(0, ISRVreceiveData, RISING);
  attachInterrupt(1, ISRVBufferOverflow, RISING); 
  pinMode(GDO0, INPUT);

  // Initialize timer1, and set a 1 mili second period
  Timer1.initialize(1000000);
  
  // Attaches ISRVtimer1() as a timer overflow interrupt
  Timer1.attachInterrupt(ISRVtimer1);  
  
  // Writing initialization message
  Serial.print("Radiuino! Base");
  
}

void loop(){

  // Wait for commands from PC to network
  if (Serial.available() > 0){ 
    Phy.receiveSerial();
  }

}

// Handle packet receive interrupt
void ISRVreceiveData(){
  
  if (int_rx == 0) {
    int_rx = 1;
    return;
  }

  // Echo any info received from network to PC
  if ( digitalRead(GDO0) == HIGH ) {
    
    // Receive dara from RF  
    if (Phy.receive(&g_pkt) == ERR)
      return;
    
    Phy.sendSerial(&g_pkt);
  }
  
  return;
}

// Handle buffer overflow interrupt
void ISRVBufferOverflow() {
  
  if (int_buff == 0) {
    int_buff = 1;
    return;
  }
  
  cc1101.Strobe(CC1101_SFRX);
  cc1101.Strobe(CC1101_SRX);
  
  return;  
}

// Handle Timer interrupt
void ISRVtimer1()
{  

  return;
}
