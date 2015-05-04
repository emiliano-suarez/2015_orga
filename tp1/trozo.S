#
#s0 puntero a bloques
#s1 puntero a trozos
#


#include <mips/regdef.h>

	.text
	.align	2

	.globl	cargarTrozos
	.ent	cargarTrozos

cargarTrozos:
	.frame $fp, 48, ra
	.set noreorder
	.cpload t9
	.set reorder
	.cprestore 24
	
	subu 	sp, sp, 104	
	
	sw 	gp,88(sp)
	sw 	$fp,92(sp)
	sw	ra,96(sp)
	move	$fp, sp
	
	#guardo los parametros con que vine #void cargarTrozos(char *bloques,int *indice,unsigned int *trozos)
	
	sw 	a0, 104($fp) 	#ptero a bloques
	sw 	a1, 108($fp) 	# ptero a trozos
	sw 	a2, 112($fp) 	# nada
	sw 	a3, 116($fp)	# nada
	
	#cargo los parametros
	move	s0,a0
	move	s1,a1

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

	lw	$fp,92(sp)
	lw	ra, 96(sp)
	lw	gp, 88(sp)
	addu	sp, sp, 104

	# Retorno.
	#
	j	ra
	.end	cargarTrozos
