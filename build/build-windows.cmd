@echo off
setlocal
cd /d "%~dp0\.."

where python >nul 2>nul || (echo Python 3 is required to generate the embedded script header.& exit /b 1)
where clang >nul 2>nul || (echo clang is required. Install LLVM or use the GitHub Actions workflow.& exit /b 1)
where lld-link >nul 2>nul || (echo lld-link is required. Install LLVM or use the GitHub Actions workflow.& exit /b 1)

python build\generate_embedded_header.py || exit /b 1
if not exist dist mkdir dist

clang --target=x86_64-pc-windows-msvc -fshort-wchar -ffreestanding -fno-stack-protector -fno-builtin -Oz -c src\standalone_launcher.c -o dist\standalone_launcher.obj || exit /b 1
lld-link dist\standalone_launcher.obj /entry:WinMainCRTStartup /subsystem:windows /nodefaultlib /machine:x64 /out:dist\FS25_MFG_Unlocker.exe || exit /b 1

del /q dist\standalone_launcher.obj >nul 2>nul
echo.
echo Built: dist\FS25_MFG_Unlocker.exe
