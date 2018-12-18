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
  int AD0, AD1, AD5;

  
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
  // AD0 = 0;
  
  pkt->AD0[1] = (byte) (AD0/256);
  pkt->AD0[2] = (byte) (AD0%256);
  
  // AD1
  AD1 = analogRead(AD1_PIN);
  // AD1 = 0;
  
  pkt->AD1[1] = (byte) (AD1/256);
  pkt->AD1[2] = (byte) (AD1%256);


  ad_contad();
  
  pkt->AD3[2] = cont_l;
  pkt->AD3[1] = cont_h;
  pkt->AD3[0] = cont_v;
 
  pkt->AD2[2] = 0;
  pkt->AD2[1] = 0;
  pkt->AD2[0] = 0;
  

  pkt->AD4[2] = flag1;
  pkt->AD4[1] = ct_delay_dep;  
  pkt->AD4[0] = ct_delay_sav;   
  
  periodo = flag1;
  
  Phy.send(pkt);
  
    
  verifica_envio();
  
  ct_delay_sav = 0;
  ct_delay_dep = 0;
  
  salva_rssi=0;
 salva_lqi=0;
  
  return;  
}
   
//---------- Preinstantiate Application object --------------------------------------

APP App = APP();

