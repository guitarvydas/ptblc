# SectorLambda

Binary Lambda Calculus virtual machine for x64 Linux in 527 bytes.

## Background

The Lambda Calculus is similar to LISP (which has six primitive
operations: CAR, CDR, CONS, etc.) except it only has a single keyword,
which is LAMBDA. John Tromp wrote a 6kb BLC VM for IOCCC 2012:

- <https://tromp.github.io/cl/Binary_lambda_calculus.html>
- <https://www.ioccc.org/2012/tromp/hint.html>

Since BLC is the world's most barebones programming language, it
deserves to have a properly barebone assembly implementation for the
x86-64 Linux platform.

## Example

Hello World can be implemented as a single-character program. The ASCII
space character decodes as `(λ 0)` in Binary Lambda Calculus, which is
the identity function.

```
$ make o//lamb
$ echo ' hello world' | o//lamb
hello world
```

After the interpreter is finished reading your closed-form expression,
it advances to the next byte, and then repeatedly applies the remaining
bytes of input to your program, and pipes the result to standard out. So
the way this normally works is as follows:

```
$ { cat hilbert.Blc; echo 123; } | o//lamb
 _   _   _   _   _   _   _   _ 
| |_| | | |_| | | |_| | | |_| |
|_   _| |_   _| |_   _| |_   _|
 _| |_____| |_   _| |_____| |_ 
|  ___   ___  | |  ___   ___  |
|_|  _| |_  |_| |_|  _| |_  |_|
 _  |_   _|  _   _  |_   _|  _ 
| |___| |___| |_| |___| |___| |
|_   ___   ___   ___   ___   _|
 _| |_  |_|  _| |_  |_|  _| |_ 
|  _  |  _  |_   _|  _  |  _  |
|_| |_| | |___| |___| | |_| |_|
 _   _  |  ___   ___  |  _   _ 
| |_| | |_|  _| |_  |_| | |_| |
|_   _|  _  |_   _|  _  |_   _|
 _| |___| |___| |___| |___| |_ 
```

## Why It Matters

Programs that are compiled to the Binary Lambda Calculus end up being
outrageously small. They're almost as small as i8086 assembly programs.
For example, the BLC brainfuck intepreter below is 112 bytes. We built
the same thing in 99 bytes for i8086 but it's still saying a lot if we
consider that i8086 is a robust CISC architecture whereas BLC is 10x
simpler than any RISC architecture dreamed of being.

So one thing you could do, if you want to create tiny programs that just
do stdio, is you use this virtual machine as a file header for your
compiled program. That way you get a nice manylinux distributable static
executable without dependencies that's several orders of a magnitude
smaller than builds produced by languages like C++, Rust, Go, or even C.

## Data Model

The 1 bit is defined `(λ (λ 1))` and the 0 bit `(λ (λ 0))`. We also use
`(λ (λ 1))` as our `CAR` function and `(λ (λ 0))` as our `CDR` function.
The `λλ 0` function also serves the purpose of `NIL`.

Your program is loaded from stdin into static .bss memory. Once it's
loaded, any subsequent data read from stdin will be loaded into bss
memory.

All remaining memory usage happens on the system RSP stack, including
heap allocations. That's because the virtual machine doesn't actually
use the system stack to perform recursive evaluations. It's a Krivine
machine that's goto-driven. Heap allocations are garbage collected using
reference counting and a free list.

By default we use a "small" memory model where we assume the virtual
machine is loaded to a low address, e.g. 0x400000 (4MB). We then mmap a
gigantic stack that grows down from from 0x100000000 (4GB). If you need
a stack size larger than 2GB then you can tune the defines in the asm
file. This will result in a slightly larger binary. It also means that
data term slots will need to be 8 bytes rather than 4 bytes each.

## Notation

This is conventional zero-indexed de Bruijn notation. The identity
function `(λ 0)` means the same thing as `(LAMBDA (X) X)` in LISP. We
can see how this notation is nice if we consider the reverse function:

    (λ 0 ((λ 0 0) (λλλλ 1 (3 3) (λ 0 3 1))) (λλ 0))

In Scheme that would be written:

    (LAMBDA (A)
      ((A ((LAMBDA (B)
             (B B))
           (LAMBDA (B)
             (LAMBDA (C)
               (LAMBDA (D)
                 (LAMBDA (E)
                   ((D (B B))
                    (LAMBDA (F)
                      ((F C) E)))))))))
       (LAMBDA (X)
         (LAMBDA (Y)
           Y))))

## Wire Encoding

The binary encoding works based on the following prefixes:

- `00` means lambda which always has exactly one argument
- `01` means application which is basically a function call
- `1⋯` means variable w/ 0-index argument into outer lambdas

Our reverse function would be represented in binary as follows:

    00010110 01000110 10000000
    00010111 00111110 11110000
    10110111 10110000 01000000

Because solid blocks of binary digits aren't very readable, we propose
the following notation for elegantly explaining the BLC encoding:

    (00 01[01[10 (01[(00 01[10 10]) (00000000 01[01[110 (01[11110 11110])]
    (00 01[01[10 11110] 110])])])] (0000 10)])

When running `o//cblc -b` and `o//blcdump -b` the parenthesis, square
brackets, and spaces are simply ignored. Anything else will have its
least-significant byte interpreted.

## I/O Runtime

The following i/o functionality is supported: `get`, `wr0`, `wr1`, and
`put`. Notice how we say functionality rather than functions. The only
keyword is lambda. So these iops are nameless. However they are
observable.

Here's how it works. By default, all terms in bss memory are internally
encoded as `0` which we define as the `get` term. So when you copy a
program like Hello World `(λ 0)` into the beginning of memory, it's
followed by a potentially infinite series of read applications, that
will call your program over and over again until EOF.

    ((λ 0) get)

In order to support output i/o operations too, the virtual machine
runtime also wraps your program with the additional support code which
includes i/o terms at hardcoded addresses. This way the `get` output is
applied to your program, and the result of that is then applied to the
writer program.

    ((λ 0 (λ (0 (λ (0 wr1) wr0)) put))
     ((λ 0) get))

This is magical expression that relies on builtin semantics as follows.
The `put` function jumps to `(λ (0 (λ ((0 (λ ((0 wr1) wr0))) put))))`
which is term index 2 after evaluation. The `wr0` and `wr1` functions
jump to `(λ (0 (λ ((0 write0) write1))))` or term index 9 after eval.

The `get` function is less magical. It loads each byte into a linked
list of true `(λλ1)` and false `(λλ0)` functions. For example ASCII `h`
which is `0b01101000` would be encoded as follows:

    (λ (0 (λ ((0 (λλ 0))
              (λ ((0 (λλ 1))
                  (λ ((0 (λλ 1))
                      (λ ((0 (λλ 0))
                          (λ ((0 (λλ 1))
                              (λ ((0 (λλ 0))
                                  (λ ((0 (λλ 0))
                                      (λ ((0 (λλ 1))
                                          (λλ 0))))))))))))))))))
       get)

The above list has eight entries and a nil terminator. It's also wrapped
inside a promise that enables further subsequent reading afterwards.

## Demo Programs

### Reverse Linked List

```
(λ 0 ((λ 0 0) (λλλλ 1 (3 3) (λ 0 3 1))) (λλ 0))
```

```
(00 (01 (01 10 ((01 (00 (01 10 10)) (00000000 (01 (01 110 ((01 11110
11110))) (00 (01 (01 10 11110) 110))))))) (0000 10)))
```

```
00000000: 00010110 01000110 10000000 00010111 00111110 11110000  .F..>.
00000006: 10110111 10110000 01000000                             ..@
```

### Universal Machine

```
(λλλ 0 (λλλλ 2 (λ 4 (2 (λ 1 (2 (λλ 2 (λ 0 1 2)))
                          (3 (λ 3 (λ 2 0 (1 0))))))
                    (0 (1 (λ 0 1))
                       (λ 3 (λ 3 (λ 1 (0 1))) 4))))
       (2 2) 1)
```

```
(01 (01 (00 (01 10 10)) (000000 (01 (01 (01 10 (00000000 (01 1110 (00
(01 (01 111110 ((01 1110 (00 (01 (01 110 ((01 1110 (0000 (01 1110 (00
(01 (01 10 110) 1110))))))) ((01 11110 (00 (01 11110 (00 (01 (01 1110
10) ((01 110 10))))))))))))) ((01 (01 10 ((01 110 (00 (01 10 110)))))
(00 (01 (01 11110 (00 (01 11110 (00 (01 110 ((01 10 110)))))))
111110))))))))) ((01 1110 1110))) 110))) (00 (01 10 ((01 (00 (01 10 10))
(00 (01 10 10)))))))
```

### Universal Machine (8-bit byte chunking)

```
(λ 0 ((λ 0 0)
      (λλλ 0 (λλλλλ 3 (λλλ 7 (4 (λ 3 (4 (λλ 2 (λ 0 1 2)))
                                     (5 (λ 5 (λ 2 0 (1 0))))) 1)
                             (2 (3 (λ 0 3) 1)
                                (4 (λ 4 (λ 1 (0 4))) 6)))
                      (λ 0 (λ 3 2 (λ 0 7 1))))
             (λλλ 0 (2 1))
             (2 2)
             1)
      (λλ 1 ((λ 0 0) (λ 0 0)))))
```

```
(00 01[10 (01[01[(00 01[10 10]) (000000 01[01[01[01[10 (0000000000
01[01[11110 (000000 01[01[111111110 (01[01[111110 (00 01[01[11110
(01[111110 (0000 01[1110 (00 01[01[10 110] 1110])])])] (01[1111110 (00
01[1111110 (00 01[01[1110 10] (01[110 10])])])])])] 110])] (01[01[1110
(01[01[11110 (00 01[10 11110])] 110])] (01[01[111110 (00 01[111110 (00
01[110 (01[10 111110])])])] 11111110])])])] (00 01[10 (00 01[01[11110
1110] (00 01[01[10 111111110] 110])])])])] (000000 01[10 (01[1110
110])])] (01[1110 1110])] 110])] (0000 01[110 (01[(00 01[10 10]) (00
01[10 10])])])])])
```

```
00000000: 00011001 01000110 10000000 01010101 10000000 00000101  .F.U..
00000006: 11110000 00001011 11111110 01011111 10000101 11110011  ..._..
0000000c: 11110000 00111100 00101101 10111001 11111100 00111111  .<-..?
00000012: 10000101 11101001 11010110 01011110 01011111 00001101  ...^_.
00000018: 11101100 10111111 00001111 11000011 10011011 11101111  ......
0000001e: 11100001 10000101 11110111 00001011 01111111 10110000  ......
00000024: 00001100 11110110 01111011 10110000 00111001 00011010  ..{.9.
0000002a: 00011010                                               .
```

### Brainfuck Interpreter (8-bit byte chunking)

```
(λ (λ (λ 0 0)
      (λ (λλλ 0 (λ (λ 1 0 0 0 (λλ 0 2 2 (λλ 0 (λλ (λ 6 (0 (2 (λλλλλ 9 (0 (λ 5 0 3 2))
                                                                      (λ 0 4 (5 4 3 2 1)))
                                                             (λλ 1 ((λ 0 0)
                                                                    (λλλλλ 0 (λ 5 5 4 (λλ (λ 7 3 0 6 5 (λ 0 1 3))
                                                                                          (λλ 4 0 1))
                                                                                      (λλ 4 (λ 0 3 2)))
                                                                             (2 0)) 6
                                                                    (λ 0)
                                                                    (λ 0) 0))))
                                                       (2 (0 (λλλλ 8 (1 (λ 4 0)
                                                                        (λ 0 3 1))
                                                                     (0 (λ 4 0 (λ 0 4 3)))))
                                                          (4 (10 (λ 0))
                                                             (11 (λ 1 ((λ 0 0)
                                                                       (λ (λλλλ 0 ((λ 0 0)
                                                                                   (λλλ 1 (0 (2 2))
                                                                                          (λ 6 (7 6 0)))) 1 0)
                                                                          (0 0)) 0))))))
                                                  (λ 11 (λ 11 (λ 2 (1 0))))))))
                   (λλ 0)))
         (0 0))
      (λ 0 (λλλλλλ 0) 2 1 1))
   ((λ 0 0)
    (λλ 0 2 (1 1))))
((λ 0 (0 (0 (λλ 0 (λλ 1) 1))))
 (λλ 1 (1 0))
 (λλ 0))
```

```
(00 01[10 (01[01[(00 01[10 10]) (000000 01[01[01[01[10 (0000000000
01[01[11110 (000000 01[01[111111110 (01[01[111110 (00 01[01[11110
(01[111110 (0000 01[1110 (00 01[01[10 110] 1110])])])] (01[1111110 (00
01[1111110 (00 01[01[1110 10] (01[110 10])])])])])] 110])] (01[01[1110
(01[01[11110 (00 01[10 11110])] 110])] (01[01[111110 (00 01[111110 (00
01[110 (01[10 111110])])])] 11111110])])])] (00 01[10 (00 01[01[11110
1110] (00 01[01[10 111111110] 110])])])])] (000000 01[10 (01[1110
110])])] (01[1110 1110])] 110])] (0000 01[110 (01[(00 01[10 10]) (00
01[10 10])])])])])
```

```
00000000: 01000100 01010001 10100001 00000001 10000100 01010101
00000006: 11010101 00000010 10110111 01110000 00110000 00100010
0000000c: 11111111 00110010 11110000 00000000 10111111 11111001
00000012: 10000101 01111111 01011110 11100001 01101111 10010101
00000018: 01111111 01111101 11101110 11000000 11100101 01010100
0000001e: 01101000 00000000 01011000 01010101 11111101 11111011
00000024: 11100000 01000101 01010111 11111101 11101011 11111011
0000002a: 11110000 10110110 11110000 00101111 11010110 00000111
00000030: 11100001 01101111 01110011 11010111 11110001 00010100
00000036: 10111100 11000000 00001011 11111111 00101110 00011111
0000003c: 10100001 01101111 01100110 00010111 11101000 01011011
00000042: 11101111 00101111 11001111 11111111 00010011 11111111
00000048: 11100001 11001010 00110100 00100000 00001010 11001000
0000004e: 11010000 00001011 10011001 11101110 00011111 11100101
00000054: 11111111 01111111 01011010 01101010 00011111 11111111
0000005a: 00001111 11111111 10000111 10011101 00000100 11010000
00000060: 10101011 00000000 00000101 11011011 00100011 01000000
00000066: 10110111 00111011 00101000 11001100 11000000 10110000
0000006c: 01101100 00001110 01110100 00010000
```

### Hilbert Space Filling Curve Diagram Generator (8-bit byte chunking)

```
(λ 0 (λλ 0 (λλ 0 (λλ 0 (λλ (λ (λ (λ (λ 0 0)
                                    (λλλ 0 (λλ (λλ 7 (λλ 0)
                                                     (λλ 1)
                                                     (1 5)
                                                     (1 3)
                                                     (λ 0 14 (3 (7 7) 1)))
                                               (λ 8 ((λ 0 0)
                                                     (λ (λλλ 0 (λλ (λ 4 (λλ 1 (7 0 3)
                                                                              (7 2 0))
                                                                        (λ 0 1))
                                                                   (1 ((λ 0 0)
                                                                       (λλ 0 (λλλλ 1 (λλ 5 0 1)
                                                                                     (5 5 2))
                                                                             (λ 1)) 0) 0))
                                                               (λ 2 (λλ 1 (2 0)
                                                                          (λλ 0)) 0))
                                                        (0 0)) 0) 7
                                                    (λλ 0))))
                                    (λλ 0 (λλλ 0)) 1
                                    (λλ 0))
                                 ((λ 0 0)
                                  (λ (λλλλλ 1 (λλ 2 (λλλλ 0 ((λ (λ 10 (7 21 (11 (4 (λλλ 2 3 0) 1) 1))
                                                                      (5 0 1)) 22) 15)
                                                            (10 3 (λλ 10 0 1) 4 2 1))))
                                     (0 0))))
                              ((λ 0 0)
                               (λλλ 0 (λλλ 5 5 (λ 0 (λλ 1 (λλ 0)
                                                          (7 0))
                                                    (λλλ 0)) 1
                                               ((λ 0 (λλ 1)
                                                     (λ 0 (λλ 0 8)
                                                          (1 (λλ 0)
                                                             (λλ 0))))
                                                (λ 7 (λλλ 1 3 2) 1))))
                               (λλλ 1) 1
                               (λ 0 (λλ 0 (λλλ 1))
                                    (λλ 0))))
                           (λλ 0 ((λ 0 0)
                                  (λλλλλ 0 (6 3)
                                           (2 (4 4) 1)))))))))
```

```
(00 01[10 (0000 01[10 (0000 01[10 (0000 01[10 (0000 01[(00 01[(00 01[(00
01[01[01[01[(00 01[10 10]) (000000 01[10 (0000 01[(0000
01[01[01[01[01[111111110 (0000 10)] (0000 110)] (01[110 1111110])]
(01[110 11110])] (00 01[01[10 1111111111111110] (01[01[11110
(01[111111110 111111110])] 110])])]) (00 01[01[01[1111111110 (01[01[(00
01[10 10]) (00 01[(000000 01[01[10 (0000 01[(00 01[01[111110 (0000
01[01[110 (01[01[111111110 10] 11110])] (01[01[111111110 1110] 10])])]
(00 01[10 110])]) (01[01[110 (01[01[(00 01[10 10]) (0000 01[01[10
(00000000 01[01[110 (0000 01[01[1111110 10] 110])] (01[01[1111110
1111110] 1110])])] (00 110)])] 10])] 10])])] (00 01[01[1110 (0000
01[01[110 (01[1110 10])] (0000 10)])] 10])]) (01[10 10])])] 10])]
111111110] (0000 10)])])])] (0000 01[10 (000000 10)])] 110] (0000 10)])
(01[(00 01[10 10]) (00 01[(0000000000 01[110 (0000 01[1110 (00000000
01[01[10 (01[(00 01[(00 01[01[111111111110 (01[01[111111110
11111111111111111111110] (01[01[1111111111110 (01[01[111110 (000000
01[01[1110 11110] 10])] 110])] 110])])] (01[01[1111110 10] 110])])
111111111111111111111110]) 11111111111111110])]
(01[01[01[01[01[111111111110 11110] (0000 01[01[111111111110 10] 110])]
111110] 1110] 110])])])]) (01[10 10])])])]) (01[01[01[01[(00 01[10 10])
(000000 01[10 (000000 01[01[01[01[1111110 1111110] (00 01[01[10 (0000
01[01[110 (0000 10)] (01[111111110 10])])] (000000 10)])] 110] (01[(00
01[01[10 (0000 110)] (00 01[01[10 (0000 01[10 1111111110])] (01[01[110
(0000 10)] (0000 10)])])]) (00 01[01[111111110 (000000 01[01[110 11110]
1110])] 110])])])])] (000000 110)] 110] (00 01[01[10 (0000 01[10 (000000
110)])] (0000 10)])])]) (0000 01[10 (01[(00 01[10 10]) (0000000000
01[01[10 (01[11111110 11110])] (01[01[1110 (01[111110 111110])]
110])])])])])])])])])
```

```
00000000: 00011000 00011000 00011000 00011000 00010001 00010001  ......
00000006: 01010100 01101000 00000110 00000100 00010101 01011111  Th..._
0000000c: 11110000 01000001 10011101 11111001 11011110 00010110  .A....
00000012: 11111111 11111110 01011111 00111111 11101111 11110110  .._?..
00000018: 00010101 11111111 10010100 01101000 01000000 01011000  ...h@X
0000001e: 00010001 01111110 00000101 11001011 11111110 10111100  .~....
00000024: 10111111 11101110 10000110 11001011 10010100 01101000  .....h
0000002a: 00010110 00000000 01011100 00001011 11111010 11001011  ..\...
00000030: 11111011 11110111 00011010 10000101 11100000 01011100  .....\
00000036: 11110100 00010100 11010101 11111110 00001000 00011000  ......
0000003c: 00001011 00000100 10001101 00001000 00000000 11100000  ......
00000042: 01111000 00000001 01100100 01000101 11111111 11100101  x.dE..
00000048: 11111111 01111111 11111111 11111110 01011111 11111111  ...._.
0000004e: 00101111 11000000 00101111 01111010 11011001 01111111  /./z..
00000054: 01011011 11111111 11111111 11111011 11111111 11111100  [.....
0000005a: 10101010 11111111 11110111 10000001 01111111 11111010  ......
00000060: 11011111 01110110 01101001 01010100 01101000 00000110  .viTh.
00000066: 00000001 01010111 11110111 11100001 01100000 01011100  .W..`\
0000006c: 00010011 11111110 10000000 10110010 00101100 00011000  ....,.
00000072: 01011000 00011011 11111110 01011100 00010000 01000010  X..\.B
00000078: 11111111 10000000 01011101 11101110 11000000 01101100  ..]..l
0000007e: 00101100 00001100 00000110 00001000 00011001 00011010  ,.....
00000084: 00000000 00010110 01111111 10111100 10111100 11111101  ......
0000008a: 11110110 01011111 01111100 00001010 00100000           ._|.
```

## Parser (8-bit byte chunking)

```
((λ (λ (λ (λ (λ (λ (λ (λ (λ 0 0)
                         (λ (λλλ (λ 0 (λ 0 0 ((λ 0 0)
                                              (λλ 3 (λ 0 (5 1)
                                                         (λ 3 3 (10 2 0)))))))
                                 ((λ (λ 0 0)
                                     (λ 1 (0 0)))
                                  (λλλ 0 (λλλ 2 (λλ 0)
                                                (λλ 1 (0 (λλ 1 (9 8)
                                                               (0 (λλ 0)
                                                                  (λλ 1 (11 10)
                                                                        (0 (λλ 0)
                                                                           (λλ 0)
                                                                           (λλ 1 (16 15 (λλ 0 (λ 15 (λλ 0 4))))
                                                                                 (λ 9)))))))
                                                      (0 (λλ 1 (λ 0 (λ 14 (λ 0 1 14)
                                                                          (λ 11 (λλ 0 (20 2)))))
                                                               (8 (λλ 0 (13 (18 8))))))) 1)
                                         (1 (λλ 1) 0))))
                            (0 0))
                         (λ 0)
                         (λ 0))
                      (λλλλ 0 7 (λ 0 7 (4 (3 2)))))
                   (λλλ 0 5 (λ 0 6 (3 2))))
                ((λ 0 0)
                 (λλλλ (λ 0 0)
                       (λ (λλλ 1 (λλλ 3 (λ 3 0 (λλ 2 0 1)
                                               (6 2)
                                               (λλλ 1))) 1)
                          (0 0)) 2 1
                       (λλ 0 6 (2 (5 5 4) 1))
                       (λλ 0 6 (λ 0 8 2)))))
             (1 (λλ 0)))
          (0 (λλ 1)))
       (λ 2 (2 (1 (1 (2 (2 (2 (λ 0 1 (λλ 0))))))))))
    (λλ 0 (λλ 0) 1))
 (λλ 0 (λλ 1) 1))
```
