from pathlib import Path

root = Path(__file__).resolve().parents[1]
src = root / "src" / "FS25_MFG_Unlocker.ps1"
out = root / "src" / "embedded_script.h"
data = src.read_bytes()

with out.open("w", encoding="ascii", newline="\n") as f:
    f.write("/* Auto-generated from FS25_MFG_Unlocker.ps1. Do not edit by hand. */\n")
    f.write("static const unsigned char g_embedded_script[] = {\n")
    for i in range(0, len(data), 16):
        chunk = data[i:i+16]
        f.write("    " + ", ".join(f"0x{b:02X}" for b in chunk) + ",\n")
    f.write("};\n")
    f.write(f"static const unsigned long long g_embedded_script_size = {len(data)}ULL;\n")

print(f"Generated {out} from {src} ({len(data)} bytes)")
