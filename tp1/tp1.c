#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ERROR_OPEN_FILE 10
#define MAX_COUNT_FILES 50
#define HASH_LENGTH 60

void printHelp();
void printVersion();
void printError(char* msgError, int codeError);
char* setFileSize(FILE* fp, long int *length);
int sha1(char *result, char *bytes, unsigned long length);

int main(int argc, char* argv[]) {
    int i = 0;
    char* param;
    char* files[MAX_COUNT_FILES];
    char *result;
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
        sha1(result, start, length);
    }

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
    
int sha1(char *result, char *bytes, unsigned long length) {

    return 1;
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

