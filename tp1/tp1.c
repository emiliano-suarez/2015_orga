#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ERROR_OPEN_FILE 10
#define MAX_COUNT_FILES 50
#define HASH_LENGTH 20

void printHelp();
void printVersion();
void printError(char* msgError, int codeError);
char* setFileSize(FILE* fp, long int *length);

// int sha1(char *result, char *bytes, unsigned long length);
int sha1(unsigned char *resultado, char *nombre_archivo, unsigned long longitudOriginal);
unsigned int leftrotate(unsigned int valor,int desplazamiento);
long int calcularTamanioArchivo(char* nombreFile);
void asignarDatos(char *file,unsigned char *bloques,long int tamanioOriginal, long int longitudRelleno);

int main(int argc, char* argv[]) {
    int i = 0;
    char* param;
    char* files[MAX_COUNT_FILES];
    unsigned char *result;
    int fileCount = 0;
    FILE* fp;
    char *start;
    long int length;

    // Parse arguments
    if (argc >= 2) {
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

        // fprintf(stdout, "%s\n", fileNames[i]);
        if (NULL == (fp = fopen(files[i],"r"))) {
            fprintf(stderr, "Files '%s' doesn't exist.", files[i]);
            exit(ERROR_OPEN_FILE);
        }
        
        start = setFileSize(fp, &length);
        sha1(result, files[i], length);
//        sha1(result, start, length);
    }

    for(i = 0; i < 20; i++) {
        unsigned char aux = result[i];
        aux<<=4;
        aux>>=4;
        printf("%x",(result[i]>>4));
        printf("%x",aux);
    }
    printf("\n");

    return 0;
}

char* setFileSize(FILE* fp, long int *length) {
    int character;
    char *start;
    int n = 0;

    fseek(fp, 0, SEEK_END);
    *length = ftell(fp);

    fseek(fp, 0, SEEK_SET);

    start = malloc(1);
    start = realloc(start, (*length) * sizeof(char*));

    while ((character = fgetc(fp)) != EOF) {
        start[n++] = (char)character;
    }
    start[n] = '\0';

    return start;
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

int sha1(unsigned char *resultado, char *nombre_archivo, unsigned long longitudOriginal)
{
        unsigned long int longitudRelleno;
        longitudRelleno = longitudOriginal;

        //incorporacion de bits de relleno 0..63 bytes
        while ((longitudRelleno % 64 )!= 0)
        {
            longitudRelleno++;
        }

        if((longitudRelleno-longitudOriginal)*8 < 65) //si hay al menos 65 bits agregamos 512 mas
        {
            longitudRelleno +=64;
        }

        /**prepocesamiento**/
        int cantBloques = longitudRelleno/64; //longArchivo/tamanio bloque   bloque = 64bytes
        unsigned char *bloques = malloc((cantBloques)*64);//mas 1 porque se guarda el tamanio
        asignarDatos(nombre_archivo,bloques,longitudOriginal,longitudRelleno); // se almacena el tamanioOrginal al final


        /**procesar el bloque en 4 rondas de 20 pasos cada ronda**/
        //la memoria temporal cuenta con 5 regstros ABCDE
        unsigned  A=0x67452301;
        unsigned  B=0xEFCDAB89;
        unsigned  C=0x98BADCFE;
        unsigned  D=0x10325476;
        unsigned  E=0xC3D2E1F0;

        unsigned int trozos[80]; //big endian
        int indice = 0;
        int i;
        unsigned int k;
        unsigned int f;
        unsigned int temp;
        unsigned a = 0;
        unsigned b = 0;
        unsigned c = 0;
        unsigned d = 0;
        unsigned e = 0;
        unsigned mascara = 0x000000FF;

        while(cantBloques--)
        {
                for(i=0;i<16;i++)
                {
                    trozos[i] = (*(bloques+indice) & mascara);
                    trozos[i]<<=8;
                    trozos[i]|= (*(bloques+indice+1) & mascara);
                    trozos[i]<<=8;
                    trozos[i]|= (*(bloques+indice+2) & mascara);
                    trozos[i]<<=8;
                    trozos[i]|= (*(bloques+indice+3) & mascara);
                    indice+=4;
                }

                for(i=16;i<80;i++)
                {
                    trozos[i] = (trozos[i-3] ^ trozos[i-8] ^ trozos[i-14] ^ trozos [i-16]);
                    trozos[i] = leftrotate(trozos[i],1);
                }

                a = A;
                b = B;
                c = C;
                d = D;
                e = E;


                for(i=0;i<80;i++)
                {
                        if(i<=19) //0 ≤ i ≤ 19
                        {
                            f = (b & c) ^ ((~b) & d);
                            k = 0x5A827999;
                        }
                        else
                            if( (i>=20)&&(i<=39))//20 ≤ i ≤ 39
                            {
                                f = b ^ c ^ d;
                                k = 0x6ED9EBA1;
                            }
                            else
                                if( (i>=40)&&(i<=59))//40 ≤ i ≤ 59
                                {
                                    f = (b & c) | (b & d) | (c & d);
                                    k = 0x8F1BBCDC;
                                }
                                else
                                    if( (i>=60)&&(i<=79))//60 ≤ i ≤ 79
                                    {
                                        f = b ^ c ^ d;
                                        k = 0xCA62C1D6;
                                    }

                        temp = leftrotate (a,5);
                        temp = temp + f + e + k + trozos[i];
                        e = d;
                        d = c;
                        c = leftrotate(b ,30);
                        b = a;
                        a = temp;
                }

            A += a;
            B += b;
            C += c;
            D += d;
            E += e;

        }

        // hh = (h0 leftshift 128) or (h1 leftshift 96) or (h2 leftshift 64) or (h3 leftshift 32) or h4
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


//un bloque tiene 64 bytes
void asignarDatos(char *file,unsigned char *bloques,long int tamanioOriginal, long int longitudRelleno)
{
    FILE *fp = fopen(file,"r");
    char caracter;
    int indice =0;
    int i =0;
    int cantBitsRelleno = 0;
    char relleno = 0x80; //minimo relleno
    char rellenoCero = 0x00;
    unsigned mascara = 0x000000FF;

    while( (caracter = getc(fp)) != EOF)
    {
            *(bloques+indice) = caracter;
            indice++;
    }

    cantBitsRelleno = (longitudRelleno - tamanioOriginal)*8;
    cantBitsRelleno = cantBitsRelleno - 64 - 8;//restamos 64 bits de tamanio y los 8 bits basicos de relleno;
    *(bloques+indice) = relleno;
    indice++;

    for(i = 0;i<(cantBitsRelleno/8);i++)
    {
        *(bloques+indice) = rellenoCero;
        indice++;
    }

    tamanioOriginal *= 8; // tamanio en bits

    for(i = 0;i<8;i++)
    {
        *(bloques+indice) = (tamanioOriginal>>(56-8*i)) & mascara;
        indice++;
    }
}



long int calcularTamanioArchivo(char* nombreFile) {
    long int tamanio =0;
    FILE *fp = fopen(nombreFile,"r");
    fseek(fp, 0, SEEK_END);
    tamanio = ftell(fp);
    return tamanio;
}

unsigned int leftrotate(unsigned int valor,int desplazamiento)
{
    desplazamiento %= 32;
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

