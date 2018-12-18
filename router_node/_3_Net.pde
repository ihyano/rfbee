#include "Headers.h"

#define AD0_PIN  0
#define AD1_PIN  1


//---------- Constructor --------------------------------------------------------

NET::NET(){

  MY_ADDR = 8;    // My address
  
}

void NET::initialize(void) {

}

inline void NET::send(packet * pkt) {

  return;  
}

inline void NET::receive(packet * pkt) {
  int AD0, AD1;
     
  // Addressing packet - Exchanging addresses
  pkt->NetHdr[2] = Net.MY_ADDR;
  pkt->NetHdr[0] = 10;
  pkt->NetHdr[1] = 222;


    // Agrega
  pkt->AD5[0] = ID1;
  pkt->AD5[1] = ad01h;  
  pkt->AD5[2] = ad01l;  
  
  pkt->IO2[0] = ID2;
  pkt->IO2[1] = ad02h;  
  pkt->IO2[2] = ad02l;  

  pkt->IO3[0] = ID3;
  pkt->IO3[1] = ad03h;  
  pkt->IO3[2] = ad03l; 


  ad_contad();
  
  pkt->AD3[2] = cont_l;
  pkt->AD3[1] = cont_h;
  pkt->AD3[0] = cont_v;

  pkt->AD4[2] = flag1;
  pkt->AD4[1] = ct_delay_dep;  
  pkt->AD4[0] = ct_delay_sav;
  

// AD0
  AD0 = analogRead(AD0_PIN);
  
  pkt->AD0[1] = (byte) (AD0/256);
  pkt->AD0[2] = (byte) (AD0%256);
  
  // AD1
  AD1 = analogRead(AD1_PIN);
  
  pkt->AD1[1] = (byte) (AD1/256);
  pkt->AD1[2] = (byte) (AD1%256);

  
  Phy.send(pkt);
  
  verifica_envio();
  
  ct_delay_sav = 0;
  ct_delay_dep = 0;
  
  ad01h = 0;
 ad02h = 0;
 ad03h = 0;

 ad01l = 0;
 ad02l = 0;
 ad03l = 0;

 salva_rssi=0;
 salva_lqi=0;

   
  return;  
}

inline void NET::envia(packet * pkt) {
      
  // Addressing packet - Exchanging addresses
  pkt->NetHdr[1] = Net.MY_ADDR;
  pkt->NetHdr[0] = 10;
  pkt->NetHdr[2] = Net.MY_ADDR;
  
  App.envia(pkt);
  
  return;  
}


//---------- Preinstantiate Network object --------------------------------------

NET Net = NET();





