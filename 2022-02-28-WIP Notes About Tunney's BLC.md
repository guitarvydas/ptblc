## Introduction

I'm trying to parse Tunney's blog post about [Binary Lambda Calculus](https://justine.lol/lambda/) down to the bit level.

I've captured my thoughts in this blog.  There are notes-to-self.  My current understanding is not-yet-complete, but HTH...

The notes might contain errors in understanding, but that's OK with me, since my understanding grows through iteration...

## Notes

- 2 types
	1. opcodes
	2. references to variables on the stack

2 types needs 1 bit ; 0 => opcode, 1 => ref

2. refs are formally called "De Bruijn Indices", but they are nothing more than anonymous variables.  Forth does this, too, but (2) Curries functions down to 1 parameter (always), Forth allows more than 1 parameter

Opcodes: there are only 2 opcodes, 1 more bit is required ('0' to signify opcode, 0/1 to signify which opcode)
1. "Abstraction" (1st class function of exactly 1 parameter), push the function onto the stack. '00'
2. "Application" Apply a 1st-class function to an arg.  Arg is top-of-stack, 1st class function is at TOS+1 (2nd item on stack). '01'

Ref always begins with a '1' bit, then followed by N 1's, followed by a '0' bit terminator, e.g.

0th item (TOS[^1]) is '10'
Next item (TOS+1) is '110'
TOS+2 item is '1110'
etc.

[^1]: TOS means Top Of Stack.

'(lambda (x) x)' is encoded as ''0010"  which means 
- Abstraction '00'
- TOS ref '10'

The whole function '(lambda (x) x)' needs 4 bits (half a byte).

The *program* '((lambda (x) x) 0101)' requires 8 bits (a full byte).  0101 is arbitrary, it gets pushed onto the stack and passed as the 1st (only) arg to the function '(lambda (x) x)' - which returns its arg '0101'.

Stdin works with characters (8 bits) not single bits.  So, the shell script:
`printf 0010 ; printf 0101`
outputs 8 *characters* (a total of 64 bits).  7 bits in each character are wasted and the blc parser discards those bits and only uses the bottom-most bit.  (N.B. the command-line version of *printf* does not add a terminating '\0' like C does.)

In ASCII, 
- '0' is 0x30, which is binary ?1100000, and,
- '1' is 0x31, which is binary ?1100001.
(where "?" is one bit - the parity bit ; ASCII is actually 7 bits plus 1 parity bit)
(I'm leaving the parity bit as ? to avoid even more confusion)

If the parser drops the top 7 bits, we get
- '0' -> binary 0
- '1' -> binary 1

The character string 0010 is 0x30303130 in hex, which is ?1100000?1100000?1100001?1100000 in binary.

The *character* string 0010 is parsed from 32 *bits* down to 4 *bits*, binary 0010.

The parser reads characters from stdin, strips them down and puts them into memory (an array).

Church numeral 0 is *defined* to be the unity function (lambda (x) x).

"False" is *defined* to be the same as numeral 0.

