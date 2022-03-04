#!/bin/sh
tr \\n n |
  sed '
      s/;.*//
      s/#.*//
      s/1/⊤/g
      s/0/⊥/g
      s/λ/00/g
      s/\[/01/g
      s/9/11111111110/g
      s/8/1111111110/g
      s/7/111111110/g
      s/6/11111110/g
      s/5/1111110/g
      s/4/111110/g
      s/3/11110/g
      s/2/1110/g
      s/⊤/110/g
      s/⊥/10/g
      s/[^01]//g
    '