##############################################################
#
# AESDCHAR PACKAGE FOR BUILDROOT
#
##############################################################

AESD_ASSIGNMENTS_VERSION = b3ebf55903a047ec8db587d692aa52e0b463ef46
AESD_ASSIGNMENTS_SITE = git@github.com:cu-ecen-aeld/assignments-3-and-later-Alie20
AESD_ASSIGNMENTS_SITE_METHOD = git
AESD_ASSIGNMENTS_GIT_SUBMODULES = YES

AESDCHAR_MODULE_SUBDIRS = aesd-char-driver


# Build directory for cloned assignment repo
AESD_ASSIGNMENTS_BUILD_DIR = $(BUILD_DIR)/aesd-assignments-$(AESD_ASSIGNMENTS_VERSION)
#export ARCH=arm64
#export CROSS_COMPILE=$(BUILD_DIR)/../host/bin/aarch64-buildroot-linux-gnu-gcc

# Build commands
define AESDCHAR_BUILD_CMDS
	
	make -C $(BUILD_DIR)/linux-6.1.44 \
	     M=$(AESD_ASSIGNMENTS_BUILD_DIR)/aesd-char-driver \
	     ARCH=arm64 \
	     CROSS_COMPILE=$(BUILD_DIR)/../host/bin/aarch64-buildroot-linux-gnu- \
	     modules

    mkdir -p $(@D)/server

	# Build the server binary using the cloned repo
	$(TARGET_CC) $(TARGET_CFLAGS) -DUSE_AESD_CHAR_DEVICE=1 \
	-o $(@D)/server/aesdsocket \
	$(AESD_ASSIGNMENTS_BUILD_DIR)/server/aesdsocket.c -lpthread
endef

# Install commands
define AESDCHAR_INSTALL_TARGET_CMDS
	# Install driver load/unload scripts
		$(INSTALL) -D -m 0644 $(AESD_ASSIGNMENTS_BUILD_DIR)/aesd-char-driver/aesdchar.ko \
		$(TARGET_DIR)/lib/modules/$(LINUX_VERSION)/extra/aesdchar.ko

	$(INSTALL) -D -m 0755 $(AESD_ASSIGNMENTS_BUILD_DIR)/aesd-char-driver/aesdchar_load \
		$(TARGET_DIR)/usr/bin/aesdchar_load
	$(INSTALL) -D -m 0755 $(AESD_ASSIGNMENTS_BUILD_DIR)/aesd-char-driver/aesdchar_unload \
		$(TARGET_DIR)/usr/bin/aesdchar_unload

	# Fix paths in load script to point to installed module location
	sed -i 's|insmod ./$module.ko|insmod /lib/modules/$$(uname -r)/extra/$module.ko|g' \
		$(TARGET_DIR)/usr/bin/aesdchar_load

	# Install aesdsocket binary and start-stop script
	$(INSTALL) -D -m 0755 $(AESD_ASSIGNMENTS_BUILD_DIR)/server/aesdsocket \
		$(TARGET_DIR)/usr/bin/aesdsocket
	$(INSTALL) -D -m 0755 $(AESD_ASSIGNMENTS_BUILD_DIR)/server/aesdsocket-start-stop \
		$(TARGET_DIR)/usr/bin/aesdsocket-start-stop
	#$(INSTALL) -m 0755 $(@D)/assignment-autotest/test/assignment8-buildroot/drivertest.sh $(TARGET_DIR)/usr/bin
		
endef

# Evaluate generic package
$(eval $(generic-package))

