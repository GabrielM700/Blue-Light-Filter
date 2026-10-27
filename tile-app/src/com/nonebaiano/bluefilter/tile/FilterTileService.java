package com.nonebaiano.bluefilter.tile;

import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.service.quicksettings.Tile;
import android.service.quicksettings.TileService;

import java.io.BufferedReader;
import java.io.InputStreamReader;

/**
 * Quick Settings tile that turns the BlueFilter module on/off.
 * It only calls the module's CLI as root: /system/bin/bluefilter {status|toggle}
 * The first tap triggers the root permission prompt (Magisk / KernelSU / APatch).
 */
public class FilterTileService extends TileService {

    private static final String BIN = "/system/bin/bluefilter";
    private final Handler main = new Handler(Looper.getMainLooper());

    @Override
    public void onStartListening() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                final Boolean on = parse(sh(BIN + " status"));
                main.post(new Runnable() {
                    @Override
                    public void run() {
                        paint(on);
                    }
                });
            }
        }).start();
    }

    @Override
    public void onClick() {
        final Tile tile = getQsTile();
        if (tile == null) return;
        final boolean wasOn = tile.getState() == Tile.STATE_ACTIVE;
        paint(!wasOn); // optimistic update, reverted below if the command fails
        new Thread(new Runnable() {
            @Override
            public void run() {
                final Boolean on = parse(sh(BIN + " toggle"));
                main.post(new Runnable() {
                    @Override
                    public void run() {
                        paint(on != null ? on : Boolean.valueOf(wasOn));
                    }
                });
            }
        }).start();
    }

    /** on == null means the state is unknown (no root / module missing). */
    private void paint(Boolean on) {
        Tile tile = getQsTile();
        if (tile == null) return;
        tile.setLabel("Blue Light Filter");
        if (on == null) {
            tile.setState(Tile.STATE_INACTIVE);
            setSubtitle(tile, "No root");
        } else if (on.booleanValue()) {
            tile.setState(Tile.STATE_ACTIVE);
            setSubtitle(tile, "On");
        } else {
            tile.setState(Tile.STATE_INACTIVE);
            setSubtitle(tile, "Off");
        }
        tile.updateTile();
    }

    private static void setSubtitle(Tile tile, String text) {
        if (Build.VERSION.SDK_INT >= 29) {
            tile.setSubtitle(text);
        }
    }

    private static Boolean parse(String out) {
        if (out == null) return null;
        if (out.contains("running") || out.contains("started")) return Boolean.TRUE;
        if (out.contains("stopped") || out.contains("reset")) return Boolean.FALSE;
        return null;
    }

    private static String sh(String cmd) {
        Process p = null;
        try {
            p = new ProcessBuilder("su", "-c", cmd).redirectErrorStream(true).start();
            BufferedReader r = new BufferedReader(new InputStreamReader(p.getInputStream()));
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = r.readLine()) != null) {
                sb.append(line).append('\n');
            }
            p.waitFor();
            return sb.toString().trim();
        } catch (Exception e) {
            return "";
        } finally {
            if (p != null) p.destroy();
        }
    }
}
