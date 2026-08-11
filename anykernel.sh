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
      SYSTEM_VER=$(grep "ro.lineage.build.version" /tmp/temp_system/system/build.prop | cut -d'=' -f2 | cut -d'.' -f1)
      # check if SYSTEM_VER is empty
      if [ -z "$SYSTEM_VER" ]; then
        ui_print "- Unable to grab properties of ro.lineage.build.version.";
        ui_print "- Checking if this is LibreMobileOS...";
        LMODROID_CHECK=1;
        SYSTEM_VER=$(grep "ro.lmodroid.version" /tmp/temp_system/system/build.prop | cut -d'=' -f2 | cut -d'.' -f1)
        # check if SYSTEM_VER is empty again
        if [ -z "$SYSTEM_VER" ]; then
          ui_print "- Unable to grab properties of ro.lmodroid.version.";
          ui_print "- Aborting installation to prevent compatibility issues.";
          umount /mnt/temp_system;
          $BIN/lptools_static unmap system;
          exit 1;
        fi
      fi
      if [ "$SYSTEM_VER" != "22" && "$SYSTEM_VER" != "23" && "$SYSTEM_VER" != "3" && "$SYSTEM_VER" != "4" && "$SYSTEM_VER" != "5" && "$SYSTEM_VER" != "6" ]; then
        ui_print "- This OS is not supported.";
        ui_print "- Aborting installation to prevent compatibility issues.";
        umount /mnt/temp_system;
        $BIN/lptools_static unmap system;
        exit 1;
      fi
    elif [ $SUPER_EXIST -eq 0 ]; then
      mkdir -p /tmp/temp_system;
      mount -t ext4 -o ro /dev/block/bootdevice/by-name/system /tmp/temp_system;
      SYSTEM_VER=$(grep "ro.lineage.build.version" /tmp/temp_system/system/build.prop | cut -d'=' -f2 | cut -d'.' -f1)
      # check if SYSTEM_VER is empty
      if [ -z "$SYSTEM_VER" ]; then
        ui_print "- Unable to grab properties of ro.lineage.build.version.";
        ui_print "- Checking if this is LibreMobileOS...";
        LMODROID_CHECK=1;
        SYSTEM_VER=$(grep "ro.lmodroid.version" /tmp/temp_system/system/build.prop | cut -d'=' -f2 | cut -d'.' -f1)
        # check if SYSTEM_VER is empty again
        if [ -z "$SYSTEM_VER" ]; then
          ui_print "- Unable to grab properties of ro.lmodroid.version.";
          ui_print "- Aborting installation to prevent compatibility issues.";
          umount /mnt/temp_system;
          exit 1;
        fi
      fi
      if [ "$SYSTEM_VER" != "22" && "$SYSTEM_VER" != "23" && "$SYSTEM_VER" != "3" && "$SYSTEM_VER" != "4" && "$SYSTEM_VER" != "5" && "$SYSTEM_VER" != "6" ]; then
        ui_print "- This OS is not supported.";
        ui_print "- Aborting installation to prevent compatibility issues.";
        umount /mnt/temp_system;
        exit 1;
      fi
    fi
  fi
elif [ $IS_ON_RECOVERY -eq 0 ]; then
  if [ $KERNEL_BUILD_TYPE == "Weekly" ];then
    SYSTEM_VER=$(getprop ro.lineage.build.version | cut -d'.' -f1);
    # check if SYSTEM_VER is empty
      if [ -z "$SYSTEM_VER" ]; then
        ui_print "- Unable to grab properties of ro.lineage.build.version.";
        ui_print "- Checking if this is LibreMobileOS...";
        LMODROID_CHECK=1;
        SYSTEM_VER=$(getprop ro.lmodroid.version | cut -d'.' -f1)
        # check if SYSTEM_VER is empty again
        if [ -z "$SYSTEM_VER" ]; then
          ui_print "- Unable to grab properties of ro.lmodroid.version.";
          ui_print "- Aborting installation to prevent compatibility issues.";
          exit 1;
        fi
      fi
    if [ "$SYSTEM_VER" != "22" && "$SYSTEM_VER" != "23" && "$SYSTEM_VER" != "3" && "$SYSTEM_VER" != "4" && "$SYSTEM_VER" != "5" && "$SYSTEM_VER" != "6" ]; then
      ui_print "- This OS is not supported.";
      ui_print "- Aborting installation to prevent compatibility issues.";
      exit 1;
    fi
  fi
fi

# print build and device information
if [ $LMODROID_CHECK -eq 1 ]; then
  if [ $KERNEL_BUILD_TYPE == "Weekly" ]; then
    if [$SYSTEM_VER == "5" || $SYSTEM_VER == "6" ]; then
      ui_print "- LibreMobileOS Version: $SYSTEM_VER";
    fi
  fi
else
  if [ $KERNEL_BUILD_TYPE == "Weekly" ]; then
    if [$SYSTEM_VER == "22" || $SYSTEM_VER == "23" ]; then
      ui_print "- LineageOS Version: $SYSTEM_VER";
    elif [$SYSTEM_VER == "3" || $SYSTEM_VER == "4" ]; then
      ui_print "- /e/ OS Version: $SYSTEM_VER";
    fi
  fi
fi
ui_print "- Kernel Build Type: $KERNEL_BUILD_TYPE";
ui_print "- Is vendor_boot partition exist: $VENDOR_BOOT_EXIST";
ui_print "- Is super partition exist: $SUPER_EXIST";
ui_print "- Is installer running in recovery: $IS_ON_RECOVERY";

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
