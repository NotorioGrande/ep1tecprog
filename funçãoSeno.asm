.data
	
	oneFloat:		.float 1.0
	oneNegFloat:		.float -1.0
	zeroFloat:		.float 0.0
	senLimit:		.float 0.0001
	valorTeste:		.float 0.5
	
.text
main:
	

	lwc1 $f14, valorTeste
	jal sen
	
	li $v0, 2
	mov.s $f12, $f0
	syscall
	
	#Finaliza o Main
	li $v0, 10
	syscall

#FIM MAIN ----------------------------------------------
	


sen: #  // $s0=k	$f24=x // retorna o resultado em $f0=sen(x)
	
	mov.s $f24, $f14
	addi $s0, $zero, 0 #k($s0) = 0
	lwc1 $f20, zeroFloat #$f20 = 0.0
	lwc1 $f22, oneNegFloat #$f22 = -1.0
	lwc1 $f26, senLimit #$f26 = 0.0001 = 10^(-4)
	
	senLoop:	
	
	# (-1)^k        float
	add $a0, $zero, $s0 
	add.s $f12, $f20, $f22 
	jal pow
	mov.s $f16, $f0 # $f16 = (-1)^k
	
	# 2.k + 1        int
	mul $t4, $s0, 2 #$t4 = 2.k
	addi $t4, $t4, 1 #$t4 = 2.k + 1
	
	# x^(2.k + 1)
	add $a0, $zero, $t4 
	add.s $f12, $f20, $f24 
	jal pow
	mov.s $f14, $f0 #$f14 = x^(2.k + 1)
	
	# (-1)^k . x^(2.k + 1)
	mul.s $f14, $f14, $f16 #$f14 = (-1)^k . x^(2.k + 1)
	
	#(2.k + 1)!
	add $t3, $zero, $t4
	jal fatorial
	move $t3, $v0 #$t3 = (2.k + 1)!
	
	#mover $t3 para $f4 (Coproc 1) e tranformar em .float
	mtc1 $t3, $f4
	cvt.s.w $f4, $f4 #$f22 = (2.k + 1)!
	
	#divisão final [(-1)^k . x^(2.k + 1)]/ (2.k + 1)!
	div.s $f28, $f14, $f4
	
	
	#tira o final de $f28
	mov.s $f0, $f28
	jal tiraSinal
	mov.s $f28, $f0
	
	#soma $f28 em $f30
	add.s $f30, $f30, $f28
	
	addi $s0, $s0, 1 #k++
	c.le.s $f28, $f26 # ? $f28 <= $f26
	bc1t senExit # se $f28 <= $26 --> true, vai pra senExit
	j senLoop
	
	
	
	senExit:
	lwc1 $f20, zeroFloat #$f20 = 0.0
	add.s $f0, $f20, $f30
	jr $ra
	
#Fim da função seno ---------------------------------------	
	
	
	

	
pow: # funcao que eleva um numero float a um numero inteiro,(n**k) o argumento do float deve ser passado em $f12 e do int em $a0
#$f6 para salvar o resultado ao longo da exec
#f8 será usado para guardar 0, f0 é o retorno

mtc1 $zero, $f8  # coloca zero no $f8 para usar para calcul,os
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


fatorial: #$t3 é o valor que se deseja em fatorial, a função retorna o resultado em $v0
	blt $t3, $zero, fatorialFim
	addi $v0, $zero, 1
	
	fatorialLoop:	
	beq $t3, 0, fatorialFim #parar quando $t3 = 0
	mul $v0, $v0, $t3 # $v0 = $v0 . $t3
	sub $t3, $t3, 1	#$t3--
	j fatorialLoop	
	
	fatorialFim:	
	jr $ra	

#Fim da função fatorial ----------------------------------


tiraSinal: #função de módulo que recebe x = $f12 // retorna em $f0
	
	lwc1 $f20, zeroFloat #$f20 = 0.0
	lwc1 $f8, oneNegFloat #$f8 = -1.0
	
	c.lt.s $f12, $f20
	bc1f tiraSinalFim #se $f12 < 0.0 for falso, então voltar o programa
	
	mul.s $f12, $f12, $f8 #$f0 = -$f0
	
	mov.s $f0, $f12
	
	tiraSinalFim:
	jr $ra
	
#Fim da função tiraSinal ------------------------------------

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
	
