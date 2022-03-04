
{ printf %s "(λ 0)" | ./compile.sh
  printf 00010101
} | ./blc

{ printf %s "(λ 0)" | ./compile.sh
  printf 0101
} | ./blc

