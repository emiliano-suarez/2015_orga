
#include <mips/regdef.h>

	.text
	.align	2

	.globl	calcularRelleno
	.ent	calcularRelleno

calcularRelleno:
	.frame $fp, 48, ra
	.set noreorder
	.cpload t9
	.set reorder
	subu 	sp, sp, 48
	.cprestore 0
	

	sw 	ra, 44(sp)
	sw	$fp,40(sp) 	
	sw	gp,36(sp)	
	move 	$fp, sp
	
	sw 	a0, 48($fp)
	sw	a1, 52($fp) 	
	#sw	a2, 56($fp)
	#sw	a3, 60($fp)
	
	#obtencion del tamanio del relleno
	
#------------------operaciones en 64 bits---------------------------------------------	

	li	t0,0
	li	t1,0			#el tamanio debe venir en bits
	move 	t0,a0			#t1|t0 = longArchivoRelleno
	move 	t1,a1
	li	t4,512		

bucle_relleno:
	remu	t2,t0,t4		#caculo el valor de la longitud en modulo 512 (resto)
	beqz	t2,fin_bucle_relleno	#no es necesario considerar la parte mas significativa
	#suma de los 64 bits
	addiu	t2,t0,8			#agrego 1 byte
	sltu	t3,t2,t0		#(t3 =1) de carry si el resultado es mas chico que el sumando
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
	sw	t0,16($fp)		#guardo la longitud relleno en 64 bits en el stack
	sw	t1,20($fp)
	sw	a0,24($fp)		#guardo la longitud original en 64 bits en el stack
	sw	a1,28($fp)
			
	move v0,t0
	move v1,t1

	lw	$fp, 40(sp)
	lw	ra, 44(sp)
	lw	gp, 36(sp)
	addu	sp, sp, 48

	# Retorno.
	#
	j	ra
	.end	calcularRelleno
