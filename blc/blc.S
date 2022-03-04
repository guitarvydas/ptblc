/*-*- mode:unix-assembly; indent-tabs-mode:t; tab-width:8; coding:utf-8     -*-│
│vi: set et ft=asm ts=8 tw=8 fenc=utf-8                                     :vi│
╞══════════════════════════════════════════════════════════════════════════════╡
│ Copyright 2022 Justine Alexandra Roberts Tunney                              │
│                                                                              │
│ Permission to use, copy, modify, and/or distribute this software for         │
│ any purpose with or without fee is hereby granted, provided that the         │
│ above copyright notice and this permission notice appear in all copies.      │
│                                                                              │
│ THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL                │
│ WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED                │
│ WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE             │
│ AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL         │
│ DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR        │
│ PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER               │
│ TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR             │
│ PERFORMANCE OF THIS SOFTWARE.                                                │
╚─────────────────────────────────────────────────────────────────────────────*/

//	@fileoverview Binary Lambda Calculus Virtual Machine
//	              In a 397 byte Linux x64 ELF executable
//
//	The Lambda Calculus is a mathematical language with 1 keyword.
//	It's a Turing tarpit, discovered by Turing's doctoral advisor.
//	This is a Church-Krivine-Tromp machine with ASCII oriented IO.
//	It implements garbage collection, lazy lists & tail recursion.
//	It extracts only the least significant bit from an stdin byte.
//	Output is only 0 and 1 bytes. It's slow but easy for learning.
//	Displacement is limited to [0,255] so progs can't be too huge.
//	Your ASCII binary serialization format, is defined as follows:
//
//	    00      means abstraction   (pops in the Krivine machine)
//	    01      means application   (push argument continuations)
//	    1⋯0     means variable      (with varint de Bruijn index)
//	    000010  e.g. means λλ0
//	    0000110 e.g. means λλ1
//
//	Your virtual machine may be compiled as follows:
//
//	    cc -no-pie -static -nostdlib -Wl,-oformat:binary -o blc blc.S
//
//	Your program is read from stdin followed by its input. Here's
//	a simple tutorial using the identity function (λ 0), which is
//	encoded as (00 10) in the binary lambda calculus:
//
//	    $ { printf 0010; printf 0101; } | ./blc; echo
//	    0101
//
//	You can use sed shell scripts as a byte code compiler. All it
//	has to do is `s/λ/00/g`, `s/\[/01/g`, `s/[^01]//g`, etc.
//
//	    #!/bin/sh
//	    tr \\n n |
//	      sed '
//	          s/;.*//
//	          s/#.*//
//	          s/1/⊤/g
//	          s/0/⊥/g
//	          s/λ/00/g
//	          s/\[/01/g
//	          s/9/11111111110/g
//	          s/8/1111111110/g
//	          s/7/111111110/g
//	          s/6/11111110/g
//	          s/5/1111110/g
//	          s/4/111110/g
//	          s/3/11110/g
//	          s/2/1110/g
//	          s/⊤/110/g
//	          s/⊥/10/g
//	          s/[^01]//g
//	        '
//
//	We can now write nicer looking programs:
//
//	    { printf %s "(λ 0)" | ./compile.sh
//	      printf 0101
//	    } | ./blc
//
//	This program means exit(0) because it returns `$nil` or `[]`:
//
//	    λ λλ0
//
//	Here's some important values:
//
//	    nil="λλ0"
//	    false="λλ0"
//	    true="λλ1"
//
//	Here's some important abstractions:
//
//	    if="λ 0"
//	    pair="λλλ [[0 2] 1]"
//	    car="λ [0 $true]"
//	    cdr="λ [0 $false]"
//	    or="λλ [[1 1] 0]"
//	    and="λλ [[1 0] 1]"
//	    not="λλλ [[2 0] 1]"
//	    xor="λλ [[1 λλ [[2 0] 1]] 0]"
//	    iszero="λλλ [[2 λ 1] 1]"
//	    Y="λ [λ [0 0] λ [1 [0 0]]]"
//
//	Here are your integers:
//
//	    zero="λλ 0"
//	    one="λλ [1 0]"
//	    two="λλ [1 [1 0]]"
//	    three="λλ [1 [1 [1 0]]]"
//	    four="λλ [1 [1 [1 [1 0]]]]"
//	    five="λλ [1 [1 [1 [1 [1 0]]]]]"
//	    six="λλ [1 [1 [1 [1 [1 [1 0]]]]]]"
//	    seven="λλ [1 [1 [1 [1 [1 [1 [1 0]]]]]]]"
//	    eight="λλ [1 [1 [1 [1 [1 [1 [1 [1 0]]]]]]]]"
//	    nine="λλ [1 [1 [1 [1 [1 [1 [1 [1 [1 0]]]]]]]]]"
//
//	Here's some arithmetic:
//
//	    pow="λλ [0 1]"
//	    mul="λλλ [2 [1 0]]"
//	    sub="λλ [[0 $dec] 1]"
//	    inc="λλλ [1 [[2 1] 0]]"
//	    dec="λλλ [[[2 λλ [0 [1 3]]] λ 1] λ 0]"
//	    add="λλλλ [[3 1] [[2 1] 0]]"
//	    fac="λλ [[[1 λλ [0 [1 λλ [[2 1] [1 0]]]]] λ1] λ0]"
//	    min="λλλλ [[[3 λλ [0 1]] λ1] [[2 λλ [3 [0 1]]] λ1]]"
//	    div="λλλλ [[[3 λλ [0 1]] λ 1] [[3 λ [[[3 λλ [0 1]] λ [3 [0 1]]] λ0]] 0]]"
//	    mod="λλλλ [[[3 $cdr] [[3 λ [[[3 λλλ [[0 [2 [5 1]]] 1]] λ1] 1]] λ1]] λλ0]"
//
//	Here's some predicates:
//
//	    eq="λλ [[[[1 λ [[0 λ0] λ0]] [[0 λλλ [1 2]] λλ0]] λλλ0] λλ1]"
//	    le="λλ [[[1 λλ [0 1]] λλλ1] [[0 λλ [0 1]] λλλ0]]"
//	    lt="λλ [[[0 λλ [0 1]] λλλ0] [[1 λλ [0 1]] λλλ1]]"
//	    odd="λ [λ [0 0] λλ [[0 λλ 1] λ [[0 λλ 0] [2 2]]]]"
//	    divides="λλ [[[1 $cdr] [λ [0 0] λ[[[1 λλλ [[0 [2 λλ0]] 1]] λ[1 1]] λλ1]]] λλ0]"
//
//	This program returns `[0, 1]` so it prints `10`.
//
//	    λ [[$pair $false] [[$pair $true] $nil]]
//
//	This program means if (1 - 1 == 0) putc('1') else putc('0');
//
//	    λ [[[$if [$iszero [[$sub $one] $one]]]
//	          [[$pair $false] $nil]]
//	       [[$pair $true] $nil]]
//
//	This program does the same thing as the ident program but
//	is more spelled out. The two arguments the runtime passes
//	are `gro` and `put` (or `λ [[0 wr0] wr1]`).  Index 110 is
//	is the outer parameter and 10 is the inner parameter.  So
//	this program is the same as doing `for (;;) putc(getc())`
//
//	    λλ [1 0]
//	    ││
//	    │└binds `put` or `(λ 0 wr0 wr1)` [cited as 0]
//	    └binds `gro` or `⋯` [cited as 1]
//
//	This will invert a stream of bits using the Y combinator.
//	It's got a whopping 16kBps of throughput.
//
//	    # a.k.a. Y(λab.(λc.c)b(λcde.❬¬c,ad❭)⊥)
//	    [$Y λλ [[[$if 0] λλλ [[$pair [$not 2]] [4 1]]] $nil]]
//	        ││           │││
//	        ││           ││└consumes $nil terminator [uncited]
//	        ││           │└binds 𝑝 input bit [cited as 1]
//	        ││           └binds (λ 0 𝑝 ⋯) [cited as 2]
//	        │└binds gro (λ 0 𝑝 ⋯) [cited by first 0]
//	        └binds recursive function [cited as 4]
//
//	This program means for x in reversed(stdin): put(x)
//
//	    # a.k.a. λa.a(ω(λbcde.d(bb)(λf.fce)))⊥
//	    λ [[0 [λ [0 0] λλλλ [[1 [3 3]] λ [[0 3] 1]]]] $nil]
//
//	This program means ['1'] * 4**3 times:
//
//	    λ [[$Y λλ [[[$if [$iszero 0]]
//	                    $nil]
//	                 [[$pair $false]
//	                  [1 [$dec 0]]]]]
//	       [[$pow $four] $three]]
//
//	If you need to exponentiate bigger numbers like 9**3 then you'll
//	likely need to tune the STACK parameter below, to mmap something
//	bigger than what the operating system provides by default.
//
//	Your VM expands your program on startup as follows:
//
//	    𝑝 ⟶ [λ [0 λ [[0 wr0] wr1]] [𝑝 ⋯]]
//
//	The lazy list convention reduces as follows:
//
//	    ⋯ ⟹ $nil                     ;; if eof / error
//	    ⋯ ⟹ λ [[0 $false] ⋯]         ;; if ~getc() & 1
//	    ⋯ ⟹ λ [[0 $true] ⋯]          ;; if  getc() & 1
//
//	The `wr0` and `wr1` conventions reduce as follows:
//
//	    wr0 ⟹ λ [0 λ [[0 wr0] wr1]]  ;; w/ putc(0) side-effect
//	    wr1 ⟹ λ [0 λ [[0 wr0] wr1]]  ;; w/ putc(1) side-effect
//
//	Here's a BLC interpreter written in BLC which is 232 bits.
//
//	    [[λ [0 0]
//	      λλλ [[[0 λλλλ [2 λ [[4 [2 λ [[1 [2 λλ [2 λ [[0 1] 2]]]]
//	                                   [3 λ [3 λ [[2 0] [1 0]]]]]]]
//	                          [[0 [1 λ [0 1]]]
//	                           λ [[3 λ [3 λ [1 [0 3]]]] 4]]]]]
//	            [2 2]] 1]]
//	     λ [0 [λ [0 0] λ [0 0]]]]
//
//	@see	https://tromp.github.io/cl/Binary_lambda_calculus.html
//	@see	https://www.ioccc.org/2012/tromp/hint.html

#define TRACE   0		// enable ./trace.sh support
#define FASTR   0		// favor perf over tininess
#define TERMS	5000000		// number of words of bss
#define STACK	0		// bytes of stack to get

#define IOP	0		// code for read, write0, write1, flush
#define VAR	1		// code for variable name lookup
#define APP	2		// code for applications
#define ABS	3		// code for abstractions

#define NEXT	0*8
#define ENVP	1*8
#define REFS	2*8+0
#define TERM	2*8+4

#define mem	%rbx
#define memd	%ebx
#define envp	%rbp
#define contp	%r9
#define frep	%r8
#define eof	%r13
#define eofb	%r13b
#define eofd	%r13d
#define idx	%r15
#define idxb	%r15b
#define idxd	%r15d

	.macro	pushpop constexpr:req register:req
	.byte	0x6a,\constexpr
	pop	%r\register
	.endm

	.macro	mxchg register:req memory:req
#if FASTR
	mov	\register,%rax
	mov	\memory,\register
	mov	%rax,\memory
#else
	xchg	\register,\memory
#endif
	.endm

	.macro	stlog ordinal:req	# strace logging
#if TRACE
	push	%rax
	push	%rcx
	pushpop	\ordinal,ax
	syscall
	pop	%rcx
	pop	%rax
#endif
	.endm
	.macro	getpid
	stlog	0x27
	.endm
	.macro	getuid
	stlog	0x66
	.endm
	.macro	getgid
	stlog	0x68
	.endm
	.macro	getppid
	stlog	0x6e
	.endm
	.macro	geteuid
	stlog	0x6b
	.endm
	.macro	getegid
	stlog	0x6c
	.endm

	.bss
	.zero	TERMS
	.previous

ehdr:	.ascii	"\177ELF"

////////////////////////////////////////////////////////////////////////////////
//	TWELVE BYTE OVERLAP		#
//	.byte	2			# EI_CLASS is ELFCLASS64
//	.byte	1			# EI_DATA is ELFDATA2LSB
//	.byte	1			# EI_VERSION is 1
//	.byte	3			# EI_OSABI is ELFOSABI_LINUX
//	.quad	0			#
kRom1:	.byte	ABS			#  0       (λ ((0 (λ (λ ?))) ⋯))
	.byte	  APP			#  1       8
	.byte	  8			#──2──┐    -
	.byte	    APP			#  3  │    (0 (λ (λ ?)))
	.byte	    2			#──4────┐  (read (λ (λ ?)))
	.byte	      VAR		#  5  │ │  0
	.byte	      0			#  6  │ │  read
	.byte	    ABS			#──7────┘  (λ (λ ?))
	.byte	      ABS		#  8  │    (λ ?)
	.byte	        VAR		#  9  ┴    ?
	.byte	0			# exit(0) %al
	.byte	0			# elf padding                     [mark]
////////////////////////////////////////////////////////////////////////////////

ehdr2:	.word	2			# e_type is ET_EXEC           [precious]
	.word	62			# e_machine is EM_X86_64      [precious]

////////////////////////////////////////////////////////////////////////////////
//	FOUR BYTE OVERLAP		#
//	.long	1			# e_version is 1                  [mark]
Bye2:	pop	%rax			# __NR_exit
	syscall				#
	.byte	0			# elf padding
////////////////////////////////////////////////////////////////////////////////

ehdr3:	.quad	_start			# e_entry                     [precious]
	.quad	phdrs - ehdr		# e_phoff is 56               [precious]

////////////////////////////////////////////////////////////////////////////////
//	FOURTEEN BYTE OVERLAP		#
//	.quad	0xc681c031		# e_shoff  [should be 0]          [mark]
//	.long	0xfce2abac		# e_flags  [should be 0]          [mark]
//	.word	0xc3			# e_ehsize [should be 64]         [mark]
Get:	push	%rdi			#
	xor	%eax,%eax		# __NR_read
	xor	%edi,%edi		# stdin
	lea	-1(mem),%esi		# buf
	syscall				#
	jmp	Get2			#
	.byte	0			# elf padding
	.byte	0			# elf padding
////////////////////////////////////////////////////////////////////////////////

	.word	56			# e_phentsize                 [precious]

////////////////////////////////////////////////////////////////////////////////
//	EIGHT BYTE OVERLAP		#
//	.word	1			# e_phnum              [correct overlap]
//	.word	0			# e_shentsize          [correct overlap]
//	.word	1|2|4			# e_shnum              [p_flags clobber]
//	.word	0			# e_shstrndx           [correct overlap]
phdrs:	.long	1			# p_type is PT_LOAD
	.long	1|2|4			# p_flags is PF_X|PF_W|PF_R
////////////////////////////////////////////////////////////////////////////////

	.quad	0			# p_offset                    [precious]
	.quad	ehdr			# p_vaddr                     [precious]

////////////////////////////////////////////////////////////////////////////////
//	EIGHT BYTE OVERLAP		#
//	.quad	ehdr			# p_paddr                         [mark]
Get2:	and	%dl,(%rsi)		# 1. al= 1 (si)='0' → ZF=1 CF=1 EAX=0
	sub	%dl,(%rsi)		# 2. al= 1 (si)='1' → ZF=1 CF=0 EAX=0
	dec	%eax			# 3. al= 0 (si)=??? → ZF=0 CF=? EAX<0
	pop	%rdi			# 4. al=-1 (si)=??? → ZF=0 CF=? EAX<0
.Lret:	ret				#
////////////////////////////////////////////////////////////////////////////////

phdrs2:	.quad	filesz			# p_filesz         [insurmountable gulf]
	.quad	memsz			# p_memsz          [insurmountable gulf]
//	.quad	4096			# p_align

Bye:	xchg	%edi,%eax
	shr	$16,%edi
	push	$60			# __NR_exit
	jmp	Bye2

Gc:	decl	REFS(%rax)		# unref memory (order matters)
	jnz	.Lret			# 1. free parents via recursion
	push	%rax			# 2. free self
	mov	NEXT(%rax),%rax		# 3. free siblings via iteration
	call	Gc
	pop	%rax
	mov	frep,NEXT(%rax)
	mov	%rax,frep
	mov	ENVP(%rax),%rax
	jmp	Gc

Parse:	push	%rdi			# save 1
0:	.byte	0xB0			# lda §movsb,%al (nop next byte)
1:	movsb				# 00 is abstraction
	call	*%r14			# Get
	jnc	2f
	call	*%r14			# Get
	jc	1b
1:	mov	$APP,%al		# 01 is application
	stosb
	push	%rdi			# save 2
	scasb
	call	Parse
	pop	%rsi			# rest 2
	mov	%al,(%rsi)
	jmp	0b
2:	mov	$VAR,%al		# 1⋯ is variable
	stosb				# 0-based de Bruijn indices
	neg	%al
3:	inc	%al
	push	%rax
	call	*%r14			# Get
	pop	%rax
	jnc	3b
	stosb
	pop	%rsi			# rest 1
	mov	%edi,%eax
	sub	%esi,%eax
	ret

Var:	getuid
	push	envp
	.byte	0x3D			# cmp §0x6D8B48,%eax (nop 4x)
1:	mov	NEXT(envp),envp
	dec	%ecx
	jns	1b
2:	mov	TERM(envp),idxd
	mov	ENVP(envp),envp
	incl	REFS(envp)
	pop	%rax
	call	Gc
	jmp	Rex

Abs:	getpid
	test	contp,contp
	jz	Bye
	mxchg	envp,NEXT(contp)
	xchg	envp,contp
	jmp	Rex

Gro:	call	*%r14			# Get
	pushpop	10,cx
	mov	$kRom1,%esi
 	jz	2f
	add	$7,%esi
2:	mov	$0,%al
	adc	$0,%al
	rep movsb
	stosb
	jmp	Rex

_start:
#if STACK
	mov	$STACK,%rsi
	mov	$9,%al			# __NR_mmap
	mov	$3,%dl			# PROT_READ|PROT_WRITE
	mov	$0x0122,%r10w		# MAP_PRIVATE|MAP_ANONYMOUS|MAP_GROWSDOWN
	syscall
	lea	-24(%rax,%rsi),%rsp
	mov	$0,%dl
#endif
	mov	$kRom,memd		# romz
	mov	$Get,%r14d		# saves two bytes
	mov	%rsp,envp		# prevent segfaults clobber argv[0]
	inc	%dl			# dx=1 for read() and write()
	.byte	0x8d,0x7b,kEnd-kRom+1	# lea kEnd-kRom+1(mem),%edi
	call	Parse			# parse expr (xxx: tight displacement)
	.byte	136,67,kEnd-kRom	# mov %al,kEnd-kRom(mem)
//	jmp	Rex			# sets main() apply length

Rex:	mov	(mem,idx),%eax		# head normal form reduction
	movzbl	%ah,%ecx		# %al should be ∈ {0,1,2,3}
	inc	idxd
	cmp	$APP,%al
	ja	Abs
	je	App
	test	%al,%al
	jnz	Var
//	jmp	Iop

Iop:	getppid				# lazy lists like haskell
	dec	idxd
	cmp	$21,idxd		# length of rom
	ja	Gro
//	jmp	Put

Put:	mov	memd,%esi
	add	$30,idxd		# 18,19 += 48,49 or '0','1'
	mov	idxb,(%rsi)
	mov	$7,idxb			# λ 0 λ 0 wr0 wr1
  	push	%rdi
	mov	%edx,%edi		# stdout
	mov	%edx,%eax		# __NR_write
	syscall
	pop	%rdi
	jmp	Rex

App:	getgid
	test	frep,frep
	jnz	1f
	xor	%eax,%eax
	push	%rax			# calloc() on stack lool
	push	%rax
	push	%rax
	mov	%rsp,frep
1:	inc	idxd
	mxchg	contp,NEXT(frep)	# get closure from free list
	xchg	contp,frep
	incl	REFS(contp)		# save machine state
	incl	REFS(envp)
	mov	envp,ENVP(contp)
	add	idxd,%ecx
	mov	%ecx,TERM(contp)
	jmp	Rex

buf:	.byte	0
kRom:	.byte	APP			#  0         [λ [0 λ [[0 wr0] wr1]] [main ⋯]]
	.byte	.Lloop-1f		#──1─┐
1:	.byte	  ABS			#  2 │       λ [0 λ [[0 wr0] wr1]]
	.byte	    APP			#  3 │       [0 λ [[0 wr0] wr1]]
	.byte	    .Lw01-1f		#──4───┐
1:	.byte	      VAR,0		#  5 │ │     0
.L0w01:	.byte	    ABS			#  7 │ │     λ [0 λ [[0 wr0] wr1]]
	.byte	      APP		#  8 │ │     [0 λ [[0 wr0] wr1]]
	.byte	      2			#──9─────┐   [put λ [[0 wr0] wr1]]
	.byte	        VAR		# 10 │ │ │   0
	.byte	        0		# 11 │ │ │   put
.Lw01:	.byte	  ABS			#─12───┴─┘   λ [[0 wr0] wr1]
	.byte	    APP			# 13 │       [[0 wr0] wr1]
	.byte	    4			#─14───┐
	.byte	      APP		# 15 │ │     [0 wr0]
	.byte	      1			#─16─────┐   1
	.byte	        VAR		# 17 │ │ │   0
.Lwr:	.byte	      IOP		#─18─────┘   wr0
	.byte	  IOP			#─19───┘     wr1
.Lloop:	.byte	APP			#─20─┘       [main ⋯]
kEnd:

	.globl	ehdr
	.globl	_start
	.type	kRom,@object
	.type	kRom1,@object
	.type	ehdr,@object
	.type	ehdr2,@object
	.type	ehdr3,@object
	.type	phdrs,@object
	.type	phdrs2,@object
	.type	buf,@object
	.weak	filesz
	.weak	memsz
