CC=gcc -g -O0
CFLAGS=-Wall -lm
LDFLAGS=
OBJ_DIR=/
SOURCES=tp1.c

OBJECTS=$(SOURCES:.c=.o)
EXECUTABLE=tp1

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CC) $(CFLAGS) sha1.o -o $@ $(SOURCES)

.c.o:
	$(CC) $(LDFLAGS) sha1.S -o sha1.o 

clean:
	rm -rf $(EXECUTABLE) $(OBJECTS) *o
