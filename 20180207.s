	.file	"removable.c"
	.intel_syntax noprefix
	.section	.rodata
.LC0:
	.string	"Usage: %s <executable>\n"
.LC1:
	.string	"open"
.LC2:
	.string	"fstat"
.LC3:
	.string	"mmap"
.LC4:
	.string	"ELF"
.LC5:
	.string	"%s is not an ELF file\n"
.LC6:
	.string	"%s is not an executable\n"
.LC7:
	.string	"Program Entry point: 0x%x\n"
.LC8:
	.string	"Section header list:\n"
.LC9:
	.string	"%s: 0x%x\n"
.LC10:
	.string	"\nProgram header list\n"
.LC11:
	.string	"Text segment: 0x%x\n"
.LC12:
	.string	"Data segment: 0x%x\n"
.LC13:
	.string	"Interpreter: %s\n"
.LC14:
	.string	"Note segment: 0x%x\n"
.LC15:
	.string	"Dynamic segment: 0x%x\n"
.LC16:
	.string	"Phdr segment: 0x%x\n"
	.text
	.globl	main
	.type	main, @function

# -4[rbp]: int i
# -8[rbp]: int fd
# -16[rbp]: uint8_t *mem
# -24[rbp]: elf32_ehdr *ehdr
# -32[rbp]: elf32_phdr *phdr
# -40[rbp]: elf32_phdr *shdr
# -48[rbp]: char *StringTable
# -56[rbp]: char *interp
# -160[rbp]: st.st_size
# -208[rbp]: struct stat st
# -212[rbp]: int argc
# -224[rbp]: char *argv

main:
.LFB5:
	.cfi_startproc
	push	rbp								# 栈底寄存器入栈
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp							# 将栈底寄存器值更新为原来栈顶寄存器
	.cfi_def_cfa_register 6
	sub	rsp, 224							# 更新指向栈顶的栈指针寄存器
	mov	DWORD PTR -212[rbp], edi			# -212[rbp] = argc
	mov	QWORD PTR -224[rbp], rsi			# -224[rbp] = char* argv
	cmp	DWORD PTR -212[rbp], 1				# argc vs 1?
	jg	.L2  								# if argc > 1, jump to l2
	mov	rax, QWORD PTR -224[rbp]			# rax = address of argv
	mov	rax, QWORD PTR [rax]				# rax = argv[0]
	mov	rsi, rax							# rsi = argv[0]
	lea	rdi, .LC0[rip]						# rdi = address of usage 
	mov	eax, 0								# save the value
	call	printf@PLT						# printf(rdi, rsi)
	mov	edi, 0								# edi = 0 > exit(edi)
	call	exit@PLT						# exit(0)
.L2:
	mov	rax, QWORD PTR -224[rbp] 			# rax = address of argv[0]
	add	rax, 8 								# rax = address of argv[1]
	mov	rax, QWORD PTR [rax]				# rax = value of argv[1]
	mov	esi, 0 								# set O_RDONLY
	mov	rdi, rax
	mov	eax, 0 								# set eax = 0
	call	open@PLT
	mov	DWORD PTR -8[rbp], eax 				# fd = eax = return value of open
	cmp	DWORD PTR -8[rbp], 0				# int fd = 0?
	jns	.L3 								# jump if not smaller than
	lea	rdi, .LC1[rip]						# rdi = "open"
	call	perror@PLT
	mov	edi, -1
	call	exit@PLT						# exit(-1)
.L3:
	lea	rdx, -208[rbp] 						# rdx = -208[rbp] = struct stat st
	mov	eax, DWORD PTR -8[rbp] 				# eax = -8[rbp] = fp
	mov	rsi, rdx							# 要区分rdx和rdi不要看走眼啊……
	mov	edi, eax
	call	fstat@PLT 						# fstat(rdi = fp, rsi = st)
	test	eax, eax 						# test 逻辑与 设置标志寄存器 结果不保存
											# # TEMP ←SRC1 AND SRC2; SF ←MSB(TEMP);
	jns	.L4 								# 如果符号位s不为1，跳转
	lea	rdi, .LC2[rip] 						# rdi = fstat
	call	perror@PLT
	mov	edi, -1
	call	exit@PLT
.L4:
	mov	rax, QWORD PTR -160[rbp] 			# rax = st.st_size
	mov	rsi, rax 							# rsi = st.st_size
	mov	eax, DWORD PTR -8[rbp] 				# eax = fd
	mov	r9d, 0 								
	mov	r8d, eax 							# fd
	mov	ecx, 2								# define MAP_PRIVATE 0x2
	mov	edx, 1								# define PROT_READ 0x1
	mov	edi, 0
	call	mmap@PLT 						
	mov	QWORD PTR -16[rbp], rax				# save, because mem(pointer) = mmap
	cmp	QWORD PTR -16[rbp], -1				# MAP_FAILED = -1
	jne	.L5 								# jump if didn't fail
	lea	rdi, .LC3[rip]						# perror(mmap)
	call	perror@PLT
	mov	edi, -1								# exit(-1) 
	call	exit@PLT
.L5:
	mov	rax, QWORD PTR -16[rbp]             # rax = mem
	mov	QWORD PTR -24[rbp], rax             # ehdr = rax = ehdr
	mov	rax, QWORD PTR -24[rbp]				# rax = ehdr
	mov	eax, DWORD PTR 28[rax]				# eax = ehdr -> e_phoff
	mov	edx, eax 							# edx = eax = ehdr -> e_phoff
	mov	rax, QWORD PTR -16[rbp] 			# rax = mem
	add	rax, rdx							# mem[edx]
	mov	QWORD PTR -32[rbp], rax             # phdr = mem][ehdr->e_phoff]
	mov	rax, QWORD PTR -24[rbp]             # rax = ehdr
	mov	eax, DWORD PTR 32[rax]              # eax = rax = ehdr->e_shoff
	mov	edx, eax 							# edx = eax
	mov	rax, QWORD PTR -16[rbp]             # rax = mem
	add	rax, rdx 							# mem[ehdr->e_shoff]
	mov	QWORD PTR -40[rbp], rax 			# shdr
	mov	rax, QWORD PTR -16[rbp]             # rax = mem
	movzx	eax, BYTE PTR [rax]             # 无符号扩展
	cmp	al, 127 							# 127, magic number of ELF, 0x7f
	je	.L6 								# jump if equal
	mov	rax, QWORD PTR -16[rbp] 			# &mem
	add	rax, 1 								# &mem[1]
	lea	rsi, .LC4[rip] 						# rsi = "ELF"
	mov	rdi, rax
	call	strcmp@PLT
	test	eax, eax
	je	.L6
	mov	rax, QWORD PTR -224[rbp] 			# argv
	add	rax, 8 								# argv[1]
	mov	rdx, QWORD PTR [rax] 				# rdx = argv[1]
	mov	rax, QWORD PTR stderr[rip] 			
	lea	rsi, .LC5[rip] 						# not an elf
	mov	rdi, rax 							# rdi = stderr
	mov	eax, 0
	call	fprintf@PLT
	mov	edi, -1
	call	exit@PLT
.L6:
	mov	rax, QWORD PTR -24[rbp] 			# ehdr
	movzx	eax, WORD PTR 16[rax] 			# eax = ehdr->e_type
	cmp	ax, 2 								# cmp ehdr->e_type vs ET_EXEC(2)
	je	.L7
	mov	rax, QWORD PTR -224[rbp] 			
	add	rax, 8
	mov	rdx, QWORD PTR [rax]
	mov	rax, QWORD PTR stderr[rip]
	lea	rsi, .LC6[rip]
	mov	rdi, rax
	mov	eax, 0
	call	fprintf@PLT
	mov	edi, -1
	call	exit@PLT
.L7:
	mov	rax, QWORD PTR -24[rbp] 			# ehdr
	mov	eax, DWORD PTR 24[rax] 				# ehdr->e_entry
	mov	esi, eax 							# esi = ehdr->e_entry
	lea	rdi, .LC7[rip] 						# rdi = program entry point
	mov	eax, 0 							
	call	printf@PLT 						# printf("program Entry point: blabla")
	mov	rax, QWORD PTR -24[rbp] 			# rax = ehdr
	movzx	eax, WORD PTR 50[rax] 			# eax = 50[ehdr]
	movzx	edx, ax 						# edx save eax
	mov	rax, rdx
	sal	rax, 2 								# rax 算数左移
	add	rax, rdx
	sal	rax, 3 								# rax + rax*4 + rax*8
	mov	rdx, rax 							# rdx = rax + rax*4 + rax*8 = 13*{50[ehdr]}	
	mov	rax, QWORD PTR -40[rbp] 			# rax = shdr
	add	rax, rdx 	 						# rax = shdr[ehdr->e_shstrndx]
	mov	eax, DWORD PTR 16[rax] 				# ofset
	mov	edx, executable 					# save eax
	mov	rax, QWORD PTR -16[rbp] 			# rax = mem
	add	rax, rdx 							# mem[shdr[ehdr->e_shstrndx].sh_offset]
	mov	QWORD PTR -48[rbp], rax 			# stringtable = rax
	lea	rdi, .LC8[rip] 						# "section header list"
	call	puts@PLT 						# print section header list
	mov	DWORD PTR -4[rbp], 1 				# int i = 1
	jmp	.L8
.L9:
	mov	eax, DWORD PTR -4[rbp] 				# eax = i
	movsx	rdx, eax 						# rdx = eax = i
	mov	rax, rdx 							# rax = i
	sal	rax, 2 								# rax = i*4
	add	rax, rdx 							# rax = i + i * 4
	sal	rax, 3 								# rax = (i + i * 4) * 8
	mov	rdx, rax 							# rdx = rax = 40i
	mov	rax, QWORD PTR -40[rbp] 			# rax = shdr
	add	rax, rdx 							# rax = shdr[40i]
	mov	ecx, DWORD PTR 12[rax] 				# ecx = 12[rax]
	mov	eax, DWORD PTR -4[rbp] 				# eax = i
	movsx	rdx, eax 						# save eax in rdx
	mov	rax, rdx 							
	sal	rax, 2 								# rax = 4i
	add	rax, rdx 							# rax = 5i
	sal	rax, 3 								# rax = 40i
	mov	rdx, rax 							# rdx = 40i
	mov	rax, QWORD PTR -40[rbp] 			# rax = shdr
	add	rax, rdx 							# rax = shdr[40i]
	mov	eax, DWORD PTR [rax] 				# eax = rax
	mov	edx, eax 							# save rax in edx
	mov	rax, QWORD PTR -48[rbp] 			# StringTable
	add	rax, rdx 							# rax = stringtable[shdr[i].sh_name]
	mov	edx, ecx 							# edx = ecx = 12{shdr[40i]} = shdr[i].sh_addr
											# 也许一个shdr的长度是40吧
	mov	rsi, rax 							# rsi = stringtable[shdr[i].sh_name]
	lea	rdi, .LC9[rip] 						# "%s: 0x%x\n"
	mov	eax, 0 			
	call	printf@PLT
	add	DWORD PTR -4[rbp], 1 				# i++
.L8:
	mov	rax, QWORD PTR -24[rbp] 			# rax = ehdr
	movzx	eax, WORD PTR 48[rax] 			# ehdr->e_shnum
	movzx	eax, ax 				
	cmp	DWORD PTR -4[rbp], eax 				# compare i and ehdr->e_shnum
	jl	.L9 								# in the for scope
	lea	rdi, .LC10[rip] 					# print "\nProgram header list\n"
	call	puts@PLT
	mov	DWORD PTR -4[rbp], 0 				# i = 0
	jmp	.L10 								# another for
.L20:
	mov	eax, DWORD PTR -4[rbp] 				# eax = i
	cdqe 									# Convert Doubleword to Quadword
	sal	rax, 5 								# rax = rax * 32
	mov	rdx, rax 							# rdx = rax
	mov	rax, QWORD PTR -32[rbp] 			# rax = phdr
	add	rax, rdx 							# rax = phdr[32i]
	mov	eax, DWORD PTR [rax] 				# eax = value of phdr[32i] = phdr[32i].p_type
	cmp	eax, 6 									
	ja	.L11 								# jump if above
	mov	eax, eax
	lea	rdx, 0[0+rax*4] 					# 4 * p_type
	lea	rax, .L13[rip] 						# rax = l13
	mov	eax, DWORD PTR [rdx+rax] 			# eax = value of [address of l13 + 4 * p_type]
	movsx	rdx, eax 						# rdx = eax
	lea	rax, .L13[rip] 						# rax = address of l13
	add	rax, rdx 							# rax = address of l12 + value of [address of l13 + 4 * p_type] = offset 
	jmp	rax
	.section	.rodata
	.align 4
	.align 4
.L13:
	.long	.L11-.L13 						# i++
	.long	.L12-.L13 						# PT_LOAD
	.long	.L14-.L13 						# PT_DYNAMIC
	.long	.L15-.L13 						# PT_INTERP
	.long	.L16-.L13 						# PT_NOTE
	.long	.L11-.L13 						# i++
	.long	.L17-.L13 						# PT_PHDR
	.text
.L12: 										# case PT_LOAD:
	mov	eax, DWORD PTR -4[rbp]
	cdqe
	sal	rax, 5
	mov	rdx, rax
	mov	rax, QWORD PTR -32[rbp]
	add	rax, rdx
	mov	eax, DWORD PTR 4[rax] 				# phdr[32i].p_offset
	test	eax, eax
	jne	.L18
	mov	eax, DWORD PTR -4[rbp]
	cdqe
	sal	rax, 5
	mov	rdx, rax
	mov	rax, QWORD PTR -32[rbp]
	add	rax, rdx
	mov	eax, DWORD PTR 8[rax]
	mov	esi, eax
	lea	rdi, .LC11[rip] 					# Text segment
	mov	eax, 0
	call	printf@PLT
	jmp	.L11
.L18:
	mov	eax, DWORD PTR -4[rbp]
	cdqe
	sal	rax, 5
	mov	rdx, rax
	mov	rax, QWORD PTR -32[rbp]
	add	rax, rdx
	mov	eax, DWORD PTR 8[rax]
	mov	esi, eax
	lea	rdi, .LC12[rip] 					# Data segment
	mov	eax, 0
	call	printf@PLT
	jmp	.L11
.L15: 										# case PT_INTERP:
	mov	eax, DWORD PTR -4[rbp]
	cdqe
	sal	rax, 5
	mov	rdx, rax
	mov	rax, QWORD PTR -32[rbp]
	add	rax, rdx
	mov	eax, DWORD PTR 4[rax] 				# phdr[32i].p_offset
	mov	edx, eax
	mov	rax, QWORD PTR -16[rbp] 			# mem
	add	rax, rdx 							# mem[phdr[32i].p_offset]
	mov	rdi, rax
	call	strdup@PLT
	mov	QWORD PTR -56[rbp], rax 			# set interp
	mov	rax, QWORD PTR -56[rbp]
	mov	rsi, rax
	lea	rdi, .LC13[rip] 					# print interpreter				
	mov	eax, 0
	call	printf@PLT
	jmp	.L11
.L16: 										# case PT_NOTE:
	mov	eax, DWORD PTR -4[rbp]
	cdqe
	sal	rax, 5
	mov	rdx, rax
	mov	rax, QWORD PTR -32[rbp]
	add	rax, rdx
	mov	eax, DWORD PTR 8[rax]
	mov	esi, eax
	lea	rdi, .LC14[rip] 					# note segment 
	mov	eax, 0
	call	printf@PLT
	jmp	.L11
.L14: 										# case PT_DYNAMIC
	mov	eax, DWORD PTR -4[rbp] 				# eax = i
	cdqe 									# double to quarter
	sal	rax, 5 								# 32i
	mov	rdx, rax 							# save the value of 32i
	mov	rax, QWORD PTR -32[rbp] 			# phdr
	add	rax, rdx 							# phdr[32i]
	mov	eax, DWORD PTR 8[rax] 				# 8{phdr[32i]} = phdr[32i].p_vaddr
	mov	esi, eax 							# esi = phdr[32i].p_vaddr
	lea	rdi, .LC15[rip] 					# dynamic segment
	mov	eax, 0 								# jump to i++
	call	printf@PLT
	jmp	.L11
.L17: 										# case PT_PHDR
	mov	eax, DWORD PTR -4[rbp]
	cdqe
	sal	rax, 5
	mov	rdx, rax
	mov	rax, QWORD PTR -32[rbp]
	add	rax, rdx
	mov	eax, DWORD PTR 8[rax]
	mov	esi, eax
	lea	rdi, .LC16[rip] 					# phdr segment
	mov	eax, 0
	call	printf@PLT
	nop
.L11:
	add	DWORD PTR -4[rbp], 1 				# i++
.L10:
	mov	rax, QWORD PTR -24[rbp] 			# rax = ehdr
	movzx	eax, WORD PTR 44[rax]			# ehdr->e_phnum
	movzx	eax, ax
	cmp	DWORD PTR -4[rbp], eax 				# compare i and ehdr->e_phnum
	jl	.L20 								# jump if less than
	mov	edi, 0
	call	exit@PLT 						# exit(0)
	.cfi_endproc
.LFE5:
	.size	main, .-main
	.ident	"GCC: (Debian 7.2.0-17) 7.2.1 20171205"
	.section	.note.GNU-stack,"",@progbits
