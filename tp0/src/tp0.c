#include <stdio.h>
#include <stdlib.h>
#define ayuda 'h'
#define version 'V'
#define caracteres 'c'
#define lineas 'n'
#define cantLineasPorDefecto 10
#define maxcantArchivos 50
typedef int bool;
#define true 1
#define false 0
#define EXIT_FAILURE 1
#define EXIT_SUCCESS 0


/*****   $tp0 -c 10 -n 2 <prueba.txt   ***/


void evaluarArgumentos();
void validacionEntero(int numero);
void imprimirAyuda();
void imprimirVersion();
void tail(int i,char* archivos[],int cantArchivos,bool caso);
void imprimir(FILE* fp, unsigned pos);
long int posicionaAlInicioLinea(FILE *fp,long int pos);

//char* getLinea(FILE *fp);

int main (int argc, char *argv[])
{
    evaluarArgumentos(argc,argv);
    printf("¡Fin del programa! \n");
    return 0;
}


void evaluarArgumentos(int argc, char *argv[])
{
    int i = 0;
    char *nombresArchivos[maxcantArchivos];
    int cantArchivos = 0;
    bool LineasPorDefecto = true;
    int cantOpcionesTail = 0;


    for(i=1;i<argc;i++)                      /*buscamos los archivos*/
    {
            if (*argv[i] == '-')             //descartamos las opciones
            {
                    switch ( *(argv[i] +1) )
                    {
                            case caracteres:
                            i++;            //si es caracter descartamos su parametro k
                            cantOpcionesTail++;
                            break;

                            case lineas:    //si es linea descartamos su parametro k
                            cantOpcionesTail++;
                            i++;
                            break;
                    }
            }
            else
            {
                    nombresArchivos[cantArchivos++]  = argv[i];
            }
    }

    if(cantOpcionesTail > 1)  // solo puede haber una opcion de Tail caracter o linea
    {
        char* error_doble_funcionalidad = "\n error en los parametros, usar -n o -c pero no ambos \n";
        fputs(error_doble_funcionalidad,stderr);
        exit(EXIT_FAILURE);
    }


        for (i = 1;i<argc;i++)   //no contamos el argumento cero dado que es el programa, ni el ultimo porque es el archivo
        {
                if (*argv[i] == '-')
                    switch ( *(argv[i] +1) )
                    {
                            case ayuda:
                            imprimirAyuda();
                            exit(EXIT_SUCCESS);
                            break;

                            case version:
                            imprimirVersion();
                            exit(EXIT_SUCCESS);
                            break;

                            case caracteres:
                            validacionEntero(atoi(argv[i+1]));
                            tail(atoi(argv[i+1]),nombresArchivos,cantArchivos,false);
                            LineasPorDefecto = false;
                            break;

                            case lineas:
                            validacionEntero(atoi(argv[i+1]));
                            tail(atoi(argv[i+1]),nombresArchivos,cantArchivos,true);
                            LineasPorDefecto = false;
                            break;

                            default:
                            fputs("\n error la opcion del menu no es correcta: ayuda\n",stderr);
                            imprimirAyuda();    //imprimir ayuda en caso de parametros incorrectos
                            exit(EXIT_FAILURE);
                            break;
                    }
        }

        if(LineasPorDefecto == true)
            tail(cantLineasPorDefecto,nombresArchivos,cantArchivos,true);

}


void tail(int cantLineaschar,char* archivos[],int cantArchivos,bool caso)
{
    FILE *fp;
    int i = 0;
    char* error_parametro = "\n error la cantidad de lineas/caracteres pedidas es mayor a la que contiene el archivo \n";
    do
    {
            if (cantArchivos < 1)
            {

                    char c;
                    	fp = fopen("archivoAuxiliar.txt","w+");
              		while( (c =getc(stdin)) != EOF)
              		{
                        	fputc(c,fp);
              		}
              		fputc('\n',fp);
            }

            else
            {
                    if ((fp = fopen(archivos[i],"r")) == NULL)
                    {
                            fputs("\n error el archivo no existe\n",stderr);
                            exit(EXIT_FAILURE);
                    }

                    fputs("\n Archivo ",stdout);
                    fputs(archivos[i],stdout);
            }


            if (caso == true) //lineas
            {
                    fseek(fp,0,SEEK_END);
                    long int posFinal = ftell(fp);
                    char finDeLinea = '\n';
                    int cantLineasLeidas = 0;

                    while(cantLineasLeidas != cantLineaschar && posFinal != 0)
                    {
                            if (fgetc(fp) == finDeLinea)
                            {
                                    cantLineasLeidas++;
                            }

                            if (fseek(fp,--posFinal,0) != 0)
                            {
                                    fputs("\n error al acceder al archivo \n",stderr);
                                    exit(EXIT_FAILURE);
                            }
                    }

                    if(cantLineasLeidas != cantLineaschar)
                    {
                            fputs(error_parametro,stderr);
                            exit(EXIT_FAILURE);
                    }
                    else
                    {
                            posFinal = posicionaAlInicioLinea(fp,posFinal);
                            imprimir(fp,posFinal);
                    }
            }

            else
            {
                    fseek(fp,0,SEEK_END);
                    long int posFinal = ftell(fp);
                    int cantCaracteresLeidos = -1;  /**ver esto**/

                    while(cantCaracteresLeidos != cantLineaschar && posFinal != 0)
                    {
                            cantCaracteresLeidos++;
                            --posFinal;
                    }

                    if(cantCaracteresLeidos != cantLineaschar)
                    {
                            fputs(error_parametro,stderr);
                            exit(EXIT_FAILURE);
                    }
                    else
                    {
                             if(posFinal >= 0)
                             {
                                    imprimir(fp,posFinal);
                             }
                             else
                             {
                                    fputs("error al acceder al archivo \n",stderr);
                                    exit(EXIT_FAILURE);
                             }
                    }
            }

            i++;
            fclose(fp);
            remove("archivoAuxiliar.txt");

    }
    while(i<cantArchivos);

}

void imprimirAyuda()
{
    printf("\n *******************************************************\n ");
    printf(" Opciones: \n");
    printf(" Para caracteres usar --> ./programa -c numero  archivos \n");
    printf(" Para lineas usar --> ./programa -n numero archivos \n");
    printf(" Para la version usar --> ./programa -V archivos  \n");
    printf(" Los numeros ingresados tienen que ser mayores que cero \n");
    printf(" ******************************************************* \n");
}

void imprimirVersion()
{
    printf("\n  Version 3.0 \n ");
}


void validacionEntero(int numero)
{
    if(numero <= 0)
    {
            char* salida = "\n error en el parametro de lineas o caracteres \n ";
            fputs(salida,stderr);
            exit(EXIT_FAILURE);
    }

}

void imprimir(FILE* fp, unsigned pos)
{
        printf("\n ****las ultimas lineas/caracteres escritos**** \n");
        fseek(fp,pos,0);
        char caracter;

            while( (caracter = fgetc(fp)) != EOF)
            {
                    fputc(caracter,stdout);
            }
}

long int posicionaAlInicioLinea(FILE *fp,long int pos)
{
        fseek(fp,pos,0);
        char caracter;
        char finLinea = '\n';

            while( (caracter = fgetc(fp)) != finLinea && pos !=0 )
            {
                    fseek(fp,--pos,0);
            }

        if (pos ==0)
        {
                return pos;
        }
        else
        {
                return pos+1;
        }
}
