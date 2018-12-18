#ifndef HEADERS_H
#define HEADERS_H 1

/* *******************************************************************
 Packet definition
 **************************************************************** */
typedef struct {
  
  // Physical header
  byte PhyHdr[4];
  
  // MAC header
  byte MACHdr[4];
  
  // Network header
  byte NetHdr[4];
  
  // Transport header
  byte TranspHdr[4];
  
  // 6 ADC Payload
  byte AD0[3];
  byte AD1[3];
  byte AD2[3];
  byte AD3[3];
  byte AD4[3];
  byte AD5[3];  
  
  // 6 I/O Payload
  byte IO0[3];
  byte IO1[3];
  byte IO2[3];
  byte IO3[3];
  byte IO4[3];
  byte IO5[3];
  
} packet;

packet g_pkt;

/* *******************************************************************
    INCLUDES FROM App.h
    **************************************************************** */

#ifndef APP_H
#define APP_H 1

class APP
{
  public:
    APP(void);
    inline void initialize(void);
    inline void send(packet * pkt);
    inline void receive(packet * pkt);
    inline void envia(packet * pkt);

  private:

};

extern APP App;

#endif

/* *******************************************************************
    INCLUDES FROM Transp.h
    **************************************************************** */

#ifndef TRANSP_H
#define TRANSP_H 1

class TRANSP
{
  public:
    TRANSP(void);
    inline void initialize(void);
    inline void send(packet * pkt);
    inline void receive(packet * pkt);

  private:
  
};

extern TRANSP Transp;

#endif

/* *******************************************************************
    INCLUDES FROM Net.h
    **************************************************************** */

#ifndef NET_H
#define NET_H 1

class NET
{
  public:
    NET(void);
    inline void initialize(void);
    inline void send(packet * pkt);
    inline void receive(packet * pkt);
    inline void envia(packet * pkt);

    byte MY_ADDR;
  private:
    
};

extern NET Net;

#endif

/* *******************************************************************
    INCLUDES FROM Mac.h
    **************************************************************** */

#ifndef MAC_H
#define MAC_H 1

class MAC
{
  public:
    MAC(void);
    inline void initialize(void);
    inline void send(packet * pkt);
    inline void receive(packet * pkt);

  private:
    
};

extern MAC Mac;

#endif

/* *******************************************************************
    INCLUDES FROM Phy.h
    **************************************************************** */

#ifndef PHY_H
#define PHY_H 1

#define BUFFLEN  CC1101_PACKT_LEN
byte serialData[BUFFLEN + 1]; // 1 extra so we can easily add a /0

class PHY
{
  public:
    PHY(void);
    inline void initialize();
    inline void send(packet * pkt);
    inline int receive(packet * pkt);
    inline void send_agr(packet * pkt);
    
    void sendSerial(packet * pkt);
    void receiveSerial(void);
    
    byte txFifoFree(void);
    void setChannel(byte channel);
    void setPower(byte power);
    
    byte POWER;                 // Power
    byte CHANNEL;               // Channel
    int SERIAL_BAUDRATE;       // Serial baudrate
  
  private:
    int initCC1101Config(void);

};

// Configuration for CC1101 generated by TI's SmartRf studio
// Stored in progmem to save on RAM
// Deviation = 4.760742 
// Base frequency = 914.999969 
// Carrier frequency = 914.999969 
// Channel number = 0 
// Carrier frequency = 914.999969 
// Modulated = true 
// Modulation format = GFSK 
// Manchester enable = false 
// Sync word qualifier mode = 30/32 sync word bits detected 
// Preamble count = 4 
// Channel spacing = 199.951172 
// Carrier frequency = 914.999969 
// Data rate = 9.59587 
// RX filter BW = 58.035714 
// Data format = Normal mode 
// CRC enable = true 
// Device address = 0 
// Address config = No address check 
// CRC autoflush = false 
// PA ramping = false 
// TX power = 0 
const byte CC1101_registerSettings[CC1101_NR_OF_CONFIGS][CC1101_NR_OF_REGISTERS] PROGMEM = {
{
    0x06,  // FSCTRL1       Frequency Synthesizer Control
    0x07,  // IOCFG0        GDO0 Output Pin Configuration
    0x00,  // FSCTRL0       Frequency Synthesizer Control
    0x23,  // FREQ2         Frequency Control Word, High Byte
    0x31,  // FREQ1         Frequency Control Word, Middle Byte
    0x3B,  // FREQ0         Frequency Control Word, Low Byte
    0xF8,  // MDMCFG4       Modem Configuration
    0x83,  // MDMCFG3       Modem Configuration
    0x13,  // MDMCFG2       Modem Configuration
    0x22,  // MDMCFG1       Modem Configuration
    0xF8,  // MDMCFG0       Modem Configuration
    0x00,  // CHANNR        Channel Number
    0x14,  // DEVIATN       Modem Deviation Setting
    0x56,  // FREND1        Front End RX Configuration
    0x10,  // FREND0        Front End TX Configuration
    0x18,  // MCSM0         Main Radio Control State Machine Configuration
    0x16,  // FOCCFG        Frequency Offset Compensation Configuration
    0x6C,  // BSCFG         Bit Synchronization Configuration
    0x43,  // AGCCTRL2      AGC Control
    0x40,  // AGCCTRL1      AGC Control
    0x91,  // AGCCTRL0      AGC Control
    0xE9,  // FSCAL3        Frequency Synthesizer Calibration
    0x2A,  // FSCAL2        Frequency Synthesizer Calibration
    0x00,  // FSCAL1        Frequency Synthesizer Calibration
    0x1F,  // FSCAL0        Frequency Synthesizer Calibration
    0x59,  // FSTEST        Frequency Synthesizer Calibration Control
    0x81,  // TEST2         Various Test Settings
    0x35,  // TEST1         Various Test Settings
    0x09,  // TEST0         Various Test Settings
    0x0E,  // FIFOTHR       RX FIFO and TX FIFO Thresholds
    0x04,  // IOCFG2        GDO2 Output Pin Configuration
    0x04,  // PKTCTRL1      Packet Automation Control
    0x04,  // PKTCTRL0      Packet Automation Control
    0x00,  // ADDR          Device Address
    0x34,  // PKTLEN        Packet length.
},
};

const byte CC1101_paTable[CC1101_NR_OF_CONFIGS][CC1101_PA_TABLESIZE] PROGMEM ={
// -30  -20   -15  -10    0   5    7   10
  {0x03,0x0E,0x1E,0x27,0x8E,0x84,0xCC,0xC3},    // Config 0 , 902 Mhz
};

extern PHY Phy;

#endif

#endif