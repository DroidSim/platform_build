# Configuration for FreeBSD on x86.
# Included by combo/select.make

# right now we get these from the environment, but we should
# pick them from the tree somewhere
$(combo_target)CC := $(CC)
$(combo_target)CXX := $(CXX)
$(combo_target)AR := $(AR)

$(combo_target)GLOBAL_CFLAGS += -fPIC -m32 -I/usr/local/include -DOS_FREEBSD
$(combo_target)GLOBAL_CFLAGS += \
	-include $(call select-android-config-h,freebsd-x86)
$(combo_target)GLOBAL_LDFLAGS += -m32

$(combo_target)NO_UNDEFINED_LDFLAGS := -Wl,--no-undefined

ifeq ($(combo_target),HOST_)
# $(1): The file to check
define get-file-size
stat -f %z "$(1)"
endef

# Which gcc to use to build qemu, which doesn't work right when
# built with 4.2.1 or later.
# using gcc34 from ports collection (lang/gcc34)
GCCQEMU := gcc34

endif  # HOST
