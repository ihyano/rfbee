#include "Headers.h"

//---------- Constructor ----------------------------------------------------------

TRANSP::TRANSP(){

}

void TRANSP::initialize(void) {
  
}

inline void TRANSP::send(packet * pkt) {

  return;  
}

inline void TRANSP::receive(packet * pkt) {
  static byte counter = 0;
  
  // Insering counter into packet
  pkt->TranspHdr[0] = counter++;


  App.receive(pkt);
  
  return;  
}

//---------- Preinstantiate Transport object --------------------------------------

TRANSP Transp = TRANSP();





