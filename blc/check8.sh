#!/bin/sh
x=${1:-o//cblc}

y="$(echo ' ok' | $x)" || {
  printf %s\\n "$x: ident return code: '$?'" >&2
  exit 1
}
if ! [ "$y" = ok ]; then
  printf %s\\n "$x: ident failed: '$y'" >&2
  exit 1
fi

y="$({ cat uni.Blc; echo ' hi'; } | $x)" || {
  printf %s\\n "$x: universal return code: '$?'" >&2
  exit 1
}
if ! [ "$y" = hi ]; then
  printf %s\\n "$x: universal failed: '$y'" >&2
  exit 1
fi

y="$(cat bf.Blc hw.bf | $x)" || {
  printf %s\\n "$x: brainfuck return code: '$?'" >&2
  exit 1
}
if ! [ "$y" = "Hello World!" ]; then
  printf %s\\n "$x: brainfuck interpreter failed: '$y'" >&2
  exit 1
fi

y="$({ cat reverse.Blc; printf 'abcdefghijklmnopqrstuvwxyz'; } | $x)" || {
  printf %s\\n "$x: reverse return code: '$?'" >&2
  exit 1
}
if ! [ "$y" = "zyxwvutsrqponmlkjihgfedcba" ]; then
  printf %s\\n "$x: reverse failed: '$y'" >&2
  exit 1
fi

if ! { cat hilbert.Blc; echo xx; } | $x; then
  printf %s\\n "$x: hilbert failed: '$y'" >&2
  exit 1
fi
