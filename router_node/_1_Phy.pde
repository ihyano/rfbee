#include "Headers.h"

//---------- Constructor ----------------------------------------------------

PHY::PHY(){
  
  POWER = 7;                 // Power
  CHANNEL = 8;               // Channel
  SERIAL_BAUDRATE = 9600;    // Serial baudrate
  
}

void PHY::initialize(void)
{
  // Configuring serial baudrate
  Serial.begin(SERIAL_BAUDRATE);   // colocar em outro lugar no sensor
  
  // Initialize RF transceptor (cc1101)
  cc1101.PowerOnStartUp();
  
  // Initialize RF transceptor configuration
  initCC1101Config();
  
  // Set Channel to be used
  setChannel(CHANNEL);

  // Set Power to be used
  setPower(POWER);
  
}

// Read available data from Serial
void PHY::receiveSerial(void) {
  
  byte len; // Length of received data in Serial port
  byte fifoSize = 0; // Length of current TXFIFO
 
  static byte pos = 0; // Total amount of received byte in Serial port
  
  // Read serial port and increased the old position
  len = Serial.available() + pos;
  
  // Only process at most BUFFLEN chars
  if (len > BUFFLEN ) {
    len = BUFFLEN;
  }
  
  // Check how much space we have in the TX fifo
  fifoSize = Phy.txFifoFree(); // The fifoSize should be the number of bytes in TX FIFO
  
  // Reset variables and exit function
  if ( fifoSize <= 0){
    Serial.flush();
    pos = 0;
    return;
  }
  
  // Don't overflow the TX fifo
  if (len > fifoSize) {
    len = fifoSize;  
  }
    
  // Finally read the Serial buffer
  for (byte i = pos; i < len; i++){
    serialData[i] = Serial.read();  // serialData is our global serial buffer
  }
    
  delayMicroseconds(1000); //==============================????????
  
  // Verify if we have more data to receive
  if ((Serial.available() > 0)  && (len < CC1101_PACKT_LEN)){
    pos = len;  // Keep the current bytes in the buffer and wait till next round.
    return;
  }
  
  if (len == sizeof(packet)){
       
    // Transmit message using RF
    Phy.send((packet *)serialData);
    
    pos = 0; // Serial databuffer is free again.
  }
  else {
    Serial.flush();
    pos = 0;
    return;
  }
  
}

// Transmit data to Serial=============================================================== colocar rssi na posição 2 e lqi na posição 3 do pacote
void PHY::sendSerial(packet * pkt) {
  
  // Write to serial based on output format:
  // Payload len, Source, Dest, Payload, Rssi, Lqi
  Serial.write((byte *)pkt, sizeof(packet)); // Data
  
}

// Read available txFifo size and handle underflow =====================================função de uplink??????
byte PHY::txFifoFree(void) {

  byte size;

  cc1101.Read(CC1101_TXBYTES, &size);
  
  // Handle a potential TX underflow by flushing the TX FIFO as described in section 10.1 of the CC 1100 datasheet
  if (size >= 64){ // State got here seems not right, so using size to make sure it no more than 64
    cc1101.Strobe(CC1101_SFTX);
    cc1101.Read(CC1101_TXBYTES,&size);
  }
  
  return (CC1101_FIFO_SIZE - size);
}

void PHY::setChannel(byte channel)
{
  cc1101.Write(CC1101_CHANNR, channel);
}


void PHY::setPower(byte power)
{
  cc1101.setPA(0, power);
}

int PHY::initCC1101Config(void){

  // Load the appropriate configuration
  cc1101.Setup(0);
  
  // Set my address
  cc1101.Write(CC1101_ADDR, Net.MY_ADDR);

  // Set PA config
  cc1101.setPA(0, 7);
  
  // Put cc1101 in proper mode
  cc1101.Strobe(CC1101_SIDLE);
  delay(1);
  cc1101.Write(CC1101_MCSM1 ,   0x0F );
  cc1101.Strobe(CC1101_SFTX);
  cc1101.Strobe(CC1101_SFRX);
  cc1101.Strobe(CC1101_SRX);
  
  return OK;
}

// Send data via RF =========================================================================================== função de downlink??????????????
inline void PHY::send(packet * pkt){
  
  byte *txData = (byte *)pkt;
  
  cc1101.Strobe(CC1101_SIDLE);
  
  // Payload data (Burst)
  cc1101.WriteBurst(CC1101_TXFIFO, txData, sizeof(packet)); // Write len bytes of the serialData buffer into the CC1101 TXFIFO
   
  // Go to TX state
  cc1101.Strobe(CC1101_STX);
  
  // Wait until all bytes are sent
  while(1){
    byte size;
        cc1101.Read(CC1101_TXBYTES, &size);
    if( size == 0 ){
      break;
    }
    else{
      cc1101.Strobe(CC1101_STX);
    }
  }

}

// Receive data via RF   ==================================================================== função de uplink????????????????????????
inline int PHY::receive(packet * pkt){

  byte stat, rssi, lqi;

  // Payload data (Burst)  
  cc1101.ReadBurst(CC1101_RXFIFO, (byte *)pkt, sizeof(packet)); // Discard address bytes from payloadLen 
  
  // RSSI
  cc1101.Read(CC1101_RXFIFO, &rssi);

  // LQI  
  stat = cc1101.Read(CC1101_RXFIFO, &lqi);
  
  
  // Handle potential RX overflows by flushing the RF FIFO as described in section 10.1 of the CC 1100 datasheet
  if ((stat & 0xF0) == 0x60){
    cc1101.Strobe(CC1101_SFRX); // Flush the RX buffer
    return ERR;
  }
  
 
  // Check if destination address is MY_ADDR
if (pkt->NetHdr[1] == 8)
  {return ERR; }

if (pkt->NetHdr[2] == 102)
  {cont_ciclo = 0;
   flag2 = 1;
   ID1 = 102;
   ad01h = pkt->AD0[1];
   ad01l = pkt->AD0[2];
            goto continua; }

if (pkt->NetHdr[2] == 99)
  {cont_ciclo2 = 0;
   flag2 = 2;
   ID2 = 99;
   ad02h = pkt->AD0[1];
   ad02l = pkt->AD0[2];
           goto continua;  }

if (pkt->NetHdr[2] == 33)
  {cont_ciclo3 = 0;
   flag2 = 3;
   ID3 = 33;
   ad03h = pkt->AD0[1];
   ad03l = pkt->AD0[2];
        goto continua; }

  return ERR;

continua:

/*
  pkt->PhyHdr[0] = rssi;
  pkt->PhyHdr[1] = lqi;
     
  Mac.receive(pkt);  //======================================================================= passa pacote para MAC
 */ 
  salva_rssi = rssi;
  salva_lqi = lqi;

  return OK;
}

inline void PHY::send_agr(packet * pkt) {

 pkt->PhyHdr[0] = salva_rssi;
 pkt->PhyHdr[1] = salva_lqi;
     
 Mac.receive(pkt);  //======================================================================= passa pacote para MAC

 return;

}


/**
 * Retorna o status de presença de portadora no canal (Carrier Sense)
 * return   1 se o canal está ocupado, 0 se o canal está livre
 */
boolean carrierSense(void)
{
  byte cs;

  /* O status da portadora é lido no registrador PKTSTATUS */  
  cc1101.Read(CC1101_PKTSTATUS,&cs);
  /* O bit de Carrier Sense é o bit 6 */
  cs &= 0x40;
  
  if (cs)
    return true;
  else
    return false;
    
}

//---------- Preinstantiate Physic object --------------------------------------

PHY Phy = PHY();

