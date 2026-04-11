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
else
  IS_SLOT_DEVICE=0;
  VENDOR_BOOT_EXIST=0;
fi

# grab kernel version from recovery
KERNEL_VERSION=$(cat /proc/version | cut -d' ' -f3 | cut -d'.' -f1,2);

# boot variables
BLOCK=/dev/block/bootdevice/by-name/boot;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import ak3 core functions
. tools/ak3-core.sh;

# boot install
if [ "$KERNEL_VERSION" = "4.4" -o "$KERNEL_VERSION" = "4.9" -o "$KERNEL_VERSION" = "4.14" -o "$KERNEL_VERSION" = "4.19" ]; then
  ui_print "Device is 4.x kernel, using ak3-core dump_boot and write_boot!";
  dump_boot;
  write_boot;
elif [ "$KERNEL_VERSION" = "5.4" ]; then
  ui_print "Device is 5.4 kernel, using ak3-core split_boot and flash_boot!";
  split_boot;
  flash_boot;
else
  ui_print "Either 3.x or GKI Kernel!!! Aborting...";
  exit 1;
fi

# vendor_boot
if [ $VENDOR_BOOT_EXIST -eq 1 ]; then
  # print vendor_boot are detected
  ui_print "Device have vendor_boot!";
  # vendor_boot variables
  BLOCK=/dev/block/bootdevice/by-name/vendor_boot;
  RAMDISK_COMPRESSION=auto;
  PATCH_VBMETA_FLAG=auto;
  # vendor_boot install
  reset_ak;
  if [ "$KERNEL_VERSION" = "4.4" -o "$KERNEL_VERSION" = "4.9" -o "$KERNEL_VERSION" = "4.14" -o "$KERNEL_VERSION" = "4.19" ]; then
    ui_print "Device is 4.x kernel, using ak3-core dump_boot and write_boot!";
    dump_boot;
    write_boot;
  elif [ "$KERNEL_VERSION" = "5.4" ]; then
    ui_print "Device is 5.4 kernel, using ak3-core split_boot and flash_boot!";
    split_boot;
    flash_boot;
  else
    ui_print "Either 3.x or GKI Kernel!!! Aborting...";
    exit 1;
  fi
else
  ui_print "Device do not have vendor_boot, skipping vendor_boot...";
fi
