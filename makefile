CFLAGS=-c -fPIC
LDFLAGS=-shared 

all:librpiIO.so

librpiIO.so:rpiIO.o
	gcc $(LDFLAGS) -o librpiIO.so rpiIO.o

rpiIO.o:rpiIO.c
	gcc $(CFLAGS) rpiIO.c -o rpiIO.o

clean:
	rm -f rpiIO.o
