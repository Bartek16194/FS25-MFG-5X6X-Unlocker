# Regression tests for the fail-closed game executable patch guard.
# Run with Windows PowerShell 5.1: powershell -NoProfile -File tests/patch-safety.Tests.ps1
$ErrorActionPreference = 'Stop'
$sourcePath = Join-Path $PSScriptRoot '..\src\FS25_MFG_Unlocker.ps1'
$source = [IO.File]::ReadAllText((Resolve-Path -LiteralPath $sourcePath).Path)
$tokens = $null
$parseErrors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseInput($source, [ref]$tokens, [ref]$parseErrors)
if ($parseErrors.Count -gt 0) {
    throw "Patcher PowerShell syntax errors: $($parseErrors -join '; ')"
}

# Load only the pure functions under test; never execute the GUI or game patcher.
foreach ($name in @('Hex-ToBytes', 'Test-BytesAt', 'Get-PatchDefinitionProbe', 'Test-TrustedPatch', 'Apply-PatchBytes', 'Get-BytesSHA256', 'Write-VerifiedLockedFile')) {
    $matching = @($ast.FindAll({
        param($node)
        $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $name
    }, $true))
    if ($matching.Count -ne 1) { throw "Expected one definition of $name, found $($matching.Count)." }
    . ([scriptblock]::Create($matching[0].Extent.Text))
}

function Assert([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

$trustedHash = ('A' * 64)
$def = @{
    Version = '1.21.0.0'
    OriginalHash = $trustedHash
    Patches = @(
        @{ Offset = 0; Old = 'AA'; New = 'BB' },
        @{ Offset = 1; Old = 'CC'; New = 'DD' }
    )
}
$version = @{ Version = '1.21.0.0' }

[byte[]]$unknownData = @(0x01, 0x02)
$unknown = Get-PatchDefinitionProbe $unknownData $def
Assert ($unknown.Old -eq 0 -and $unknown.Total -eq 2) 'Unknown layout must have 0/2 matches.'
Assert (-not (Test-TrustedPatch $unknown $version $trustedHash)) '0/2 signatures must be blocked.'

[byte[]]$knownData = @(0xAA, 0xCC)
$known = Get-PatchDefinitionProbe $knownData $def
Assert ($known.State -eq 'original-compatible') 'Original byte layout should be recognized.'
Assert (Test-TrustedPatch $known $version $trustedHash) 'Exactly verified build should be allowed.'
Assert (-not (Test-TrustedPatch $known @{ Version = '1.25.1.0' } $trustedHash)) 'Future game version must be blocked.'
Assert (-not (Test-TrustedPatch $known $version ('B' * 64))) 'Wrong executable SHA-256 must be blocked.'
Assert (-not (Test-TrustedPatch $known $version '')) 'Missing executable hash must be blocked.'

[byte[]]$patchedData = @(0xBB, 0xDD)
$patched = Get-PatchDefinitionProbe $patchedData $def
Assert (-not (Test-TrustedPatch $patched $version $trustedHash)) 'Already patched executable must be blocked.'

[byte[]]$mixedData = @(0xAA, 0xDD)
$mixed = Get-PatchDefinitionProbe $mixedData $def
Assert (-not (Test-TrustedPatch $mixed $version $trustedHash)) 'Partially patched executable must be blocked.'

# Existing writer must never overwrite unknown original bytes, regardless of caller.
$script:PatchDefinition = $def
[byte[]]$unexpected = @(0x01, 0x02)
$threw = $false
try { $null = Apply-PatchBytes $unexpected $true } catch { $threw = $true }
Assert $threw 'Write function must reject byte mismatch.'

Assert (-not $source.Contains('function Apply-PatchBytesForce')) 'Unsafe force-write function must not exist.'
Assert (-not $source.Contains('$forceMode')) 'Unsafe force-mode branching must not exist.'
Assert ($source.Contains('Test-TrustedPatch $liveProbe $versionInfo $beforeHash')) 'Write-time trust gate must exist.'
Assert ($source.Contains('Write-VerifiedLockedFile $script:CurrentExe $beforeHash')) 'Locked EXE write must exist.'
Assert ($source.Contains('Write-VerifiedLockedFile $script:CurrentExe $patchedExeHash')) 'Locked conditional EXE rollback must exist.'
Assert ($source.Contains('Write-VerifiedLockedFile $script:CurrentGameXml $beforeXmlHash')) 'Locked XML write must exist.'

# Synthetic local files only: never open, modify, or test-write the installed game EXE.
$folder = Join-Path ([IO.Path]::GetTempPath()) ("FS25LockedTest_" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $folder | Out-Null
try {
    $sample = Join-Path $folder 'sample.bin'
    [byte[]]$original = @(1, 2, 3, 4)
    [byte[]]$patchedBytes = @(5, 6, 7, 8)
    $originalHash = Get-BytesSHA256 $original
    $patchedHash = Get-BytesSHA256 $patchedBytes
    [IO.File]::WriteAllBytes($sample, $original)
    Write-VerifiedLockedFile $sample $originalHash $patchedBytes
    Assert ((Get-BytesSHA256 ([IO.File]::ReadAllBytes($sample))) -eq $patchedHash) 'Verified writer must commit expected bytes.'

    # A replaced/updated game executable cannot be overwritten with a stale patch.
    [byte[]]$external = @(10, 11, 12, 13)
    [IO.File]::WriteAllBytes($sample, $external)
    $refused = $false
    try { Write-VerifiedLockedFile $sample $originalHash $patchedBytes } catch { $refused = $true }
    Assert $refused 'Writer must refuse a changed target before writing.'
    Assert ((Get-BytesSHA256 ([IO.File]::ReadAllBytes($sample))) -eq (Get-BytesSHA256 $external)) 'Refused write must preserve new content.'

    # If the update takes place after patching, rollback must not overwrite it.
    $refused = $false
    try { Write-VerifiedLockedFile $sample $patchedHash $original } catch { $refused = $true }
    Assert $refused 'Conditional rollback must refuse a replaced target.'
    Assert ((Get-BytesSHA256 ([IO.File]::ReadAllBytes($sample))) -eq (Get-BytesSHA256 $external)) 'Refused rollback must preserve new content.'

    # A concurrent exclusive handle must reject the write instead of racing.
    $handle = [IO.File]::Open($sample, [IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
    try {
        $refused = $false
        try { Write-VerifiedLockedFile $sample (Get-BytesSHA256 $external) $patchedBytes } catch { $refused = $true }
        Assert $refused 'Another file lock must prevent the write.'
    } finally { $handle.Dispose() }
    Assert ((Get-BytesSHA256 ([IO.File]::ReadAllBytes($sample))) -eq (Get-BytesSHA256 $external)) 'Locked writer must not change the file.'
} finally {
    Remove-Item -LiteralPath $folder -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Host 'PASS: fail-closed patch eligibility, layout and write regression tests.'
