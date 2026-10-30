# global properties
properties() { '
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=sweet
device.name2=sweetin
supported.versions=11-16
supported.patchlevels=
supported.vendorpatchlevels=
'; }

# kernel build type
KERNEL_BUILD_TYPE="Weekly";

# check if device have vendor_boot
if [ -e /dev/block/bootdevice/by-name/vendor_boot ]; then
  VENDOR_BOOT_EXIST=1;
else
  VENDOR_BOOT_EXIST=0;
fi

# grab details of installer running in recovery
RECOVERY_DETAIL=$(getprop init.svc.recovery);
if [ "$RECOVERY_DETAIL" == "running" ]; then
  IS_ON_RECOVERY=1;
else
  IS_ON_RECOVERY=0;
fi

# grab kernel version from recovery
KERNEL_VERSION=$(cat /proc/version | cut -d' ' -f3 | cut -d'.' -f1)

# boot variables
BLOCK=/dev/block/bootdevice/by-name/boot;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import ak3 core functions
. tools/ak3-core.sh;

# print build and device information
ui_print "- Kernel Build Type: $KERNEL_BUILD_TYPE";
ui_print "- Kernel base version: $KERNEL_VERSION";
ui_print "- Is vendor_boot partition exist: $VENDOR_BOOT_EXIST";
ui_print "- Is installer running in recovery: $IS_ON_RECOVERY";

# boot install
dump_boot;
write_boot;

# Installation finished
ui_print " ";
ui_print "- Installation finished! Force reboot your phone if the recovery hung up/stuck!";
ui_print " ";