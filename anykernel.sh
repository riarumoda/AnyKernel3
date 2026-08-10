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

# check if device have super partition
if [ -e /dev/block/bootdevice/by-name/super ]; then
  SUPER_EXIST=1;
else
  SUPER_EXIST=0;
fi

# grab details of installer running in recovery
RECOVERY_DETAIL=$(getprop init.svc.recovery);
if [ "$RECOVERY_DETAIL" == "recovery" ]; then
  IS_ON_RECOVERY=1;
else
  IS_ON_RECOVERY=0;
fi

# grab kernel version from recovery
KERNEL_VERSION=$(cat /proc/version | cut -d' ' -f3 | cut -d'.' -f1,2);
KERNEL_PRINT_VERSION=$(cat /proc/version | cut -d' ' -f3);

# boot variables
BLOCK=/dev/block/bootdevice/by-name/boot;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import ak3 core functions
. tools/ak3-core.sh;

# check super environment
if [ $IS_ON_RECOVERY -eq 1 ]; then
  if [ "$KERNEL_BUILD_TYPE" == "Weekly" ]; then
    if [ $SUPER_EXIST -eq 1 ]; then
      $BIN/lptools_static map system;
      mkdir -p /tmp/temp_system;
      mount -t ext4 -o ro /dev/block/mapper/system /tmp/temp_system;
      SYSTEM_VER=$(cat /tmp/temp_system/system/build.prop | grep "ro.lineage.build.version" | cut -d'=' -f2);
      if [ "$SYSTEM_VER" != "22.0" && "$SYSTEM_VER" != "22.1" && "$SYSTEM_VER" != "22.2" && "$SYSTEM_VER" != "23.0" && "$SYSTEM_VER" != "23.1" && "$SYSTEM_VER" != "23.2" ]; then
        ui_print "- This OS is not supported.";
        ui_print "- Aborting installation to prevent compatibility issues.";
        umount /mnt/temp_system;
        $BIN/lptools_static unmap system;
        exit 1;
      fi
    elif [ $SUPER_EXIST -eq 0 ]; then
      mkdir -p /tmp/temp_system;
      mount -t ext4 -o ro /dev/block/bootdevice/by-name/system /tmp/temp_system;
      SYSTEM_VER=$(cat /tmp/temp_system/system/build.prop | grep "ro.lineage.build.version" | cut -d'=' -f2);
      if [ "$SYSTEM_VER" != "22.0" && "$SYSTEM_VER" != "22.1" && "$SYSTEM_VER" != "22.2" && "$SYSTEM_VER" != "23.0" && "$SYSTEM_VER" != "23.1" && "$SYSTEM_VER" != "23.2" ]; then
        ui_print "- This OS is not supported.";
        ui_print "- Aborting installation to prevent compatibility issues.";
        umount /mnt/temp_system;
        exit 1;
      fi
    fi
  fi
elif [ $IS_ON_RECOVERY -eq 0 ]; then
  if [ $KERNEL_BUILD_TYPE == "Weekly" ];then
    SYSTEM_VER=$(getprop ro.lineage.build.version);
    if [ "$SYSTEM_VER" != "22.0" && "$SYSTEM_VER" != "22.1" && "$SYSTEM_VER" != "22.2" && "$SYSTEM_VER" != "23.0" && "$SYSTEM_VER" != "23.1" && "$SYSTEM_VER" != "23.2" ]; then
      ui_print "- This OS is not supported.";
      ui_print "- Aborting installation to prevent compatibility issues.";
      exit 1;
    fi
  fi
fi

# print recovery kernel and recovery version
if [ $KERNEL_BUILD_TYPE == "Weekly" ]; then
  ui_print "- LineageOS Version: $SYSTEM_VER";
fi
ui_print "- Kernel Build Type: $KERNEL_BUILD_TYPE";
ui_print "- Is vendor_boot partition exist: $VENDOR_BOOT_EXIST";
ui_print "- Is super partition exist: $SUPER_EXIST";

# unmount system in here instead to avoid issues, recovery only
if [ $IS_ON_RECOVERY -eq 1 ]; then
  if [ $KERNEL_BUILD_TYPE == "Weekly" ];then
    if [ $SUPER_EXIST -eq 1 ]; then
      umount /tmp/temp_system;
      $BIN/lptools_static unmap system;
    elif [ $SUPER_EXIST -eq 0 ]; then
      umount /tmp/temp_system;
    fi
  fi
fi

# boot install
if [ "$KERNEL_VERSION" = "4.4" -o "$KERNEL_VERSION" = "4.9" -o "$KERNEL_VERSION" = "4.14" -o "$KERNEL_VERSION" = "4.19" ]; then
  dump_boot;
  write_boot;
elif [ "$KERNEL_VERSION" = "5.4" ]; then
  split_boot;
  flash_boot;
else
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
    dump_boot;
    write_boot;
  elif [ "$KERNEL_VERSION" = "5.4" ]; then
    split_boot;
    flash_boot;
  else
    exit 1;
  fi
fi
