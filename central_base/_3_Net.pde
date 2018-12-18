#include "Headers.h"

//---------- Constructor --------------------------------------------------------

NET::NET(){

  MY_ADDR = 10;    // My address
  
}

void NET::initialize(void) {

}

inline void NET::send(packet * pkt) {

  return;  
}

inline void NET::receive(packet * pkt) {
  
  return;  
}

//---------- Preinstantiate Network object --------------------------------------

NET Net = NET();





