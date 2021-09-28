	.data
headMsg:	.asciz	"Start av testprogram. Skriv in 5 tal!"
endMsg:		.asciz	"Slut pa testprogram"
buf:		.space	64
sum:		.quad	0
count:		.quad	0
temp:		.quad	0
bufIn:		.space64
bufInPos:	.quad 0
bufOut:		.space64
bufOutPos:	.quad 0
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
	movq $bufin, %rdi
	movq $64, %rsi #maximum numbers of characters accepted to load
	movq stdin, %rdx
	call fgets
	#Reset bufInPos to 0
	movq $0, bufInPos #set the position of the buff to 0
	ret

getInt:
	leaq bufInPos, %rsi
	leaq bufin, %rdi
	cmpq (%rdi), 0 #if the buffert is empty
	je finish
	incq (%rsi)
	cmpq (%rdi), 32 #if the buffert is a space
	je incpos
	cmpq (%rdi), 43 #if the buffert is a plus sign
	je incpostal
	cmpq (%rdi), 45 #if the buffert is a minus sign
	je incpos
	again:
		cmpq (%rsi), $64 #if the buffert is full
		jge finish
		cmpq (%rdi), 0 #if the buffert is NULL
		je finish
		cmpq (%rdi), 48 #if the buffert is a less than the sign 0
		jl finish
		cmpq (%rdi), 57 #if the buffert is a greater than the sign 9
		jle finish
		sub (%rdi), $48
		imulq 10, SaveNumber
		addq (%rdi), SaveNumber
		incq (%rsi)
		jmp again

incpos: #if the buffert is a space
	incq (%rsi)
	jmp again

incpostal: #if the buffert is a plus sign


finish:
	call inImage
