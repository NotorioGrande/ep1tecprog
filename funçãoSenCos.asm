.data

	oneFloat:		.float 1.0
	oneNegFloat:		.float -1.0
	zeroFloat:		.float 0.0
	senLimit:		.float 0.0001
	valorFloat:		.float 6
	valorTeste:		.word 4


.text 
main:
	
	l.s $f14, valorFloat
	lw $a0, valorTeste
	jal sen
	
	mov.s $f12, $f0
	li $v0, 2
	syscall
	
	
	
	
	
	li $v0, 10
	syscall
#FIM MAIN


sen: 	# entrada: angulo em rad: $f14
  	# $s0=k	$f24=x
  	# retorna o resultado em $f0=sen(x)
	
	subi $sp, $sp, 4
	sw $ra, 0($sp)  # salva o return adress para chamar pow
	
	mov.s $f18, $f14 # o angulo � salvo em $f18
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
	add $s1, $zero, $t4 #faz c�pia de $t4 em $s1
	
	# x^(2.k + 1)
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
	bc1t senExit # se $f30 <= $26 --> true, vai pra senExit
	j senLoop
	
	senExit:
	lw $ra, 0($sp)  #guarda o valor que tava na stack
	addi $sp, $sp, 4  #deixa a stack arrumadinha pro proximo
	
	mov.s $f0, $f28
	jr $ra
	
#Fim da função seno ---------------------------------------	

pow: # funcao que eleva um numero float a um numero inteiro,(n**k) o argumento do float deve ser passado em $f12 e do int em $a0
#$f6 para salvar o resultado ao longo da exec
#f8 será usado para guardar 0, f0 é o retorno

mtc1 $zero, $f8  # coloca zero no $f8 para usar para calculos
beq $a0, $0, powzero #se for 0 retornar 1
move $t3, $a0  # coloca K em t3
addi $t3, $t3, -1 # subtrai 1 pq o número de vezes que a multiplicação deve ser feita é K-1
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


#Fim da função pow -------------------------------------

fatorialDiv: 	# fun��o que divide um float por um fatorial
		# entrada:	$a0 = fatorial	$f14 = numerador da div
		# saida:	$f0 = resultado da divis�o
		
	subi $sp, $sp, 4
	sw $ra, 0($sp)  # salva o return adress para chamar pow
			
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
	sw $ra, 0($sp)  # salva o return adress para chamar pow
	li $a0, 2 #coloca 2 em a0 para chamar a funcao pow
	mov.s $f0, $f12 # coloca o sen em $f0 para chamar a função pow
	jal pow # fez sen² e colou em $f0
	lwc1 $f4, oneFloat
	sub.s $f6, $f4, $f0 #Coloca em $f6 1 - Sen²
	sqrt.s $f0, $f6 # Coloca em $f0 sqrt(1 - Sen²)]
	lw $ra, 0($sp)  #guarda o valor que tava na stack
	addi $sp, $sp, 4  #deixa a stack arrumadinha pro proximo
	jr $ra  # volta para a funcao
	# fim da funcao
	
