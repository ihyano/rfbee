/* Arquivo: RN.pde */
#include <RADIUINO.h>
#include <EEPROM.h>
#include <SPI.h>

#include <avr/wdt.h>

#include <avr/power.h>
#include <avr/sleep.h>

#include <avr/interrupt.h>   
#include <avr/io.h> 

#include <util/delay.h> 
#include <util/atomic.h>

#include "Headers.h"

#define LED_PIN (13)

volatile int f_wdt=0;

int ct_delay_ant =6;
int ct_delay_ant_sav =0;
int ct_delay_dep =0;
int ct_delay_sav =0;
int ct_envia =0;

int ct_awake =0;
int ct_compensa =0;

int cont_v =0;
int cont_h =0;
int cont_l =0;

bool recebido = false;
bool prim_vez = true;
bool stay_awake = false;

int latencia_rot = 7;
int latencia_rot_ant = 7;

byte RSSId1;
byte ad01h;
byte ad01l;
byte ID1;

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
 
 // Transport layer initialization
 Transp.initialize();
 
 // Application layer initialization
 App.initialize();
 
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
 
 setup_wdt();
 
}

void loop(){
  
    recebido = false;
    
    espera_chamada();

    Net.envia(&g_pkt);     
       setup_wdt_1000();  
       enterSleep();
       setup_wdt_500();  
       enterSleep();
  //     setup_wdt_250();  
    //   enterSleep();
       acorda();

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


/***************************************************
 *  Name:        ISR(WDT_vect)
 *
 *  Returns:     Nothing.
 *
 *  Parameters:  None.
 *
 *  Description: Watchdog Interrupt Service. This
 *               is executed when watchdog timed out.
 *
 ***************************************************/
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

/***************************************************
 *  Name:        setup
 *
 *  Returns:     Nothing.
 *
 *  Parameters:  None.
 *
 *  Description: Setup for the serial comms and the
 *                Watch dog timeout. 
 *
 ***************************************************/
void setup_wdt()
{
 // Serial.begin(9600);
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
  WDTCSR = 1<<WDP1 | 1<<WDP2; /* 1.0 second */
  
  /* Enable the WD interrupt (note no reset). */
  WDTCSR |= _BV(WDIE);
  
  Serial.println("Initialisation complete.");
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
  
 // CSn(0);
  
 // SPI_MasterTransmit(0x36); //idle mode
  /* Re-enable the peripherals. */
  power_all_enable();
  
//  CSn(0);
//  while(bit_is_set(PINB,fb)){} 
//  SPI_MasterTransmit(0x36); //idle mode
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

void setup_wdt_2000()
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
  WDTCSR = 1<<WDP0 | 1<<WDP1 | 1<<WDP2; /* 2.0 seconds */
 // WDTCSR = 1<<WDP2; /* 0.250 second */
  
  /* Enable the WD interrupt (note no reset). */
  WDTCSR |= _BV(WDIE);
  
  Serial.println("Initialisation complete.");
}

void setup_wdt_125()
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
 // WDTCSR = 1<<WDP0 | 1<<WDP2; /* 0.5 second */
  WDTCSR = 1<<WDP0 | 1<<WDP1; /* 0.125 second */
    
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
 //  WDTCSR = 1<<WDP0; /* 0.032 second */
// wdt_enable(WDTO_120MS);
// wdt_enable(WDTO_8S);
// wdt_enable(WDTO_15MS);

  
  /* Enable the WD interrupt (note no reset). */
  WDTCSR |= _BV(WDIE);
  
//  Serial.println("Initialisation complete.");
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
 // WDTCSR = 1<<WDP0 | 1<<WDP3; /* 8.0 seconds */
 // WDTCSR = 1<<WDP3; /* 4.0 seconds */
   //  WDTCSR = 1<<WDP0; /* 0.032 second */
  WDTCSR = 1<<WDP2; /* 0.250 second */
  
  /* Enable the WD interrupt (note no reset). */
  WDTCSR |= _BV(WDIE);
  
//  Serial.println("Initialisation complete.");
}

void setup_wdt_32()
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
 // WDTCSR = 1<<WDP0 | 1<<WDP2; /* 0.5 second */
  WDTCSR = 1<<WDP0; /* 0.032 second */
//  WDTCSR = 1<<WDP0 | 1<<WDP1; /* 0.125 second */
    
  /* Enable the WD interrupt (note no reset). */
  WDTCSR |= _BV(WDIE);
  
  Serial.println("Initialisation complete.");
}

void acorda() {
  cc1101.Strobe(CC1101_SIDLE);
       delay(1);
       cc1101.Write(CC1101_MCSM1 ,   0x0F );
       cc1101.Strobe(CC1101_SFTX);
       cc1101.Strobe(CC1101_SFRX);
       cc1101.Strobe(CC1101_SRX); 
}


 void espera_chamada() {
   
   stay_awake = true;
   
continua_acordado:

   if (stay_awake == true) {
      delay(10);
      goto continua_acordado; }  
 
 }
 
 void verifica_envio() {
    
ATOMIC_BLOCK(ATOMIC_FORCEON);
//   enviou = false;
   
//   delay(20);
   
cont_envio:   

      delayMicroseconds(500);
      while(Phy.txFifoFree() != CC1101_FIFO_SIZE)
         {ct_envia++;
         delay(1);} 

   
/* 
   if (Phy.txFifoFree() != CC1101_FIFO_SIZE)
   { enviou = false;
   }
   else
   {enviou = true;}
   
   if (enviou == false) {
      delay(1);
      ct_envia++;
      if (ct_envia > 40) {
        enviou = true; } 
      else
        {goto cont_envio;}
    } */
}




/* Arquivo: RN_3_Net.pde  */
#include "Headers.h"

//---------- Constructor --------------------------------------------------------

NET::NET(){

  MY_ADDR = 55;    // My address
  
}

void NET::initialize(void) {

}

inline void NET::send(packet * pkt) {

  return;  
}

inline void NET::receive(packet * pkt) {
      
  // Addressing packet - Exchanging addresses
/*  pkt->NetHdr[0] = pkt->NetHdr[2];
  pkt->NetHdr[0] = 10;
  pkt->NetHdr[2] = Net.MY_ADDR;
  pkt->NetHdr[1] = 222;
  
   Transp.receive(pkt);
if (pkt->NetHdr[0] == 10) {
      if (pkt->NetHdr[2] == Net.MY_ADDR) {
         if (pkt->NetHdr[1] == 8) {
             recebido = true;
         }
         else { recebido = false;
         }
      }
      else { recebido = false;
      }
  }
  else { recebido = false;
  }     */
  
  if (pkt->NetHdr[1] == 8) {
      ct_delay_sav = ct_awake;
      recebido = true;
      }
//  else { recebido = false;
  //     }
  
  
  return;  
}

inline void NET::envia(packet * pkt) {
      
  // Addressing packet - Exchanging addresses
  pkt->NetHdr[1] = 222;
  pkt->NetHdr[0] = 10;
  pkt->NetHdr[2] = Net.MY_ADDR;
  
  App.envia(pkt);
  
  return;  
}





//---------- Preinstantiate Network object --------------------------------------

NET Net = NET();


/* Arquivo: RN_5_App.pde  */


#include "Headers.h"

//---------- Constructor -----------------------------------------------------------

#define AD0_PIN  0
#define AD1_PIN  1
#define AD2_PIN  2
#define AD3_PIN  3
#define AD4_PIN  4
#define AD5_PIN  5

#define IO0_PIN  4
#define IO1_PIN  5
#define IO2_PIN  6
#define IO3_PIN  7
#define IO4_PIN  8
#define IO5_PIN  9

APP::APP(){

}

void APP::initialize(void) {
  
  pinMode (IO0_PIN, OUTPUT); 
  pinMode (IO1_PIN, OUTPUT); 
  pinMode (IO2_PIN, OUTPUT); 
  pinMode (IO3_PIN, OUTPUT); 
  pinMode (IO4_PIN, OUTPUT); 
  pinMode (IO5_PIN, OUTPUT); 
  
}

inline void APP::send(packet * pkt) {

  return;  
}

inline void APP::receive(packet * pkt) {
  
  // envia(pkt);
  
  return;  
}


inline void APP::envia(packet * pkt) {
  int AD0, AD1;
int cont_v =0;
int cont_alto =0;
int cont_baixo =0;
int wcontad =0;

  
  // IO0
  if (pkt->IO0[0] == 1)
  {
    digitalWrite (IO0_PIN, HIGH);
  }
  else {
    digitalWrite (IO0_PIN, LOW);
  }

  // IO0
  if (pkt->IO1[0] == 1)
  {
    digitalWrite (IO1_PIN, HIGH);
  }
  else {
    digitalWrite (IO1_PIN, LOW);
  }
  
  // AD0
  AD0 = analogRead(AD0_PIN);
  
  pkt->AD0[1] = (byte) (AD0/256);
  pkt->AD0[2] = (byte) (AD0%256);
  
  // AD1
  AD1 = analogRead(AD1_PIN);
  
  pkt->AD1[1] = (byte) (AD1/256);
  pkt->AD1[2] = (byte) (AD1%256);
  pkt->AD1[0] = ct_envia;

  ad_contad();
  
  pkt->AD2[2] = cont_l;
  pkt->AD2[1] = cont_h;
  pkt->AD2[0] = cont_v;


  pkt->AD4[2] = ct_delay_dep;
  pkt->AD4[1] = latencia_rot;  
  pkt->AD4[0] = ct_delay_sav;
  
  pkt->IO1[0] = ID1;
  pkt->IO1[1] = ad01h;  
  pkt->IO1[2] = ad01l; 
  pkt->IO5[1] = RSSId1;
  
  Phy.send(pkt);
  
  ad01h = 0;
  ad01l = 0;
  RSSId1 = 0;
    
  return;  
}
    
//---------- Preinstantiate Application object --------------------------------------

APP App = APP();




