#!/bin/sh
x=${1:-o//blc}

y="$({ printf 0010; printf '1110001'; } | $x)" || {
  printf %s\\n "$x: ident return code: '$?'" >&2
  exit 1
}
if ! [ "$y" = "1110001" ]; then
  printf %s\\n "$x: ident failed: '$y'" >&2
  exit 1
fi

y="$({ cat reverse.blc; printf '1110001'; } | $x)" || {
  printf %s\\n "$x: reverse return code: '$?'" >&2
  exit 1
}
if ! [ "$y" = "1000111" ]; then
  printf %s\\n "$x: reverse failed: '$y'" >&2
  exit 1
fi

y="$({ cat reverse.blc; printf '111000'; } | $x)" || {
  printf %s\\n "$x: reverse trailing zero return code: '$?'" >&2
  exit 1
}
if ! [ "$y" = "000111" ]; then
  printf %s\\n "$x: reverse trailing zero failed: '$y'" >&2
  exit 1
fi

y="$({ cat uni.blc; printf 0010; printf '1110001'; } | $x)" || {
  printf %s\\n "$x: universal return code: '$?'" >&2
  exit 1
}
if ! [ "$y" = "1110001" ]; then
  printf %s\\n "$x: universal failed: '$y'" >&2
  exit 1
fi
