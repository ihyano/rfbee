/* Arquivo RT.pde */
#include <RADIUINO.h>
#include <EEPROM.h>
#include <SPI.h>

#include <avr/wdt.h>

#include <avr/power.h>
#include <avr/sleep.h>

#include <util/delay.h> 
#include <util/atomic.h> 

#include <avr/interrupt.h>   
#include <avr/io.h> 

#include "Headers.h"

#define LED_PIN (13)

volatile int f_wdt=0;

int ct_awake = 0;
int periodo = 1;
int ct_awake_ant = 0;
int ct_awake_dep = 0;

int cont_v =0;
int cont_h =0;
int cont_l =0;
int cont_ciclo =0;
int cont_ciclo2=0;
int cont_ciclo3=0;

int flag1=1;
int flag2=0;
boolean enviou = false;

int ct_delay_ant =3;
int ct_delay_ant2 =3;
int ct_compensa =3;
int ct_compensa2 =3;
int ct_delay_dep =0;
int ct_delay_sav =0;
int ct_envia = 0;     

byte RSSIu1;
byte RSSIu2;
byte RSSIu3;

byte RSSId1;
byte RSSId2;
byte RSSId3;

byte ad01h;
byte ad02h;
byte ad03h;

byte ad01l;
byte ad02l;
byte ad03l;

byte salva_rssi;
byte salva_lqi;

byte ID1;
byte ID2;
byte ID3;

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
 Serial.print("Radiuino! Sensor");
 
 analogReference(2);
 
}

void loop(){

volta:

 periodo2(); 
 periodo3();   
 periodo1();
 
 Phy.send_agr(&g_pkt);
    delay(4);
 
      setup_wdt_500();  
      enterSleep();
      setup_wdt_1000();  
      enterSleep();

}

// Handle packet receive interrupt
void ISRVreceiveData(){
 
 if (int_rx == 0) {
 int_rx = 1;
 return;
 }
 
 // Receive data from base and reply with sensor information
 if ( digitalRead(GDO0) == HIGH ) {
 
 // Receive data from RF  
    Phy.receive(&g_pkt);      
    
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



/*  Description: Watchdog Interrupt Service. This
 *               is executed when watchdog timed out. */
ISR(WDT_vect)
{
  if(f_wdt == 0)
  {
    f_wdt=1;
  }
  else
  {
    Serial.println("WDT Overrun!!!");
  } 
}

 /*  Description: Setup for the serial comms and the
 *                Watch dog timeout. */
void setup_wdt_1000()
{
  Serial.println("Initialising...");
  
  /*** Setup the WDT ***/
  
  /* Clear the reset flag. */
  MCUSR &= ~(1<<WDRF);
  
  /* In order to change WDE or the prescaler, we need to
   * set WDCE (This will allow updates for 4 clock cycles).
   */
  WDTCSR |= (1<<WDCE) | (1<<WDE);

  /* set new watchdog timeout prescaler value */
  WDTCSR = 1<<WDP1 | 1<<WDP2; /* 1.0 seconds */
 // WDTCSR = 1<<WDP0 | 1<<WDP1; /* 0.125 second */
  
  /* Enable the WD interrupt (note no reset). */
  WDTCSR |= _BV(WDIE);
  
  Serial.println("Initialisation complete.");
}

void setup_wdt_250()
{
  Serial.println("Initialising...");
  
  /*** Setup the WDT ***/
  
  /* Clear the reset flag. */
  MCUSR &= ~(1<<WDRF);
  
  /* In order to change WDE or the prescaler, we need to
   * set WDCE (This will allow updates for 4 clock cycles).
   */
  WDTCSR |= (1<<WDCE) | (1<<WDE);

  /* set new watchdog timeout prescaler value */
 // WDTCSR = 1<<WDP0 | 1<<WDP1 | 1<<WDP2; /* 2.0 seconds */
  WDTCSR = 1<<WDP2; /* 0.250 second */
  
  /* Enable the WD interrupt (note no reset). */
  WDTCSR |= _BV(WDIE);
  
  Serial.println("Initialisation complete.");
}

void setup_wdt_500()
{
  Serial.println("Initialising...");
  
  /*** Setup the WDT ***/
  
  /* Clear the reset flag. */
  MCUSR &= ~(1<<WDRF);
  
  /* In order to change WDE or the prescaler, we need to
   * set WDCE (This will allow updates for 4 clock cycles).
   */
  WDTCSR |= (1<<WDCE) | (1<<WDE);

  /* set new watchdog timeout prescaler value */
 // WDTCSR = 1<<WDP0 | 1<<WDP3; /* 8.0 seconds */
 // WDTCSR = 1<<WDP3; /* 4.0 seconds */
  WDTCSR = 1<<WDP0 | 1<<WDP2; /* 0.5 second */
 // WDTCSR = 1<<WDP0 | 1<<WDP1; /* 0.125 second */
    
  /* Enable the WD interrupt (note no reset). */
  WDTCSR |= _BV(WDIE);
  
  Serial.println("Initialisation complete.");
}

void setup_wdt_64()
{
  Serial.println("Initialising...");
  
  /*** Setup the WDT ***/
  
  /* Clear the reset flag. */
  MCUSR &= ~(1<<WDRF);
  
  /* In order to change WDE or the prescaler, we need to
   * set WDCE (This will allow updates for 4 clock cycles).
   */
  WDTCSR |= (1<<WDCE) | (1<<WDE);

  /* set new watchdog timeout prescaler value */
 // WDTCSR = 1<<WDP0 | 1<<WDP3; /* 8.0 seconds */
 // WDTCSR = 1<<WDP3; /* 4.0 seconds */
 //  WDTCSR = 1<<WDP0; /* 0.032 second */
// wdt_enable(WDTO_120MS);
// wdt_enable(WDTO_8S);
wdt_enable(WDTO_15MS);

  
  /* Enable the WD interrupt (note no reset). */
  WDTCSR |= _BV(WDIE);
  
//  Serial.println("Initialisation complete.");
}

/***************************************************
 *  Name:        enterSleep
 *
 *  Returns:     Nothing.
 *
 *  Parameters:  None.
 *
 *  Description: Enters the arduino into sleep mode.
 *
 ***************************************************/
void enterSleep(void)
{
 // set_sleep_mode(SLEEP_MODE_PWR_SAVE);
  set_sleep_mode(SLEEP_MODE_PWR_DOWN);

CSn(0); 
while(bit_is_set(PINB,4)){} 
SPI_MasterTransmit(0x36); //idle mode 
_delay_ms(100); 
SPI_MasterTransmit(0x39); //sleep mode 
CSn(1); 

/* GICR=1<<INT1; 
set_sleep_mode(SLEEP_MODE_PWR_DOWN); 
MCUCR=(0<<ISC11)|(0<<ISC10); 
sei(); */ 

  
  sleep_enable();
  
  /* Now enter sleep mode. */
  sleep_mode();
  
  /* The program will continue from here after the WDT timeout*/
  sleep_disable(); /* First thing to do is disable sleep. */
  
  /* Re-enable the peripherals. */
  power_all_enable();
  
}

void sleepAtmega(void)
{
 
  set_sleep_mode(SLEEP_MODE_PWR_DOWN);

//  CSn(0); 

  sei();

  
  sleep_enable();
  
  /* Now enter sleep mode. */
  sleep_mode();
  
  /* The program will continue from here after the WDT timeout*/
  sleep_disable(); /* First thing to do is disable sleep. */
  
  /* Re-enable the peripherals. */
  power_all_enable();
  
}



void SPI_MasterTransmit(char cData) //Transmit data on the SPI interface
{

SPDR = cData; // Start transmission

while(!(SPSR & (1<<SPIF))) // Wait for transmission complete
;
}

void CSn(int i) //Toggle CSn
{
if(i==1)
PORTB|=0x04;
else
PORTB&=0xFB;
} 

void ad_contad(void) {

  if (cont_l == 255) {
      cont_h++;
      cont_l = 0;
      if (cont_h == 255) {
         cont_v++;
         cont_h = 0;
         }
      else {
         }
  }
 else { cont_l++;
         }
  
  return;
    
    }

void acorda() {
  cc1101.Strobe(CC1101_SIDLE);
       delay(1);
       cc1101.Write(CC1101_MCSM1 ,   0x0F );
       cc1101.Strobe(CC1101_SFTX);
       cc1101.Strobe(CC1101_SFRX);
       cc1101.Strobe(CC1101_SRX); 
}

void periodo1() {
  
   flag1 = 1;
   flag2 = 0;

   cont_ciclo++;

  if  (cont_ciclo3 > 0) {
          Net.envia(&g_pkt);
         }     

   ct_awake_ant = 0;         
   while (ct_awake_ant < 88) {
      delay(1);
      ct_delay_sav++;
      ct_awake_ant++;
      if (flag2 > 0) {
        ct_awake_ant = 88;  }
      }
      
   delay(4);
   int ct_awake_dur = 4;         
   ct_delay_dep = ct_awake_dur;     
   if (flag2 > 0) {
     ct_awake_dur = 88; }
   else {   Net.envia(&g_pkt); }

   while (ct_awake_dur < 88) {
      delay(1);
      ct_awake_dur++;
      ct_delay_sav++;
      ct_delay_dep++;
      if (flag2 > 0) {
        ct_awake_dur = 88;  }
      }

      
  
}

void periodo2() {


   flag1 = 2;
   flag2 = 1;
  
   cont_ciclo2++;
//   if  (cont_ciclo2 > 0) {
          Net.envia(&g_pkt);
//          cont_ciclo2 = 0;
//          }     

    ct_awake_ant = 0;         
   while (ct_awake_ant < 88) {
      delay(1);
      ct_delay_sav++;
      ct_awake_ant++;
      if (flag2 > 1) {
        ct_awake_ant = 88;  }
      }

   delay(4);
   int ct_awake_dur = 4;         
   ct_delay_dep = ct_awake_dur;     
   if (flag2 > 1) {
     ct_awake_dur = 40; }

   while (ct_awake_dur < 30) {
      delay(1);
      ct_awake_dur++;
      ct_delay_sav++;
      ct_delay_dep++;
      if (flag2 > 1) {
       ct_awake_dur = 40; }

      }
  
}

void periodo3() {


   flag1 = 3;
   flag2 = 2;
   
   cont_ciclo3++;

   if  (cont_ciclo2 > 0) {
          Net.envia(&g_pkt);

          }     

     ct_awake_ant = 0;         
   while (ct_awake_ant < 88) {
      delay(1);
      ct_delay_sav++;
      ct_awake_ant++;
      if (flag2 > 2) {
        ct_awake_ant = 88;  }
      }

   delay(4);
   int ct_awake_dur = 4;         
   ct_delay_dep = ct_awake_dur;     
   if (flag2 > 2) {
     ct_awake_dur = 88; }
   else {   Net.envia(&g_pkt); }

   while (ct_awake_dur < 88) {
      delay(1);
      ct_awake_dur++;
      ct_delay_sav++;
      ct_delay_dep++;
      if (flag2 > 2) {
       ct_awake_dur = 88; }

      }
      
 
}

void verifica_envio() {
  
 ATOMIC_BLOCK(ATOMIC_FORCEON);

   enviou = false;
   delayMicroseconds(500);  
    
    while(Phy.txFifoFree() != CC1101_FIFO_SIZE)
         {ct_envia++;
         delay(1);} 

         enviou = true;

    
}
