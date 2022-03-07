#!/bin/sh

I="λ 0"
S="λλλ [[2 0] [1 0]]"    # λxyz.xz(yz)
K="λλ 1"                 # λxy.x       a.k.a. true
B="λλλ [2 [1 0]]"        # λxyz.x(yz)  a.k.a. mult
C="λλλ [[2 0] 1]"        # λxyz.xzy
W="λλ [[1 0] 0]"         # λxy.xyy

nil="λλ 0"
zero="λλ 0"
false="λλ 0"
one="λλ [1 0]"
two="λλ [1 [1 0]]"
three="λλ [1 [1 [1 0]]]"
four="λλ [1 [1 [1 [1 0]]]]"
five="λλ [1 [1 [1 [1 [1 0]]]]]"
six="λλ [1 [1 [1 [1 [1 [1 0]]]]]]"
seven="λλ [1 [1 [1 [1 [1 [1 [1 0]]]]]]]"
eight="λλ [1 [1 [1 [1 [1 [1 [1 [1 0]]]]]]]]"
nine="λλ [1 [1 [1 [1 [1 [1 [1 [1 [1 0]]]]]]]]]"
true="λλ 1"
or="λλ [[0 0] 1]"
and="λλ [[0 1] 0]"
car="λ [0 $false]"
cdr="λ [0 $true]"
if="λ 0"                            # λpxy.pxy
compose="λλλ [2 [1 0]]"             # λfg.λx.f(gx)
map="λλλλ [[2 [[$compose 1] 3]] 0]" # λfl.λgi.l((λfg.λx.f(gx))gf)i
pair="λλλ [[0 2] 1]"                # λxy.λf.fxy
cons="λλλλ [[1 3] [[2 1] 0]]"       # λxy.λfi.fx(yfi)
read="λ [0 λλ [[$pair 1] 0]]"
omega="λ [0 0]"
OMEGA="[$omega $omega]"
# not="λ [[0 λλ 0] λλ 1]"
not="λλλ [[2 0] 1]"
xor="λλ [[1 λλ [[2 0] 1]] 0]"
iszero="λλλ [[2 λ 1] 1]"
mul="λλλ [2 [1 0]]"
pow="λλ [0 1]"
add="λλλλ [[3 1] [[2 1] 0]]"
inc="λλλ [1 [[2 1] 0]]"
dec="λλλ [[[2 λλ [0 [1 3]]] λ 1] λ 0]"
sub="λλ [[0 $dec] 1]"
#Y="λ [λ [1 [0 0]] λ [1 [0 0]]]"              # Y   ≡ λf.(λx.f(xx))(λx.f(xx))  # Curry
#Y="λ [λ [0 0] λ [1 λ [[1 1] 0]]]"            # Y?  ≡ λf.ω(λg.f(λa.gga))       # Rosetta
#Y="[λ [0 0] λλ [0 [[1 1] 0]]]"               # Y′  ≡ ω(λzf.f(zzf))            # Turing
#Y="[λλ [[1 0] 1] λλ [1 [[0 1] 0]]]"          # Y′′ ≡ ∧(λyx.y(xyx))            # Tromp
Y="λ [λ [0 0] λ [1 [0 0]]]"                   # Tromp
Z="λ [λ [1 λ [[1 1] 0]] λ [1 λ [[1 1] 0]]]"   # λf.(λx.f(λv.xxv))(λx.f(λv.xxv))
div="λλλλ [[[3 λλ [0 1]] λ 1] [[3 λ [[[3 λλ [0 1]] λ [3 [0 1]]] λ 0]] 0]]"         # λbcde.b(λfg.gf)(λf.e)(b(λf.c(λgh.hg)(λg.d(gf))(λg.g))e) [Bertram Felgenhauer]
mod="λλλλ [[[3 $cdr] [[3 λ [[[3 λλλ [[0 [2 [5 1]]] 1]] λ 1] 1]] λ 1]] $false]"  # λbcde.b(λf.f(λgh.g))(b(λf.c(λghi.i(g(dh))h)(λg.f)e)(λf.e))(λfg.g)
reverse="λ [[0 [$omega λλλλ [[1 [3 3]] λ [[0 3] 1]]]] $nil]"
odd="λ [λ [0 0] λλ [[0 λλ 1] λ [[0 λλ 0] [2 2]]]]"
le="λλ [[[1 λλ [0 1]] λλλ1] [[0 λλ [0 1]] λλλ0]]"
lt="λλ [[[0 λλ [0 1]] λλλ0] [[1 λλ [0 1]] λλλ1]]"
eq="λλ [[[[1 λ [[0 λ0] λ0]] [[0 λλλ [1 2]] λλ0]] λλλ0] λλ1]"
min="λλλλ [[[3 λλ [0 1]] λ1] [[2 λλ [3 [0 1]]] λ1]]"
fac="λλ [[[1 λλ [0 [1 λλ [[2 1] [1 0]]]]] λ1] λ0]"
all="λ [$omega λλ [[0 $false] [1 1]]]"

var="λλλλ [2 3]"
app="λλλλλ [[1 4] 3]"
lam="λλλλ [0 3]"
# lambda calculus self-interpreter (reduces to normal form if it exists)
E="[$Y λλ [[[0 λ 0] λλ [[3 1] [3 0]]] λλ [3 [1 0]]]]"  # E ≝ Y(λem.m(λx.x)(λmn.(em)(en))(λmv.e(mv)))
# lambda calculus self-reducer (reduces to normal form if it exists)
P="[$Y λλλ [[0 λ [3 λλλ [[1 5] [3 $false]]]] 1]]"                                                                  # P ≝ Y(λpm.(λx.x(λv.p(λabc.bm(v(λab.b))))m))
RR="[$Y λλ [[[0 λ 0] λλ [[[3 1] $true] [3 0]]] λ [λλ [[0 1] λλλ [0 λ [[5 [$P λλλ [2 3]]] $false]]] λ [3 [1 0]]]]]" # RR ≝ Y(λrm.m(λx.x)(λmn.(rm)(λab.a)(rn))(λm.(λgx.xg(λabc.c(λw.g(P(λabc.aw))(λab.b))))(λv.r(mv))))
R="λ [[$RR 0] $false]"                                                                                             # R ≝ λm.RRm(λab.b)

# printf "$R" | ./compile.sh | o/blcdump -l >/dev/null
# exit

# [$Y λλ [[0 λλλλ [[0 [$not 3]] [5 2]]] $nil]]

# {
#   printf %s "
# [$Y λλ [[0 λλλ [[$pair [$not 2]] [4 1]]] $nil]]
# " | ./compile.sh
#   dd if=/dev/urandom bs=64 count=150
# } | rusage.com o/cblc | wc -c
# exit $?

# [$Y λλ [[0 λλλλ [[0 [$not 3]] [5 2]]] $nil]]

# λ [[$Y λλ [[[$if [$iszero 0]]
#                 $nil]
#              [[$pair $false]
#               [1 [$dec 0]]]]]
#    [[$div $eight] $two]]

# (λf.(λx.f(xx))(λx.f(xx)))(λecs.s(λat.t(λb.ae(λx.b(c(λzy.x((λxy.λf.fxy)yz)))(e(λy.c(λz.xz(yz)))))(b(c(λz.zb))(λs.e(λx.c(λz.x(zb)))t)))))
# ω(λabc.c(λdefg.e(λh.d(f(λi.h(g(λjk.i(λl.lkj)))(f(λj.g(λk.ik(jk))))))(h(g(λi.ih))(λi.f(λj.g(λk.j(kh)))e))))(aa)b)(λa.a(ωω))
# (λa.aa)(λabc.c(λdefg.e(λh.d(f(λi.h(g(λjk.i(λl.lkj)))(f(λj.g(λk.ik(jk))))))(h(g(λi.ih))(λi.f(λj.g(λk.j(kh)))e))))(aa)b)(λa.a((λb.bb)(λb.bb)))

# printf 0101000110100000000101011000000000011110000101111110011110000101110011110000001111000010110110111001111100001111100001011110100111010010110011100001101100001011111000011111000011100110111101111100111101110110000110010001101000011010 | o/asc2bin | o/blcdump -lb
# exit

# printf 0101000110100000000101011000000000011110000101111110011110000101110011110000001111000010110110111001111100001111100001011110100111010010110011100001101100001011111000011111000011100110111101111100111101110110000110010001101000011010 | wc -c
# exit

# ω(λabc.c(λdefg.e(λh.d(f(λi.h(g(λjk.i(λl.lkj)))(f(λj.g(λk.ik(jk))))))(h(g(λi.ih))(λi.f(λj.g(λk.j(kh)))e))))(aa)b)(λa.a(ωω))
# ω(λabc.c(λdefg.e(λh.d(f(λi.h(g(λjk.i(λl.lkj)))(f(λj.g(λk.ik(jk))))))(h(g(λi.ih))(λi.f(λj.g(λk.j(kh)))e))))(aa)b)(λa.a(ωω))

# (\ab.(\c.c)b(\cdef.f((\g.g(\hi.i)(\hi.h))c)(ad))(\cd.d))
# Y(λfi.i(λci_o.o(¬c)(fi))⊥)
# [$Y λλ [[[$if 0] λλλλ [[0 [$not 3]] [5 2]]] $nil]]

# 0=⊥
# 1=⋯
# 2=⊤                        [cdr bit]
# 3=⊥
# 4=λ [[0 ⊤] ⋯]
# 5=⊤                        [first bit]
# 6=λ [[0 ⊤] λ [[0 ⊤] ⋯]]
# 7=[0 0]
# [$Y λλ [[0 λλλ [[$pair [$not 2]] [4 1]]] $nil]]
# [$omega λλ [[0 λλλ [[$pair [[2 $false] $true]] [[4 4] 1]]] $nil]]
# [$omega λλ [[0 λλλ [[λλλ [[0 2] 1] [[2 $false] $true]] [[4 4] 1]]] $nil]]
# [$omega λλ [[0 λλλλ [[0 [[3 $false] $true]] [[5 5] 2]]] $nil]]
# [$Y λλ [[0 λλλλ [[0 [[3 $false] $true]] [5 2]]] $nil]]
# [λ [0 0] λλ [[0 λλλλ [[0 [[3 λλ 0] λλ 1]] [[5 5] 2]]] λλ 0]]

{
printf %s "
[λ [0 0] λλ [[0 λλλλ [[0 [[3 λλ 0] λλ 1]] [[5 5] 2]]] λλ 0]]
" | ./compile.sh
printf 01110
# -lNnS
} | o/cblc 2>&1 |
     cut -c -10000 |
     head -n10000

# {
# printf %s "
# [λ [0 0] λλ [[0 λλλλ [[0 [[3 λλ 0] λλ 1]] [[5 5] 2]]] λλ 0]]
# " | ./compile.sh
# # printf 01010
# # -lNnS
# } | o/blcdump -nB 2>&1 |
#      cut -c -10000 |
#      head -n10000

# echo "nil='$(printf %s "$nil" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "zero='$(printf %s "$zero" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "false='$(printf %s "$false" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "one='$(printf %s "$one" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "two='$(printf %s "$two" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "three='$(printf %s "$three" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "four='$(printf %s "$four" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "five='$(printf %s "$five" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "six='$(printf %s "$six" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "seven='$(printf %s "$seven" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "eight='$(printf %s "$eight" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "nine='$(printf %s "$nine" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "true='$(printf %s "$true" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "or='$(printf %s "$or" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "and='$(printf %s "$and" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "first='$(printf %s "$first" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "second='$(printf %s "$second" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "if='$(printf %s "$if" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "compose='$(printf %s "$compose" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "map='$(printf %s "$map" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "pair='$(printf %s "$pair" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "cons='$(printf %s "$cons" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "read='$(printf %s "$read" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "omega='$(printf %s "$omega" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "OMEGA='$(printf %s "$OMEGA" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "not='$(printf %s "$not" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "xor='$(printf %s "$xor" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "iszero='$(printf %s "$iszero" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "mul='$(printf %s "$mul" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "pow='$(printf %s "$pow" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "add='$(printf %s "$add" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "inc='$(printf %s "$inc" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "dec='$(printf %s "$dec" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "sub='$(printf %s "$sub" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "Y='$(printf %s "$Y" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "Z='$(printf %s "$Z" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "div='$(printf %s "$div" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "mod='$(printf %s "$mod" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "reverse='$(printf %s "$reverse" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "odd='$(printf %s "$odd" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "le='$(printf %s "$le" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "lt='$(printf %s "$lt" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "eq='$(printf %s "$eq" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "min='$(printf %s "$min" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "fac='$(printf %s "$fac" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
# echo "all='$(printf %s "$all" | ./compile.sh | o/blcdump -nl 2>/dev/null)'"
