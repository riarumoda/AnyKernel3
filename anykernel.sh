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

# check if device have vendor_boot
if [ -e /dev/block/bootdevice/by-name/vendor_boot ]; then
  IS_SLOT_DEVICE=1;
  VENDOR_BOOT_EXIST=1;
  ui_print "Device have vendor_boot!";
else
  IS_SLOT_DEVICE=0;
  VENDOR_BOOT_EXIST=0;
  ui_print "Device do not have vendor_boot!";
fi

# boot variables
BLOCK=/dev/block/bootdevice/by-name/boot;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import ak3 core functions
. tools/ak3-core.sh;

# boot install
dump_boot;
write_boot;

# vendor_boot
if [ $VENDOR_BOOT_EXIST -eq 1 ]; then
  # vendor_boot variables
  BLOCK=/dev/block/bootdevice/by-name/vendor_boot;
  RAMDISK_COMPRESSION=auto;
  PATCH_VBMETA_FLAG=auto;
  # vendor_boot install
  reset_ak;
  dump_boot;
  write_boot;
fi
