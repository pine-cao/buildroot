MEDIASERVER_SITE = $(TOPDIR)/../app/mediaserver
MEDIASERVER_SITE_METHOD = local

MEDIASERVER_DEPENDENCIES = rkmedia dbus dbus-cpp librkdb json-for-modern-cpp

MEDIASERVER_CONF_OPTS += -DBR2_SDK_PATH=$(HOST_DIR)

ifeq ($(BR2_PACKAGE_RK_OEM), y)
MEDIASERVER_INSTALL_TARGET_OPTS = DESTDIR=$(BR2_PACKAGE_RK_OEM_INSTALL_TARGET_DIR) install/fast
MEDIASERVER_DEPENDENCIES += rk_oem
MEDIASERVER_CONF_OPTS += -DMEDIASERVER_CONF_PREFIX="\"/oem\""
endif

ifeq ($(BR2_PACKAGE_MEDIASERVE_LINKAPI), y)
    MEDIASERVER_CONF_OPTS += -DENABLE_LINK_SUPPORT=ON
    MEDIASERVER_DEPENDENCIES += cjson
endif

ifeq ($(BR2_PACKAGE_MEDIASERVE_MINILOGGER), y)
    MEDIASERVER_CONF_OPTS += -DENABLE_MINILOGGER=ON
    MEDIASERVER_DEPENDENCIES += minilogger
endif

ifeq ($(BR2_PACKAGE_MEDIASERVE_OSD_SERVER), y)
    MEDIASERVER_CONF_OPTS += -DENABLE_OSD_SERVER=ON
    MEDIASERVER_DEPENDENCIES += freetype
endif

$(eval $(cmake-package))
