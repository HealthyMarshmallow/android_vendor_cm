TARGET_UNOFFICIAL_BUILD_ID := temasek

PRODUCT_BRAND ?= cyanogenmod

#check device aspect ratio (tablet or phone) to import full screen bootanimation where appropriate
ifdef SCREEN_RATIO_PROPORTIONATE
ifeq ($(SCREEN_RATIO_PROPORTIONATE),true)
# Set bootanimation size to width to differentiate between tablet and phone devices for aspect ratio
TARGET_BOOTANIMATION_SIZE := $(TARGET_SCREEN_WIDTH)
endif
else
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
	if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )
endif

TARGET_BOOTANIMATION_NAME := $(TARGET_BOOTANIMATION_SIZE)

ifdef SCREEN_RATIO_PROPORTIONATE
ifeq ($(SCREEN_RATIO_PROPORTIONATE),true)
PRODUCT_BOOTANIMATION := vendor/cm/prebuilt/common/bootanimation/$(TARGET_SCREEN_ASPECT_RATIO)/$(TARGET_BOOTANIMATION_NAME).zip
endif
else
PRODUCT_BOOTANIMATION := vendor/cm/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif
ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_BOOTANIMATION := vendor/cm/prebuilt/common/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip
endif

ifdef CM_NIGHTLY
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=cyanogenmodnightly
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=cyanogenmod
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

ifneq ($(TARGET_BUILD_VARIANT),user)
# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0
endif

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Copy over the changelog to the device
PRODUCT_COPY_FILES += \
    vendor/cm/CHANGELOG.mkdn:system/etc/CHANGELOG-CM.txt

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/cm/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/cm/prebuilt/common/bin/50-cm.sh:system/addon.d/50-cm.sh \
    vendor/cm/prebuilt/common/bin/blacklist:system/addon.d/blacklist

# Backup Services whitelist
PRODUCT_COPY_FILES += \
    vendor/cm/config/permissions/backup.xml:system/etc/sysconfig/backup.xml

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/bin/otasigcheck.sh:install/bin/otasigcheck.sh

# LCD density backup
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/bin/97-backup.sh:system/addon.d/97-backup.sh \
    vendor/cm/prebuilt/common/etc/backup.conf:system/etc/backup.conf 

# init.d support
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/cm/prebuilt/common/bin/sysinit:system/bin/sysinit

ifneq ($(TARGET_BUILD_VARIANT),user)
# userinit support
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit
endif

# CM-specific init file
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.local.rc:root/init.cm.rc

# Copy over added mimetype supported in libcore.net.MimeUtils
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/lib/content-types.properties:system/lib/content-types.properties

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

ifneq ($(TARGET_ARCH),arm64)
# Viper4Android
PRODUCT_COPY_FILES += \
   vendor/cm/prebuilt/common/bin/audio_policy.sh:system/audio_policy.sh \
   vendor/cm/prebuilt/common/addon.d/95-LolliViPER.sh:system/addon.d/95-LolliViPER.sh \
   vendor/cm/prebuilt/common/su.d/50viper.sh:system/su.d/50viper.sh \
   vendor/cm/prebuilt/common/app/Viper4Android/Viper4Android.apk:system/priv-app/Viper4Android/Viper4Android.apk
endif

# APP REMOVAL SCRIPT
PRODUCT_COPY_FILES += \
   vendor/cm/prebuilt/common/addon.d/60-removal.sh:system/addon.d/60-removal.sh \
   vendor/cm/prebuilt/common/addon.d/98-temasek.sh:system/addon.d/98-temasek.sh

# This is CM!
PRODUCT_COPY_FILES += \
    vendor/cm/config/permissions/com.cyanogenmod.android.xml:system/etc/permissions/com.cyanogenmod.android.xml

# Theme engine
include vendor/cm/config/themes_common.mk

# CMSDK
include vendor/cm/config/cmsdk_common.mk

# Required CM packages
PRODUCT_PACKAGES += \
    CMAudioService \
    Development \
    BluetoothExt \
    Profiles \
    ThemeManagerService

# Optional CM packages
PRODUCT_PACKAGES += \
    libemoji

# Include librsjni explicitly to workaround GMS issue
PRODUCT_PACKAGES += \
    librsjni

# Omni Apps
PRODUCT_PACKAGES += \
    OmniSwitch

# Custom CM packages
PRODUCT_PACKAGES += \
    Launcher3 \
    Trebuchet \
    AudioFX \
    CMWallpapers \
    CMFileManager \
    Eleven \
    LockClock \
    CyanogenSetupWizard \
    CMSettingsProvider \
    ExactCalculator \
    LiveLockScreenService \
    WeatherProvider \
    DataUsageProvider

# Exchange support
PRODUCT_PACKAGES += \
    Exchange2

# Extra tools in CM
PRODUCT_PACKAGES += \
    libsepol \
    mke2fs \
    tune2fs \
    nano \
    htop \
    mkfs.ntfs \
    fsck.ntfs \
    mount.ntfs \
    gdbserver \
    micro_bench \
    oprofiled \
    sqlite3 \
    strace \
    pigz

# Custom off-mode charger
ifneq ($(WITH_CM_CHARGER),false)
PRODUCT_PACKAGES += \
    charger_res_images \
    cm_charger_res_images \
    font_log.png \
    libhealthd.cm
endif

# ExFAT support
WITH_EXFAT ?= true
ifeq ($(WITH_EXFAT),true)
TARGET_USES_EXFAT := true
PRODUCT_PACKAGES += \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat
endif

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libffmpeg_extractor \
    libffmpeg_omx \
    media_codecs_ffmpeg.xml

PRODUCT_PROPERTY_OVERRIDES += \
    media.sf.omx-plugin=libffmpeg_omx.so \
    media.sf.extractor-plugin=libffmpeg_extractor.so

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_PACKAGES += \
    procmem \
    procrank \
    su
endif

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=0

DEVICE_PACKAGE_OVERLAYS += vendor/cm/overlay/common

PRODUCT_VERSION_MAJOR = 13
PRODUCT_VERSION_MINOR = 0
PRODUCT_VERSION_MAINTENANCE := 2

ifeq ($(TARGET_VENDOR_SHOW_MAINTENANCE_VERSION),true)
    CM_VERSION_MAINTENANCE := $(PRODUCT_VERSION_MAINTENANCE)
else
    CM_VERSION_MAINTENANCE := 0
endif

# Set CM_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat

ifndef CM_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "CM_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^CM_||g')
        CM_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL,$(CM_BUILDTYPE)),)
    CM_BUILDTYPE :=
endif

ifdef CM_BUILDTYPE
    ifneq ($(CM_BUILDTYPE), SNAPSHOT)
        ifdef CM_EXTRAVERSION
            # Force build type to EXPERIMENTAL
            CM_BUILDTYPE := EXPERIMENTAL
            # Remove leading dash from CM_EXTRAVERSION
            CM_EXTRAVERSION := $(shell echo $(CM_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to CM_EXTRAVERSION
            CM_EXTRAVERSION := -$(CM_EXTRAVERSION)
        endif
    else
        ifndef CM_EXTRAVERSION
            # Force build type to EXPERIMENTAL, SNAPSHOT mandates a tag
            CM_BUILDTYPE := EXPERIMENTAL
        else
            # Remove leading dash from CM_EXTRAVERSION
            CM_EXTRAVERSION := $(shell echo $(CM_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to CM_EXTRAVERSION
            CM_EXTRAVERSION := -$(CM_EXTRAVERSION)
        endif
    endif
else
    # If CM_BUILDTYPE is not defined, set to UNOFFICIAL
    CM_BUILDTYPE := UNOFFICIAL
    CM_EXTRAVERSION :=
endif

ifeq ($(CM_BUILDTYPE), UNOFFICIAL)
    ifneq ($(TARGET_UNOFFICIAL_BUILD_ID),)
        CM_EXTRAVERSION := -$(TARGET_UNOFFICIAL_BUILD_ID)
    endif
endif

ifeq ($(CM_BUILDTYPE), RELEASE)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
        CM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(CM_BUILD)
    else
        ifeq ($(TARGET_BUILD_VARIANT),user)
            ifeq ($(CM_VERSION_MAINTENANCE),0)
                CM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(CM_BUILD)
            else
                CM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(CM_VERSION_MAINTENANCE)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(CM_BUILD)
            endif
        else
            CM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(CM_BUILD)
        endif
    endif
else
    ifeq ($(CM_VERSION_MAINTENANCE),0)
        CM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d-%H%M%S)-$(CM_BUILDTYPE)$(CM_EXTRAVERSION)-$(CM_BUILD)
    else
        CM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(CM_VERSION_MAINTENANCE)-$(shell date -u +%Y%m%d-%H%M%S)-$(CM_BUILDTYPE)$(CM_EXTRAVERSION)-$(CM_BUILD)
    endif
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.cm.version=$(CM_VERSION) \
  ro.cm.releasetype=$(CM_BUILDTYPE) \
  ro.modversion=cm-$(CM_VERSION) \
  ro.cmlegal.url=https://cyngn.com/legal/privacy-policy

-include vendor/cm-priv/keys/keys.mk

CM_DISPLAY_VERSION := $(CM_VERSION)

ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),)
ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),build/target/product/security/testkey)
  ifneq ($(CM_BUILDTYPE), UNOFFICIAL)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
      ifneq ($(CM_EXTRAVERSION),)
        # Remove leading dash from CM_EXTRAVERSION
        CM_EXTRAVERSION := $(shell echo $(CM_EXTRAVERSION) | sed 's/-//')
        TARGET_VENDOR_RELEASE_BUILD_ID := $(CM_EXTRAVERSION)
      else
        TARGET_VENDOR_RELEASE_BUILD_ID := $(shell date -u +%Y%m%d-%H%M%S)
      endif
    else
      TARGET_VENDOR_RELEASE_BUILD_ID := $(TARGET_VENDOR_RELEASE_BUILD_ID)
    endif
    ifeq ($(CM_VERSION_MAINTENANCE),0)
        CM_DISPLAY_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(CM_BUILD)
    else
        CM_DISPLAY_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(CM_VERSION_MAINTENANCE)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(CM_BUILD)
    endif
endif
endif
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.cm.display.version=$(CM_DISPLAY_VERSION)

-include $(WORKSPACE)/build_env/image-auto-bits.mk

-include vendor/cyngn/product.mk

$(call prepend-product-if-exists, vendor/extra/product.mk)
