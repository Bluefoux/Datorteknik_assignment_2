	.data
headMsg:	.asciz	"Start av testprogram. Skriv in 5 tal!"
endMsg:		.asciz	"Slut pa testprogram"
bufOut:		.space	64
bufIn:		.space	64
buf:		.space	64
sum:		.quad	0
count:		.quad	0
temp:		.quad	0
bufInPos:	.quad	0
bufOutPos:	.quad	0
Number:		.quad	0
SaveNumber:	.quad	0


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
	movq	$buf,%rdi
	call	getText
	movq	$buf,%rdi
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
	movq $bufIn, %rdi
	movq $64, %rsi #maximum numbers of characters accepted to load
	movq stdin, %rdx
	call fgets
	#Reset bufInPos to 0
	movq $0, bufInPos #set the position of the buff to 0
	ret

.global outImage
outImage:
	#calls puts to print the stored memory in bufOut
	movq $bufOut, %rdi
	call puts
	#Reset bufOutPos to 0
	movq $0, bufOutPos #set the position of the buff to 0
	ret

.global getInt
getInt:
	ret

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
	incq 	%rbx # Increment rax with 1
	incq 	%rax
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
	movq	$bufIn, %rdi         #<--- check om det funkar, ta bort sen.
	call	puts
	ret

.global getChar
getChar:
	leaq bufIn, %rcx # Load bufin adress to rcx register
	cmpq $0, %rcx # If bufin == NULL then
	je callinimage # Call inimage
	pushq %rcx
	call getInPos # Get the current pos in bufin
	popq %rcx
	cmpq $64, %rax # If bufin is full(bufinpos == 64) then
	jge callinimage # Call inimage
	movq %rax, %rdi # Move current inpos to %rdi
	movzbq (%rcx,%rdi), %rax # Move character to rax
	incq %rdi # Increment rdi with 1 
	pushq %rax
	call setInPos # Set new bufinpos
	popq %rax
	ret #return rax (the char)
callinimage:
	call inImage

.global putInt
putInt:
 ret
	 
.global putText
putText:
	leaq bufOut, %rcx # Load bufOut adress to rcx register
	pushq %rdi
	pushq %rcx
	call getOutPos # Get the current pos in bufOut
	popq %rcx
	popq %rdi
	put_text_again:
	mov %edi,(%rcx, %rax)
	incq %rax # Increment rdi with 1 
	cmpq $64, %rax # If bufout is full(bufoutpos == 64) then
	jge finishputText # Call outimage
	jmp put_text_again
callOutImagePutText:
	call outImage
	ret
finishputText:
	movq %rax, %rdi
	call setOutPos # Set new bufoutpos
	ret #return rax (for no reason)

.global putChar
putChar:
	leaq bufOut, %rcx # Load bufOut adress to rcx register
	pushq %rdi
	pushq %rcx
	call getOutPos # Get the current pos in bufOut
	popq %rcx
	popq %rdi
	mov %di,(%rcx,%rax)
	incq %rax # Increment rdi with 1 
	cmpq $64, %rax # If bufout is full(bufoutpos == 64) then
	jge callOutImagePutChar # Call outimage
	movq %rax, %rdi
	call setOutPos # Set new bufoutpos
	ret #return rax (for no reason)
callOutImagePutChar:
	call outImage
	ret

.global getInPos
getInPos: # Return current bufferposition for the inbufer
	# Returnvalue is stored in register %rax and returned
	leaq bufInPos, %rcx
	movq (%rcx), %rax
	ret

.global getOutPos
getOutPos: # Return current bufferposition for the outbufer
	# Returnvalue is stored in register %rax and returned
	leaq bufOutPos, %rcx
	movq (%rcx), %rax
	ret

.global setInPos
setInPos: # Used to set the position of  the current bufferposition for the inbuffer
	cmpq $0, %rdi
	jle set_to_0
	cmpq $64, %rdi
	jge set_max_pos
	movq %rdi, bufInPos
	jmp finish
set_to_0:
	movq $0, bufInPos
	jmp finish
set_max_pos:
	movq $64, bufInPos
	jmp finish
finish:
	ret

.global setOutPos
setOutPos: # Used to set the position of  the current bufferposition for the inbuffer
	cmpq $0, %rdi
	jle out_set_to_0
	cmpq $64, %rdi
	jge out_set_max_pos
	movq %rdi, bufOutPos
	jmp out_finish
out_set_to_0:
	movq $0, bufOutPos
	jmp out_finish
out_set_max_pos:
	movq $64, bufOutPos
	jmp out_finish
out_finish:
	ret
