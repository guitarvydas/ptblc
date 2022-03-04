.PHONY: all clean check tags

COMMA = ,

LINK.s =					\
	$(LD)					\
	$(LDFLAGS)				\
	-o $@					\
	$(patsubst %.lds,-T %.lds,$^)

LINK.c =					\
	$(CC)					\
	$(CCFLAGS)				\
	$(CFLAGS)				\
	$(addprefix -Wl$(COMMA),$(LDFLAGS))	\
	$(CPPFLAGS)				\
	-o $@					\
	$(patsubst %.lds,-T %.lds,$^)

FILES := $(wildcard *.*)
SSRCS  = $(filter %.S,$(FILES))
CSRCS  = $(filter %.c,$(FILES))
HSRCS  = $(filter %.h,$(FILES))

all:		o//
o//:		o//cblc				\
		o//blcdump			\
		o//asc2bin			\
		o//bru2bin			\
		o//lam2bin			\
		o//tromp			\
		o//blc				\
		o//blc.dbg			\
		o//Blc				\
		o//Blc.dbg

check:		all				\
		o//blc.ok			\
		o//blc.dbg.ok			\
		o//cblc.ok			\
		o//Blc.ok			\
		o//Blc.dbg.ok			\
		o//cBlc.ok			\
		o//tromp.ok			\
		o//bru2bin.ok			\
		o//lam2bin.ok

clean:
	rm -rf o/

tags:		TAGS				\
		HTAGS

TAGS:		$(CSRCS)
	/usr/bin/ctags -e -o TAGS $^

HTAGS:		$(HSRCS)
	/usr/bin/ctags -e -o TAGS $^

o//blc:		o//blc.o			\
		flat.lds
	$(LINK.s)

o//Blc:		o//Blc.o			\
		flat.lds
	$(LINK.s)

o//blc.dbg:	o//blc.o			\
		unflat.lds
	$(LINK.s)

o//Blc.dbg:	o//Blc.o			\
		unflat.lds
	$(LINK.s)

o//lam2bin:	o//lam2bin.o
	$(LINK.c)

o//bru2bin:	o//bru2bin.o
	$(LINK.c)

o//asc2bin:	o//asc2bin.o			\
		o//getbit.o			\
		o//error.o			\
		o//debug.o			\
		o//dump.o			\
		o//print.o			\
		o//vars.o
	$(LINK.c)

o//cblc:	o//cblc.o			\
		o//parse.o			\
		o//needbit.o			\
		o//getbit.o			\
		o//error.o			\
		o//debug.o			\
		o//dump.o			\
		o//print.o			\
		o//vars.o
	$(LINK.c)

o//blcdump:	o//blcdump.o			\
		o//parse.o			\
		o//needbit.o			\
		o//getbit.o			\
		o//error.o			\
		o//debug.o			\
		o//dump.o			\
		o//print.o			\
		o//vars.o
	$(LINK.c)

o//tromp:	o//tromp.o
	$(LINK.c)

.PHONY:		o//blc.ok
o//blc.ok:	o//blc				\
		reverse.blc
	./check.sh $<

.PHONY:		o//blc.dbg.ok
o//blc.dbg.ok:	o//blc.dbg			\
		reverse.blc			\
		uni.blc
	./check.sh $<

.PHONY:		o//Blc.ok
o//Blc.ok:	o//Blc				\
		hilbert.Blc			\
		reverse.Blc			\
		uni.Blc				\
		bf.Blc				\
		hw.bf
	./check8.sh $<

.PHONY:		o//Blc.dbg.ok
o//Blc.dbg.ok:	o//Blc.dbg			\
		hilbert.Blc			\
		reverse.Blc			\
		uni.Blc				\
		bf.Blc				\
		hw.bf
	./check8.sh $<

.PHONY:		o//cblc.ok
o//cblc.ok:	o//cblc				\
		reverse.blc			\
		uni.blc
	./check.sh $<

.PHONY:		o//cBlc.ok
o//cBlc.ok:	o//cblc				\
		hilbert.Blc			\
		reverse.Blc			\
		uni.Blc				\
		bf.Blc				\
		hw.bf
	./check8.sh "$< -b"

.PHONY:		o//tromp.ok
o//tromp.ok:	o//tromp			\
		hilbert.Blc			\
		reverse.Blc			\
		uni.Blc				\
		bf.Blc				\
		hw.bf
	./check8.sh $<

.PHONY:		o//lam2bin.ok
o//lam2bin.ok:	o//lam2bin
	./checklam2bin.sh $<

.PHONY:		o//bru2bin.ok
o//bru2bin.ok:	o//bru2bin
	./checkbru2bin.sh $<

o//%.o: %.c blc.h Makefile
	@mkdir -p $(@D)
	$(CC) $(CCFLAGS) $(CPPFLAGS) $(CFLAGS) $(addprefix -Wa$(COMMA),$(ASFLAGS)) -c -o $@ $<

o//%.s: %.c blc.h Makefile
	@mkdir -p $(@D)
	$(CC) $(CCFLAGS) $(CPPFLAGS) $(CFLAGS) -S -c -o $@ $<

o//%.o: %.S Makefile
	@mkdir -p $(@D)
	$(CC) $(CCFLAGS) $(CPPFLAGS) -c -o $@ $<

o//tromp.o: CFLAGS += -w
o//cblc.com: o//cblc; cp $< $@
o//tromp.com: o//tromp; cp $< $@
o//blcdump.com: o//blcdump; cp $< $@
o//asc2bin.com: o//asc2bin; cp $< $@
