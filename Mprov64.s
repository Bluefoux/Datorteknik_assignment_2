	.data
headMsg:	.asciz	"Start av testprogram. Skriv in 5 tal!"
endMsg:		.asciz	"Slut pa testprogram"
testMSG:	.asciz	"test %s \n"
bufOut:		.space	64
bufIn:		.space	64
#buf:		.space	64
count:		.quad	0
temp:		.quad	0
bufInPos:	.quad	0
bufOutPos:	.quad	0
sum:		.quad	0
Number:		.quad	0



	.text
	.global	main
main:
	pushq	$0
	movq	$headMsg,%rdi
	call	putText
	call	outImage
	call	inImage
	movq	$5,count
l1:
	call	getInt
	movq	%rax,temp
	cmpq	$0,%rax
	jge		l2
	call	getOutPos
	decq	%rax
	movq	%rax,%rdi
	call	setOutPos
l2:
	movq	temp,%rdx
	add	%rdx,sum
	movq	%rdx,%rdi
	call	putInt
	movq	$'+',%rdi
	call	putChar
	decq	count
	cmpq	$0,count
	jne	l1
	call	getOutPos
	decq	%rax
	movq	%rax,%rdi
	call	setOutPos
	movq	$'=',%rdi
	call	putChar
	movq	sum, %rdi
	call	putInt
	call	outImage
	movq	$12,%rsi
	movq	$bufIn,%rdi # printar inte texten som skrivs in från inputen
	call	getText
	movq	$bufIn,%rdi
	call	putText
	movq	$125,%rdi
	call	putInt
	call	outImage
	movq	$endMsg,%rdi
	call	putText
	call	outImage
	popq	%rax
	ret

.global inImage
inImage:
	#calls fgets to get input from the user and put it into a buffer
	movq 	$bufIn, %rdi
	movq 	$64, %rsi #maximum numbers of characters accepted to load
	movq 	stdin, %rdx
	call 	fgets
	#Reset bufInPos to 0
	movq 	$0, bufInPos #set the position of the buff to 0
	ret

.global outImage
outImage:
	#calls puts to print the stored memory in bufOut
	movq 	$bufOut, %rdi
	call 	puts
	#Reset bufOutPos to 0
	movq 	$0, bufOutPos #set the position of the buff to 0
	movq	$0, bufOut
	ret

.global getInt
getInt: 
	# ascii #32 = " "
	# ascii #43 = +
	# ascii #45 = -
	# ascii #48 = 0
	# ascii #57 = 9
	movq	$0, Number # Number = 0
	movq	$0, %r14
get_int_again:
	call 	getChar # Get a char (to rax)
	cmpq	$32, %rax # " "
	je 		get_int_again
	cmpq	$43, %rax # +
	je 		get_int_again
	cmpq	$45, %rax # -
	je 		get_int_neg
get_int_again_continue:
	cmpq	$48, %rax # If rax (the char) is less than the ascii # 48 (siffran 0)
	jl		finish_get_int
	cmpq	$57, %rax #If rax (the char) is bigger than the ascii # 57 (siffran 9)
	jg		finish_get_int
	subq	$48, %rax #ASCII to int
	movq	%rax, %r13
	imulq	$10, Number, %rax
	movq	%rax, Number
	addq	%r13, Number
	jmp		get_next_int
get_next_int:
	call	getChar
	jmp		get_int_again_continue
get_int_neg:
	# character switch Number (change Number to a negative number)
	movq	$1, %r14
	jmp		get_next_int #fortsätt
finish_get_int:
	cmpq	$0, %r14
	je		exit_get_int
	negq	(Number)
exit_get_int:
	movq	Number, %rax
	ret		# Return the number (in rax)

.global getText
getText:
	leaq 	bufIn, %rcx # Load bufin adress to rcx register
	cmpq 	$0, %rcx # If bufin == NULL then
	je 		callinimageGetText # Call inimage
	pushq 	%rdi
	pushq 	%rcx
	call 	getInPos
	popq 	%rdi
	popq 	%rcx
	movq 	$0, %rbx
	get_text_again:
	incq 	%rbx # Increment rbx with 1
	incq 	%rax # Increment rax with 1
	cmpq 	%rcx, %rax
	je 		finishgetText
	cmpq 	%rsi, %rbx
	je 		finishgetText
	mov 	%di,(%rcx, %rax)
	jmp 	get_text_again
	ret
callinimageGetText:
	call 	inImage
	ret
finishgetText:
	movq 	%rax, %rdi
	call 	setInPos
	call 	getInPos
	movq 	%rdi, %rax
	ret

.global getChar
getChar:
	leaq 	bufIn, %rcx # Load bufin adress to rcx register
	cmpq 	$0, %rcx # If bufin == NULL then
	je 		callinimage # Call inimage
	pushq 	%rcx
	call 	getInPos # Get the current pos in bufin
	popq 	%rcx
	cmpq 	$64, %rax # If bufin is full(bufinpos == 64) then
	jge 	callinimage # Call inimage
	movq 	%rax, %rdi # Move current inpos to %rdi
	movzbq 	(%rcx,%rdi), %rax # Move character to rax
	incq 	%rdi # Increment rdi with 1 
	pushq 	%rax
	call 	setInPos # Set new bufinpos
	popq 	%rax
	ret 	# return rax (the char)
callinimage:
	pushq	%rdi
	call 	inImage
	popq	%rdi
	jmp		getChar

.global putInt
putInt: 
	movq	$0, %r14
	movq	$0, %r13
	movq	%rdi, %rax
	cmpq	$0, %rax # Är talet positivt?
	jge		put_int_again
	movq	$1, %r14 # hjälp minne om talet är negativt
	negq	%rax # Gör talet temporärligt positivt för att kunna utföra divitionen
put_int_again:
	movq	$10, %r15
	cqto	# Konvertera %rax till 128-bitars register
	idivq	%r15 # Dividera rax med r15 (r15 = 10)
	addq	$48, %rdx # ASCII to int
	cltq	# Konvertera till 64-bitars register
	movq	%rdx, %rdi
	pushq	%rdi # Spara ASCII på stacken
	incq	%r13
	cmpq	$0, %rax
	je		put_int_finish
	jmp		put_int_again
put_int_finish:
	cmpq	$0, %r14
	je		put_int_positiv
	movq	$45, %rdi # Gör talet negativt
	pushq	%rax
	pushq	%rdx
	call	putChar
	popq	%rdx
	popq	%rax
put_int_positiv:
	cmpq	$0, %r13 # Är antal tecken som ska skrivas ut = 0?
	je		put_int_ret # Gå till return
	popq	%rdi # Hämta tecken från stacken
	pushq	%rax
	pushq	%rdx
	call	putChar # Skriv ut
	popq	%rdx
	popq	%rax
	decq	%r13 # Minskar antal tecken
	jmp		put_int_positiv # Nästa tecken
put_int_ret:
	ret

.global putText
putText:
	movq 	%rdi, %r12
	movq	$0, %r13
put_text_again:
	movzbq 	(%r12, %r13), %rdi
	cmpq	$0, %rdi
	je		finishputText
	pushq	%rdi
	call	putChar
	popq	%rdi
	incq	%r13
	jmp		put_text_again
finishputText:
	ret 	#return rax (for no reason)

.global putChar
putChar:
	leaq 	bufOut, %rcx # Load bufOut adress to rcx register
	pushq 	%rdi
	pushq 	%rcx
	call 	getOutPos # Get the current pos in bufOut
	popq 	%rcx
	popq 	%rdi
	mov 	%di,(%rcx,%rax)
	incq 	%rax # Increment rdi with 1 
	cmpq 	$64, %rax # If bufout is full(bufoutpos == 64) then
	jge 	callOutImagePutChar # Call outimage
	movq 	%rax, %rdi
	call 	setOutPos # Set new bufoutpos
	ret 	#return rax (for no reason)
callOutImagePutChar:
	call 	outImage
	ret

.global getInPos
getInPos: # Return current bufferposition for the inbufer
	# Returnvalue is stored in register %rax and returned
	leaq 	bufInPos, %rcx
	movq 	(%rcx), %rax
	ret

.global getOutPos
getOutPos: # Return current bufferposition for the outbufer
	# Returnvalue is stored in register %rax and returned
	leaq 	bufOutPos, %rcx
	movq 	(%rcx), %rax
	ret

.global setInPos
setInPos: # Used to set the position of  the current bufferposition for the inbuffer
	cmpq 	$0, %rdi
	jle 	set_to_0
	cmpq 	$64, %rdi
	jge 	set_max_pos
	movq 	%rdi, bufInPos
	jmp 	finish
set_to_0:
	movq 	$0, bufInPos
	jmp 	finish
set_max_pos:
	movq 	$64, bufInPos
	jmp 	finish
finish:
	ret

.global setOutPos
setOutPos: # Used to set the position of  the current bufferposition for the inbuffer
	cmpq 	$0, %rdi
	jle 	out_set_to_0
	cmpq 	$64, %rdi
	jge 	out_set_max_pos
	movq 	%rdi, bufOutPos
	jmp 	out_finish
out_set_to_0:
	movq 	$0, bufOutPos
	jmp 	out_finish
out_set_max_pos:
	movq 	$64, bufOutPos
	jmp 	out_finish
out_finish:
	ret
