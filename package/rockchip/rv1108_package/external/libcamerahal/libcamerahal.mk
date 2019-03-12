LIBCAMERAHAL_SITE = $(TOPDIR)/../external/libcamerahal
LIBCAMERAHAL_SITE_METHOD = local

LIBCAMERAHAL_DEPENDENCIES = libion

define LIBCAMERAHAL_CONFIGURE_CMDS
        cd $(@D); $(TARGET_MAKE_ENV) CROSS_COMPILE=$(TARGET_CROSS) $(MAKE) $(TARGET_MAKE_OPTS) clean
endef

define LIBCAMERAHAL_BUILD_CMDS
	cd $(@D) && \
        $(TARGET_MAKE_ENV) CROSS_COMPILE=$(TARGET_CROSS) $(MAKE) $(TARGET_MAKE_OPTS)
endef

define LIBCAMERAHAL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m  644 $(@D)/camera_engine_cifisp/build/lib/libcam_engine_cifisp.so $(TARGET_DIR)/usr/lib/
	$(INSTALL) -D -m  644 $(@D)/camera_engine_cifisp/build/lib/libcam_ia.so $(TARGET_DIR)/usr/lib/
	mkdir -p $(TARGET_DIR)/etc/cam_iq/
        $(INSTALL) -D -m 0755 $(@D)/camera_engine_cifisp/IQ/*.xml $(TARGET_DIR)/etc/cam_iq/
	mkdir -p $(TARGET_DIR)/usr/include/CameraHal/linux
        $(foreach header,$(wildcard $(@D)/camera_engine_cifisp/HAL/include/*.h),$(INSTALL) -D -m 644 $(header) $(TARGET_DIR)/usr/include/CameraHal;)
	cp -fr $(@D)/camera_engine_cifisp/include/linux/* $(TARGET_DIR)/usr/include/CameraHal/linux
endef

define LIBCAMERAHAL_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m  644 $(@D)/camera_engine_cifisp/build/lib/libcam_engine_cifisp.so $(STAGING_DIR)/usr/lib/
	$(INSTALL) -D -m  644 $(@D)/camera_engine_cifisp/build/lib/libcam_ia.so $(STAGING_DIR)/usr/lib/
endef



$(eval $(generic-package))