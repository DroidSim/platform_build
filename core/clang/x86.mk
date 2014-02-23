# Clang flags for x86 arch, target or host.

CLANG_CONFIG_x86_EXTRA_ASFLAGS := \
  -msse3
ifeq ($(TARGET_OS),gnu_linux)
CLANG_CONFIG_x86_EXTRA_CFLAGS := \
  -I /usr/include/i386-linux-gnu/c++/4.8
else
CLANG_CONFIG_x86_EXTRA_CFLAGS :=
endif
CLANG_CONFIG_x86_EXTRA_LDFLAGS :=

# Include common unknown flags
ifeq ($(TARGET_OS),gnu_linux)
CLANG_CONFIG_x86_UNKNOWN_CFLAGS := \
  $(CLANG_CONFIG_UNKNOWN_CFLAGS) \
  -finline-limit=300 \
  -fno-inline-functions-called-once \
  -mfpmath=sse
else
CLANG_CONFIG_x86_UNKNOWN_CFLAGS := \
  $(CLANG_CONFIG_UNKNOWN_CFLAGS) \
  -finline-limit=300 \
  -fno-inline-functions-called-once \
  -mfpmath=sse \
  -mbionic
endif

# We don't have any x86 flags to substitute yet.
define subst-clang-incompatible-x86-flags
  $(1)
endef
