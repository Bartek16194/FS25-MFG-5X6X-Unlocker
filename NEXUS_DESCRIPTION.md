# FS25 DLSS MFG 5X / 6X Unlocker

Unlocks **5X and 6X DLSS Multi Frame Generation directly in Farming Simulator 25's graphics menu** and enables the required FS25 development controls for FPS above the normal in-game limiter.

## Installation

Download **FS25_MFG_Unlocker.exe**, run it, select your Farming Simulator 25 installation if necessary, then click **ENABLE 5X / 6X + FPS UNLOCK**.

That's it. The public download is a **single standalone EXE** — no scripts or extra files need to be placed next to it.

The tool automatically:

- reads the game build from the FS25 `VERSION` file,
- finds `Documents\My Games\FarmingSimulator2025\game.xml`,
- unlocks 5X and 6X in the normal FS25 graphics menu,
- enables development controls required for FPS above the normal limiter,
- creates backups and provides **Restore Original**.

## RTX 40 series

RTX 40-series users need an Ada MFG compatibility helper. If it is not detected, the unlocker can open and install the user-downloaded files from:

Native DLSS MFG for Ada GPUs — Nexus Mods mod 2038  
https://www.nexusmods.com/site/mods/2038?tab=description

The third-party mod is **not included** in this download. Download it from its original Nexus page, then use **INSTALL DOWNLOADED FILE...** and select its ZIP or `version.dll`.

RTX 50-series users do not need this helper. RTX 20/30-series cards do not support native NVIDIA DLSS Frame Generation / Multi Frame Generation.

## Version support

Developed and tested on **FS25 1.19.0.0**. Dedicated executable layouts for **1.20.0.0** and **1.21.0.0** are also included.

The unlocker is not hard-locked by the version number. It checks the executable against its embedded layouts and automatically selects the correct one. Unknown future versions can still be attempted through the clearly marked EXPERIMENTAL path after a verified backup is created.

## Troubleshooting

If 5X and 6X both behave like 6X, reset any previous DLSSG override in NVIDIA Profile Inspector. A driver-level fixed multi-frame override takes priority over the value selected by FS25.

Source code and documentation:  
https://github.com/Bartek16194
