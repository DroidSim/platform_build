# Decides how to install the jni libraries needed by an apk.
# Input variables:
#   LOCAL_JNI_SHARED_LIBRARIES
#   LOCAL_INSTALLED_MODULE
#   rs_compatibility_jni_libs (from java.mk)
#   my_module_path (from base_rules.mk)
#   partition_tag (from base_rules.mk)
#   my_prebuilt_src_file (from prebuilt_internal.mk)
#
# Output variables:
#   jni_shared_libraries, jni_shared_libraries_abi, if we are going to embed the libraries into the apk;
#   my_extracted_jni_libs, if we extract jni libs from prebuilt apk.
#

jni_shared_libraries := \
    $(addprefix $($(LOCAL_2ND_ARCH_VAR_PREFIX)TARGET_OUT_INTERMEDIATE_LIBRARIES)/, \
      $(addsuffix .so, \
          $(LOCAL_JNI_SHARED_LIBRARIES)))

# Include RS dynamically-generated libraries as well
# Keep this ifneq, as the += otherwise adds spaces that need to be stripped.
ifneq ($(rs_compatibility_jni_libs),)
jni_shared_libraries += $(rs_compatibility_jni_libs)
endif

my_embed_jni :=
ifneq ($(TARGET_BUILD_APPS),)
my_embed_jni := true
endif
ifneq ($(filter tests samples, $(LOCAL_MODULE_TAGS)),)
my_embed_jni := true
endif
ifeq ($(filter $(TARGET_OUT)/% $(TARGET_OUT_VENDOR)/% $(TARGET_OUT_OEM)/%, $(my_module_path)),)
# If this app isn't to be installed to system partitions.
my_embed_jni := true
endif

# App-specific lib path.
my_app_lib_path :=  $($(LOCAL_2ND_ARCH_VAR_PREFIX)TARGET$(partition_tag)_OUT_SHARED_LIBRARIES)/$(basename $(LOCAL_INSTALLED_MODULE_STEM))
my_extracted_jni_libs :=

ifdef my_embed_jni
# App explicitly requires the prebuilt NDK stl shared libraies.
# The NDK stl shared libraries should never go to the system image.
ifneq ($(filter $(LOCAL_NDK_STL_VARIANT), stlport_shared c++_shared),)
ifndef LOCAL_SDK_VERSION
$(error LOCAL_SDK_VERSION must be defined with LOCAL_NDK_STL_VARIANT, \
    LOCAL_PACKAGE_NAME=$(LOCAL_PACKAGE_NAME))
endif
endif
ifeq (stlport_shared,$(LOCAL_NDK_STL_VARIANT))
jni_shared_libraries += \
    $(HISTORICAL_NDK_VERSIONS_ROOT)/current/sources/cxx-stl/stlport/libs/$(TARGET_$(LOCAL_2ND_ARCH_VAR_PREFIX)CPU_ABI)/libstlport_shared.so
else ifeq (c++_shared,$(LOCAL_NDK_STL_VARIANT))
jni_shared_libraries += \
    $(HISTORICAL_NDK_VERSIONS_ROOT)/current/sources/cxx-stl/llvm-libc++/libs/$(TARGET_$(LOCAL_2ND_ARCH_VAR_PREFIX)CPU_ABI)/libc++_shared.so
endif

# Set the abi directory used by the local JNI shared libraries.
# (Doesn't change how the local shared libraries are compiled, just
# sets where they are stored in the apk.)
ifeq ($(LOCAL_JNI_SHARED_LIBRARIES_ABI),)
    jni_shared_libraries_abi := $(TARGET_$(LOCAL_2ND_ARCH_VAR_PREFIX)CPU_ABI)
else
    jni_shared_libraries_abi := $(LOCAL_JNI_SHARED_LIBRARIES_ABI)
endif

else  # not my_embed_jni

jni_shared_libraries := $(strip $(jni_shared_libraries))
ifneq ($(jni_shared_libraries),)
# The jni libaries will be installed to the system.img.
my_jni_filenames := $(notdir $(jni_shared_libraries))
# Make sure the JNI libraries get installed
$(LOCAL_INSTALLED_MODULE) : | $(addprefix $($(LOCAL_2ND_ARCH_VAR_PREFIX)TARGET$(partition_tag)_OUT_SHARED_LIBRARIES)/, $(my_jni_filenames))

# Create symlink in the app specific lib path
ifdef LOCAL_POST_INSTALL_CMD
my_leading_separator := ;
else
my_leading_separator :=
endif
$(LOCAL_INSTALLED_MODULE): PRIVATE_POST_INSTALL_CMD += \
  $(my_leading_separator)mkdir -p $(my_app_lib_path) \
  $(foreach lib, $(my_jni_filenames), ;ln -sf ../$(lib) $(my_app_lib_path)/$(lib))

# Clear jni_shared_libraries to not embed it into the apk.
jni_shared_libraries :=
endif  # $(jni_shared_libraries) not empty
endif  # my_embed_jni

ifdef LOCAL_PREBUILT_JNI_LIBS
# Install prebuilt JNI libs to the app specific lib path.
# Files like @path/to/libfoo.so (path inside the apk) are JNI libs extracted from the prebuilt apk;
# Files like path/to/libfoo.so (path relative to LOCAL_PATH) are prebuilts in the source tree.
my_extracted_jni_libs := $(patsubst @%,%, \
    $(filter @%, $(LOCAL_PREBUILT_JNI_LIBS)))
ifdef my_extracted_jni_libs
ifndef my_prebuilt_src_file
$(error No prebuilt apk to extract prebuilt jni libraries $(my_extracted_jni_libs))
endif
# We use the first jni lib file as dependency.
my_installed_prebuilt_jni := $(my_app_lib_path)/$(notdir $(firstword $(my_extracted_jni_libs)))
$(my_installed_prebuilt_jni): PRIVATE_JNI_LIBS := $(my_extracted_jni_libs)
$(my_installed_prebuilt_jni): $(my_prebuilt_src_file)
	@echo "Extract JNI libs ($@ <- $<)"
	@mkdir -p $(dir $@)
	$(hide) unzip -j -o -d $(dir $@) $< $(PRIVATE_JNI_LIBS) && touch $@

$(LOCAL_INSTALLED_MODULE) : | $(my_installed_prebuilt_jni)
endif

my_prebulit_jni_libs := $(addprefix $(LOCAL_PATH)/, \
    $(filter-out @%, $(LOCAL_PREBUILT_JNI_LIBS)))
ifdef my_prebulit_jni_libs
$(foreach lib, $(my_prebulit_jni_libs), \
    $(eval $(call copy-one-file, $(lib), $(my_app_lib_path)/$(notdir $(lib)))))

$(LOCAL_INSTALLED_MODULE) : | $(addprefix $(my_app_lib_path)/, $(notdir $(my_prebulit_jni_libs)))
endif
endif  # LOCAL_PREBULT_JNI_LIBS
