# 
# a0 tiene el puntero al resultado
# a1 tiene el punero al bloque	
# a2 tiene el HI del tamanio
# a3 tiene el LO del tamanio
#

#include <sys/syscall.h>
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
	
	subu 	sp, sp, 104	
	
	sw 	gp,88(sp)
	sw 	$fp,92(sp)
	sw	ra,96(sp)
	mov	$fp, sp
	
	#guardo los parametros con que vine
	
	sw 	a0, 104($fp) 	#ptero a resultado
	sw 	a1, 108($fp) 	#ptero a bloques
	sw 	a2, 112($fp) 	#ptero a parte baja del longitudoriginal
	sw 	a3, 116($fp)	#ptero a parte alta del longitudoriginal
	
	#obtencion del tamanio del relleno
	
#------------------operaciones en 64 bits---------------------------------------------	

	li	t0,0
	li	t1,0			#el tamanio debe venir en bits
	move 	t0,a2			#t1|t0 = longArchivoRelleno
	move 	t1,a3
	li	t4,512		

bucle_relleno:
	remu	t2,t0,t2		#caculo el valor de la longitud en modulo 512 (resto)
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
	beqz	t3,obtener_cant_bloque	#si no hay acarreo no sumar al mas significativo
	addiu	t1,t1,1			#t1|t0 = longArchivoRelleno
									
obtener_cant_bloque:
	#obtenemos la cant de bloques dividiendo entre 8*512 con un shiff de 12 bits

	sw	t0,16($fp)		#guardo la longitud relleno en 64 bits en el stack
	sw	t1,20($fp)
	sw	a0,24($fp)		#guardo la longitud original en 64 bits en el stack
	sw	a1,28($fp)	
		
	srl	t2,t0,9			#divido el tamnio entre 512 para obtener la cantBloques
	sll	t3,t1,23
	or	t2,t2,t3
	srl	t3,t1,9		

	sw	t2,32($fp)		#guardo la cantidad de bloques en el stack 64 bits
	sw	t3.36($fp)		#t3|t2 = cantidad de bloques

#------------------FIN de operaciones en 64 bits---------------------------------------------	


#************************hacer el bucle de sha1**************************************************

# while(cantBloques--)
# {

bucle_sha1:
	
#------------------cargar los datos en las 80 palabras---------------------------------------------

#s0 = bloques
#s1 = trozos

	lw	s0, 108($fp)		#apunto a bloques

	li	a0,80			#malloc
	la	t0,mymalloc
	jalr 	ra,$t0
	move	s1,v0
					
#--------------------
	sw	zero,64($fp) 		# i=0
	li	t0,255			# mascara 0x000000ff
	sw	t0,80($fp)		#mascara en 88

FOR16PRIMEROS:
	#traigo los datos
	lw	t0,64($fp)		#t0 cargo i
	lw 	t5,80($fp)		#t5 = mascara
	
	#comienzo
	
	lbu	t6,0(s0)		#t6 cargo el byte al que apunta (t4 = bloques + indice), lo carga de 0 a 7
	and 	t6,t6,t5		#t6 con el and de la mascara, queda 00 00 00 ALGO
	sll	t6,t6,8			#lo muevo 8 lugares, quedaria 00 00 ALGO 00
	
	addiu 	s0,s0,1			#(*(bloques+indice+1)
	lbu	t7,0(s0)		#t7 cargo el byte al que apunta (t4 = bloques + indice + 1), lo carga de 0 a 7
	and 	t7,t7,t5		#t7 con el and de la mascara, queda 00 00 00 ALGO
	or	t6,t6,t7		#suma logica de t6 y t7, quedaria 00 00 ALGO ALGO	
	sll	t6,t6,8			#muevo quedaria 00 ALGO ALGO 00
	
	addiu 	s0,s0,1			#(*(bloques+indice+2) (ya habia sumado 1 antes)
	lbu	t7,0(s0)		#t7 cargo el byte al que apunta (t4 = bloques + indice + 2), lo carga de 0 a 7
	and 	t7,t7,t5		#t7 con el and de la mascara, queda 00 00 00 ALGO
	or	t6,t6,t7		#suma logica de t6 y t7, quedaria 00 ALGO ALGO ALGO
	sll	t6,t6,8			#muevo quedaria ALGO ALGO ALGO 00
	
	addiu 	s0,s0,1			#(*(bloques+indice+3) (ya habia sumado 1 antes)
	lbu	t7,0(s0)		#t6 cargo el byte al que apunta (t4 = bloques + indice + 3), lo carga de 0 a 7
	and 	t7,t7,t5		#t6 con el and de la mascara, queda 00 00 00 ALGO
	or	t6,t6,t7		#suma logica de t6 y t7, quedaria ALGO ALGO ALGO ALGO
	
	#GUARDO
	sw	t6, 0(s1)		#guardo t6 en (t2 = trozos + i*4)
	
	#AUMENTO VARIABLES
	

	addiu 	t0,t0,1			#i = i + 1
	sw 	t0,64($fp)		#guardo

	addiu 	s1,s1,4			# avanzo a la sig palabra
	addiu 	s0,s0,1			# avanzo al sig byte
	
	addiu	t7,t0,-16
	beqz	t7,FOR16TO80
	
	b FOR16PRIMEROS


FOR16TO80:
	#traigo los datos
	lw	t0,64($fp)		#t0 cargo i
	
	addiu 	s1,s1,-12		#t3 apunta a trozos(i - 3).. 3 lugares = 4bytesx3 = 12 bytes  
	lw	t4,0(s1)		#t4 traigo la palabra a la q apunta t3
	addiu 	s1,s1,12

	addiu 	s1,s1,-32		#t5 apunta a trozos(i - 8)
	lw 	t6,0(s1)		#t6 traigo la palabra a la que apunta t5
	addiu 	s1,s1,32
	
	xor 	t4,t4,t6		#t4 = *(trozos + (i-3)) ^ *(trozos + (i-8))
	
	addiu 	s1,s1,-56		#t5 apunta a trozos(i - 14)
	lw 	t6,0(s1)		#t6 traigo la palabra a la que apunta t5
	addiu 	s1,s1,56

	xor 	t4,t4,t6		#t4 = *(trozos + (i-3)) ^ *(trozos + (i-8)) ^ *(trozos + (i-14))
	
	addiu 	s1,s1,-64		#t5 apunta a trozos(i - 16)
	lw 	t6,0(s1)		#t6 traigo la palabra a la que apunta t5
	addiu 	s1,s1,64

	xor 	t4,t4,t6		#t4 = *(trozos + (i-3)) ^ *(trozos + (i-8)) ^ *(trozos + (i-14)) ^ *(trozos + (i-16)));
	
	rol	t4,t4,1			#leftrotate 1 ¡?
	
	sw 	t4,0(s1)		#guardo t4 en t2 = trozos + i*4 es decir apunta a trozos[i]
	
	addiu	t0,t0,1			#i = i + 1
	sw 	t0,64($fp)		#guardo
	addiu	s1,s1,4			#t2 = avanzo a la siguiente palabra

	addiu	t7,t0,-80
	beqz	t7,FinDelFor
	
	b FOR16TO80

FinDelFor:
#------------------FIN de cargar los datos en las 80 palabras---------------------------------------------

  	#a = A;
        #b = B;
        #c = C;
        #d = D;
        #e = E;

	#cargo variables en s0..s7
	addiu	s1,s1,-320		#hago que apunte al inicio nuevamente 80*4, 80 palabras

	lw	s2,cteA
	sw 	s2, 40($fp) 		#40 es el lugar de A
	lw	s3,cteB
	sw 	s3, 44($fp)
	lw	s4,cteC
	sw 	s4, 48($fp)
	lw	s5,cteD
	sw 	s5, 52($fp)
	lw	s6,cteE
	sw 	s6, 56($fp) 		#56 es el lugar de E

#-------------------------algoritmoSha1---------------------------------------------------------
			
#
#s2 = a
#s3 = b
#s4 = c
#s5 = d
#s6 = e
#s7 = f (funcion)
#

	#inicializar i de vuelta
	sw	zero,64($fp)		# i = 0
	lw	t6,64($fp)		# traigo i, t6 = i
	
PROCESO0A19:
	lw	t6,64($fp)		# traigo i, t6 = i
	move 	s7,zero		
	
	and	s7,s3,s4		#en f(s7) <-- (b & c)
	not	t0,s3			#t0 niego b
	and	t1,t0,s5		#en t1 <-- ((~b) & d)
	xor	s7,s7,t1		#f(s7) <-- (b & c) ^ ((~b) & d)
	
	lw 	t2,ctek1		#cargo en t2, k1
	sw 	t2,72($fp)		#72 es donde esta k en el stack

	
	jal	ASIGNACIONTEMPORAL


	addiu	t6,t6,1
	sw	t6,64($fp)
	
	addiu	t7,t6,-20
	beqz	t7,PROCESO20A39

	b PROCESO0A19


PROCESO20A39:
	lw	t6,64($fp)		# traigo i, t6 = i
	move 	s7,zero	
	
	xor 	s7,s3,s4		#f <-- b ^ c
	xor 	s7,s7,s5		#f <-- b ^ c ^ d
	
	lw 	t0,ctek2		#cargo en t0, k2
	sw 	t0,72($fp)		#72 es donde esta k en el stack


	jal	ASIGNACIONTEMPORAL


	addiu	t6,t6,1
	sw	t6,64($fp)
	
	addiu	t7,t6,-40
	beqz	t7,PROCESO40A59
	
	b PROCESO20A39
	
PROCESO40A59:
	lw	t6,64($fp)		# traigo i, t6 = i
	move 	s7,zero	
	
	and 	s7,s3,s4		#en f(s7) <-- (b & c)
	and 	t0,s3,s5			#en t0 <-- (b & d)
	
	or	s7,s7,t0		#f <-- (b & c) | (b & d)
	
	and 	t0,s4,s5			#en t0 <-- (c & d)
	
	or 	s7,s7,t0		#f <-- (b & c) | (b & d) | (c & d)
	
	lw 	t0,ctek3		#cargo en t0, k3
	sw 	t0,72($fp)		#72 es donde esta k en el stack


	jal	ASIGNACIONTEMPORAL	


	addiu	t6,t6,1
	sw	t6,64($fp)
	
	addiu	t7,t6,-60
	beqz	t7,PROCESO60A79
	
	b PROCESO40A59	
	
PROCESO60A79:
	lw	t6,64($fp)		# traigo i, t6 = i
	move 	s7,zero	
	
	xor 	s7,s3,s4		#f <-- b ^ c
	xor 	s7,s7,s5		#f <-- b ^ c ^ d
	
	lw 	t0,ctek4		#cargo en t0, k4
	sw 	t0,72($fp)		#72 es donde esta k en el stack


	jal	ASIGNACIONTEMPORAL

	addiu	t6,t6,1
	sw	t6,64($fp)

	addiu	t7,t6,-80
	beqz	t7,return_algoritmo
	
	b PROCESO60A79
	

ASIGNACIONTEMPORAL:

	#ESTO FINALIZA EL FOR DE 80 CON EL ALGORITMO PER SE
	
	rol 	t0,s2,5			#en t0 leftrotate a 5
	addu 	t0,t0,s7		#t0 = t0 + f
	addu 	t0,t0,s6		#t0 = t0 + f + e
	lw	t1,72($fp)		#t1 cargo k
	addu 	t0,t0,t1		#t0 = t0 + f + e + k
	
	lw	t1,64($fp)		#t1	cargo i
	sll	t2,t1,2			#t2 = i*4
	addu 	t3,s1,t2		#t3 = trozos + i*4 es decir apunta a trozos[i]
	lw	t4,0(t3)		#t4 traigo la palabra a la q apunta t3
	
	addu 	t0,t0,t4		#t0 = t0 + f + e + k + trozos[i]
	
	sw	t0,76($fp)		#guardo t0 en temp (76($fp))
	#sw	s5,0(s6)		#e = d;
	move 	s6,s5
	#sw	s4,0(s5)		#d = c;
	move 	s5,s4
	rol	s4,s3,30		#c = leftrotate(b ,30);
	#sw	s2,0(s3)		#b = a;
	move 	s3,s2
	#sw	t0,0(s2)		#a = temp;
	move 	s2,t0

	#AUMENTO I
	#addiu 	t1,t1,1			#i = i + 1
	#sw 	t1,64($fp)		#guardo
	
	jalr 	ra

return_algoritmo:

#-------------------------FIN algoritmoSha1---------------------------------------------------------

	sw	t0,32			#traigo LO de cantBloques
	sw	t1,36			#traigo HI de cantBloques
	
	bneqz	t0,no_hay_over		#si LO es distinto de cero, entonces no hay problema
	beqz	t1,fin_bucle			#si HI es cero entonces termina
	addiu	t1,t1,-1		#restamos 1 al la parte mas significativa
	lw	t0,cteAux		#asignamos a t0 = 0xffffffff
	b	guardarDatos
no_hay_over:
	addiu	t0,t0,-1		#quito 1 a cantBloques

guardarDatos:
	lw	t0,32			#guardo LO de cantBloques
	lw	t1,36			#guardo HI de cantBloques
	
	b	bucle_sha1
fin_bucle:

#****************************FIN de hacer el bucle de sha1*******************************************
       #A += a;
       #B += b;
       #C += c;
       #D += d;
       #E += e;

	lw	t0,cteA
	addu	t0,t0,s2
	sw 	t0, 40($fp) 		

	lw	t1,cteB
	addu	t1,t1,s3
	sw 	t1, 44($fp)

	lw	t2,cteC
	addu	t2,t2,s4
	sw 	t2, 48($fp)

	lw	t3,cteD
	addu	t3,t3,s5
	sw 	t3, 52($fp)

	lw	t4,cteE
	addu	t4,t4,s6
	sw 	t4, 56($fp) 		


#----------------asignar datos de retorno--------------------------	
	#for(i = 0;i<4;i++)
	#{
	#        resultado[i]    = (A>>(24-8*i));
	#        resultado[i+4]  = (B>>(24-8*i));
	#        resultado[i+8]  = (C>>(24-8*i));
	#        resultado[i+12] = (D>>(24-8*i));
	#        resultado[i+16] = (E>>(24-8*i));
	#}
	
	sw 	t5, 104($fp) 	#traemos el puntero de resultado
	sw	zero,64($fp) 		# i=0
	lw	t6,64($fp) 		# t6 = i

for0to4:
	lw	t6,64($fp) 		# t6 = i
	sll	t6,t6,3			# t6 = 8*i
	li	t7,24
	subu	t7,t7,t6		# t7 = (24-8*i)

	srl	t6,t0,t7		# t6 = A>>(24-8*i)
	sw	t6,0(t5)		# resultado[i] = t6


	srl	t6,t1,t7		# t6 = B>>(24-8*i)
	addiu	t5,t5,4			# t5 = t5 +4 = resultado[i+4]
	sw	t6,0(t5)		# resultado[i+4] = t6


	srl	t6,t2,t7		# t6 = C>>(24-8*i)
	addiu	t5,t5,4 		# t5 = t5 +4 = resultado[i+8]
	sw	t6,0(t5)		# resultado[i+8] = t6
	

	srl	t6,t3,t7		# t6 = D>>(24-8*i)
	addiu	t5,t5,4 		# t5 = t5 +4 = resultado[i+12]
	sw	t6,0(t5)		# resultado[i+12] = t6


	srl	t6,t4,t7		# t6 = E>>(24-8*i)
	addiu	t5,t5,4 		# t5 = t5 +4 = resultado[i+16]
	sw	t6,0(t5)		# resultado[i+16] = t6

	addiu	t5,t5,1			#avanzamos al siguiente byte
	addiu	t5,t5,-16		#retrocedemos los 16 bytes que se avanzaron	

	lw	t6,64($fp) 		# t6 = i
	addiu	t6,t6,1			#i++
	sw	t6,64($fp) 		#guardamos i

	addiu	t7,t6,-4
	beqz	t7,fin
	b	for0to4
	
fin:


#---------------FIN asignar datos de retorno ------------------------	

	.end sha1

 #-------------------------------------------------------------------------------------------------------------------------------------------
#AREA DE DATOS	
	.data	# comienza zona de datos

	cteA: .word 0x67452301
	cteB: .word 0xEFCDAB89
	cteC: .word 0x98BADCFE
	cteD: .word 0x10325476
	cteE: .word 0xC3D2E1F0
	ctek1: .word 0x5A827999;
	ctek2: .word 0x6ED9EBA1;
	ctek3: .word 0x8F1BBCDC;
	ctek4: .word 0xCA62C1D6;
	cteAux: .word 0xFFFFFFFF

