ifeq ($(HOST_OS),darwin)
# nothing required here yet
endif

ifeq ($(HOST_OS),linux)

ifneq ($(strip $(BUILD_HOST_64bit)),)
# Needs to be updated along with gcc
HOST_ARCH_DESCRIPTOR_FOR_CLANG := x86_64-linux
else
# Needs to be updated along with gcc
HOST_ARCH_DESCRIPTOR_FOR_CLANG := i686-linux
endif


ifneq ($(strip $(BUILD_HOST_64bit)),)
CLANG_CONFIG_x86_LINUX_HOST_EXTRA_ASFLAGS := \
  --gcc-toolchain=$(HOST_TOOLCHAIN_FOR_CLANG) \
  --sysroot=$(HOST_TOOLCHAIN_FOR_CLANG)/sysroot \
  -no-integrated-as

CLANG_CONFIG_x86_LINUX_HOST_EXTRA_CFLAGS := \
  --gcc-toolchain=$(HOST_TOOLCHAIN_FOR_CLANG) \
  -no-integrated-as

CLANG_CONFIG_x86_LINUX_HOST_EXTRA_CPPFLAGS :=   \
  --gcc-toolchain=$(HOST_TOOLCHAIN_FOR_CLANG) \
  --sysroot=$(HOST_TOOLCHAIN_FOR_CLANG)/sysroot \
  -isystem $(HOST_TOOLCHAIN_FOR_CLANG)/x86_64-linux/include/c++/4.8 \
  -isystem $(HOST_TOOLCHAIN_FOR_CLANG)/x86_64-linux/include/c++/4.8/x86_64-linux \
  -isystem $(HOST_TOOLCHAIN_FOR_CLANG)/x86_64-linux/include/c++/4.8/backward \
  -no-integrated-as

CLANG_CONFIG_x86_LINUX_HOST_EXTRA_LDFLAGS := \
  --gcc-toolchain=$(HOST_TOOLCHAIN_FOR_CLANG) \
  --sysroot=$(HOST_TOOLCHAIN_FOR_CLANG)/sysroot \
  -B$(HOST_TOOLCHAIN_FOR_CLANG)/x86_64-linux/bin \
  -B$(HOST_TOOLCHAIN_FOR_CLANG)/lib/gcc/x86_64-linux/4.8 \
  -L$(HOST_TOOLCHAIN_FOR_CLANG)/lib/gcc/x86_64-linux/4.8 \
  -L$(HOST_TOOLCHAIN_FOR_CLANG)/x86_64-linux/lib64/ \
  -no-integrated-as
else
CLANG_CONFIG_x86_LINUX_HOST_EXTRA_CPPFLAGS :=   \
  --sysroot=$(HOST_TOOLCHAIN_FOR_CLANG)/sysroot \
  -isystem $(HOST_TOOLCHAIN_FOR_CLANG)/x86_64-linux/include/c++/4.8 \
  -isystem $(HOST_TOOLCHAIN_FOR_CLANG)/x86_64-linux/include/c++/4.8/x86_64-linux/32 \
  -isystem $(HOST_TOOLCHAIN_FOR_CLANG)/x86_64-linux/include/c++/4.8/backward \
  -no-integrated-as

CLANG_CONFIG_x86_LINUX_HOST_EXTRA_LDFLAGS := \
  --sysroot=$(HOST_TOOLCHAIN_FOR_CLANG)/sysroot \
  -B$(HOST_TOOLCHAIN_FOR_CLANG)/x86_64-linux/bin \
  -B$(HOST_TOOLCHAIN_FOR_CLANG)/lib/gcc/x86_64-linux/4.8/32 \
  -L$(HOST_TOOLCHAIN_FOR_CLANG)/lib/gcc/x86_64-linux/4.8/32 \
  -L$(HOST_TOOLCHAIN_FOR_CLANG)/x86_64-linux/lib32/ \
  -no-integrated-as
endif # BUILD_HOST_64bit
endif # linux

ifeq ($(HOST_OS),windows)
# nothing required here yet
endif