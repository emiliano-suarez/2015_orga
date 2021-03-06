#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ERROR_OPEN_FILE 10
#define MAX_COUNT_FILES 50
#define HASH_LENGTH 20
#define MAX_FILE_SIZE 1000

void printHelp();
void printVersion();
void printError(char* msgError, int codeError);
void setFileSize(FILE* fp, long long int *length);
int readFromStdInput(int argumentCount);
int sha1(unsigned char *resultado, char *nombre_archivo, unsigned long long longitudOriginal);
unsigned int leftrotate(unsigned int valor, int desplazamiento);
void asignarDatos(FILE* fp, char *bloques, long long int tamanioOriginal, long long int longitudRelleno);
void showCheckSum(unsigned char *result);

long long int calcularRelleno(long long int longitudOriginal);
void cargarTrozos(char *bloque,unsigned int *Trozos);
void algoritmoSha1(unsigned int *Trozos, unsigned *a, unsigned *b, unsigned *c, unsigned *d, unsigned *e);

int main(int argc, char* argv[]) {
    int i = 0;
    char* param;
    char* files[MAX_COUNT_FILES];
    unsigned char *result;
    int fileCount = 0;
    FILE* fp;
    long long int length;

    if (readFromStdInput(argc)) {
        int c;

        fp = fopen("archivoAuxiliar.txt", "w+");
        while ((c = fgetc(stdin)) != EOF) {
            fputc(c, fp);
        };

        setFileSize(fp, &length);
        long long int longitudRelleno = calcularRelleno(length);
        char *bloques = malloc(longitudRelleno/8);

        result = malloc(HASH_LENGTH);
        // se almacena el tamanioOrginal al final
        asignarDatos(fp, bloques, length, longitudRelleno);
        sha1(result, bloques, length);
        showCheckSum(result);

        fclose (fp);
        remove("archivoAuxiliar.txt");

        return 0;

    } else if (argc >= 2) { // Parse arguments
        param = *(argv + 1);
        if ((strcmp(param, "-h") == 0) || (strcmp(param, "--help") == 0) ) {
            printHelp();
        }
        else if ((strcmp(param, "-V") == 0) || (strcmp(param, "--version") == 0)) {
            printVersion();
        }
    }

    // Search for files
    for(i = 1; i < argc; i++) {
        if (*argv[i] != '-') {
            files[fileCount++]  = argv[i];
        }
    }

    // Process each file
    for(i = 0; i < fileCount; i++) {
        result = malloc(HASH_LENGTH);

        if (NULL == (fp = fopen(files[i],"r"))) {
            fprintf(stderr, "Files '%s' doesn't exist.", files[i]);
            exit(ERROR_OPEN_FILE);
        }
        
        setFileSize(fp, &length);
        long long int longitudRelleno = calcularRelleno(length);
        char *bloques = malloc(longitudRelleno/8);
        
        fp = fopen(files[i],"r");

        // se almacena el tamanioOrginal al final
        asignarDatos(fp, bloques, length, longitudRelleno);
        sha1(result,bloques, length);
        fclose(fp);
    }

    showCheckSum(result);

    return 0;
}

void setFileSize(FILE* fp, long long int *length) {
    int character;
    char *start;
    int n = 0;

    fseek(fp, 0, SEEK_END);
    *length = ftell(fp);

    fseek(fp, 0, SEEK_SET);

    start = malloc(MAX_FILE_SIZE);
    
    if ((*length) > MAX_FILE_SIZE) {
        start = realloc(start, (*length));
    }

    *length *= 8;  // devuelve el tamanio en bits

    while ((character = fgetc(fp)) != EOF) {
        start[n++] = (char)character;
    }
    start[n] = '\0';
}

void printHelp()
{
    fprintf(stdout, "$ tp1 -h\n");
    fprintf(stdout, "Usage:\n");
    fprintf(stdout, "  tp1 -h\n");
    fprintf(stdout, "  tp1 -V\n");
    fprintf(stdout, "  tp1 [file...]\n");
    fprintf(stdout, "Options:\n");
    fprintf(stdout, "  -V, --version    Print version and quit.\n");
    fprintf(stdout, "  -h, --help       Print this information and quit.\n\n");
    fprintf(stdout, "Examples:\n");
    fprintf(stdout, "  tp1 foo\n");
    fprintf(stdout, "  echo \"hello\" | tp1\n\n");
}

int sha1(unsigned char *resultado, char *bloques, unsigned long long longitudOriginal)
{
    long long int longitudRelleno = calcularRelleno(longitudOriginal);
    // Prepocesamiento

    // longArchivo/tamanio bloque   bloque = 512bits
    long long int cantBloques = longitudRelleno/512;

    // procesar el bloque en 4 rondas de 20 pasos cada ronda
    // la memoria temporal cuenta con 5 regstros ABCDE
    unsigned  A=0x67452301;
    unsigned  B=0xEFCDAB89;
    unsigned  C=0x98BADCFE;
    unsigned  D=0x10325476;
    unsigned  E=0xC3D2E1F0;

    // big endian
    unsigned int trozos[80];

    int i;
    unsigned a = 0;
    unsigned b = 0;
    unsigned c = 0;
    unsigned d = 0;
    unsigned e = 0;

    while(cantBloques--)
    {
        cargarTrozos(bloques, trozos);

        a = A;
        b = B;
        c = C;
        d = D;
        e = E;

        algoritmoSha1(trozos, &a, &b, &c, &d, &e);

        A += a;
        B += b;
        C += c;
        D += d;
        E += e;
    }

    // hh = (h0 leftshift 128) or (h1 leftshift 96) or (h2 leftshift 64)
    //      or (h3 leftshift 32) or h4
    for(i = 0;i<4;i++)
    {
        resultado[i]    = (A>>(24-8*i));
        resultado[i+4]  = (B>>(24-8*i));
        resultado[i+8]  = (C>>(24-8*i));
        resultado[i+12] = (D>>(24-8*i));
        resultado[i+16] = (E>>(24-8*i));
    }

    return 0;
}


// un bloque tiene 64 bytes
void asignarDatos(FILE *fp, char *bloques,long long int tamanioOriginal, long long int longitudRelleno)
{
    char caracter;
    int indice =0;
    int i =0;
    int cantBitsRelleno = 0;
    char relleno = 0x80; //minimo relleno
    char rellenoCero = 0x00;
    unsigned mascara = 0x00000000000000FF;

    while( (caracter = getc(fp)) != EOF)
    {
            *(bloques+indice) = caracter;
            indice++;
    }

    cantBitsRelleno = (longitudRelleno - tamanioOriginal);

    // restamos 64 bits de tamanio y los 8 bits basicos de relleno;
    cantBitsRelleno = cantBitsRelleno - 64 - 8;
    *(bloques+indice) = relleno;
    indice++;

    for(i = 0;i<(cantBitsRelleno/8);i++)
    {
        *(bloques+indice) = rellenoCero;
        indice++;
    }

    for(i = 0;i<8;i++)
    {
        *(bloques+indice) = (tamanioOriginal>>(56-8*i)) & mascara;
        indice++;
    }

}

// devuleve el tamanio en bits
long long int calcularTamanioArchivo(char* nombreFile)
{
    long long int tamanio =0;
    FILE *fp = fopen(nombreFile,"r");
    fseek(fp,0,SEEK_END);
    tamanio = ftell(fp)*8;
    return tamanio;
}


unsigned int leftrotate(unsigned int valor,int desplazamiento)
{
    desplazamiento %=32;
    unsigned retorno;
    retorno = (valor << desplazamiento) |  (valor >> (32 - desplazamiento));
    return retorno;
}

void printVersion()
{
    fprintf(stdout, "Copyright (c) 2015\n");
    fprintf(stdout, "Conjunto de instrucciones MIPS. v1.0.0\n\n");
}

void printError(char* msgError, int codeError)
{
    fprintf(stderr, "%s\n", msgError);
    exit(codeError);
}

void showCheckSum(unsigned char *result) {
    int i;
    for(i = 0; i < 20; i++) {
        unsigned char aux = result[i];
        aux<<=4;
        aux>>=4;
        printf("%x",(result[i]>>4));
        printf("%x",aux);
    }
    printf("\n");
}

int readFromStdInput(int argumentCount) {
    return (int)(argumentCount < 2);
}

// Funciones en C, que fueron implementadas en Assembly.
void cargarTrozos(char *bloques,unsigned int *trozos)
{
    int i;
    unsigned mascara = 0x000000FF;
    for (i = 0; i < 16; i++) {
        trozos[i] = (*(bloques++) & mascara);
        trozos[i]<<=8;
        trozos[i]|= (*(bloques++) & mascara);
        trozos[i]<<=8;
        trozos[i]|= (*(bloques++) & mascara);
        trozos[i]<<=8;
        trozos[i]|= (*(bloques++) & mascara);
    }

    for (i = 16; i < 80; i++) {
        trozos[i] = (trozos[i-3] ^ trozos[i-8] ^ trozos[i-14] ^ trozos [i-16]);
        trozos[i] = leftrotate(trozos[i], 1);
    }

}

long long int calcularRelleno(long long int longitudOriginal)
{
    unsigned long long int longitudRelleno;
    longitudRelleno = longitudOriginal;

    //incorporacion de bits de relleno 0..512 bits
    while ((longitudRelleno % 512 ) != 0) {
        longitudRelleno++;
    }

    // si hay al menos 65 bits agregamos 512 mas
    if((longitudRelleno - longitudOriginal) < 65)
    {
        longitudRelleno +=512;
    }

    return longitudRelleno;
}

void algoritmoSha1(unsigned int *trozos,unsigned *a,unsigned *b,unsigned *c,unsigned *d,unsigned *e)
{
    int i;
    unsigned int k;
    unsigned int f;
    unsigned int temp;

    for(i = 0; i < 80; i++) {
        if(i <= 19) {
            f = (*b & *c) ^ ((~*b) & *d);
            k = 0x5A827999;
        } else if ((i >= 20) && ( i <= 39)) {
            f = *b ^ *c ^ *d;
            k = 0x6ED9EBA1;
        } else if ((i >= 40) && ( i<= 59)) {
            f = (*b & *c) | (*b & *d) | (*c & *d);
            k = 0x8F1BBCDC;
        } else if ((i >= 60) && ( i<= 79)) {
            f = *b ^ *c ^ *d;
            k = 0xCA62C1D6;
        }

        temp = leftrotate (*a,5);
        temp = temp + f + *e + k + trozos[i];
        *e = *d;
        *d = *c;
        *c = leftrotate(*b ,30);
        *b = *a;
        *a = temp;
    }
}
