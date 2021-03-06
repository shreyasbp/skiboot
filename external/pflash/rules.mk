.DEFAULT_GOAL := all

override CFLAGS  += -O2 -Wall -I.
PFLASH_OBJS    = pflash.o progress.o version.o common-arch_flash.o
LIBFLASH_FILES := libflash.c libffs.c ecc.c blocklevel.c file.c
LIBFLASH_OBJS := $(addprefix libflash-, $(LIBFLASH_FILES:.c=.o))
LIBFLASH_SRC := $(addprefix libflash/,$(LIBFLASH_FILES))
OBJS	= $(PFLASH_OBJS) $(LIBFLASH_OBJS)
EXE     = pflash
sbindir?=/usr/sbin

PFLASH_VERSION ?= $(shell ../../make_version.sh $(EXE))
LINKAGE?=static

ifeq ($(LINKAGE),dynamic)
include ../shared/rules.mk
SHARED=../shared/$(SHARED_NAME)
OBJS=$(PFLASH_OBJS) $(SHARED)
INSTALLDEPS+=install-shared

install-shared:
	$(MAKE) -C ../shared install PREFIX=$(PREFIX)

$(SHARED):
	$(MAKE) -C ../shared
endif

version.c: .version
	@(if [ "a$(PFLASH_VERSION)" = "a" ]; then \
	echo "#error You need to set PFLASH_VERSION environment variable" > $@ ;\
	else \
	echo "const char version[] = \"$(PFLASH_VERSION)\";" ;\
	fi) > $@

%.o : %.c
	$(Q_CC)$(CC) $(CFLAGS) -c $< -o $@

$(LIBFLASH_SRC): | links

$(LIBFLASH_OBJS): libflash-%.o : libflash/%.c
	$(Q_CC)$(CC) $(CFLAGS) -c $< -o $@

$(EXE): $(OBJS)
	$(Q_CC)$(CC) $(CFLAGS) $^ -lrt -o $@

