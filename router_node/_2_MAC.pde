#include "Headers.h"

//---------- Constructor --------------------------------------------------------

MAC::MAC(){

}

void MAC::initialize(void) {

}

inline void MAC::send(packet * pkt) {

  return;  
}

inline void MAC::receive(packet * pkt) {
      
  Net.receive(pkt);
  
  return;  
}

//---------- Preinstantiate Network object --------------------------------------

MAC Mac = MAC();





