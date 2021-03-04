#!/usr/bin/python3


# ;       Autor:
# ; Brown Ramírez, Belinda 
# ; López, José
# ; timna.brown@ucr.ac.cr
# ; jose.lopezpicado@ucr.ac.cr
# ; Feb, 2021

# RTI = (N+1)*2^(M + 9)/OSC_CLK

import csv

f = open('DataBase_NMtime.csv', 'w')

OSC_CLK = 8000000.0; 
with f:

    writer = csv.writer(f)
    writer.writerow(["N","M","time"])
    for N in range(16):
        for M in range(8):
            time = ((N+1) * pow(2, M + 9)) / OSC_CLK
            time = time * 1000
            writer.writerow([N,M,time])