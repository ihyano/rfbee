# PROGRAMA PARA MEDIR RSSI UPLINK E DOWNLINK

import serial
import math
import time
import struct
from time import localtime, strftime

# Configura a serial
# para COMn o numero que se coloca eh n-1 no primeiro parametro. Ex COM9  valor 8

n_serial = raw_input("Digite o numero da serial:") #seta a serial

n_serial1 = int(n_serial) - 1

ser = serial.Serial(n_serial1, 9600, timeout=0.5,parity=serial.PARITY_NONE) # seta valores da serial

filename1 = strftime("Sensor_%Y_%m_%d_%H-%M-%S.txt")
print "Arquivo de log: %s" % filename1
S = open(filename1, 'w')

filename2 = strftime("S102_%Y_%m_%d_%H-%M-%S.txt")
print "Arquivo de log: %s" % filename2
S102 = open(filename2, 'w')

filename3 = strftime("S99_%Y_%m_%d_%H-%M-%S.txt")
print "Arquivo de log: %s" % filename3
S99 = open(filename3, 'w')

filename4 = strftime("S33_%Y_%m_%d_%H-%M-%S.txt")
print "Arquivo de log: %s" % filename4
S33 = open(filename4, 'w')

filename5 = strftime("S8_%Y_%m_%d_%H-%M-%S.txt")
print "Arquivo de log: %s" % filename5
S8 = open(filename5, 'w')

filename6 = strftime("SP_%Y_%m_%d_%H-%M-%S.txt")
print "Arquivo de log: %s" % filename6
SP = open(filename6, 'w')



i = 0
i2 = 0
i3 = 0
ct_rot = 0
tot_rot = 0
per_rot = 0
tot_poll = 0
tot_agr = 0
per_99 = 0
ct_99 = 0
tot_99 = 0
per_102 = 0
ct_102 = 0
tot_102 = 0
per_33 = 0
ct_33 = 0
tot_33 = 0
dif_rot = 0
dif_99 = 0
dif_102 = 0
dif_33 = 0
ct_ed = 0
erro = 0
AD0 = 100
AD1 = 200
AD2 = 0
AD3 = 0
AD5 = 0
Tensao = 0
Tensao1 = 0
Tensao2 = 0
Tensao3 = 0
Divisor = 0
ID1 = 0
ID2 = 0
ID3 = 0
RSSIu1 = 0
RSSIu2 = 0
RSSIu3 = 0
RSSId1 = 0
RSSId2 = 0
RSSId3 = 0
poll1 = 0
poll2 = 0
poll3 = 0

while True:
 try:
#=============Escreve na serial para enviar para base
       

  line = ser.read(52) # faz a leitura de 11 bytes do buffer que recebe da serial pela COM
       
  if len(line) == 52: # checa se o buffer onde esta line tem 52 bytes, algumas vezes ele esta vazio
            
    IDori = ord(line[10])       # ID origem
    IDrot = ord(line[9])	     # ID roteador
    IDdest = ord(line[8])       # ID destino
    cont = ord(line[12])      # contador

    ad0h = ord(line[17])
    ad0l = ord(line[18])
    ad1v = ord(line[19])
    ad1h = ord(line[20])
    ad1l = ord(line[21])
    ad2v = ord(line[22])
    ad2h = ord(line[23])
    ad2l = ord(line[24])
    ad3v = ord(line[25])
    ad3h = ord(line[26])
    ad3l = ord(line[27])
    ad4v = ord(line[28])
    ad4h = ord(line[29])
    ad4l = ord(line[30])
    ad5v = ord(line[31])
    ad5h = ord(line[32])
    ad5l = ord(line[33])
    io0v = ord(line[34])
    io0h = ord(line[35])
    io0l = ord(line[36])
    io1v = ord(line[37])
    io1h = ord(line[38])
    io1l = ord(line[39])
    io2v = ord(line[40])
    io2h = ord(line[41])
    io2l = ord(line[42])
    io3v = ord(line[43])
    io3h = ord(line[44])
    io3l = ord(line[45])
    io4v = ord(line[46])
    io4h = ord(line[47])
    io4l = ord(line[48])
    io5v = ord(line[49])
    io5h = ord(line[50])
    io5l = ord(line[51])
    
         
    rssid = ord(line[0])     # RSSI_DownLink
    rssiu = ord(line[2])     # RSSI_UpLink
    lqid = ord(line[1])     # LQI Downlink
    lqiu = ord(line[3])     # LQI Uplink

    if IDori == 102 or IDori == 8 or IDori == 99 or IDori == 33:
      if IDdest == 10:
       if IDrot == 8 or IDrot == 222:

         ID1 = ad5v
         Tensao1 = (ad5h * 256 + ad5l) * 0.0032
          
         ID2 = io2v
         Tensao2 = (io2h * 256 + io2l) * 0.0032
         
         ID3 = io3v
         Tensao3 = (io3h * 256 + io3l) * 0.0032

         if io4v > 128:
            RSSId1=((io4v-256)/2.0)-74
         else:
            RSSId1=(io4v/2.0)-74
         
         if io4h > 128:
            RSSId2=((io4h-256)/2.0)-74
         else:
            RSSId2=(io4h/2.0)-74

         if io4l > 128:
            RSSId3=((io4l-256)/2.0)-74
         else:
            RSSId3=(io4l/2.0)-74
         

         #RSSI Downlink 
       
         if rssid > 128:
            RSSId=((rssid-256)/2.0)-74
         else:
            RSSId=(rssid/2.0)-74

         #RSSI Uplink

         if rssiu > 128:
            RSSIu=((rssiu-256)/2.0)-74
         else:
            RSSIu=(rssiu/2.0)-74

         AD0 = ad0h * 256 + ad0l
         AD1 = ad1h * 256 + ad1l
         AD2 = ad2h * 256 + ad2l + ad2v * 65536
         AD3 = ad3h * 256 + ad3l + ad3v * 65536

         Tensao = AD0 * 0.0032
         

         i = i + 1
         i2 = i2 + 1

         if i2 > 224000:
             S.close()
             filename1 = strftime("Sensor_%Y_%m_%d_%H-%M-%S.txt")
             print "Arquivo de log: %s" % filename1
             S = open(filename1, 'w')
             i2 = 0
             
         if i3 > 64000:
             S102.close()
             filename2 = strftime("S102_%Y_%m_%d_%H-%M-%S.txt")
             print "Arquivo de log: %s" % filename2
             S102 = open(filename2, 'w')
             S99.close()
             filename3 = strftime("S99_%Y_%m_%d_%H-%M-%S.txt")
             print "Arquivo de log: %s" % filename3
             S99 = open(filename3, 'w')
             S33.close()
             filename4 = strftime("S33_%Y_%m_%d_%H-%M-%S.txt")
             print "Arquivo de log: %s" % filename4
             S33 = open(filename4, 'w')
             S8.close()
             filename5 = strftime("S8_%Y_%m_%d_%H-%M-%S.txt")
             print "Arquivo de log: %s" % filename5
             S8 = open(filename5, 'w')
             SP.close()
             filename6 = strftime("SP_%Y_%m_%d_%H-%M-%S.txt")
             print "Arquivo de log: %s" % filename6
             SP = open(filename6, 'w')
             i3 = 0
             

         if IDrot == 222:
            if IDori == 99:
               ct_99 = ct_99 + 1
               if ct_99 <> AD2:
                  dif_99 = dif_99 + 1
                  ct_99 = AD2
                  erro = dif_99
               tot_99 = tot_99 + 1
               per_99 = (dif_99 * 100.00)/tot_99
               imp_tot = tot_99
               imp_per = per_99
               print >>S99,time.asctime(),i, i2, 'RSSIu =',RSSIu,'RSSId =',RSSId,'Rot =', AD3, 'ED =', AD2, 'Erro =',dif_99, 'dl=', ad1v, ad4l, ad4h, ad4v, 'ID =', IDori, IDdest, IDrot, 'c=', ad2v, ad2h, ad2l, AD1, AD0, Tensao, tot_99, per_99
            else:
               if IDori == 102:
                  ct_102 = ct_102 + 1
                  if ct_102 <> AD2:
                     dif_102 = dif_102 + 1
                     ct_102 = AD2
                     erro = dif_102
                  tot_102 = tot_102 + 1
                  per_102 = (dif_102 * 100.00)/tot_102
                  imp_tot = tot_102
                  imp_per = per_102
                  print >>S102,time.asctime(),i, i2, 'RSSIu =',RSSIu,'RSSId =',RSSId,'Rot =', AD3, 'ED =', AD2, 'Erro =',dif_102, 'dl=', ad1v, ad4l, ad4h, ad4v, 'ID =', IDori, IDdest, IDrot, 'c=', ad2v, ad2h, ad2l, AD1, AD0, Tensao, tot_102, per_102
               else:
                   if IDori == 33:
                       ct_33 = ct_33 + 1
                       if ct_33 <> AD2:
                          dif_33 = dif_33 + 1
                          ct_33 = AD2
                          erro = dif_33
                       tot_33 = tot_33 + 1
                       per_33 = (dif_33 * 100.00)/tot_33
                       imp_tot = tot_33
                       imp_per = per_33
                       print >>S33,time.asctime(),i, i2, 'RSSIu =',RSSIu,'RSSId =',RSSId,'Rot =', AD3, 'ED =', AD2, 'Erro =',dif_33, 'dl=', ad1v, ad4l, ad4h, ad4v, 'ID =', IDori, IDdest, IDrot, 'c=', ad2v, ad2h, ad2l, AD1, AD0, Tensao, tot_33, per_33
                   else:
                       ct_rot = ct_rot + 1
                       if ct_rot <> AD3:
                          dif_rot = dif_rot + 1
                          ct_rot = AD3
                       tot_agr = tot_agr + 1
                       i3 = i3 + 1
                       tot_rot = tot_rot + 1
                       per_rot = (dif_rot * 100.00)/tot_rot
                       imp_tot = tot_rot
                       imp_per = per_rot
                       print >>S8,time.asctime(),i, i2, 'RSSIu =',RSSIu,'RSSId =',RSSId,'Rot =', AD3, 'ED =', AD2, 'Erro =',dif_rot, 'dl=', ad1v, ad4l, ad4h, ad4v, 'ID =', IDori, IDdest, IDrot, 'c=', ad2v, ad2h, ad2l, AD1, AD0, Tensao, ID1, Tensao1, RSSId1, ID2, Tensao2, RSSId2, ID3, Tensao3, RSSId3, tot_rot, per_rot, tot_agr
                       
                         
         else:
            ct_rot = ct_rot + 1
            if ct_rot <> AD3:
               dif_rot = dif_rot + 1
               ct_rot = AD3
            tot_poll = tot_poll + 1
            tot_rot = tot_rot + 1
            per_rot = (dif_rot * 100.00)/tot_rot
            imp_tot = tot_rot
            imp_per = per_rot
            if ad4l == 1:
                poll1 = poll1 + 1
            else:
                if ad4l == 2:
                    poll2 = poll2 + 1
                else:
                    if ad4l == 3:
                        poll3 = poll3 + 1
            print >>SP,time.asctime(),i, i2, 'RSSIu =',RSSIu,'RSSId =',RSSId,'Rot =', AD3, 'ED =', AD2, 'Erro =',dif_rot, 'dl=', ad1v, ad4l, ad4h, ad4v, 'ID =', IDori, IDdest, IDrot, 'c=', ad2v, ad2h, ad2l, AD1, AD0, Tensao, tot_rot, per_rot, tot_poll, poll1, poll2, poll3
            
            
            
         print >>S,time.asctime(),i, i2, 'RSSIu =',RSSIu,'RSSId =',RSSId,'Rot =', AD3, 'ED =', AD2, 'Erro =',erro, 'dif_rot =', dif_rot, 'dl=', ad1v, ad4l, ad4h, ad4v, 'ID =', IDori, IDdest, IDrot, 'c=', ad2v, ad2h, ad2l, AD1, AD0, Tensao, ID1, Tensao1, RSSId1, ID2, Tensao2, RSSId2, ID3, Tensao3, RSSId3, imp_tot, imp_per

         print     time.asctime(),i, i2, 'RSSIu =',RSSIu,'RSSId =',RSSId,'Rot =', AD3, 'ED =', AD2, 'Erro =',erro, 'dif_rot =', dif_rot, 'dl=', ad1v, ad4l, ad4h, ad4v, 'ID =', IDori, IDdest, IDrot, 'c=', ad2v, ad2h, ad2l, AD1, AD0, Tensao, ID1, Tensao1, RSSId1, ID2, Tensao2, RSSId2, ID3, Tensao3, RSSId3, imp_tot, imp_per

         
         
 except KeyboardInterrupt:
    ser.close()
    S.close()
    S102.close()
    S99.close()
    S33.close()
    S8.close()
    SP.close()
    break

