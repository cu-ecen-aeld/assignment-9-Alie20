##############################################################
#
# AESDCHAR PACKAGE FOR BUILDROOT
#
##############################################################

AESDCHAR_VERSION = b3ebf55903a047ec8db587d692aa52e0b463ef46
AESDCHAR_SITE = git@github.com:cu-ecen-aeld/assignments-3-and-later-Alie20.git
AESDCHAR_SITE_METHOD = git
AESDCHAR_GIT_SUBMODULES = YES

# Tell Buildroot where to find the kernel module sources
AESDCHAR_MODULE_SUBDIRS = aesd-char-driver

# ------------------------------------------------------------
# 🧱 Install the driver and its helper scripts
# ------------------------------------------------------------
define AESDCHAR_INSTALL_TARGET_CMDS
	# Install kernel module
	$(INSTALL) -D -m 0644 $(@D)/aesd-char-driver/aesdchar.ko \
		$(TARGET_DIR)/lib/modules/$(LINUX_VERSION)/extra/aesdchar.ko

	# Install driver load/unload scripts
	$(INSTALL) -D -m 0755 $(@D)/aesd-char-driver/aesdchar_load \
		$(TARGET_DIR)/usr/bin/aesdchar_load
	$(INSTALL) -D -m 0755 $(@D)/aesd-char-driver/aesdchar_unload \
		$(TARGET_DIR)/usr/bin/aesdchar_unload

	# Fix insmod path inside the load script
	sed -i 's|insmod ./$module.ko|insmod /lib/modules/$$(uname -r)/extra/$module.ko|g' \
		$(TARGET_DIR)/usr/bin/aesdchar_load
endef

# ------------------------------------------------------------
# 🧩 Buildroot hooks
# ------------------------------------------------------------
$(eval $(kernel-module))
$(eval $(generic-package))

