#!/bin/sh
make

# copy stdin
# ==========
#
# o//blc
# RL: took 1,686µs wall time
# RL: ballooned to 276kb in size
# RL: needed 1,636µs cpu (0% kernel)
# RL: caused 80 page faults (100% memcpy)
#
# o//Blc (note: processes 8x more bits)
# RL: took 4,123µs wall time
# RL: ballooned to 3,336kb in size
# RL: needed 4,078µs cpu (0% kernel)
# RL: caused 337 page faults (100% memcpy)
#
# o//cblc
# RL: took 401µs wall time
# RL: ballooned to 176kb in size
# RL: needed 359µs cpu (0% kernel)
# RL: caused 42 page faults (100% memcpy)
#
# o//cblc -b (note: processes 8x more bits)
# RL: took 2,217µs wall time
# RL: ballooned to 220kb in size
# RL: needed 2,170µs cpu (0% kernel)
# RL: caused 55 page faults (100% memcpy)
#
# o//tromp -a
# RL: took 1,286µs wall time
# RL: ballooned to 628kb in size
# RL: needed 1,242µs cpu (0% kernel)
# RL: caused 177 page faults (100% memcpy)
#
# o//tromp (note: processes 8x more bits)
# RL: took 3,548µs wall time
# RL: ballooned to 2,888kb in size
# RL: needed 3,497µs cpu (0% kernel)
# RL: caused 742 page faults (100% memcpy)

echo
echo copy stdin
echo ==========
echo
echo o//blc
{ printf '0010'; cat Makefile; } | rusage.com o//blc >/dev/null || exit
echo
echo o//Blc '(note: processes 8x more bits)'
{ printf ' '; cat Makefile; } | rusage.com o//Blc >/dev/null || exit
echo
echo o//cblc
{ printf '0010'; cat Makefile; } | rusage.com o//cblc >/dev/null || exit
echo
echo o//cblc -b '(note: processes 8x more bits)'
{ printf ' '; cat Makefile; } | rusage.com o//cblc -b >/dev/null || exit
echo
echo o//tromp -a
{ printf '0010'; cat Makefile; } | rusage.com o//tromp -a >/dev/null || exit
echo
echo o//tromp '(note: processes 8x more bits)'
{ printf ' '; cat Makefile; } | rusage.com o//tromp >/dev/null || exit

# reverse stdin
# =============
#
# o//blc
# RL: took 35,613µs wall time
# RL: ballooned to 664kb in size
# RL: needed 35,549µs cpu (9% kernel)
# RL: caused 177 page faults (100% memcpy)
#
# o//Blc (note: processes 8x more bits)
# RL: took 31,863µs wall time
# RL: ballooned to 3,336kb in size
# RL: needed 31,808µs cpu (0% kernel)
# RL: caused 338 page faults (100% memcpy)
#
# o//cblc
# RL: took 45,201µs wall time
# RL: ballooned to 680kb in size
# RL: needed 45,159µs cpu (0% kernel)
# RL: caused 170 page faults (100% memcpy)
#
# o//cblc -b (note: processes 8x more bits)
# RL: took 45,059µs wall time
# RL: ballooned to 740kb in size
# RL: needed 44,984µs cpu (7% kernel)
# RL: caused 185 page faults (100% memcpy)
# RL: 2 context switches (50% consensual)
#
# o//tromp -a
# RL: took 38,753µs wall time
# RL: ballooned to 1,140kb in size
# RL: needed 38,689µs cpu (0% kernel)
# RL: caused 305 page faults (100% memcpy)
#
# o//tromp (note: processes 8x more bits)
# RL: took 39,747µs wall time
# RL: ballooned to 3,404kb in size
# RL: needed 39,683µs cpu (0% kernel)
# RL: caused 871 page faults (100% memcpy)

echo
echo reverse stdin
echo =============
echo
echo o//blc
{ cat reverse.blc; cat Makefile; } | rusage.com o//blc >/dev/null || exit
echo
echo o//Blc '(note: processes 8x more bits)'
{ cat reverse.Blc; cat Makefile; } | rusage.com o//Blc >/dev/null || exit
echo
echo o//cblc
{ cat reverse.blc; cat Makefile; } | rusage.com o//cblc >/dev/null || exit
echo
echo o//cblc -b '(note: processes 8x more bits)'
{ cat reverse.Blc; cat Makefile; } | rusage.com o//cblc -b >/dev/null || exit
echo
echo o//tromp -a
{ cat reverse.blc; cat Makefile; } | rusage.com o//tromp -a >/dev/null || exit
echo
echo o//tromp '(note: processes 8x more bits)'
{ cat reverse.Blc; cat Makefile; } | rusage.com o//tromp >/dev/null || exit

echo
echo invert stdin
echo =============
echo
echo o//blc
{ cat invert.blc; cat Makefile; } | rusage.com o//blc >/dev/null || exit
echo
echo o//cblc
{ cat invert.blc; cat Makefile; } | rusage.com o//cblc >/dev/null || exit
echo
echo o//tromp -a
{ cat invert.blc; cat Makefile; } | rusage.com o//tromp -a >/dev/null || exit

# echo
# echo o//Blc '(note: processes 8x more bits)'
# { cat invert.Blc; cat Makefile; } | rusage.com o//Blc >/dev/null || exit
# echo
# echo o//cblc -b '(note: processes 8x more bits)'
# { cat invert.Blc; cat Makefile; } | rusage.com o//cblc -b >/dev/null || exit
# echo
# echo o//tromp '(note: processes 8x more bits)'
# { cat invert.Blc; cat Makefile; } | rusage.com o//tromp >/dev/null || exit
