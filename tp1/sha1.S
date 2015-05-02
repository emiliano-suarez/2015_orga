# 
# a0 tiene el puntero al resultado
# a1 tiene el punero a los archivos	
# a2 tiene el HI del tamanio
# a3 tiene el LO del tamanio
#

#include <mips/regdef.h>

	.text
	.align	2

	.globl	sha1
	.ent	sha1

sha1:
	#.frame $fp, 44, ra
	.set noreorder
	.cpload t9
	.set reorder
	.cprestore 24
	
	subu 	sp, sp, 48
	sw 	ra, 42(sp)
	sw	$fp, 38(fp) 	
	sw	$gp, 34(fp)	
	move 	$fp, sp
	
	sw 	a0, 48(fp)
	sw	a1, 52(fp) 	
	sw	a2, 56(fp)
	sw	a3, 60(fp)
	
	#obtencion del tamanio del relleno
	
#------------------operaciones en 64 bits---------------------------------------------	

	li	t0,0
	li	t1,0			#el tamanio debe venir en bits
	move 	t0,a2			#t1|t0 = longArchivoRelleno
	move 	t1,a3
	li	t2,512		

bucle_relleno:
	rem	t2,t0,t2		#caculo el valor de la longitud en modulo 512 (resto)
	beqz	t2,fin_bucle_relleno	#no es necesario considerar la parte mas significativa
	#suma de los 64 bits
	addiu	t2,t0,8			#agrego 1 byte
	sltu	t3,t2,t0		#(t0 =1) de carry si el resultado es mas chico que el sumando
	move	t0,t2			#volvamos el valor a t0
	beqz	t3,bucle_relleno
	addiu	t1,t1,1			#sumamos 1 al la parte mas significativa
	b	bucle_relleno		#solucionar la suma en 64 bits
	
fin_bucle_relleno:
	slti 	t2,t0,65		#si t0<65 entonces t2 =1 y agregamos 512 bits
	beqz	t2,obtener_bloque
	addiu	t2,t0,512		#agrega un bloque de 512 extra
	sltu	t3,t2,t0		
	move	t0,t2			
	beqz	t3,obtener_bloque	#si no hay acarreo no sumar al mas significativo
	addiu	t1,t1,1			#t1|t0 = longArchivoRelleno
									
obtener_bloque:
	#obtenemos la cant de bloques dividiendo entre 8*512 con un shiff de 12 bits

	sw	t0,16(fp)		#guardo la longitud relleno en 64 bits en el stack
	sw	t1,20(fp)
	sw	a0,24(fp)		#guardo la longitud original en 64 bits en el stack
	sw	a1,28(fp)	

	srl	t2,t0,12
	sll	t3,t1,20
	or	t2,t2,t3
	srl	t3,t1,12		
	sw	t2,32(fp)		#guardo la cantidad de bloques en el stack 64 bits
	sw	t3.36(fp)		#t3|t2 = cantidad de bloques

	move	a0,t0			#paso el tamanio como argumento en 64 bits
	move	a1,t1
	
	jalr	mymalloc
	move	s0,v0			#guardo en un registro permanente el puntero al inicio del bloque
					#s0 = puntero al inicio de los bloques

	lw 	t0,24(fp)		#t1|t0 = longArchivoRelleno
	lw 	t1,28(fp)
	lw 	t2,32(fp)		#t3|t2 = longArchivoOriginal
	lw 	t3,36(fp)

#------------------FIN de operaciones en 64 bits---------------------------------------------	


#------------------asignar los datos del archivo en los bloques--------------------------------------------- 
#s0 = puntero al inicio de los bloques
asignar_datos_aBloque:			#puse cualquier numero
	ld	t0,234(fp)		#recupero la longitud relleno en 64 bits del el stack
	ld	t2,234(fp)		#recupero la longitud original en 64 bits del el stack

asignarDatos(nombre_archivo,bloques,longitudOriginal,longitudRelleno); // se almacena el tamanioOrginal al final
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
        
#------------------FIN de asignar los datos del archivo en los bloques---------------------------------------------

#------------------hacer el bucle de sha1---------------------------------------------
#s0 = puntero al inicio de los bloques
cargar_Buffer:
	lw 	s1,A	
	lw 	s2,B	
	lw 	s3,C
	lw 	s4,D	
	lw 	s5,E
	
procesamiento_bloques:	
	#procesar los datos de un bloque
	#mientras haya bloques while(cantBloques--)
	lw	t0,16(fp)	#cargo la cantidad de bloques
	li	t1,0
	sw	t1,20(fp)	#guardo el indice para recorrer los bloques
	
loop_bloques:
	
#------------------cargar los datos en las 80 palabras---------------------------------------------
	#uso las 80 palabras del stack
	#cargar los datos del bloque en un buffer (buffers de int)
	
	li	t1,0		#guardo el indice para recorrer el buffer
	
	lw
	lw
	lw
	lw
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
	
#------------------FIN de cargar los datos en las 80 palabras---------------------------------------------

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

        
        {
                

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
        subu	t0,t0,1	
	beqz	t0,fin_looop_bloques	#si t0=0 entonces fin del loop
	b       looop_bloques
	
fin_looop_bloques:
#------------------FIN de hacer el bucle de sha1---------------------------------------------

	 #-------------------------------------------------------------------------------------------------------------------------------------------
#AREA DE DATOS	
	
	A:0x67452301
        B:0xEFCDAB89
        C:0x98BADCFE
        D:0x10325476
        E:0xC3D2E1F0	
        k1:0x5A827999
        k2:0x6ED9EBA1
        k3:0x8F1BBCDC
        k4:0xCA62C1D6
        
	.rdata
	.align 2

iniciador: .asciiz "P2\n"
