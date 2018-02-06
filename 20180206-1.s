	.section	__TEXT,__text,regular,pure_instructions
	.macosx_version_min 10, 10
	.globl	_main
	.align	4, 0x90
_main:                                  ## @main
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
	sub	rsp, 16
	mov	dword ptr [rbp - 4], 0     # return address
	mov	dword ptr [rbp - 8], 0     # i=0
	cmp	dword ptr [rbp - 8], 0     # i=0?
	jle	LBB0_2                     # jump if less than or equal
## BB#1:
	mov	eax, dword ptr [rbp - 8]   # eax = i = 0
	mov	ecx, eax                   # ecx = eax = i = 0
	add	ecx, 1                     # ecx += 1
	mov	dword ptr [rbp - 8], ecx   # i = ecx = 1
	mov	dword ptr [rbp - 12], eax  # saving the value of eax
	jmp	LBB0_3
LBB0_2:                                    # i--
	mov	eax, dword ptr [rbp - 8]   # move i to eax = 0
	mov	ecx, eax                   # move i to ecx = 0
	add	ecx, 4294967295            # ecx=-1
	mov	dword ptr [rbp - 8], ecx   # i = -1
	mov	dword ptr [rbp - 12], eax  ## saving the value of eax
LBB0_3:
	mov	eax, dword ptr [rbp - 12]  ## original i = 0
	lea	rdi, qword ptr [rip + L_.str]
	mov	ecx, dword ptr [rbp - 8]   # ecx = i
	add	ecx, eax                   # ecx += eax (original i, 0)
	mov	dword ptr [rbp - 8], ecx   # i = ecx
	mov	esi, dword ptr [rbp - 8]
	mov	al, 0
	call	_printf
	xor	ecx, ecx
	mov	dword ptr [rbp - 16], eax  ## 4-byte Spill
	mov	eax, ecx
	add	rsp, 16
	pop	rbp
	ret
	.cfi_endproc

	.section	__TEXT,__cstring,cstring_literals
L_.str:                                    ## @.str
	.asciz	"%d"


.subsections_via_symbols
