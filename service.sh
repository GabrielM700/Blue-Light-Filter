#!/system/bin/sh
# =============================================================
# BlueFilter - Boot service
# Executed by Magisk / KernelSU after every boot
# =============================================================

MODDIR="/data/adb/modules/bluelightfilter"
AUTOBOOT_FILE="$MODDIR/autoboot"

# Wait until Android has fully booted
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

# Give SurfaceFlinger extra time to initialize and become stable.
# Without this delay the service call can silently fail.
sleep 5

# Only apply the filter if the user explicitly enabled auto-start
# on boot via the WebUI Quick Actions. The autoboot file is
# created / removed by the GUI — never by the filter toggle itself.
if [ -f "$AUTOBOOT_FILE" ]; then
    /system/bin/bluefilter start
else
    # SurfaceFlinger forgets the color matrix on reboot. Drop the stale
    # "enabled" flag so the WebUI and the Quick Settings tile show "Off".
    rm -f "$MODDIR/enabled"
fi

# Best effort: put the Quick Settings tile in the panel once.
# If it does not show up, add it manually (edit icon -> drag the tile).
TILE_MARK="$MODDIR/.tile_added"
TILE_CMP="com.nonebaiano.bluefilter.tile/.FilterTileService"
if [ ! -f "$TILE_MARK" ] && pm path com.nonebaiano.bluefilter.tile > /dev/null 2>&1; then
    cmd statusbar add-tile "$TILE_CMP" > /dev/null 2>&1
    touch "$TILE_MARK"
fi
