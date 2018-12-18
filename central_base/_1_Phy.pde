#include "Headers.h"

//---------- Constructor ----------------------------------------------------

PHY::PHY(){
  
  
  //----------------PARÂMETROS DE CAMADA FÍSICA RÁDIO
  POWER = 7;                 // Power
  CHANNEL = 8;               // Channel
  
  
  
  //----------------PARÂMETRO DE CAMDA FÍSICA USB
  SERIAL_BAUDRATE = 9600;    // Serial baudrate
  
}

void PHY::initialize(void)
{
  // Configuring serial baudrate
  Serial.begin(SERIAL_BAUDRATE);
  
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
    
  delayMicroseconds(1000);
  
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

// Transmit data to Serial
void PHY::sendSerial(packet * pkt) {
  
  // Write to serial based on output format:
  // Payload len, Source, Dest, Payload, Rssi, Lqi
  Serial.write((byte *)pkt, sizeof(packet)); // Data
  
}

// Read available txFifo size and handle underflow
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
  
  // Put cc1101 in tranceiver mode
  cc1101.Strobe(CC1101_SIDLE);
  delay(1);
  cc1101.Write(CC1101_MCSM1 ,   0x0F );
  cc1101.Strobe(CC1101_SFTX);
  cc1101.Strobe(CC1101_SFRX);
  cc1101.Strobe(CC1101_SRX);
    
  return OK;
}

// Send data via RF
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

// Receive data via RF
inline int PHY::receive(packet * pkt){

  byte stat, rssi, lqi;

  // Payload data (Burst)  
  cc1101.ReadBurst(CC1101_RXFIFO, (byte *)pkt, sizeof(packet)); // Discard address bytes from payloadLen 
  
  // RSSI
  cc1101.Read(CC1101_RXFIFO, &rssi);

  // LQI  
  stat = cc1101.Read(CC1101_RXFIFO, &lqi);
  
  // Check if destination address is MY_ADDR
  /* if (pkt->NetHdr[0] != Net.MY_ADDR)
  {
    return ERR;
  }  */

  // Handle potential RX overflows by flushing the RF FIFO as described in section 10.1 of the CC 1100 datasheet
  if ((stat & 0xF0) == 0x60){
    cc1101.Strobe(CC1101_SFRX); // Flush the RX buffer
    return ERR;
  }

  pkt->PhyHdr[2] = rssi;
  pkt->PhyHdr[3] = lqi;
  
  return OK;
}

//---------- Preinstantiate Physic object --------------------------------------

PHY Phy = PHY();

