sha1:
	subu sp, sp, 104	
	#inicializo
	
	sw $gp,88($sp)
	sw $fp,92($sp)
	sw $ra,96($sp)
	move $fp, $sp
	
	#guardo los parametros con que vine
	
	sw $a0, 104($fp) #ptero a resultado
	sw $a1, 108($fp) #ptero al nombrearchivo
	sw $a2, 112($fp) #ptero a parte baja,creo, del longitudoriginal
	sw $a2, 116($fp)	#ptero a parte alta,creo, del longitudoriginal
	
	#longitudRelleno (de 64 bits) son 16($fp) y 20 ($fp)
	#longitudOriginal (de 64 bits) son 24($fp) y 28 ($fp); este viene en a2 y a3 (xq es de 64b), creo.

###PARTE RUBEN 64 BITS
###BLOQUES ESTÁ EN S0
	
	#ASIGNAR CTES, VER ESTO!!!!!! CHEQUEAR QUE SEA ASI!

	lw t0, cteA
	sw t0, 40($fp) #40 es el lugar de A
	lw t0, cteB
	sw t0, 44($fp)
	lw t0, cteC
	sw t0, 48($fp)
	lw t0, cteD
	sw t0, 52($fp)
	lw t0, cteE
	sw t0, 56($fp) #56 es el lugar de E

	#MALLOC del de 80, trozos
	
	li	$t0,80
	la	$t9,malloc
	jalr $ra,$t9
	sw	$v0,$s1 #trozos está en $s1, en v0 me devolvieron el ptero
	
	#inicializacion de indice,a,b,c,d,e,mascara
	
	sw	$zero,60($fp) #indice esta en 64
	sw	$zero,$s2 #a en s2
	sw	$zero,$s3 #b
	sw	$zero,$s4 #c
	sw	$zero,$s5 #d
	sw	$zero,$s6 #e en 100
	
	li	$t0,255			# mascara 0x000000ff
	sw	$t0,88($fp)	#mascara en 88
	
	
int i; #no inicializados tdv
unsigned int k; #no inicializados tdv
unsigned int f; #no inicializados tdv
unsigned int temp; #no inicializados tdv

while(cantBloques--)
{
	#inicializar i
	sw	$zero,64($fp)
	
FOR16PRIMEROS:
	
	#traigo los datos
	
	lw	$t0,64($fp)		#t0	cargo i
	sll	$t1,$t0,2		#t1 = i*4
	addu $t2,$s1,$t1	#t2 = trozos + i*4
	lw	$t3,60($fp)		#t3 cargo indice
	addu $t4, s0, $t3	#t4 = bloques + indice
	lw $t5, 80($fp)		#t5 = mascara
	
	#comienzo
	
	lbu	$t6,0($t4)		#t6 cargo el byte al que apunta (t4 = bloques + indice), lo carga de 0 a 7
	and $t6,$t6,$t5		#t6 con el and de la mascara, queda 00 00 00 ALGO
	sll	$t6,$t6,8		#lo muevo 8 lugares, quedaria 00 00 ALGO 00
	
	addu $t4,$t4,1		#(*(bloques+indice+1)
	lbu	$t7,0($t4)		#t7 cargo el byte al que apunta (t4 = bloques + indice + 1), lo carga de 0 a 7
	and $t7,$t7,$t5		#t7 con el and de la mascara, queda 00 00 00 ALGO
	or	$t6,$t6,$t7		#suma logica de t6 y t7, quedaria 00 00 ALGO ALGO	
	sll	$t6,$t6,8		#muevo quedaria 00 ALGO ALGO 00
	
	addu $t4,$t4,1		#(*(bloques+indice+2) (ya habia sumado 1 antes)
	lbu	$t7,0($t4)		#t7 cargo el byte al que apunta (t4 = bloques + indice + 2), lo carga de 0 a 7
	and $t7,$t7,$t5		#t7 con el and de la mascara, queda 00 00 00 ALGO
	or	$t6,$t6,$t7		#suma logica de t6 y t7, quedaria 00 ALGO ALGO ALGO
	sll	$t6,$t6,8		#muevo quedaria ALGO ALGO ALGO 00
	
	addu $t4,$t4,1		#(*(bloques+indice+3) (ya habia sumado 1 antes)
	lbu	$t6,0($t4)		#t6 cargo el byte al que apunta (t4 = bloques + indice + 3), lo carga de 0 a 7
	and $t6,$t6,$t5		#t6 con el and de la mascara, queda 00 00 00 ALGO
	or	$t6,$t6,$t7		#suma logica de t6 y t7, quedaria ALGO ALGO ALGO ALGO
	
	#GUARDO
	sw	$t6, 0($t2)		#guardo t6 en (t2 = trozos + i*4)
	
	#AUMENTO VARIABLES
	
	addu $t3,$t3,4		#indice = indice + 4
	addu $t0,$t0,1		#i = i + 1
	
	b DONDE-SEA-QUE-ME-LLAMARON

for(i=16;i<80;i++)
{
*(trozos + i) = (*(trozos + (i-3)) ^ *(trozos + (i-8)) ^ *(trozos + (i-14)) ^ *(trozos + (i-16)));
*(trozos + i) = leftrotate(*(trozos + i),1);
}

		
	lw	$t0,40($fp)
	sw	$t0,$s2 	#a = A;
	lw	$t0,44($fp) 
	sw	$t0,$s3 	#b = B;
	lw	$t0,48($fp)
	sw	$t0,$s4 	#c = C;
	lw	$t0,52($fp)
	sw	$t0,$s5 	#d = D;
	lw	$t0,56($fp)
	sw	$t0,$s6 	#e = E;
	
	#inicializar i de vuelta
	sw	$zero,64($fp)
	
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

##############

	.data	# comienza zona de datos

	cteA: .word 0x67452301
	cteB: .word 0xEFCDAB89
	cteC: .word 0x98BADCFE
	cteD: .word 0x10325476
	cteE: .word 0xC3D2E1F0
	
