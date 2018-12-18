#include "Headers.h"

//---------- Constructor --------------------------------------------------------

NET::NET(){

  MY_ADDR = 99;    // My address
  
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





