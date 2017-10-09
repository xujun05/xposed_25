#!/system/bin/sh

MODDIR=${0%/*}
DISABLE=/data/data/de.robv.android.xposed.installer/conf/disabled
MIRRDIR=/dev/magisk/mirror

[ -f $DISABLE ] && exit

IS22=false
case $MODDIR in
  *xposed_22* )
    IS22=true
    ;;
esac

# Fix Magisk bug
chcon u:object_r:system_file:s0 /magisk

mount -o rw,remount /
ln -s $MODDIR/xposed.prop /xposed.prop
mount -o ro,remount /

! $IS22 && exit

# Cleanup
if [ -f $MODDIR/lists ]; then
  for dir in `cat $MODDIR/lists`; do
    rm -rf $MODDIR$dir 2>/dev/null
  done
fi
rm -f $MODDIR/lists

for ODEX in `find /system -type f -name "*.odex*" 2>/dev/null`; do
  # Rename the odex files
  mkdir -p $MODDIR${ODEX%/*}
  touch $MODDIR${ODEX%/*}/.replace
  ln -s $MIRRDIR$ODEX $MODDIR${ODEX}.xposed
  # Record so we can remove afterwards
  echo ${ODEX%/*} >> $MODDIR/lists
done
for BOOT in `find /system/framework -type f -name "boot.*" 2>/dev/null`; do
  ln -s $MIRRDIR$BOOT $MODDIR$BOOT 2>/dev/null
done
