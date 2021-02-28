# #Assembly makefile
# ;       Autor:
# ; Brown Ramírez, Belinda 
# ; López, José
# ; timna.brown@ucr.ac.cr
# ; jose.lopezpicado@ucr.ac.cr
# ; Feb, 2021
#********************
SRC = ./src/ 

all: build load monitor

build:
	as12 $(SRC)main.asm -L

load:
	dbug12 load $(SRC)main.s19

monitor:
	dbug12 monitor

	

