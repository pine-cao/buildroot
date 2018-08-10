################################################################################
#
# rkwifibt
#
################################################################################

RKWIFIBT_VERSION = 1.0.0
RKWIFIBT_SITE_METHOD = local
RKWIFIBT_SITE = $(TOPDIR)/../external/rkwifibt

RKWIFIBT_MODULES_PATH = $(TOPDIR)/../kernel/drivers/net/wireless/rockchip_wlan
BT_TTY_DEV = $(call qstrip,$(BR2_PACKAGE_RKWIFIBT_BTUART))

ifeq ($(BR2_PACKAGE_RKWIFIBT_AP6255),y)
CHIP_VENDOR = BROADCOM
CHIP_NAME = AP6255
BT_FIRMWARE = BCM4345C0.hcd
endif

ifeq ($(BR2_PACKAGE_RKWIFIBT_AP6212A1),y)
CHIP_VENDOR = BROADCOM
CHIP_NAME = AP6212A1
BT_FIRMWARE = bcm43438a1.hcd
endif

ifeq ($(BR2_PACKAGE_RKWIFIBT_AWCM256),y)
CHIP_VENDOR = BROADCOM
CHIP_NAME = AW-CM256
BT_FIRMWARE = BCM4345C0.hcd
endif

ifeq ($(BR2_PACKAGE_RKWIFIBT_AWNB197),y)
CHIP_VENDOR = BROADCOM
CHIP_NAME = AW-NB197
BT_FIRMWARE = BCM4343A1.hcd
endif

ifeq ($(BR2_PACKAGE_RKWIFIBT_RTL8723DS),y)
CHIP_VENDOR = REALTEK
CHIP_NAME = RTL8723DS
BT_FIRMWARE = y
endif

ifeq ($(BR2_PACKAGE_RKWIFIBT_RTL8189FS),y)
CHIP_VENDOR = REALTEK
CHIP_NAME = RTL8189FS
endif

ifeq ($(call qstrip,$(BR2_ARCH)),arm)
RKWIFIBT_BIN_DIR = $(@D)/bin/arm
endif
ifeq ($(call qstrip,$(BR2_ARCH)),aarch64)
RKWIFIBT_BIN_DIR = $(@D)/bin/arm64
endif

ifeq ($(CHIP_VENDOR), REALTEK)

ifeq ($(CHIP_NAME), RTL8723DS)

ifeq ($(call qstrip,$(BR2_ARCH)),aarch64)
define RKWIFIBT_BUILD_CMDS
    $(MAKE) -C $(@D)/realtek/rtk_hciattach/ CC=$(TARGET_CC)
    $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(TOPDIR)/../kernel/ M=$(@D)/realtek/bluetooth_uart_driver ARCH=arm64 \
            CROSS_COMPILE=$(TOPDIR)/../prebuilts/gcc/linux-x86/aarch64/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
         
endef
endif

ifeq ($(call qstrip,$(BR2_ARCH)),arm)
define RKWIFIBT_BUILD_CMDS
    $(MAKE) -C $(@D)/realtek/rtk_hciattach/ CC=$(TARGET_CC)  
    $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(TOPDIR)/../kernel/ M=$(@D)/realtek/bluetooth_uart_driver ARCH=arm \
            CROSS_COMPILE=$(TOPDIR)/../prebuilts/gcc/linux-x86/arm/gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-       
endef
endif

define RKWIFIBT_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/realtek/rtk_hciattach/rtk_hciattach $(TARGET_DIR)/usr/bin/rtk_hciattach
    $(INSTALL) -D -m 0755 $(@D)/realtek/bluetooth_uart_driver/hci_uart.ko $(TARGET_DIR)/usr/lib/modules/hci_uart.ko    
    $(INSTALL) -D -m 0755 $(RKWIFIBT_BIN_DIR)/rtwpriv $(TARGET_DIR)/usr/bin/rtwpriv
    $(INSTALL) -D -m 0755 $(RKWIFIBT_BIN_DIR)/bluetooth-player $(TARGET_DIR)/usr/bin/bluetooth-player

    mkdir -p $(TARGET_DIR)/lib/firmware/rtlbt/
    $(INSTALL) -D -m 0755 $(@D)/realtek/$(CHIP_NAME)/* $(TARGET_DIR)/lib/firmware/rtlbt/
    sed -i 's/BT_TTY_DEV/\/dev\/$(BT_TTY_DEV)/g' $(@D)/bt_load_rtk_firmware
    $(INSTALL) -D -m 0755 $(@D)/bt_load_rtk_firmware $(TARGET_DIR)/usr/bin/bt_pcba_test
    $(INSTALL) -D -m 0755 $(@D)/bt_realtek_start $(TARGET_DIR)/usr/bin/bt_realtek_start
    $(INSTALL) -D -m 0755 $(@D)/bt_realtek_hfp_start $(TARGET_DIR)/usr/bin/bt_realtek_hfp_start
    $(INSTALL) -D -m 0755 $(@D)/bt_realtek_hfp_hanup $(TARGET_DIR)/usr/bin/bt_realtek_hfp_hanup
    $(INSTALL) -D -m 0755 $(@D)/bt_realtek_hfp_accept $(TARGET_DIR)/usr/bin/bt_realtek_hfp_accept
    cp $(TARGET_DIR)/usr/bin/bt_pcba_test $(TARGET_DIR)/usr/bin/bt_load_rtk_firmware
    $(INSTALL) -D -m 0755 $(@D)/S66load_wifi_modules $(TARGET_DIR)/etc/init.d
endef

endif # RTL8723DS

ifeq ($(CHIP_NAME), RTL8189FS)
define RKWIFIBT_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/S66load_wifi_modules $(TARGET_DIR)/etc/init.d
endef
endif #RTL8189FS

endif # CHIP_VENDOR

ifeq ($(CHIP_VENDOR), BROADCOM)
define RKWIFIBT_BUILD_CMDS
    $(TARGET_CC) -o $(@D)/brcm_tools/brcm_patchram_plus1 $(@D)/brcm_tools/brcm_patchram_plus1.c
    $(TARGET_CC) -o $(@D)/brcm_tools/dhd_priv $(@D)/brcm_tools/dhd_priv.c
endef

define RKWIFIBT_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/lib/modules
    mkdir -p $(TARGET_DIR)/system/etc/firmware
    $(INSTALL) -D -m 0644 $(@D)/firmware/broadcom/$(CHIP_NAME)/wifi/* $(TARGET_DIR)/system/etc/firmware
    $(INSTALL) -D -m 0644 $(@D)/firmware/broadcom/$(CHIP_NAME)/bt/* $(TARGET_DIR)/system/etc/firmware
    $(INSTALL) -D -m 0755 $(@D)/brcm_tools/brcm_patchram_plus1 $(TARGET_DIR)/usr/bin/brcm_patchram_plus1
    sed -i 's/MODULE_PATH/\/usr\/lib\/modules\/bcmdhd.ko/g' $(@D)/S66load_wifi_modules
    $(INSTALL) -D -m 0755 $(@D)/S66load_wifi_modules $(TARGET_DIR)/etc/init.d
    sed -i 's/BTFIRMWARE_PATH/\/system\/etc\/firmware\/$(BT_FIRMWARE)/g' $(@D)/bt_load_broadcom_firmware
    sed -i 's/BT_TTY_DEV/\/dev\/$(BT_TTY_DEV)/g' $(@D)/bt_load_broadcom_firmware
    $(INSTALL) -D -m 0755 $(@D)/bt_load_broadcom_firmware $(TARGET_DIR)/usr/bin/bt_pcba_test
    $(INSTALL) -D -m 0755 $(RKWIFIBT_BIN_DIR)/* $(TARGET_DIR)/usr/bin/
endef
endif

$(eval $(generic-package))
