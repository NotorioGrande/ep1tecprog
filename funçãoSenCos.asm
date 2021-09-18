.data

	oneFloat:		.float 1.0
	oneNegFloat:		.float -1.0
	zeroFloat:		.float 0.0
	senLimit:		.float 0.0001
	valorFloat:		.float 3.0
	mat: 			.space 16 # numero de bytes
	matFinal:		.space 8 #numero de bytes
	twoQuad: 		.float 1.58 # valores  para fazer comparacao
	fourQuad:		.float 4.74
	
	valorX:			.float 3.0
	valorY:			.float 2.0

.text 
main:
	
	la $t1, matFinal
	l.s $f8, valorX
	l.s $f10, valorY
	
	s.s $f8, ($t1)
	s.s $f10, 4($t1)
	
	
	l.s $f14, valorFloat
	jal multiplicaMatriz
	
	
	la $t1, matFinal
	l.s $f12, 4($t1)
	li $v0, 2
	syscall
	
	
	
	
	
	li $v0, 10
	syscall
#FIM MAIN ----------------------------------

#Inicio da funcao multiplicaMatriz
multiplicaMatriz: # entrada: angulo em rad: $f14 | Vetor --> matFinal
	
	subi $sp, $sp, 4
	sw $ra, 0($sp)  # salva o return address para chamar
	
	jal criaMatriz
	
	la $s1, mat
	li $t1, 0 # i eh o indice da linha que queremos acessar
	sll $t1, $t1, 1 # i * nCols(2)
	addi $t1, $t1, 0 # j eh o indice da coluna que queremos acessar
	sll $t1, $t1, 2 # offset = indice do vetor * tamanho de um int (4)
	add $t1, $t1, $s1 # posicao da celula = offset + posicao da matriz
	
	l.s $f10, ($t1) #$f10 = Matriz[0][0] = cos
	
							
	la $s1, mat
	li $t1, 1 # i eh o indice da linha que queremos acessar
	sll $t1, $t1, 1 # i * nCols(2)
	addi $t1, $t1, 0 # j eh o indice da coluna que queremos acessar
	sll $t1, $t1, 2 # offset = indice do vetor * tamanho de um int (4)
	add $t1, $t1, $s1 # posicao da celula = offset + posicao da matriz
	
	l.s $f8, ($t1) #$f8 = Matriz[1][0] = sen
	
	
	la $s1, mat
	li $t1, 0 # i eh o indice da linha que queremos acessar
	sll $t1, $t1, 1 # i * nCols(2)
	addi $t1, $t1, 1 # j eh o indice da coluna que queremos acessar
	sll $t1, $t1, 2 # offset = indice do vetor * tamanho de um int (4)
	add $t1, $t1, $s1 # posicao da celula = offset + posicao da matriz
	
	l.s $f6, ($t1) #$f6 = Matriz[0][1] = -sen
	
	
	la $s1, mat
	li $t1, 1 # i eh o indice da linha que queremos acessar
	sll $t1, $t1, 1 # i * nCols(2)
	addi $t1, $t1, 1 # j eh o indice da coluna que queremos acessar
	sll $t1, $t1, 2 # offset = indice do vetor * tamanho de um int (4)
	add $t1, $t1, $s1 # posicao da celula = offset + posicao da matriz
	
	l.s $f4, ($t1) #$f4 = Matriz[1][1] = cos
	
	
	la $s1, matFinal	
	l.s $f16, ($s1) #$f16 = Vetor[0] = x
	l.s $f18, 4($s1) #$f18 = Vetor[1] = y
	
	
	mul.s $f30, $f16, $f10 # x.cos
	mul.s $f28, $f18, $f6 # y.(-sen)	
	add.s $f26, $f28, $f30 # x.cos + y.(-sen)
	
	la $s1, matFinal	
	s.s $f26, ($s1)	#guarda [x.cos + y.(-sen)] em Vetor[0]
	
	
	mul.s $f30, $f16, $f8 # x.sen
	mul.s $f28, $f18, $f4 # y.cos
	add.s $f26, $f28, $f30 # x.sen + y.cos
	
	la $s1, matFinal	
	s.s $f26, 4($s1)	#guarda [x.sen + y.cos] em Vetor[1]	
	
	
	lw $ra, 0($sp)  #guarda o valor que tava na stack
	addi $sp, $sp, 4  #deixa a stack arrumadinha pro proximo
	jr $ra
#Fim da funcao multiplicaMatriz

#Inicio da funcao criaMatriz
criaMatriz:	# entrada: angulo em rad: $f14
	
	subi $sp, $sp, 4
	sw $ra, 0($sp)  # salva o return address para chamar	
	
	l.s $f20, zeroFloat #$f20 = 0.0
	l.s  $f22, oneNegFloat #$f22 = -1.0
	
	jal sen
	add.s $f28, $f0, $f20 #$f28 = sen
	
	mov.s $f12, $f0
	jal cos  # a funcao cos nao leva em conta o quadrante, entao o sinal precisa ser ajustado baseado no angulo
	mov.s $f16, $f0 # $f16 = cos
	
	
	subi $sp, $sp, 4
	s.s $f14, 0($sp)  # salva o return address para chamar
	
	l.s $f24, oneFloat
	mul.s $f12, $f14, $f24 # $f12 = angulo
	jal sinalcos
	
	l.s $f14, 0($sp)  #guarda o valor que tava na stack
	addi $sp, $sp, 4  #deixa a stack arrumadinha pro proximo
	
	
	mul.s $f0, $f0, $f16 # $f0 = cos * sinalcos(angulo)
	mov.s $f30, $f0 #$f30 = cos
	
	# matriz[0][0] = cos
	
	l.s $f20, zeroFloat #$f20 = 0.0
	l.s  $f22, oneNegFloat #$f22 = -1.0
	add.s $f0, $f20, $f30
	
	la $s1, mat
	li $t1, 0 # i eh o indice da linha que queremos acessar
	sll $t1, $t1, 1 # i * nCols(2)
	addi $t1, $t1, 0 # j eh o indice da coluna que queremos acessar
	sll $t1, $t1, 2 # offset = indice do vetor * tamanho de um int (4)
	add $t1, $t1, $s1 # posicao da celula = offset + posicao da matriz
	
	swc1 $f0, 0($t1)
	
	
	# matriz[1][1] = cos
	
	l.s $f20, zeroFloat #$f20 = 0.0
	l.s  $f22, oneNegFloat #$f22 = -1.0
	add.s $f0, $f20, $f30
	
	la $s1, mat
	li $t1, 1 # i eh o indice da linha que queremos acessar
	sll $t1, $t1, 1 # i * nCols(2)
	addi $t1, $t1, 1 # j eh o indice da coluna que queremos acessar
	sll $t1, $t1, 2 # offset = indice do vetor * tamanho de um int (4)
	add $t1, $t1, $s1 # posicao da celula = offset + posicao da matriz
	
	swc1 $f0, ($t1)
	
	
	# matriz[0][1] = -sen
	
	l.s $f20, zeroFloat #$f20 = 0.0
	l.s  $f22, oneNegFloat #$f22 = -1.0
	mul.s $f0, $f28, $f22 #$f0 = -sen
	
	la $s1, mat
	li $t1, 0 # i eh o indice da linha que queremos acessar
	sll $t1, $t1, 1 # i * nCols(2)
	addi $t1, $t1, 1 # j eh o indice da coluna que queremos acessar
	sll $t1, $t1, 2 # offset = indice do vetor * tamanho de um int (4)
	add $t1, $t1, $s1 # posicao da celula = offset + posicao da matriz
	
	swc1 $f0, ($t1)
	
	
	# matriz[1][0] = sen
	
	l.s $f20, zeroFloat #$f20 = 0.0
	l.s  $f22, oneNegFloat #$f22 = -1.0
	add.s $f0, $f20, $f28
	
	la $s1, mat
	li $t1, 1 # i eh o indice da linha que queremos acessar
	sll $t1, $t1, 1 # i * nCols(2)
	addi $t1, $t1, 0 # j eh o indice da coluna que queremos acessar
	sll $t1, $t1, 2 # offset = indice do vetor * tamanho de um float (4)
	add $t1, $t1, $s1 # posicao da celula = offset + posicao da matriz
	
	swc1 $f0, ($t1)
	
	
	
	lw $ra, 0($sp)  #guarda o valor que tava na stack
	addi $sp, $sp, 4  #deixa a stack arrumadinha pro proximo
	
	jr $ra
#Fim da funcao criaMatriz


#Inicio da funcao sen
sen: 	# entrada: angulo em rad: $f14
  	# $s0=k	$f24=x
  	# retorna o resultado em $f0=sen(x)
	
	subi $sp, $sp, 4
	sw $ra, 0($sp)  # salva o return address para chamar pow
	
	mov.s $f18, $f14 # o angulo eh salvo em $f18
	addi $s0, $zero, 0 #k($s0) = 0
	l.s  $f20, zeroFloat #$f20 = 0.0
	l.s  $f22, oneNegFloat #$f22 = -1.0
	l.s  $f24, oneFloat #$f24 = 1.0
	l.s $f26, senLimit #$f26 = 0.0001 = 10^(-4)
	l.s $f28, zeroFloat #f28 = 0
	
	senLoop:	
	
	# (-1)^k        float
	add $a0, $zero, $s0 
	add.s $f12, $f20, $f22 
	
	subi $sp, $sp, 8
	sw $s0, 0($sp)  # salva o $s0 para chamar pow
	swc1 $f18, 4($sp) #salva o $f18 para chamar pow
	
	jal pow
	
	lw $s0, 0($sp)  #guarda o valor que tava na stack
	lwc1 $f18, 4($sp)
	addi $sp, $sp, 8  #deixa a stack arrumadinha pro proximo
	
	mov.s $f16, $f0 # $f16 = (-1)^k
	
	# 2.k + 1        int
	mul $t4, $s0, 2 #$t4 = 2.k
	addi $t4, $t4, 1 #$t4 = 2.k + 1
	add $s1, $zero, $t4 #faz cï¿½pia de $t4 em $s1
	
	# x^(2.k + 1)		float
	add $a0, $zero, $t4 
	add.s $f12, $f20, $f18 
	
	subi $sp, $sp, 8
	sw $s0, 0($sp)  # salva o $s0 para chamar pow
	swc1 $f18, 4($sp) #salva o $f18 para chamar pow
	
	jal pow
	
	lw $s0, 0($sp)  #guarda o valor que tava na stack
	lwc1 $f18, 4($sp)
	
	addi $sp, $sp, 8  #deixa a stack arrumadinha pro proximo
	mov.s $f14, $f0 #$f14 = x^(2.k + 1)
	
	# (-1)^k . x^(2.k + 1)
	mul.s $f14, $f14, $f16 #$f14 = (-1)^k . x^(2.k + 1)
	
	# (-1)^k . x^(2.k + 1)/(2.k + 1)!
	add $a0, $zero, $s1
	jal fatorialDiv
	mov.s $f30, $f0 #$f30 = (-1)^k . x^(2.k + 1)
	
	#soma $f28 + $f30 e coloca em $f28
	add.s $f28, $f28, $f30
	
	addi $s0, $s0, 1 #k++
	abs.s $f30, $f30 # |$f30|
	c.le.s $f30, $f26 # ? $f30 <= $f26
	bc1t senExit # se $f30 <= $f26 --> true, vai pra senExit
	j senLoop
	
	senExit:
	lw $ra, 0($sp)  #guarda o valor que tava na stack
	addi $sp, $sp, 4  #deixa a stack arrumadinha pro proximo
	
	mov.s $f0, $f28
	jr $ra
	
#Fim da funcao seno ---------------------------------------	

#Inicio da funcao pow
pow: # funcao que eleva um numero float a um numero inteiro,(n**k) o argumento do float deve ser passado em $f12 e do int em $a0
#$f6 para salvar o resultado ao longo da exec
#f8 sera usado para guardar 0, f0 eh o retorno

mtc1 $zero, $f8  # coloca zero no $f8 para usar para calculos
beq $a0, $0, powzero #se for 0 retornar 1
move $t3, $a0  # coloca K em t3
addi $t3, $t3, -1 # subtrai 1 pq o numero de vezes que a multiplicacao deve ser feita eh K-1
li $t2, 0 #coloca 0 em t2 para servir de variavel para a variavel de controle
add.s $f6, $f12, $f8  #coloca $f12 em $f6
#inicio do for
powfor:
beq $t2, $t3, powexit
mul.s $f6, $f6, $f12 # conta da exponenciacao
addi $t2, $t2, 1 # atualiza a variavel
j powfor
powexit:
add.s $f0, $f6, $f8  # coloca o resultado no registrador e finaliza na linha de baixo
jr $ra

powzero:
li $t3, 1
mtc1 $t3, $f18
cvt.s.w $f18,$f18
add.s $f0, $f18, $f8 # colocar 1 no retorno
jr $ra # retorno


#Fim da funcao pow -------------------------------------

#Inicio da funcao fatorialDiv
fatorialDiv: 	# funcao que divide um float por um fatorial
		# entrada:	$a0 = fatorial	$f14 = numerador da div
		# saida:	$f0 = resultado da divisao
		
	subi $sp, $sp, 4
	sw $ra, 0($sp)  # salva o return address para chamar pow
			
	move $t3, $a0 #move para $t3 o valor que se deseja fatorial
	mov.s $f8, $f14 #move para $f8 o valor do numerador
	
	blt $t3, $zero, fatorialFim #se $t3 < 0 terminar a funcao
	
	fatorialLoop:	
	beq $t3, 0, fatorialFim #parar quando $t3 = 0

	add $t4, $zero, $t3 #copia o valor de $t3 para $t4
	mtc1 $t4, $f6 #move $t4 para Coproc1 $f6
	cvt.s.w $f6,$f6 #converte para float
	
	div.s $f8, $f8, $f6

	sub $t3, $t3, 1	#$t3--
	j fatorialLoop	
	
	fatorialFim:	
	lw $ra, 0($sp)  #guarda o valor que tava na stack
	addi $sp, $sp, 4  #deixa a stack arrumadinha pro proximo
	
	mov.s $f0, $f8 #passa o resultado para $f0
	jr $ra	


#Fim da funcao fatorial ----------------------------------

#Inicio da funcao cos
cos:
# funcao recebe o sen de um numero em $f12 e retorna em $f0
# identidade trigonemetrica: Cos = sqrt(1 - Sen²)
	subi $sp, $sp, 4
	sw $ra, 0($sp)  # salva o return address para chamar pow
	li $a0, 2 #coloca 2 em a0 para chamar a funcao pow
	jal pow # fez sen² e colocou em $f0
	lwc1 $f4, oneFloat
	sub.s $f6, $f4, $f0 #Coloca em $f6 1 - Sen²
	sqrt.s $f8, $f6 # Coloca em $f0 sqrt(1 - Sen²)]
	mov.s $f0, $f8
	lw $ra, 0($sp)  #guarda o valor que tava na stack
	addi $sp, $sp, 4  #deixa a stack arrumadinha pro proximo
	jr $ra  # volta para a funcao
	# fim da funcao

#SinalCos - recebe o angulo em radianos e devolve o sinal do cos
sinalcos:  #recebe o angulo em rad em $f12
	mov.s $f4, $f12 # coloca o angulo em $f4 
	lwc1 $f6, twoQuad # coloca o valor que marca a entrada para o segundo quadrante
	lwc1 $f10, fourQuad # coloca o valor que marca a entrada para o quadrante quadrante
	c.lt.s $f10, $f4 # vai retornar falso na flag se o angulo for maior ou igual a marca do terceiro quadrante, ou seja, se o angulo esta no quarto
	bc1t sinalcospos
	c.le.s $f4, $f6 # checa se o angulo eh menor ou igual a marca que indica entrada para o segundo quadrante, ou seja, se o angulo esta no primeiro quad
	bc1t sinalcospos
	#agora, se o angulo nao esta no primeiro nem quarto quadrante, ele esta no segundo ou no terceiro, que possuem sinal negativo
	j sinalcosneg

sinalcospos:  # caso em que o sinal do quadrante for positivo
	lwc1 $f0, oneFloat
	jr $ra

sinalcosneg:
	lwc1 $f0, oneNegFloat
	jr $ra
	
