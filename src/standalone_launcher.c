/*
 * FS25 DLSS MFG 5X/6X Unlocker - standalone launcher
 *
 * This tiny native Windows bootstrap contains the PowerShell/WinForms patcher
 * as an embedded byte array. At runtime it writes the script to the app's
 * private LocalAppData directory and launches Windows PowerShell 5.1.
 *
 * It deliberately uses no CRT or Windows SDK import libraries. Win32 APIs are
 * resolved from loaded PE modules through the PEB so the project can be built
 * with clang + lld-link in the GitHub Actions workflow without bundling DLLs.
 */

typedef unsigned char  BYTE;
typedef unsigned short WORD;
typedef unsigned short WCHAR;
typedef unsigned int   DWORD;
typedef int            BOOL;
typedef unsigned long long QWORD;
typedef unsigned long long SIZE_T;
typedef void*          HANDLE;
typedef void*          LPVOID;
typedef const void*    LPCVOID;
typedef WCHAR*         LPWSTR;
typedef const WCHAR*   LPCWSTR;

#define TRUE 1
#define FALSE 0
#define INVALID_HANDLE_VALUE ((HANDLE)(QWORD)-1)
#define GENERIC_WRITE        0x40000000u
#define FILE_SHARE_READ      0x00000001u
#define CREATE_ALWAYS        2u
#define FILE_ATTRIBUTE_NORMAL 0x00000080u
#define INFINITE             0xFFFFFFFFu
#define MAX_PATHBUF          32768

#include "embedded_script.h"

typedef struct _STARTUPINFOW {
    DWORD cb;
    LPWSTR lpReserved;
    LPWSTR lpDesktop;
    LPWSTR lpTitle;
    DWORD dwX;
    DWORD dwY;
    DWORD dwXSize;
    DWORD dwYSize;
    DWORD dwXCountChars;
    DWORD dwYCountChars;
    DWORD dwFillAttribute;
    DWORD dwFlags;
    WORD wShowWindow;
    WORD cbReserved2;
    BYTE* lpReserved2;
    HANDLE hStdInput;
    HANDLE hStdOutput;
    HANDLE hStdError;
} STARTUPINFOW;

typedef struct _PROCESS_INFORMATION {
    HANDLE hProcess;
    HANDLE hThread;
    DWORD dwProcessId;
    DWORD dwThreadId;
} PROCESS_INFORMATION;

typedef DWORD (*PFN_GetEnvironmentVariableW)(LPCWSTR, LPWSTR, DWORD);
typedef BOOL (*PFN_CreateDirectoryW)(LPCWSTR, LPVOID);
typedef HANDLE (*PFN_CreateFileW)(LPCWSTR, DWORD, DWORD, LPVOID, DWORD, DWORD, HANDLE);
typedef BOOL (*PFN_WriteFile)(HANDLE, LPCVOID, DWORD, DWORD*, LPVOID);
typedef BOOL (*PFN_CloseHandle)(HANDLE);
typedef BOOL (*PFN_CreateProcessW)(LPCWSTR, LPWSTR, LPVOID, LPVOID, BOOL, DWORD, LPVOID, LPCWSTR, STARTUPINFOW*, PROCESS_INFORMATION*);
typedef DWORD (*PFN_WaitForSingleObject)(HANDLE, DWORD);
typedef void (*PFN_ExitProcess)(DWORD);
typedef HANDLE (*PFN_LoadLibraryW)(LPCWSTR);
typedef int (*PFN_MessageBoxW)(HANDLE, LPCWSTR, LPCWSTR, unsigned int);

static WCHAR g_dir[MAX_PATHBUF];
static WCHAR g_script_path[MAX_PATHBUF];
static WCHAR g_cmd[MAX_PATHBUF];
static STARTUPINFOW g_si;
static PROCESS_INFORMATION g_pi;

#if defined(_MSC_VER)
unsigned long long __readgsqword(unsigned long Offset);
#pragma intrinsic(__readgsqword)
static void* read_peb(void) {
    return (void*)__readgsqword(0x60);
}
#else
static void* read_peb(void) {
    void* p;
    __asm__ volatile ("movq %%gs:0x60, %0" : "=r"(p));
    return p;
}
#endif

static BYTE lower_ascii(BYTE c) {
    if (c >= 'A' && c <= 'Z') return (BYTE)(c + ('a' - 'A'));
    return c;
}

static int ascii_eq(const char* a, const char* b) {
    unsigned int i = 0;
    while (a[i] && b[i]) {
        if (a[i] != b[i]) return 0;
        i++;
    }
    return a[i] == 0 && b[i] == 0;
}

static int module_name_matches(WCHAR* wide, WORD bytes, const char* ascii_no_ext) {
    unsigned int wlen = (unsigned int)(bytes / 2);
    unsigned int alen = 0;
    while (ascii_no_ext[alen]) alen++;
    if (wlen < alen) return 0;
    for (unsigned int i = 0; i < alen; i++) {
        BYTE wc = (BYTE)(wide[i] & 0xFF);
        if (lower_ascii(wc) != lower_ascii((BYTE)ascii_no_ext[i])) return 0;
    }
    if (wlen == alen) return 1;
    return wide[alen] == '.' || wide[alen] == 0;
}

static void* find_loaded_module(const char* ascii_no_ext) {
    BYTE* peb = (BYTE*)read_peb();
    if (!peb) return 0;
    BYTE* ldr = *(BYTE**)(peb + 0x18);
    if (!ldr) return 0;
    BYTE* head = ldr + 0x20; /* InMemoryOrderModuleList */
    BYTE* cur = *(BYTE**)head;
    unsigned int guard = 0;
    while (cur && cur != head && guard++ < 128) {
        BYTE* entry = cur - 0x10; /* InMemoryOrderLinks offset */
        void* dllBase = *(void**)(entry + 0x30);
        WORD nameLen = *(WORD*)(entry + 0x58);
        WCHAR* nameBuf = *(WCHAR**)(entry + 0x60);
        if (dllBase && nameBuf && module_name_matches(nameBuf, nameLen, ascii_no_ext)) return dllBase;
        cur = *(BYTE**)cur;
    }
    return 0;
}

static void* resolve_export_internal(void* module, const char* name, int depth);

static void* resolve_forwarder(const char* fwd, int depth) {
    char mod[64];
    char fn[128];
    unsigned int i = 0, j = 0;
    while (fwd[i] && fwd[i] != '.' && i < sizeof(mod)-1) { mod[i] = fwd[i]; i++; }
    mod[i] = 0;
    if (fwd[i] != '.') return 0;
    i++;
    while (fwd[i] && j < sizeof(fn)-1) { fn[j++] = fwd[i++]; }
    fn[j] = 0;
    if (!fn[0] || fn[0] == '#') return 0;
    void* m = find_loaded_module(mod);
    if (!m) return 0;
    return resolve_export_internal(m, fn, depth + 1);
}

static void* resolve_export_internal(void* module, const char* name, int depth) {
    if (!module || depth > 8) return 0;
    BYTE* base = (BYTE*)module;
    if (*(WORD*)base != 0x5A4D) return 0;
    DWORD peoff = *(DWORD*)(base + 0x3C);
    BYTE* nt = base + peoff;
    if (*(DWORD*)nt != 0x00004550u) return 0;
    BYTE* opt = nt + 24;
    WORD magic = *(WORD*)opt;
    if (magic != 0x20B) return 0;
    DWORD expRva = *(DWORD*)(opt + 0x70);
    DWORD expSize = *(DWORD*)(opt + 0x74);
    if (!expRva) return 0;
    BYTE* exp = base + expRva;
    DWORD nNames = *(DWORD*)(exp + 0x18);
    DWORD funcsRva = *(DWORD*)(exp + 0x1C);
    DWORD namesRva = *(DWORD*)(exp + 0x20);
    DWORD ordsRva = *(DWORD*)(exp + 0x24);
    DWORD* funcs = (DWORD*)(base + funcsRva);
    DWORD* names = (DWORD*)(base + namesRva);
    WORD* ords = (WORD*)(base + ordsRva);
    for (DWORD i = 0; i < nNames; i++) {
        const char* nm = (const char*)(base + names[i]);
        if (ascii_eq(nm, name)) {
            DWORD rva = funcs[ords[i]];
            if (rva >= expRva && rva < expRva + expSize) {
                return resolve_forwarder((const char*)(base + rva), depth);
            }
            return base + rva;
        }
    }
    return 0;
}

static void* resolve_export(void* module, const char* name) {
    return resolve_export_internal(module, name, 0);
}

static unsigned int wlen(const WCHAR* s) {
    unsigned int n = 0;
    while (s && s[n]) n++;
    return n;
}

static int wappend(WCHAR* dst, unsigned int cap, const WCHAR* src) {
    unsigned int n = wlen(dst), i = 0;
    if (!src) return 0;
    while (src[i] && n + i + 1 < cap) { dst[n+i] = src[i]; i++; }
    dst[n+i] = 0;
    return src[i] == 0;
}

static void append_uint(WCHAR* dst, unsigned int cap, DWORD v) {
    WCHAR tmp[16];
    unsigned int n = 0;
    if (v == 0) tmp[n++] = '0';
    while (v && n < 15) { tmp[n++] = (WCHAR)('0' + (v % 10)); v /= 10; }
    unsigned int d = wlen(dst);
    while (n && d + 1 < cap) dst[d++] = tmp[--n];
    dst[d] = 0;
}

static void show_error(PFN_LoadLibraryW LoadLibraryW, const WCHAR* text) {
    if (!LoadLibraryW) return;
    HANDLE user = LoadLibraryW((const WCHAR*)L"user32.dll");
    if (!user) return;
    PFN_MessageBoxW MessageBoxW = (PFN_MessageBoxW)resolve_export(user, "MessageBoxW");
    if (MessageBoxW) MessageBoxW(0, text, (const WCHAR*)L"FS25 MFG Unlocker", 0x10u);
}

void WinMainCRTStartup(void) {
    void* k32 = find_loaded_module("kernel32");
    if (!k32) for (;;) {}

    PFN_GetEnvironmentVariableW GetEnvironmentVariableW = (PFN_GetEnvironmentVariableW)resolve_export(k32, "GetEnvironmentVariableW");
    PFN_CreateDirectoryW CreateDirectoryW = (PFN_CreateDirectoryW)resolve_export(k32, "CreateDirectoryW");
    PFN_CreateFileW CreateFileW = (PFN_CreateFileW)resolve_export(k32, "CreateFileW");
    PFN_WriteFile WriteFile = (PFN_WriteFile)resolve_export(k32, "WriteFile");
    PFN_CloseHandle CloseHandle = (PFN_CloseHandle)resolve_export(k32, "CloseHandle");
    PFN_CreateProcessW CreateProcessW = (PFN_CreateProcessW)resolve_export(k32, "CreateProcessW");
    PFN_WaitForSingleObject WaitForSingleObject = (PFN_WaitForSingleObject)resolve_export(k32, "WaitForSingleObject");
    PFN_ExitProcess ExitProcess = (PFN_ExitProcess)resolve_export(k32, "ExitProcess");
    PFN_LoadLibraryW LoadLibraryW = (PFN_LoadLibraryW)resolve_export(k32, "LoadLibraryW");

    if (!ExitProcess) for (;;) {}
    if (!GetEnvironmentVariableW || !CreateDirectoryW || !CreateFileW || !WriteFile || !CloseHandle || !CreateProcessW || !WaitForSingleObject) {
        show_error(LoadLibraryW, (const WCHAR*)L"Could not resolve required Windows APIs.");
        ExitProcess(2);
    }

    DWORD n = GetEnvironmentVariableW((const WCHAR*)L"LOCALAPPDATA", g_dir, MAX_PATHBUF);
    if (!n || n >= MAX_PATHBUF - 128) {
        show_error(LoadLibraryW, (const WCHAR*)L"LOCALAPPDATA could not be resolved.");
        ExitProcess(3);
    }
    if (!wappend(g_dir, MAX_PATHBUF, (const WCHAR*)L"\\FS25MFGUnlocker")) ExitProcess(4);
    CreateDirectoryW(g_dir, 0); /* ERROR_ALREADY_EXISTS is fine */

    g_script_path[0] = 0;
    if (!wappend(g_script_path, MAX_PATHBUF, g_dir)) ExitProcess(5);
    if (!wappend(g_script_path, MAX_PATHBUF, (const WCHAR*)L"\\FS25_MFG_Unlocker.runtime.ps1")) ExitProcess(5);

    HANDLE f = CreateFileW(g_script_path, GENERIC_WRITE, FILE_SHARE_READ, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    if (f == INVALID_HANDLE_VALUE || !f) {
        show_error(LoadLibraryW, (const WCHAR*)L"Could not create the embedded runtime script in LocalAppData.");
        ExitProcess(6);
    }
    DWORD written = 0;
    BOOL ok = WriteFile(f, g_embedded_script, (DWORD)g_embedded_script_size, &written, 0);
    CloseHandle(f);
    if (!ok || written != (DWORD)g_embedded_script_size) {
        show_error(LoadLibraryW, (const WCHAR*)L"Could not write the embedded runtime script.");
        ExitProcess(7);
    }

    g_cmd[0] = 0;
    wappend(g_cmd, MAX_PATHBUF, (const WCHAR*)L"powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -STA -File \"");
    wappend(g_cmd, MAX_PATHBUF, g_script_path);
    wappend(g_cmd, MAX_PATHBUF, (const WCHAR*)L"\"");

    g_si.cb = (DWORD)sizeof(STARTUPINFOW);
    if (!CreateProcessW(0, g_cmd, 0, 0, FALSE, 0, 0, 0, &g_si, &g_pi)) {
        show_error(LoadLibraryW, (const WCHAR*)L"Windows PowerShell could not be started.");
        ExitProcess(8);
    }

    if (g_pi.hThread) CloseHandle(g_pi.hThread);
    WaitForSingleObject(g_pi.hProcess, INFINITE);
    if (g_pi.hProcess) CloseHandle(g_pi.hProcess);

    /* Deliberately keep the extracted script in LocalAppData. The GUI can
       restart itself elevated using $PSCommandPath; deleting it here creates
       a race with UAC. The next launch overwrites the same runtime file. */
    ExitProcess(0);
}
