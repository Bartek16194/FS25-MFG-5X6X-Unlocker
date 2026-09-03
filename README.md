# FS25 DLSS MFG 5X / 6X Unlocker

A small Windows utility that unlocks **5X and 6X DLSS Multi Frame Generation options directly in Farming Simulator 25's graphics menu**.

The public build is a **single standalone `FS25_MFG_Unlocker.exe`**. Users do not need to copy scripts, install Python, or use NVIDIA Profile Inspector just to select 5X/6X.

Created by **Bartek16194** — https://github.com/Bartek16194

## What it does

- Adds **5X** and **6X** to FS25's DLSS Frame Generation menu.
- Makes FS25 save the selected values normally as `<dlssg>5X</dlssg>` or `<dlssg>6X</dlssg>` in `game.xml`.
- Enables FS25 development controls required to go above the game's normal FPS limiter:

```xml
<development>
    <controls>true</controls>
    <openDevConsole onWarnings="false" onErrors="false"/>
</development>
```

- Reads the actual game version from the game's `VERSION` file.
- Automatically finds `Documents\My Games\FarmingSimulator2025\game.xml` when possible.
- Creates backups before changing the game executable or `game.xml`.
- Provides **Restore Original** from the same GUI.
- Detects the installed NVIDIA GPU and only shows the Ada MFG helper workflow when it is relevant.

## Download / normal installation

For a normal user the installation is intentionally simple:

1. Download **`FS25_MFG_Unlocker.exe`** from Releases or Nexus Mods.
2. Run it.
3. Select the Farming Simulator 25 folder, `x64` folder, or `FarmingSimulator2025Game.exe` if it was not detected automatically.
4. Check the detected `game.xml` path. If it was not found, select it manually.
5. Click **ENABLE 5X / 6X + FPS UNLOCK**.
6. Start FS25 and select 5X or 6X in the normal graphics menu.

After a successful patch the **Enable** button is disabled and **Restore Original** becomes available.

## GPU compatibility

### GeForce RTX 50 series

RTX 50-series cards support NVIDIA Multi Frame Generation natively. The unlocker only needs to expose FS25's hidden 5X/6X modes; the Ada compatibility helper is not required.

### GeForce RTX 40 series

RTX 40-series cards require an Ada MFG compatibility solution to use the newer MFG modes. This project is designed to work with:

**Native DLSS MFG for Ada GPUs — Nexus Mods mod 2038**  
https://www.nexusmods.com/site/mods/2038?tab=description

If an RTX 40-series GPU is detected and the helper is missing, the program offers:

- **GET MOD 2038** — opens the original Nexus Mods page.
- **INSTALL DOWNLOADED FILE...** — select either the downloaded ZIP or its `version.dll`; the unlocker installs the DLL next to `FarmingSimulator2025Game.exe`.

The mod itself is **not bundled or mirrored**. It must be downloaded from its original Nexus Mods page.

### GeForce RTX 20 / 30 series

These GPUs do not provide native NVIDIA DLSS Frame Generation / Multi Frame Generation support. The RTX 40 Ada helper is therefore not offered.

## Tested version and other FS25 builds

The patch was developed and tested on:

**Farming Simulator 25 — 1.19.0.0**

The executable currently contains embedded patch layouts for:

- **1.19.0.0** — tested
- **1.20.0.0** — supported layout
- **1.21.0.0** — supported layout

The game build displayed in the GUI is read from the game's `VERSION` file; the actual patch layout is selected by checking the executable bytes. GIANTS moved several relevant functions and globals between builds, so each known layout is validated before patching.

There is intentionally no hard version-number lock. Unknown future builds can still use the EXPERIMENTAL path after an exact backup is created.

## Backups and Restore Original

Before modifying files, the unlocker creates its own backups. Restore is only enabled when a patched state or an unlocker-managed backup is detected.

The tool can restore:

- the original `FarmingSimulator2025Game.exe`,
- the original `game.xml`,
- an Ada `version.dll` installed through this utility, including restoration of a previously existing DLL when applicable.

Game updates can replace the patched executable. If that happens, simply run the latest unlocker again after verifying that the new FS25 build is supported by the compatibility scan.

## If 5X and 6X both behave like 6X

Check NVIDIA Profile Inspector. A previous driver-level DLSSG override can force a fixed multi-frame count regardless of what FS25 requests.

Reset the Farming Simulator 25 profile or set the DLSS-FG override values back to their defaults, then restart the game.

The unlocker itself does **not** require NVIDIA Profile Inspector.

## Standalone EXE design

`FS25_MFG_Unlocker.exe` is a native x64 Windows bootstrap with the actual PowerShell/WinForms patcher embedded inside it.

At runtime it extracts that embedded script into:

`%LOCALAPPDATA%\FS25MFGUnlocker\FS25_MFG_Unlocker.runtime.ps1`

and launches it with the Windows PowerShell included with Windows 10/11. The runtime script is kept there so the GUI can safely restart itself elevated through UAC when required. The next run overwrites the same file.

**For the end user this is still a one-file download:** only `FS25_MFG_Unlocker.exe` is required.

## Building from source

Source layout:

```text
src/
  FS25_MFG_Unlocker.ps1     # patching logic + WinForms GUI
  standalone_launcher.c     # native single-file bootstrap
  embedded_script.h         # generated embedded PS1 data

build/
  generate_embedded_header.py
  build-windows.cmd

.github/workflows/
  build.yml
```

### Local Windows build

Requirements:

- Windows 10/11 x64
- Python 3
- LLVM/Clang with `clang` and `lld-link`

Run:

```bat
build\build-windows.cmd
```

The finished file is created as:

```text
dist\FS25_MFG_Unlocker.exe
```

### GitHub Actions

The included `build.yml` rebuilds the embedded header, compiles the native x64 executable and uploads the standalone EXE plus its SHA-256 as a workflow artifact.

For public releases, attach **only `FS25_MFG_Unlocker.exe`** to the GitHub Release/Nexus main file. Keep the source code in the repository rather than making users download a source bundle to run the mod.

## Reporting an unsupported FS25 update

If a new Farming Simulator 25 version shows **Unknown layout**, include:

- the FS25 version shown by the unlocker,
- the version written in the game's `VERSION` file,
- the SHA-256 of `FarmingSimulator2025Game.exe`,
- whether the executable is original/verified by Steam.

Do not upload copyrighted GIANTS executables to a public issue.

## Notes

- This tool does not distribute any GIANTS Software executable.
- It modifies the user's own local copy and keeps a backup for restoration.
- The RTX 40 MFG helper is a separate third-party Nexus mod and remains the responsibility of its original author.
- Steam/game updates may restore the original executable and require reapplying the unlock.

## Author

**Bartek16194**  
GitHub: https://github.com/Bartek16194


## Experimental support for unknown builds

If a newer Farming Simulator 25 build no longer exactly matches an embedded layout, the unlocker shows how many signatures match and selects the **closest known template** for an optional EXPERIMENTAL attempt.

This may work when GIANTS changed unrelated code, but it can still make the game fail to start when the relevant functions moved. Before any experimental write, the tool creates a byte-for-byte backup and records its SHA-256. **RESTORE ORIGINAL** restores that exact pre-patch file.


## FS25 1.21 support

Version 1.21.0.0 has a dedicated pattern-mapped layout derived from the same stable anchors used by 1.19/1.20: the FrameInterpolationMode initializer, the `FRAME_INTERPOLATION_4X` enum registration block, and the three DLSS frame-interpolation clamp sites. Runtime validation is still recommended after every game update.
