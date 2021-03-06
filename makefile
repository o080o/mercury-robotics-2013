CFLAGS=-c -fPIC 
LDFLAGS=-shared -llua -lwiringPi

all:rpiIO.so

rpiIO.so:rpiIO.o
	gcc -o rpiIO.so rpiIO.o $(LDFLAGS) 

rpiIO.o:rpiIO.c
	gcc $(CFLAGS) rpiIO.c -o rpiIO.o

clean:
	rm -f rpiIO.o
