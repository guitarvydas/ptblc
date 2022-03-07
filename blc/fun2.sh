#!/bin/sh

compile() { sed '
s/nil\|false\|zero\|⊥/(λab.b)/g
s/true\|⊤/(λab.a)/g
s/one/(λab.ab)/g
s/two/(λab.a(ab))/g
s/three/(λab.a(a(ab)))/g
s/four/(λab.a(a(a(ab))))/g
s/five/(λab.a(a(a(a(ab)))))/g
s/six/(λab.a(a(a(a(a(ab))))))/g
s/seven/(λab.a(a(a(a(a(a(ab)))))))/g
s/eight/(λab.a(a(a(a(a(a(a(ab))))))))/g
s/nine/(λab.a(a(a(a(a(a(a(a(ab)))))))))/g
s/and/(λab.aba)/g
s/first/(λa.a(λbc.c))/g
s/second/(λa.a(λbc.b))/g
s/compose/(λabc.a(bc))/g
s/map/(λabcd.b((λefg.e(fg))ca)d)/g
s/pair/(λabc.cab)/g
s/cons/(λabcd.ca(bcd))/g
s/read/(λa.a(λbc.(λdef.fde)bc))/g
s/omega\|ω/(λa.aa)/g
s/OMEGA/((λa.aa)(λa.aa))/g
s/not\|¬/(λa.a(λbc.c)(λbc.b))/g
s/xor/(λab.a((λc.c(λde.e)(λde.d))b)b)/g
s/iszero/(λa.a(λbcd.d)(λbc.b))/g
s/mul/(λabc.a(bc))/g
s/pow/(λab.ba)/g
s/add/(λabcd.ac(bcd))/g
s/inc/(λabc.b(abc))/g
s/dec/(λabc.a(λde.e(db))(λd.c)(λd.d))/g
s/sub/(λab.b(λcde.c(λfg.g(fd))(λf.e)(λf.f))a)/g
s/divides/(λab.a(λc.c(λde.d))((λc.cc)(λc.b(λdef.f(d(λgh.h))e)(λd.cc)(λde.d)))(λcd.d))/
s/div/(λabcd.a(λef.fe)(λe.d)(a(λe.b(λfg.gf)(λf.c(fe))(λf.f))d))/g
s/mod/(λabcd.a(λe.e(λfg.f))(a(λe.b(λfgh.h(f(cg))g)(λf.e)d)(λe.d))(λef.f))/g
s/reverse/(λa.a((λb.bb)(λbcde.d(bb)(λf.fce)))(λbc.c))/g
s/odd/(λa.(λb.bb)(λbc.c(λde.d)(λd.d(λef.f)(bb))))/g
s/min/(λabcd.a(λef.fe)(λe.d)(b(λef.c(fe))(λe.d)))/g
s/fac/(λab.a(λcd.d(c(λef.de(ef))))(λc.b)(λc.c))/g
s/or/(λab.aab)/g
s/if/(λa.a)/g
s/le/(λab.a(λcd.dc)(λcde.d)(b(λcd.dc)(λcde.e)))/g
s/lt/(λab.b(λcd.dc)(λcde.e)(a(λcd.dc)(λcde.d)))/g
s/eq/(λab.a(λc.c(λd.d)(λd.d))(b(λcde.dc)(λcd.d))(λcde.e)(λcd.c))/g
s/Y/(λa.(λb.a(bb))(λb.a(bb)))/g
s/Z/(λa.(λb.a(λc.bbc))(λb.a(λc.bbc)))/g
' | o/lam2bin; }

{
printf %s "
ω(λab.b(λcdef.f(c(λgh.h)(λgh.g))(aad))(λcd.d))
" | compile
printf 1011
} | o/blcdump -l 2>&1 |
     cut -c -10000 |
     head -n10000
