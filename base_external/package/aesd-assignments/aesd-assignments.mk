##############################################################
#
# AESD-ASSIGNMENTS
#
##############################################################

AESD_ASSIGNMENTS_VERSION = 1a53ae96bd434af828dd1feb129ab6ef3a338d99
AESD_ASSIGNMENTS_SITE = git@github.com:cu-ecen-aeld/assignments-3-and-later-Alie20.git
AESD_ASSIGNMENTS_SITE_METHOD = git
AESD_ASSIGNMENTS_GIT_SUBMODULES = YES

# ------------------------------------------------------------
# 🧱 Build steps
# ------------------------------------------------------------
define AESD_ASSIGNMENTS_BUILD_CMDS
	# Build the finder application
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/finder-app all

	# Build the aesdsocket server (compiled with char device enabled)
	$(MAKE) -C $(@D)/server CROSS_COMPILE=$(TARGET_CROSS) CC=$(TARGET_CC) USE_AESD_CHAR_DEVICE=0

endef

# ------------------------------------------------------------
# 📦 Installation steps
# ------------------------------------------------------------
define AESD_ASSIGNMENTS_INSTALL_TARGET_CMDS
	# Copy configuration files
	$(INSTALL) -d 0755 $(TARGET_DIR)/etc/finder-app/conf/
	$(INSTALL) -m 0755 $(@D)/conf/* $(TARGET_DIR)/etc/finder-app/conf/

	# Copy assignment 4 test scripts
	$(INSTALL) -m 0755 $(@D)/assignment-autotest/test/assignment4/* $(TARGET_DIR)/bin

	# Copy finder utilities
	$(INSTALL) -m 0755 $(@D)/finder-app/writer $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0755 $(@D)/finder-app/finder.sh $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0755 $(@D)/finder-app/finder-test.sh $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0755 $(@D)/finder-app/writer.sh $(TARGET_DIR)/usr/bin/

	# Copy aesdsocket and startup script
	$(INSTALL) -m 0755 $(@D)/server/aesdsocket $(TARGET_DIR)/usr/bin/
	$(INSTALL) -m 0755 $(@D)/server/aesdsocket-start-stop $(TARGET_DIR)/etc/init.d/S99aesdsocket
endef

# ------------------------------------------------------------
# 🧩 Register package
# ------------------------------------------------------------
$(eval $(generic-package))

