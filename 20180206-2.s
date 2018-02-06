	.section	__TEXT,__text,regular,pure_instructions
	.macosx_version_min 10, 10
	.globl	_f
	.align	4, 0x90
_f:                                     ## @f
	.cfi_startproc
## BB#0:
	push	rbp
Ltmp0:
	.cfi_def_cfa_offset 16
Ltmp1:
	.cfi_offset rbp, -16
	mov	rbp, rsp
Ltmp2:
	.cfi_def_cfa_register rbp
	mov	al, sil				       # corpse of a rsi -> "c"
	mov	qword ptr [rbp - 8], rdi	       # rbp-8 = rdi = str = address of a 
	mov	byte ptr [rbp - 9], al		       # rbp-9 = "c"
	mov	rdi, qword ptr [rbp - 8]
	mov	qword ptr [rbp - 24], rdi	       # rbp-24 = char *it1
	mov	rdi, qword ptr [rbp - 8]	
	mov	qword ptr [rbp - 32], rdi	       # rbp-32 = char *it2
LBB0_1:                                 
                                       
	mov	rax, qword ptr [rbp - 32]	       # rax = it2
	movsx	ecx, byte ptr [rax]		       # ecx = it2,
	cmp	ecx, 0 				       # *it2 == 0 ?
	je	LBB0_6				       # if *it2 == 0 -> return 
## BB#2:                                
	jmp	LBB0_3				       # else:
LBB0_3:                                 
                                        
	mov	rax, qword ptr [rbp - 32]	        
	movsx	ecx, byte ptr [rax]		       # ecx = char *it2 (cmp wouldn't change the value of it)
	movsx	edx, byte ptr [rbp - 9]		       # edx = "c"
	cmp	ecx, edx			       
	jne	LBB0_5				       # if it2 != "c" -> *it1++ = *it2++
## BB#4:                                
	mov	rax, qword ptr [rbp - 32]	       # rax = it2
	add	rax, 1				       # rax += 1
	mov	qword ptr [rbp - 32], rax	       # it2 += 1
	jmp	LBB0_3				       # jump back
LBB0_5:                                		       
	mov	rax, qword ptr [rbp - 32]	       # rax = it2
	mov	rcx, rax			       # rcx = it2
	add	rcx, 1				       # rcx += 1
	mov	qword ptr [rbp - 32], rcx	       # it2 = it2 + 1 -> stack update
	mov	dl, byte ptr [rax]		       # dl = byte of original it2
	mov	rax, qword ptr [rbp - 24]	       # rax = it1
	mov	rcx, rax			       # rcx = it1
	add	rcx, 1				       # rcx += 1
	mov	qword ptr [rbp - 24], rcx	       # it1 = it1 + 1 -> stack update
	mov	byte ptr [rax], dl		       # byte of original it1 = byte of original it2
	jmp	LBB0_1			               # jmp
LBB0_6:
	mov	rax, qword ptr [rbp - 8]		# set rax to saved value
	pop	rbp
	ret						# return 
	.cfi_endproc

	.globl	_main
	.align	4, 0x90
_main:                                  ## @main
	.cfi_startproc
## BB#0:
	push	rbp
Ltmp3:
	.cfi_def_cfa_offset 16
Ltmp4:
	.cfi_offset rbp, -16
	mov	rbp, rsp
Ltmp5:
	.cfi_def_cfa_register rbp
	sub	rsp, 48
	mov	eax, 10					# malloc(eax * sizeof)
	mov	ecx, eax				# ecx = eax
	mov	dword ptr [rbp - 4], 0			# return 0
	mov	dword ptr [rbp - 8], edi		# save the value of edi
	mov	qword ptr [rbp - 16], rsi		# save the value of rsi 
	mov	rdi, rcx				# rdi = 10  

	call	_malloc					# malloc(rdi)
	lea	rsi, qword ptr [rip + L_.str]		# rsi = "abcdcccd"
	mov	rdx, -1
	mov	qword ptr [rbp - 24], rax		# save the value of return result of malloc -> address of pointer 
	mov	rdi, qword ptr [rbp - 24]		# rdi = address of a
	 
	call	___strcpy_chk				# strcpy(rdi,rsi)
	mov	esi, 99					# rsi = ascii(99) = "c"
	mov	rdi, qword ptr [rbp - 24]		# rdi = address of a 
	mov	qword ptr [rbp - 32], rax 		# save the value of return address of malloc

	call	_f					# f(a,"c")
	lea	rdi, qword ptr [rip + L_.str1]		# rdi = "%s\n"
	mov	rsi, rax				# rsi = return result of f()
	mov	al, 0

	call	_printf				
	mov	rdi, qword ptr [rbp - 24]		# rdi = address of a 
	mov	dword ptr [rbp - 36], eax 		# save the return result of printf
	
	call	_free					# free(rdi)			
	xor	eax, eax				# set eax = 0
	add	rsp, 48
	pop	rbp
	ret
	.cfi_endproc

	.section	__TEXT,__cstring,cstring_literals
L_.str:                                 ## @.str
	.asciz	"abcdcccd"

L_.str1:                                ## @.str1
	.asciz	"%s\n"


.subsections_via_symbols
