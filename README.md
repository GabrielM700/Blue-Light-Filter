# Blue Light Filter

A Magisk/KernelSU module that applies a system-wide blue light filter directly through SurfaceFlinger, Android's graphics compositor.

## Why reduce blue light?
Screens emit a high amount of blue light, which can cause eye strain, headaches, and difficulty sleeping, especially at night. Reducing blue light in the evening helps your eyes feel more comfortable and makes it easier to wind down before bed.

## Features
- Covers the entire screen, including status bar and navigation bar.
- No overlay window. Works even on apps that block screen overlays.
- Configurable RGB color via a built-in WebUI.
- Auto-start on boot (optional).
- No background process. Zero battery impact.
- Works with Magisk and KernelSU.
- **New in v1.1.0:** Quick Settings tile and `bluefilter toggle` command.

## What is this project?
Most blue light filter apps draw a colored overlay on top of the screen, which has limitations, it doesn't cover the status bar, navigation bar, or apps with `FLAG_SECURE`. This module applies the filter at the compositor level using a SurfaceFlinger color transform matrix, so it covers everything with no exceptions.

## Prerequisites
- Android 8.0+ (API 26 or higher)
- Magisk or KernelSU installed
- MMRL or KSUWebUIStandalone installed (to access the WebUI)

## Installation
1. Download the latest release.
2. Flash it in Magisk or KernelSU.
3. Reboot your device.
4. Open the WebUI via MMRL or KSUWebUIStandalone.
5. Adjust the color sliders and tap **Apply & Save**.

## Quick Settings tile (v1.1.0)
After rebooting, pull down Quick Settings, tap the pencil (edit) and drag **Blue Light Filter** into the panel
(the module tries to add it by itself on first boot). Tap it to toggle the filter and grant root to
"Blue Light Filter" when asked. The first "On" uses a warm default color until you pick one in the WebUI.
The same toggle is available from a root shell with `bluefilter toggle`.

## Usage
- **Blue Light Filter toggle** — enables or disables the filter.
- **Custom Color** — set your own RGB values (Red minimum is 0.10 to avoid a black screen).
- **Auto-start on boot** — re-applies the filter automatically after every reboot.
- **Remove filter now** — clears the filter from the screen without changing your saved settings.

## Building from source
The flashable zip contains the tile APK, so it has to be built:
- **GitHub Actions:** open **Actions → Build module → Run workflow** and download the `BlueLightFilter` artifact.
- **Local:** install JDK 17+ and the Android SDK (build-tools + a platform), set `ANDROID_HOME` and run `./build.sh`.
  The result is `dist/BlueLightFilter_v1_1_0.zip`.

## Known Issues
- May not work on ROMs that restrict SurfaceFlinger binder access, such as some MIUI and One UI builds. Run `bluefilter diag` in a root shell to check.

## Credits
- Original project and author: **None Baiano** — [NoneBaiano/BlueLightFIlter](https://github.com/NoneBaiano/BlueLightFIlter). All credit for the idea, the SurfaceFlinger approach, the WebUI and the module goes to him.
- This repository carries the v1.1.0 source (Quick Settings tile, `bluefilter toggle`, build workflow) and keeps the original GPL-3.0 license.
- WebUI is compatible with [MMRL](https://github.com/MMRLApp/MMRL) and KSUWebUIStandalone.

## License
This project is licensed under the GNU General Public License v3.0 (GPL-3.0).
You are free to modify and redistribute it under the same terms.

See the full [LICENSE](LICENSE) file for details.
