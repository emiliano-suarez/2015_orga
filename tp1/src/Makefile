CC=gcc -g -O0
CFLAGS=-Wall -lm
LDFLAGS=
OBJ_DIR=/
SOURCES=main.c
SOURCES_ANSI=ansi/main.c
MIPS_FILES=algoritmo.S relleno.S trozo.S

OBJECTS=$(SOURCES:.c=.o)
EXECUTABLE=sha

mips:
	$(CC) $(CFLAGS) $(SOURCES) $(MIPS_FILES) -o $(EXECUTABLE)

c:
	$(CC) $(CFLAGS) $(SOURCES_ANSI) -o $(EXECUTABLE)

clean:
	rm -rf $(EXECUTABLE) $(OBJECTS)

