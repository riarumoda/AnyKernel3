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
  VENDOR_BOOT_EXIST=1;
else
  VENDOR_BOOT_EXIST=0;
fi

# grab kernel version from recovery
KERNEL_VERSION=$(cat /proc/version | cut -d' ' -f3 | cut -d'.' -f1,2);
KERNEL_PRINT_VERSION=$(cat /proc/version | cut -d' ' -f3);

# grab recovery properties
TWRP_BOOT=$(getprop ro.twrp.boot)
TWRP_VER=$(getprop ro.twrp.version)
OFOX_VER=$(getprop ro.orangefox.version)
LINEAGE_VER=$(getprop ro.lineage.build.version)

# check recovery environment
ui_print "- Checking recovery environment..."

if [ "$TWRP_BOOT" == "1" ] || [ -n "$TWRP_VER" ] || [ -n "$OFOX_VER" ]; then
  ui_print "- Unsupported Recovery Detected!"
  ui_print "- Please flash this kernel using LineageOS Recovery."
  exit 1
fi

if [ -z "$LINEAGE_VER" ]; then
  ui_print "- LineageOS Recovery not detected."
  ui_print "- Aborting installation to prevent compatibility issues."
  exit 1
fi

# print recovery kernel and recovery version
ui_print "- Recovery Version: $LINEAGE_VER";
ui_print "- Recovery Kernel Version: $KERNEL_PRINT_VERSION";

# boot variables
BLOCK=/dev/block/bootdevice/by-name/boot;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import ak3 core functions
. tools/ak3-core.sh;

# boot install
if [ "$KERNEL_VERSION" = "4.4" -o "$KERNEL_VERSION" = "4.9" -o "$KERNEL_VERSION" = "4.14" -o "$KERNEL_VERSION" = "4.19" ]; then
  ui_print "- Device is 4.x kernel, using ak3-core dump_boot and write_boot!";
  dump_boot;
  write_boot;
elif [ "$KERNEL_VERSION" = "5.4" ]; then
  ui_print "- Device is 5.4 kernel, using ak3-core split_boot and flash_boot!";
  split_boot;
  flash_boot;
else
  ui_print "- Either 3.x or GKI Kernel!!! Aborting...";
  exit 1;
fi

# vendor_boot
if [ $VENDOR_BOOT_EXIST -eq 1 ]; then
  # print vendor_boot are detected
  ui_print "- Device have vendor_boot!";
  # vendor_boot variables
  BLOCK=/dev/block/bootdevice/by-name/vendor_boot;
  RAMDISK_COMPRESSION=auto;
  PATCH_VBMETA_FLAG=auto;
  # vendor_boot install
  reset_ak;
  if [ "$KERNEL_VERSION" = "4.4" -o "$KERNEL_VERSION" = "4.9" -o "$KERNEL_VERSION" = "4.14" -o "$KERNEL_VERSION" = "4.19" ]; then
    ui_print "- Device is 4.x kernel, using ak3-core dump_boot and write_boot!";
    dump_boot;
    write_boot;
  elif [ "$KERNEL_VERSION" = "5.4" ]; then
    ui_print "- Device is 5.4 kernel, using ak3-core split_boot and flash_boot!";
    split_boot;
    flash_boot;
  else
    ui_print "- Either 3.x or GKI Kernel!!! Aborting...";
    exit 1;
  fi
else
  ui_print "- Device do not have vendor_boot, skipping vendor_boot...";
fi
