#
#a0 puntero a trozos
#a1 a
#a2 b
#a3 c
#a4 d
#a5 e
#



#include <mips/regdef.h>

	.text
	.align	2

	.globl	algoritmoSha1
	.ent	algoritmoSha1

algoritmoSha1:
	.frame $fp, 48, ra
	.set noreorder
	.cpload t9
	.set reorder
	subu 	sp, sp, 48	
	.cprestore 0
	
	
	sw 	gp,32(sp)
	sw 	$fp,36(sp)
	sw	ra,40(sp)
	move	$fp, sp
	
	sw 	a0, 48($fp) 		# trozos
	sw 	a1, 52($fp) 		# a
	sw 	a2, 56($fp) 		# b
	sw 	a3, 60($fp)		# c
	
	la	t0,4(a3)		# dir
	la	t1,8(a3)		# dir

	sw 	t0, 64($fp)		# d
	sw 	t1, 68($fp)		# e

	
#-------------------algoritmo--------------------------------------
			
#
#s2 = a
#s3 = b
#s4 = c
#s5 = d
#s6 = e
#s7 = f (funcion)
#
	#cargo variables en s0..s7

	move	s1,a0
	lw	s2,0(a1)
	lw	s3,0(a2)
	lw	s4,0(a3)
	lw	s5,4(a3)
	lw	s6,8(a3)

	#inicializar i de vuelta
	sw	zero,16($fp)		# i = 0
	lw	t6,16($fp)		# traigo i, t6 = i
	
PROCESO0A19:
	lw	t6,16($fp)		# traigo i, t6 = i
	move 	s7,zero		
	
	and	s7,s3,s4		#en f(s7) <-- (b & c)
	not	t0,s3			#t0 niego b
	and	t1,t0,s5		#en t1 <-- ((~b) & d)
	xor	s7,s7,t1		#f(s7) <-- (b & c) ^ ((~b) & d)
	
	lw 	t2,ctek1		#cargo en t2, k1
	sw 	t2,20($fp)		#es donde esta k en el stack

	
	jal	ASIGNACIONTEMPORAL


	addiu	t6,t6,1
	sw	t6,16($fp)
	
	addiu	t7,t6,-20
	beqz	t7,PROCESO20A39

	b PROCESO0A19


PROCESO20A39:
	lw	t6,16($fp)		# traigo i, t6 = i
	move 	s7,zero	
	
	xor 	s7,s3,s4		#f <-- b ^ c
	xor 	s7,s7,s5		#f <-- b ^ c ^ d
	
	lw 	t0,ctek2		#cargo en t0, k2
	sw 	t0,20($fp)		#es donde esta k en el stack


	jal	ASIGNACIONTEMPORAL


	addiu	t6,t6,1
	sw	t6,16($fp)
	
	addiu	t7,t6,-40
	beqz	t7,PROCESO40A59
	
	b PROCESO20A39
	
PROCESO40A59:
	lw	t6,16($fp)		# traigo i, t6 = i
	move 	s7,zero	
	
	and 	s7,s3,s4		#en f(s7) <-- (b & c)
	and 	t0,s3,s5			#en t0 <-- (b & d)
	
	or	s7,s7,t0		#f <-- (b & c) | (b & d)
	
	and 	t0,s4,s5			#en t0 <-- (c & d)
	
	or 	s7,s7,t0		#f <-- (b & c) | (b & d) | (c & d)
	
	lw 	t0,ctek3		#cargo en t0, k3
	sw 	t0,20($fp)		#es donde esta k en el stack


	jal	ASIGNACIONTEMPORAL	


	addiu	t6,t6,1
	sw	t6,16($fp)
	
	addiu	t7,t6,-60
	beqz	t7,PROCESO60A79
	
	b PROCESO40A59	
	
PROCESO60A79:
	lw	t6,16($fp)		# traigo i, t6 = i
	move 	s7,zero	
	
	xor 	s7,s3,s4		#f <-- b ^ c
	xor 	s7,s7,s5		#f <-- b ^ c ^ d
	
	lw 	t0,ctek4		#cargo en t0, k4
	sw 	t0,20($fp)		#es donde esta k en el stack


	jal	ASIGNACIONTEMPORAL

	addiu	t6,t6,1
	sw	t6,16($fp)

	addiu	t7,t6,-80
	beqz	t7,return_algoritmo
	
	b PROCESO60A79
	

ASIGNACIONTEMPORAL:

	#ESTO FINALIZA EL FOR DE 80 CON EL ALGORITMO PER SE
	
	rol 	t0,s2,5			#en t0 leftrotate a 5
	addu 	t0,t0,s7		#t0 = t0 + f
	addu 	t0,t0,s6		#t0 = t0 + f + e
	lw	t1,20($fp)		#t1 cargo k
	addu 	t0,t0,t1		#t0 = t0 + f + e + k
	
	lw	t1,16($fp)		#t1	cargo i
	sll	t2,t1,2			#t2 = i*4
	addu 	t3,s1,t2		#t3 = trozos + i*4 es decir apunta a trozos[i]
	lw	t4,0(t3)		#t4 traigo la palabra a la q apunta t3
	
	addu 	t0,t0,t4		#t0 = t0 + f + e + k + trozos[i]
	
	sw	t0,24($fp)		#guardo t0 en temp (24($fp))
	#sw	s5,0(s6)		#e = d;
	move s6,s5
	#sw	s4,0(s5)		#d = c;
	move s5,s4
	rol	s4,s3,30		#c = leftrotate(b ,30);
	#sw	s2,0(s3)		#b = a;
	move s3,s2
	#sw	t0,0(s2)		#a = temp;
	move s2,t0

	#AUMENTO I
	#addiu 	t1,t1,1			#i = i + 1
	#sw 	t1,16($fp)		#guardo
	
	jalr 	ra

return_algoritmo:
#--------------------FIN algoritmo--------------------------------------

	
	lw 	a0, 48($fp) 		# trozos
	lw 	a1, 52($fp) 		# a
	lw 	a2, 56($fp) 		# b
	lw 	a3, 60($fp)		# c
	lw 	t6, 64($fp)		# d
	lw 	t7, 68($fp)		# e

	sw	s2,0(a1)
	sw	s3,0(a2)
	sw	s4,0(a3)
	sw	s5,0(t6)
	sw	s6,0(t7)
	

	lw	$fp,36(sp)
	lw	ra, 40(sp)
	lw	gp, 32(sp)
	addu	sp, sp, 48

	# Retorno.
	#
	j	ra
	.end	algoritmoSha1



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
