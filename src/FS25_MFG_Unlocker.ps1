param(
    [string]$GamePath = "",
    [string]$GameXmlPath = ""
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$AppName = "FS25 DLSS MFG 5X/6X Unlocker"
$AppVersion = "1.0.0"
$TestedVersion = "1.19.0.0"
$TestedOriginalHash = "66271CD30C35ED93571A790D15E20FEF97A3F018FCA08C3A1221C6B024C232C6"
$TestedPatchedHash  = "D8FE54BD82B7F4EE6632CD99DAE188CFB16C1A1CD9F8D624B1B59909BFF1379B"
$SupportedVersions = @("1.19.0.0","1.20.0.0","1.21.0.0")
$AuthorUrl = "https://github.com/Bartek16194"
$MfgModUrl = "https://www.nexusmods.com/site/mods/2038?tab=description"
$SettingsDir = Join-Path $env:LOCALAPPDATA "FS25MFGUnlocker"
$SettingsFile = Join-Path $SettingsDir "lastpath.txt"
$GameXmlSettingsFile = Join-Path $SettingsDir "lastgamexml.txt"

$PatchDefinitions = @(
@{
    Version = "1.21.0.0"
    OriginalHash = "0A024D593DFF968DF60DF0129590321D93F3AC303E60DEEBE5347E40D223546C"
    PatchedHash = "A39B49EB1050E1950F4FB018A6AD587CDA3F33A35EB05F96C386DC8C363CB280"
    Name = "FS25 MFG 5X/6X patch layout 1.21 (pattern-mapped)"
    Patches = @(
            @{ Offset = 0x46900; Old = "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"; New = "4C8D05F9000000BA04000000488D4C2420E81A1539004C8BC04C8B0D30B80D014C3B0D31B80D0174338B08418909488B501848897818488B481048897810488B400849897808498941084989491049895118488305F6B70D0120EB0F498BD1488D0DE2B70D01E855433900488D4C2428E86BD105004C8D0587000000BA05000000488D4C2420E8A51439004C8BC04C8B0DBBB70D014C3B0DBCB70D0174338B08418909488B501848897818488B481048897810488B40084989780849894108498949104989511848830581B70D0120EB0F498BD1488D0D6DB70D01E8E0423900488D4C2428E8F6D00500C7056CB70D0106000000488D0D0586DC00E91CBE0300355800365800" },
            @{ Offset = 0x46B00; Old = "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"; New = "488D0D99961602E804C50E004C8D0539000000BA04000000488BC8E870F50D00488D0D79961602E8E4C40E004C8D0530000000BA05000000488BC8E850F50D00488D0D59961602E9FF1B47004652414D455F494E544552504F4C4154494F4E5F3558004652414D455F494E544552504F4C4154494F4E5F365800" },
            @{ Offset = 0x82815; Old = "488D0DE4C7D800"; New = "E9E640FCFF9090" },
            @{ Offset = 0x4B8744; Old = "488D0D557ACF01"; New = "E9B7E3B8FF9090" },
            @{ Offset = 0x4EF88F; Old = "03"; New = "05" },
            @{ Offset = 0x4EFA16; Old = "03"; New = "05" },
            @{ Offset = 0x4EFC33; Old = "03"; New = "05" }
        )
},
@{
    Version = "1.20.0.0"
    OriginalHash = "6A1C6C6C97B190AB218E1490A0335F92DFAFD5D3AF8D65CEDFFF17B4DD6A3DF4"
    PatchedHash = "4423499A5E4042EC063C19A49413597C8F2EFECF6D76C1550DF4CEC132102CC5"
    Name = "FS25 MFG 5X/6X patch layout 1.20"
    Patches = @(
            @{ Offset = 0x46900; Old = "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"; New = "4C8D05F9000000BA04000000488D4C2420E8EA0939004C8BC04C8B0D30B80D014C3B0D31B80D0174338B08418909488B501848897818488B481048897810488B400849897808498941084989491049895118488305F6B70D0120EB0F498BD1488D0DE2B70D01E825383900488D4C2428E85BD105004C8D0587000000BA05000000488D4C2420E8750939004C8BC04C8B0DBBB70D014C3B0DBCB70D0174338B08418909488B501848897818488B481048897810488B40084989780849894108498949104989511848830581B70D0120EB0F498BD1488D0D6DB70D01E8B0373900488D4C2428E8E6D00500C7056CB70D0106000000488D0DE58EDC00E91CBE0300355800365800" },
            @{ Offset = 0x46B00; Old = "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"; New = "488D0D79961602E844C00E004C8D0539000000BA04000000488BC8E810EF0D00488D0D59961602E824C00E004C8D0530000000BA05000000488BC8E8F0EE0D00488D0D39961602E9EFFF46004652414D455F494E544552504F4C4154494F4E5F3558004652414D455F494E544552504F4C4154494F4E5F365800" },
            @{ Offset = 0x82815; Old = "488D0DC4D0D800"; New = "E9E640FCFF9090" },
            @{ Offset = 0x4B6B34; Old = "488D0D4596CF01"; New = "E9C7FFB8FF9090" },
            @{ Offset = 0x4EDBEF; Old = "03"; New = "05" },
            @{ Offset = 0x4EDD76; Old = "03"; New = "05" },
            @{ Offset = 0x4EDF93; Old = "03"; New = "05" }
        )
},
@{
    Version = "1.19.0.0"
    OriginalHash = "66271CD30C35ED93571A790D15E20FEF97A3F018FCA08C3A1221C6B024C232C6"
    PatchedHash = "D8FE54BD82B7F4EE6632CD99DAE188CFB16C1A1CD9F8D624B1B59909BFF1379B"
    Name = "FS25 MFG 5X/6X patch layout"
    Patches = @(
            @{ Offset = 0x46900; Old = "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"; New = "4C8D05F9000000BA04000000488D4C2420E89A0739004C8BC04C8B0D30FA0C014C3B0D31FA0C0174338B08418909488B501848897818488B481048897810488B400849897808498941084989491049895118488305F6F90C0120EB0F498BD1488D0DE2F90C01E8D5353900488D4C2428E8FBD005004C8D0587000000BA05000000488D4C2420E8250739004C8BC04C8B0DBBF90C014C3B0DBCF90C0174338B08418909488B501848897818488B481048897810488B40084989780849894108498949104989511848830581F90C0120EB0F498BD1488D0D6DF90C01E860353900488D4C2428E886D00500C7056CF90C0106000000488D0D857DDC00E91CBE0300355800365800" },
            @{ Offset = 0x46B00; Old = "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"; New = "488D0DA9D61502E864BF0E004C8D0539000000BA04000000488BC8E830EE0D00488D0D89D61502E844BF0E004C8D0530000000BA05000000488BC8E810EE0D00488D0D69D61502E91AFD46004652414D455F494E544552504F4C4154494F4E5F3558004652414D455F494E544552504F4C4154494F4E5F365800" },
            @{ Offset = 0x82815; Old = "488D0D64BFD800"; New = "E9E640FCFF9090" },
            @{ Offset = 0x4B685F; Old = "488D0D4AD9CE01"; New = "E99C02B9FF9090" },
            @{ Offset = 0x4ED91F; Old = "03"; New = "05" },
            @{ Offset = 0x4EDAA6; Old = "03"; New = "05" },
            @{ Offset = 0x4EDCC3; Old = "03"; New = "05" }
        )
}
)
$script:PatchDefinition = $PatchDefinitions[0]

function Hex-ToBytes([string]$Hex) {
    if (($Hex.Length % 2) -ne 0) { throw "Invalid hex data." }
    [byte[]]$bytes = New-Object byte[] ($Hex.Length / 2)
    for ($i = 0; $i -lt $bytes.Length; $i++) {
        $bytes[$i] = [Convert]::ToByte($Hex.Substring($i * 2, 2), 16)
    }
    Write-Output -NoEnumerate $bytes
}

function Get-SHA256([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant()
}

function Resolve-GameExe([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
    $Path = [Environment]::ExpandEnvironmentVariables($Path.Trim('"').Trim())
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        if ([IO.Path]::GetFileName($Path) -ieq "FarmingSimulator2025Game.exe") { return (Resolve-Path -LiteralPath $Path).Path }
        return $null
    }
    $candidates = @(
        (Join-Path $Path "FarmingSimulator2025Game.exe"),
        (Join-Path $Path "x64\FarmingSimulator2025Game.exe")
    )
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return (Resolve-Path -LiteralPath $candidate).Path }
    }
    return $null
}

function Get-GameRootFromExe([string]$ExePath) {
    if ([string]::IsNullOrWhiteSpace($ExePath)) { return $null }
    try {
        $exeFolder = Split-Path -Parent $ExePath
        if ((Split-Path -Leaf $exeFolder) -ieq 'x64') {
            return (Split-Path -Parent $exeFolder)
        }
        if (Test-Path -LiteralPath (Join-Path $exeFolder 'VERSION') -PathType Leaf) { return $exeFolder }
        $parent = Split-Path -Parent $exeFolder
        if ($parent -and (Test-Path -LiteralPath (Join-Path $parent 'VERSION') -PathType Leaf)) { return $parent }
    } catch {}
    return $null
}

function Get-GameVersionInfo([string]$ExePath) {
    $root = Get-GameRootFromExe $ExePath
    if (-not $root) { return @{ Version=$null; VersionFile=$null; Root=$null } }
    $versionFile = Join-Path $root 'VERSION'
    if (-not (Test-Path -LiteralPath $versionFile -PathType Leaf)) {
        return @{ Version=$null; VersionFile=$versionFile; Root=$root }
    }
    try {
        $raw = [IO.File]::ReadAllText($versionFile).Trim()
        $m = [regex]::Match($raw, '(?<!\d)\d+\.\d+\.\d+\.\d+(?!\d)')
        $version = if ($m.Success) { $m.Value } elseif ($raw.Length -gt 0) { ($raw -split "`r?`n")[0].Trim() } else { $null }
        return @{ Version=$version; VersionFile=$versionFile; Root=$root }
    } catch {
        return @{ Version=$null; VersionFile=$versionFile; Root=$root }
    }
}

function Get-DefaultGameXmlPath {
    $candidates = New-Object System.Collections.Generic.List[string]
    try {
        $docs = [Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments)
        if ($docs) { $candidates.Add((Join-Path $docs 'My Games\FarmingSimulator2025\game.xml')) }
    } catch {}
    if ($env:USERPROFILE) { $candidates.Add((Join-Path $env:USERPROFILE 'Documents\My Games\FarmingSimulator2025\game.xml')) }
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return (Resolve-Path -LiteralPath $candidate).Path }
    }
    if ($candidates.Count -gt 0) { return $candidates[0] }
    return $null
}

function Resolve-GameXml([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
    $Path = [Environment]::ExpandEnvironmentVariables($Path.Trim('"').Trim())
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        if ([IO.Path]::GetFileName($Path) -ieq 'game.xml') { return (Resolve-Path -LiteralPath $Path).Path }
        return $null
    }
    if (Test-Path -LiteralPath $Path -PathType Container) {
        $candidate = Join-Path $Path 'game.xml'
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return (Resolve-Path -LiteralPath $candidate).Path }
    }
    return $null
}

function Get-DevControlsState([string]$GameXml) {
    if ([string]::IsNullOrWhiteSpace($GameXml) -or -not (Test-Path -LiteralPath $GameXml -PathType Leaf)) { return 'missing' }
    try {
        $doc = New-Object System.Xml.XmlDocument
        $doc.PreserveWhitespace = $true
        $doc.Load($GameXml)
        $dev = $doc.SelectSingleNode('/game/development')
        if (-not $dev) { return 'needs-change' }
        $controls = $dev.SelectSingleNode('controls')
        $console = $dev.SelectSingleNode('openDevConsole')
        $controlsOk = ($controls -and $controls.InnerText.Trim().ToLowerInvariant() -eq 'true')
        $consoleOk = ($console -and $console.GetAttribute('onWarnings').ToLowerInvariant() -eq 'false' -and $console.GetAttribute('onErrors').ToLowerInvariant() -eq 'false')
        if ($controlsOk -and $consoleOk) { return 'enabled' }
        return 'needs-change'
    } catch { return 'invalid' }
}

function Write-DevControlsUnlock([string]$SourcePath, [string]$DestinationPath) {
    $doc = New-Object System.Xml.XmlDocument
    $doc.PreserveWhitespace = $true
    $doc.Load($SourcePath)
    $root = $doc.SelectSingleNode('/game')
    if (-not $root) { throw 'game.xml does not contain a <game> root element.' }

    $dev = $doc.SelectSingleNode('/game/development')
    if (-not $dev) {
        $dev = $doc.CreateElement('development')
        $controls = $doc.CreateElement('controls')
        $controls.InnerText = 'true'
        $console = $doc.CreateElement('openDevConsole')
        [void]$console.SetAttribute('onWarnings','false')
        [void]$console.SetAttribute('onErrors','false')

        [void]$dev.AppendChild($doc.CreateWhitespace("`r`n        "))
        [void]$dev.AppendChild($controls)
        [void]$dev.AppendChild($doc.CreateWhitespace("`r`n        "))
        [void]$dev.AppendChild($console)
        [void]$dev.AppendChild($doc.CreateWhitespace("`r`n    "))

        $last = $root.LastChild
        if ($last -and ($last.NodeType -eq [System.Xml.XmlNodeType]::Whitespace -or $last.NodeType -eq [System.Xml.XmlNodeType]::SignificantWhitespace)) {
            [void]$root.InsertBefore($doc.CreateWhitespace("`r`n    "), $last)
            [void]$root.InsertBefore($dev, $last)
        } else {
            [void]$root.AppendChild($doc.CreateWhitespace("`r`n    "))
            [void]$root.AppendChild($dev)
            [void]$root.AppendChild($doc.CreateWhitespace("`r`n"))
        }
    } else {
        $controls = $dev.SelectSingleNode('controls')
        if (-not $controls) {
            $controls = $doc.CreateElement('controls')
            [void]$dev.PrependChild($controls)
        }
        $controls.InnerText = 'true'

        $console = $dev.SelectSingleNode('openDevConsole')
        if (-not $console) {
            $console = $doc.CreateElement('openDevConsole')
            [void]$dev.AppendChild($console)
        }
        [void]$console.SetAttribute('onWarnings','false')
        [void]$console.SetAttribute('onErrors','false')
    }

    $doc.Save($DestinationPath)
    if ((Get-DevControlsState $DestinationPath) -ne 'enabled') { throw 'game.xml validation failed after enabling development controls.' }
}

function Test-BytesAt([byte[]]$Data, [int64]$Offset, [string]$Hex) {
    [byte[]]$expected = Hex-ToBytes $Hex
    if ($Offset -lt 0 -or $Offset + $expected.Length -gt $Data.Length) { return $false }
    for ($i=0; $i -lt $expected.Length; $i++) {
        if ($Data[$Offset+$i] -ne $expected[$i]) { return $false }
    }
    return $true
}

function Get-PatchDefinitionProbe([byte[]]$Data, $Definition) {
    $oldCount = 0; $newCount = 0; $total = $Definition.Patches.Count
    foreach ($p in $Definition.Patches) {
        if (Test-BytesAt $Data $p.Offset $p.Old) { $oldCount++ }
        elseif (Test-BytesAt $Data $p.Offset $p.New) { $newCount++ }
    }
    $state = 'incompatible'
    if ($oldCount -eq $total) { $state = 'original-compatible' }
    elseif ($newCount -eq $total) { $state = 'patched-compatible' }
    elseif (($oldCount + $newCount) -eq $total -and $newCount -gt 0) { $state = 'mixed' }
    return @{ Definition=$Definition; State=$state; Old=$oldCount; New=$newCount; Total=$total }
}

function Select-BestPatchDefinition([string]$ExePath) {
    try { [byte[]]$data = [IO.File]::ReadAllBytes($ExePath) } catch { return $null }
    $probes = @()
    foreach ($def in $PatchDefinitions) {
        $probe = Get-PatchDefinitionProbe $data $def
        $probes += $probe
        if ($probe.State -eq 'original-compatible' -or $probe.State -eq 'patched-compatible' -or $probe.State -eq 'mixed') {
            return $probe
        }
    }
    $best = $null
    foreach ($probe in $probes) {
        if (-not $best -or $probe.Old -gt $best.Old -or ($probe.Old -eq $best.Old -and $probe.New -gt $best.New)) {
            $best = $probe
        }
    }
    return $best
}

function Get-PatchLayoutState([string]$ExePath) {
    try { [byte[]]$data = [IO.File]::ReadAllBytes($ExePath) } catch { return 'error' }
    $oldCount = 0; $newCount = 0; $total = $script:PatchDefinition.Patches.Count
    foreach ($p in $script:PatchDefinition.Patches) {
        if (Test-BytesAt $data $p.Offset $p.Old) { $oldCount++ }
        elseif (Test-BytesAt $data $p.Offset $p.New) { $newCount++ }
    }
    if ($oldCount -eq $total) { return 'original-compatible' }
    if ($newCount -eq $total) { return 'patched-compatible' }
    if (($oldCount + $newCount) -eq $total -and $newCount -gt 0) { return 'mixed' }
    return 'incompatible'
}

function Get-PatchMatchSummary([string]$ExePath) {
    try { [byte[]]$data = [IO.File]::ReadAllBytes($ExePath) } catch { return @{ Old=0; New=0; Unknown=$script:PatchDefinition.Patches.Count; Total=$script:PatchDefinition.Patches.Count } }
    $oldCount = 0; $newCount = 0; $unknownCount = 0; $total = $script:PatchDefinition.Patches.Count
    foreach ($p in $script:PatchDefinition.Patches) {
        if (Test-BytesAt $data $p.Offset $p.Old) { $oldCount++ }
        elseif (Test-BytesAt $data $p.Offset $p.New) { $newCount++ }
        else { $unknownCount++ }
    }
    return @{ Old=$oldCount; New=$newCount; Unknown=$unknownCount; Total=$total }
}

function Test-BasicPeFile([string]$ExePath) {
    try {
        [byte[]]$head = New-Object byte[] 64
        $fs = [IO.File]::Open($ExePath,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::Read)
        try {
            if ($fs.Read($head,0,$head.Length) -lt 64) { return $false }
        } finally { $fs.Dispose() }
        return ($head[0] -eq 0x4D -and $head[1] -eq 0x5A)
    } catch { return $false }
}

function Test-ProcessRunning {
    return $null -ne (Get-Process -Name "FarmingSimulator2025Game" -ErrorAction SilentlyContinue)
}

function Test-WriteAccess([string]$Folder) {
    try {
        $p = Join-Path $Folder ((".mfg56_write_test_{0}.tmp") -f [Guid]::NewGuid().ToString('N'))
        [IO.File]::WriteAllText($p, "test")
        Remove-Item -LiteralPath $p -Force
        return $true
    } catch { return $false }
}

function Restart-Elevated([string]$PathToKeep, [string]$GameXmlToKeep) {
    $args = @('-NoProfile','-WindowStyle','Hidden','-ExecutionPolicy','Bypass','-STA','-File',('"{0}"' -f $PSCommandPath))
    if ($PathToKeep) { $args += @('-GamePath', ('"{0}"' -f $PathToKeep)) }
    if ($GameXmlToKeep) { $args += @('-GameXmlPath', ('"{0}"' -f $GameXmlToKeep)) }
    Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList ($args -join ' ')
    [System.Windows.Forms.Application]::Exit()
}

function Apply-PatchBytes([byte[]]$Data, [bool]$Forward) {
    foreach ($p in $script:PatchDefinition.Patches) {
        $expectedHex = if ($Forward) { $p.Old } else { $p.New }
        $replaceHex  = if ($Forward) { $p.New } else { $p.Old }
        [byte[]]$expected = Hex-ToBytes $expectedHex
        [byte[]]$replace  = Hex-ToBytes $replaceHex
        if ($expected.Length -ne $replace.Length) { throw "Internal patch size mismatch at 0x$($p.Offset.ToString('X'))." }
        if ($p.Offset + $expected.Length -gt $Data.Length) { throw "Patch offset outside executable at 0x$($p.Offset.ToString('X'))." }
        for ($i = 0; $i -lt $expected.Length; $i++) {
            if ($Data[$p.Offset + $i] -ne $expected[$i]) {
                throw "Compatibility check failed at 0x$((($p.Offset + $i)).ToString('X')). No changes were written."
            }
        }
        [Array]::Copy($replace, 0, $Data, $p.Offset, $replace.Length)
    }
    Write-Output -NoEnumerate $Data
}

function Apply-PatchBytesForce([byte[]]$Data) {
    foreach ($p in $script:PatchDefinition.Patches) {
        [byte[]]$replace = Hex-ToBytes $p.New
        if ($p.Offset + $replace.Length -gt $Data.Length) { throw "Experimental patch offset outside executable at 0x$($p.Offset.ToString('X'))." }
        [Array]::Copy($replace, 0, $Data, $p.Offset, $replace.Length)
    }
    Write-Output -NoEnumerate $Data
}

function Backup-CurrentFile([string]$Source, [string]$Backup) {
    if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) { throw "Source file missing: $Source" }
    $srcHash = Get-SHA256 $Source
    if (Test-Path -LiteralPath $Backup -PathType Leaf) {
        $bakHash = Get-SHA256 $Backup
        if ($bakHash -ne $srcHash) {
            $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
            $archive = "$Backup.previous_$stamp"
            Move-Item -LiteralPath $Backup -Destination $archive -Force
        }
    }
    Copy-Item -LiteralPath $Source -Destination $Backup -Force
    if ((Get-SHA256 $Backup) -ne $srcHash) { throw "Backup verification failed for $([IO.Path]::GetFileName($Source))." }
    [IO.File]::WriteAllText("$Backup.sha256", $srcHash)
    return $srcHash
}

function Restore-VerifiedBackup([string]$Backup, [string]$Destination) {
    if (-not (Test-Path -LiteralPath $Backup -PathType Leaf)) { return $false }
    $hashFile = "$Backup.sha256"
    if (Test-Path -LiteralPath $hashFile -PathType Leaf) {
        $expected = [IO.File]::ReadAllText($hashFile).Trim().ToUpperInvariant()
        if ($expected -and (Get-SHA256 $Backup) -ne $expected) { throw "Backup hash verification failed: $Backup" }
    }
    Copy-Item -LiteralPath $Backup -Destination $Destination -Force
    if (Test-Path -LiteralPath $hashFile -PathType Leaf) {
        $expected = [IO.File]::ReadAllText($hashFile).Trim().ToUpperInvariant()
        if ($expected -and (Get-SHA256 $Destination) -ne $expected) { throw "Restore verification failed for $Destination" }
    }
    return $true
}

function Get-NvidiaGpu {
    try {
        $gpus = @(Get-CimInstance Win32_VideoController -ErrorAction Stop | Where-Object { $_.Name -match 'NVIDIA|GeForce' })
        if ($gpus.Count -gt 0) {
            $rtx = $gpus | Where-Object { $_.Name -match 'RTX\s*[2-9][0-9]{3}' } | Select-Object -First 1
            if ($rtx) { return $rtx.Name }
            return $gpus[0].Name
        }
    } catch {}
    return $null
}

function Get-GpuStatus([string]$GpuName, [string]$X64Folder) {
    $versionDll = Join-Path $X64Folder 'version.dll'
    $hasBridge = Test-Path -LiteralPath $versionDll
    $family = Get-GpuFamily $GpuName
    switch ($family) {
        'rtx50' { return @{ Text=("{0} — native MFG; helper not required" -f $GpuName); Color='accent'; NeedsBridge=$false; HasBridge=$hasBridge } }
        'rtx40' {
            if ($hasBridge) { return @{ Text=("{0} — Ada MFG enabler detected" -f $GpuName); Color='accent'; NeedsBridge=$false; HasBridge=$true } }
            return @{ Text=("{0} — Ada MFG enabler not detected" -f $GpuName); Color='amber'; NeedsBridge=$true; HasBridge=$false }
        }
        'rtx2030' { return @{ Text=("{0} — mod 2038 is for RTX 40-series only" -f $GpuName); Color='muted'; NeedsBridge=$false; HasBridge=$hasBridge } }
        'unknown' { return @{ Text='GPU not detected — MFG helper hidden'; Color='muted'; NeedsBridge=$false; HasBridge=$hasBridge } }
        default { return @{ Text=("{0} — verify MFG support for this GPU" -f $GpuName); Color='muted'; NeedsBridge=$false; HasBridge=$hasBridge } }
    }
}


function Get-GpuFamily([string]$GpuName) {
    if ([string]::IsNullOrWhiteSpace($GpuName)) { return 'unknown' }
    if ($GpuName -match 'RTX\s*50\d\d') { return 'rtx50' }
    if ($GpuName -match 'RTX\s*40\d\d') { return 'rtx40' }
    if ($GpuName -match 'RTX\s*(20|30)\d\d') { return 'rtx2030' }
    return 'other'
}

function Get-MfgBridgePaths([string]$ExePath) {
    if ([string]::IsNullOrWhiteSpace($ExePath)) { return $null }
    $x64 = Split-Path -Parent $ExePath
    $target = Join-Path $x64 'version.dll'
    return @{
        Target = $target
        Backup = "$target.mfg56.bridge.bak"
        Marker = "$target.mfg56.installed.json"
    }
}

function Test-Pe64Dll([string]$Path) {
    try {
        if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $false }
        [byte[]]$b = [IO.File]::ReadAllBytes($Path)
        if ($b.Length -lt 256 -or $b[0] -ne 0x4D -or $b[1] -ne 0x5A) { return $false }
        $pe = [BitConverter]::ToInt32($b, 0x3C)
        if ($pe -lt 0 -or ($pe + 6) -ge $b.Length) { return $false }
        if ($b[$pe] -ne 0x50 -or $b[$pe+1] -ne 0x45 -or $b[$pe+2] -ne 0 -or $b[$pe+3] -ne 0) { return $false }
        $machine = [BitConverter]::ToUInt16($b, $pe + 4)
        return ($machine -eq 0x8664)
    } catch { return $false }
}

function Resolve-MfgBridgeSource([string]$SelectedPath) {
    if ([string]::IsNullOrWhiteSpace($SelectedPath)) { return $null }
    $SelectedPath = (Resolve-Path -LiteralPath $SelectedPath).Path
    $ext = [IO.Path]::GetExtension($SelectedPath).ToLowerInvariant()
    if ($ext -eq '.dll') {
        if ([IO.Path]::GetFileName($SelectedPath) -ine 'version.dll') {
            throw 'Select the version.dll file from Native DLSS MFG for Ada GPUs.'
        }
        return @{ Path=$SelectedPath; TempDir=$null }
    }
    if ($ext -eq '.zip') {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $tempDir = Join-Path ([IO.Path]::GetTempPath()) ("FS25MFGBridge_" + [Guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        try {
            $zip = [IO.Compression.ZipFile]::OpenRead($SelectedPath)
            try {
                $entries = @($zip.Entries | Where-Object { $_.Name -ieq 'version.dll' })
                if ($entries.Count -eq 0) { throw 'The selected ZIP does not contain version.dll.' }
                $entry = $entries | Sort-Object { $_.FullName.Length } | Select-Object -First 1
                $out = Join-Path $tempDir 'version.dll'
                [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $out, $true)
                return @{ Path=$out; TempDir=$tempDir }
            } finally { $zip.Dispose() }
        } catch {
            Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            throw
        }
    }
    throw 'Select version.dll or the downloaded ZIP archive containing version.dll.'
}

function Install-MfgBridge([string]$ExePath, [string]$SelectedPath) {
    $resolved = Resolve-MfgBridgeSource $SelectedPath
    try {
        if (-not (Test-Pe64Dll $resolved.Path)) { throw 'Selected version.dll is not a valid 64-bit Windows DLL.' }
        $paths = Get-MfgBridgePaths $ExePath
        $targetFolder = Split-Path -Parent $paths.Target
        if (-not (Test-WriteAccess $targetFolder)) { throw 'The x64 folder is not writable. Run the unlocker as Administrator and try again.' }
        $sourceHash = Get-SHA256 $resolved.Path
        $hadOriginal = Test-Path -LiteralPath $paths.Target -PathType Leaf
        if ($hadOriginal) {
            $existingHash = Get-SHA256 $paths.Target
            if ($existingHash -eq $sourceHash) {
                return @{ Installed=$false; AlreadyPresent=$true; Target=$paths.Target; Hash=$sourceHash }
            }
            if (-not (Test-Path -LiteralPath $paths.Backup)) {
                Copy-Item -LiteralPath $paths.Target -Destination $paths.Backup -Force
            }
        }
        $tmp = "$($paths.Target).mfg56.tmp"
        Copy-Item -LiteralPath $resolved.Path -Destination $tmp -Force
        if ((Get-SHA256 $tmp) -ne $sourceHash) { throw 'Temporary MFG bridge copy verification failed.' }
        Copy-Item -LiteralPath $tmp -Destination $paths.Target -Force
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
        if ((Get-SHA256 $paths.Target) -ne $sourceHash) { throw 'Installed MFG bridge verification failed.' }
        $marker = [ordered]@{
            installedBy = $AppName
            appVersion = $AppVersion
            installedAt = (Get-Date).ToString('o')
            hadOriginalVersionDll = [bool]$hadOriginal
            installedSha256 = $sourceHash
            sourceFile = [IO.Path]::GetFileName($SelectedPath)
        }
        ($marker | ConvertTo-Json -Depth 3) | Set-Content -LiteralPath $paths.Marker -Encoding UTF8
        return @{ Installed=$true; AlreadyPresent=$false; Target=$paths.Target; Hash=$sourceHash }
    } finally {
        if ($resolved -and $resolved.TempDir) { Remove-Item -LiteralPath $resolved.TempDir -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

function Restore-MfgBridgeIfManaged([string]$ExePath) {
    $paths = Get-MfgBridgePaths $ExePath
    if (-not $paths -or -not (Test-Path -LiteralPath $paths.Marker -PathType Leaf)) { return 'not-managed' }
    try {
        $meta = Get-Content -LiteralPath $paths.Marker -Raw | ConvertFrom-Json
        if ($meta.hadOriginalVersionDll -and (Test-Path -LiteralPath $paths.Backup -PathType Leaf)) {
            Copy-Item -LiteralPath $paths.Backup -Destination $paths.Target -Force
            Remove-Item -LiteralPath $paths.Backup -Force -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath $paths.Marker -Force -ErrorAction SilentlyContinue
            return 'restored-original'
        }
        if (Test-Path -LiteralPath $paths.Target -PathType Leaf) {
            $currentHash = Get-SHA256 $paths.Target
            if ($meta.installedSha256 -and $currentHash -ne $meta.installedSha256.ToString().ToUpperInvariant()) {
                return 'changed-since-install'
            }
            Remove-Item -LiteralPath $paths.Target -Force
        }
        Remove-Item -LiteralPath $paths.Marker -Force -ErrorAction SilentlyContinue
        return 'removed-installed'
    } catch { return 'restore-error' }
}

# ---------------- UI ----------------
# ---------------- UI ----------------
$bg = [Drawing.Color]::FromArgb(22,24,28)
$panel = [Drawing.Color]::FromArgb(31,34,39)
$panel2 = [Drawing.Color]::FromArgb(40,44,50)
$text = [Drawing.Color]::FromArgb(238,241,244)
$muted = [Drawing.Color]::FromArgb(166,173,181)
$accent = [Drawing.Color]::FromArgb(118,207,68)
$amber = [Drawing.Color]::FromArgb(244,190,72)
$red = [Drawing.Color]::FromArgb(236,87,87)
$blue = [Drawing.Color]::FromArgb(85,166,255)

$form = New-Object Windows.Forms.Form
$form.Text = "$AppName v$AppVersion"
$form.ClientSize = New-Object Drawing.Size(900, 785)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = $bg
$form.ForeColor = $text
$form.Font = New-Object Drawing.Font('Segoe UI', 9.5)

$title = New-Object Windows.Forms.Label
$title.Text = 'FS25 DLSS MFG 5X / 6X Unlocker'
$title.Font = New-Object Drawing.Font('Segoe UI Semibold', 22)
$title.ForeColor = $text
$title.Location = New-Object Drawing.Point(28,22)
$title.AutoSize = $true
$form.Controls.Add($title)

$sub = New-Object Windows.Forms.Label
$sub.Text = 'Unlocks native 5X/6X MFG options and enables FS25 development controls for FPS above the in-game limiter.'
$sub.ForeColor = $muted
$sub.Location = New-Object Drawing.Point(31,66)
$sub.AutoSize = $true
$form.Controls.Add($sub)

$pathLabel = New-Object Windows.Forms.Label
$pathLabel.Text = 'Farming Simulator 25 folder or FarmingSimulator2025Game.exe'
$pathLabel.Font = New-Object Drawing.Font('Segoe UI Semibold', 10)
$pathLabel.Location = New-Object Drawing.Point(31,103)
$pathLabel.AutoSize = $true
$form.Controls.Add($pathLabel)

$pathBox = New-Object Windows.Forms.TextBox
$pathBox.Location = New-Object Drawing.Point(34,128)
$pathBox.Size = New-Object Drawing.Size(702,28)
$pathBox.BackColor = $panel2
$pathBox.ForeColor = $text
$pathBox.BorderStyle = 'FixedSingle'
$form.Controls.Add($pathBox)

$browse = New-Object Windows.Forms.Button
$browse.Text = 'Choose EXE...'
$browse.Location = New-Object Drawing.Point(750,126)
$browse.Size = New-Object Drawing.Size(115,32)
$browse.FlatStyle = 'Flat'
$browse.BackColor = $panel2
$browse.ForeColor = $text
$browse.FlatAppearance.BorderColor = [Drawing.Color]::FromArgb(70,75,82)
$form.Controls.Add($browse)

$hint = New-Object Windows.Forms.Label
$hint.Text = 'Paste the game root, x64 folder or EXE path. The VERSION file in the game root is used for build detection.'
$hint.ForeColor = $muted
$hint.Location = New-Object Drawing.Point(34,160)
$hint.Size = New-Object Drawing.Size(831,22)
$form.Controls.Add($hint)

$xmlLabel = New-Object Windows.Forms.Label
$xmlLabel.Text = 'FS25 user game.xml (development controls / FPS limiter unlock)'
$xmlLabel.Font = New-Object Drawing.Font('Segoe UI Semibold', 10)
$xmlLabel.Location = New-Object Drawing.Point(31,194)
$xmlLabel.AutoSize = $true
$form.Controls.Add($xmlLabel)

$xmlBox = New-Object Windows.Forms.TextBox
$xmlBox.Location = New-Object Drawing.Point(34,219)
$xmlBox.Size = New-Object Drawing.Size(702,28)
$xmlBox.BackColor = $panel2
$xmlBox.ForeColor = $text
$xmlBox.BorderStyle = 'FixedSingle'
$form.Controls.Add($xmlBox)

$browseXml = New-Object Windows.Forms.Button
$browseXml.Text = 'Choose game.xml...'
$browseXml.Location = New-Object Drawing.Point(750,217)
$browseXml.Size = New-Object Drawing.Size(115,32)
$browseXml.FlatStyle = 'Flat'
$browseXml.BackColor = $panel2
$browseXml.ForeColor = $text
$browseXml.FlatAppearance.BorderColor = [Drawing.Color]::FromArgb(70,75,82)
$form.Controls.Add($browseXml)

$xmlHint = New-Object Windows.Forms.Label
$xmlHint.Text = 'Auto-detected from Documents\My Games\FarmingSimulator2025\game.xml when available; otherwise select it manually.'
$xmlHint.ForeColor = $muted
$xmlHint.Location = New-Object Drawing.Point(34,251)
$xmlHint.Size = New-Object Drawing.Size(831,22)
$form.Controls.Add($xmlHint)

$statusPanel = New-Object Windows.Forms.Panel
$statusPanel.Location = New-Object Drawing.Point(34,282)
$statusPanel.Size = New-Object Drawing.Size(831,187)
$statusPanel.BackColor = $panel
$form.Controls.Add($statusPanel)

function Add-StatusRow([string]$name, [int]$y) {
    $l = New-Object Windows.Forms.Label
    $l.Text = $name
    $l.ForeColor = $muted
    $l.Location = New-Object Drawing.Point(18,$y)
    $l.Size = New-Object Drawing.Size(205,23)
    $statusPanel.Controls.Add($l)
    $v = New-Object Windows.Forms.Label
    $v.Text = '—'
    $v.Font = New-Object Drawing.Font('Segoe UI Semibold', 9.5)
    $v.ForeColor = $text
    $v.Location = New-Object Drawing.Point(225,$y)
    $v.Size = New-Object Drawing.Size(585,23)
    $statusPanel.Controls.Add($v)
    return $v
}
$buildValue = Add-StatusRow 'Game build (VERSION)' 16
$patchValue = Add-StatusRow 'MFG unlock' 48
$devValue = Add-StatusRow 'FPS / dev controls' 80
$gpuValue = Add-StatusRow 'GPU / MFG' 112
$backupValue = Add-StatusRow 'Backups' 144
$gpuValue.Size = New-Object Drawing.Size(305,23)

$openMfgPage = New-Object Windows.Forms.Button
$openMfgPage.Text = 'GET MOD 2038'
$openMfgPage.Location = New-Object Drawing.Point(536,105)
$openMfgPage.Size = New-Object Drawing.Size(116,31)
$openMfgPage.FlatStyle = 'Flat'
$openMfgPage.BackColor = $panel2
$openMfgPage.ForeColor = $text
$openMfgPage.FlatAppearance.BorderColor = [Drawing.Color]::FromArgb(70,75,82)
$openMfgPage.Visible = $false
$statusPanel.Controls.Add($openMfgPage)

$installMfg = New-Object Windows.Forms.Button
$installMfg.Text = 'INSTALL DOWNLOADED FILE...'
$installMfg.Location = New-Object Drawing.Point(660,105)
$installMfg.Size = New-Object Drawing.Size(152,31)
$installMfg.FlatStyle = 'Flat'
$installMfg.BackColor = $panel2
$installMfg.ForeColor = $text
$installMfg.FlatAppearance.BorderColor = [Drawing.Color]::FromArgb(70,75,82)
$installMfg.Visible = $false
$statusPanel.Controls.Add($installMfg)


$install = New-Object Windows.Forms.Button
$install.Text = 'ENABLE 5X / 6X + FPS UNLOCK'
$install.Location = New-Object Drawing.Point(34,489)
$install.Size = New-Object Drawing.Size(330,48)
$install.FlatStyle = 'Flat'
$install.BackColor = $accent
$install.ForeColor = [Drawing.Color]::FromArgb(18,22,18)
$install.Font = New-Object Drawing.Font('Segoe UI Semibold', 10.5)
$install.FlatAppearance.BorderSize = 0
$form.Controls.Add($install)

$restore = New-Object Windows.Forms.Button
$restore.Text = 'RESTORE ORIGINAL'
$restore.Location = New-Object Drawing.Point(376,489)
$restore.Size = New-Object Drawing.Size(230,48)
$restore.FlatStyle = 'Flat'
$restore.BackColor = $panel2
$restore.ForeColor = $text
$restore.Font = New-Object Drawing.Font('Segoe UI Semibold', 10)
$restore.FlatAppearance.BorderColor = [Drawing.Color]::FromArgb(70,75,82)
$form.Controls.Add($restore)

$openFolder = New-Object Windows.Forms.Button
$openFolder.Text = 'OPEN x64 FOLDER'
$openFolder.Location = New-Object Drawing.Point(618,489)
$openFolder.Size = New-Object Drawing.Size(247,48)
$openFolder.FlatStyle = 'Flat'
$openFolder.BackColor = $panel2
$openFolder.ForeColor = $text
$openFolder.Font = New-Object Drawing.Font('Segoe UI Semibold', 10)
$openFolder.FlatAppearance.BorderColor = [Drawing.Color]::FromArgb(70,75,82)
$form.Controls.Add($openFolder)

$logLabel = New-Object Windows.Forms.Label
$logLabel.Text = 'Activity'
$logLabel.Font = New-Object Drawing.Font('Segoe UI Semibold', 10)
$logLabel.Location = New-Object Drawing.Point(31,557)
$logLabel.AutoSize = $true
$form.Controls.Add($logLabel)

$log = New-Object Windows.Forms.RichTextBox
$log.Location = New-Object Drawing.Point(34,582)
$log.Size = New-Object Drawing.Size(831,116)
$log.BackColor = [Drawing.Color]::FromArgb(17,19,22)
$log.ForeColor = $muted
$log.BorderStyle = 'FixedSingle'
$log.ReadOnly = $true
$log.Font = New-Object Drawing.Font('Consolas', 9)
$form.Controls.Add($log)

$footer = New-Object Windows.Forms.Label
$footer.Text = 'Tested on FS25 1.19.0.0. Embedded layouts: 1.19 + 1.20 + 1.21. Unknown builds try the closest layout only after backup.'
$footer.ForeColor = $muted
$footer.Location = New-Object Drawing.Point(34,715)
$footer.Size = New-Object Drawing.Size(670,38)
$form.Controls.Add($footer)

$github = New-Object Windows.Forms.LinkLabel
$github.Text = 'github.com/Bartek16194'
$github.LinkColor = $blue
$github.ActiveLinkColor = $accent
$github.VisitedLinkColor = $blue
$github.Location = New-Object Drawing.Point(704,720)
$github.Size = New-Object Drawing.Size(161,25)
$github.TextAlign = 'MiddleRight'
$form.Controls.Add($github)

$script:CurrentExe = $null
$script:CurrentHash = $null
$script:CurrentState = 'none'
$script:CurrentGameXml = $null
$script:CurrentDevState = 'missing'
$script:CurrentGpu = Get-NvidiaGpu

function Log-Line([string]$Message, [Drawing.Color]$Color = $muted) {
    $log.SelectionStart = $log.TextLength
    $log.SelectionLength = 0
    $log.SelectionColor = $Color
    $log.AppendText(("[{0}] {1}`r`n" -f (Get-Date -Format 'HH:mm:ss'), $Message))
    $log.ScrollToCaret()
}

function Set-Value($Label, [string]$TextValue, [Drawing.Color]$Color) {
    $Label.Text = $TextValue
    $Label.ForeColor = $Color
}

function Save-LastPaths {
    try {
        New-Item -ItemType Directory -Path $SettingsDir -Force | Out-Null
        [IO.File]::WriteAllText($SettingsFile, $pathBox.Text)
        [IO.File]::WriteAllText($GameXmlSettingsFile, $xmlBox.Text)
    } catch {}
}

function Refresh-Status {
    $script:CurrentExe = Resolve-GameExe $pathBox.Text
    $script:CurrentGameXml = Resolve-GameXml $xmlBox.Text
    $script:CurrentHash = $null
    $script:CurrentState = 'none'
    $script:CurrentDevState = 'missing'

    # Important button behavior: Restore is NEVER enabled before a successful/recognized patch.
    # Enable is disabled as soon as the EXE is recognized as patched.
    $install.Enabled = $false
    $restore.Enabled = $false
    $openFolder.Enabled = $false
    $openMfgPage.Visible = $false
    $installMfg.Visible = $false

    if (-not $script:CurrentExe) {
        Set-Value $buildValue 'Select the game folder or EXE' $muted
        Set-Value $patchValue 'Not scanned' $muted
        Set-Value $devValue 'Waiting for game selection' $muted
        Set-Value $gpuValue '—' $muted
        Set-Value $backupValue '—' $muted
        return
    }

    $openFolder.Enabled = $true
    try {
        $script:CurrentHash = Get-SHA256 $script:CurrentExe
        $versionInfo = Get-GameVersionInfo $script:CurrentExe
        if ($versionInfo.Version) {
            if ($versionInfo.Version -eq $TestedVersion) {
                Set-Value $buildValue ("{0} — TESTED" -f $versionInfo.Version) $accent
            } elseif ($SupportedVersions -contains $versionInfo.Version) {
                Set-Value $buildValue ("{0} — SUPPORTED LAYOUT" -f $versionInfo.Version) $accent
            } else {
                Set-Value $buildValue ("{0} — untested, closest-layout scan enabled" -f $versionInfo.Version) $amber
            }
        } else {
            Set-Value $buildValue 'VERSION file not found/readable — compatibility scan still available' $amber
        }

        $probe = Select-BestPatchDefinition $script:CurrentExe
        if ($probe -and $probe.Definition) { $script:PatchDefinition = $probe.Definition }
        $script:CurrentState = if ($probe) { $probe.State } else { 'incompatible' }
        switch ($script:CurrentState) {
            'original-compatible' {
                Set-Value $patchValue 'Compatible — ready to unlock 5X/6X' $accent
                $install.Enabled = $true
            }
            'patched-compatible' {
                Set-Value $patchValue 'Enabled — native 5X/6X menu unlocked' $accent
                $install.Enabled = $false
                $restore.Enabled = $true
            }
            'mixed' {
                Set-Value $patchValue 'Partial/mixed patch detected — restore from backup recommended' $amber
                $install.Enabled = $false
                if (Test-Path -LiteralPath "$script:CurrentExe.mfg56.bak") { $restore.Enabled = $true }
            }
            default {
                $match = if ($probe) { $probe } else { Get-PatchMatchSummary $script:CurrentExe }
                $template = if ($script:PatchDefinition.Version) { $script:PatchDefinition.Version } else { 'unknown' }
                Set-Value $patchValue ("Unknown layout — best template {0}: {1}/{2} signatures match; EXPERIMENTAL attempt available" -f $template,$match.Old,$match.Total) $amber
                $install.Enabled = (Test-BasicPeFile $script:CurrentExe)
            }
        }
        if (Test-Path -LiteralPath "$script:CurrentExe.mfg56.bak" -PathType Leaf) { $restore.Enabled = $true }

        if (-not $script:CurrentGameXml) {
            Set-Value $devValue 'game.xml not found — select it manually before enabling' $amber
        } else {
            $script:CurrentDevState = Get-DevControlsState $script:CurrentGameXml
            switch ($script:CurrentDevState) {
                'enabled' { Set-Value $devValue 'Enabled — development controls ready for uncapped FPS' $accent }
                'needs-change' { Set-Value $devValue 'Ready — controls will be enabled automatically' $amber }
                'invalid' { Set-Value $devValue 'Selected game.xml is invalid or unreadable' $red }
                default { Set-Value $devValue 'game.xml not found' $amber }
            }
        }

        $x64 = Split-Path -Parent $script:CurrentExe
        $gpu = Get-GpuStatus $script:CurrentGpu $x64
        $gpuColor = switch ($gpu.Color) { 'accent' {$accent} 'amber' {$amber} default {$muted} }
        Set-Value $gpuValue $gpu.Text $gpuColor
        if ($gpu.NeedsBridge) {
            $openMfgPage.Visible = $true
            $installMfg.Visible = $true
        }

        $exeBak = "$script:CurrentExe.mfg56.bak"
        $xmlBak = if ($script:CurrentGameXml) { "$script:CurrentGameXml.mfg56.bak" } else { $null }
        $exeBakOk = Test-Path -LiteralPath $exeBak
        $xmlBakOk = ($xmlBak -and (Test-Path -LiteralPath $xmlBak))
        $bridgePaths = Get-MfgBridgePaths $script:CurrentExe
        $bridgeManaged = ($bridgePaths -and (Test-Path -LiteralPath $bridgePaths.Marker -PathType Leaf))
        if ($exeBakOk -and $xmlBakOk) {
            $suffix = if ($bridgeManaged) { ' + managed MFG helper' } else { '' }
            Set-Value $backupValue ("EXE + game.xml backups available{0}" -f $suffix) $accent
        } elseif ($exeBakOk) {
            Set-Value $backupValue 'EXE backup available; game.xml backup not found' $muted
        } else {
            Set-Value $backupValue 'EXE + game.xml backups will be created before changes' $muted
        }
    } catch {
        Set-Value $buildValue 'Error while reading game files' $red
        Set-Value $patchValue $_.Exception.Message $red
    }
}

function Select-GameXmlDialog {
    $dlg = New-Object Windows.Forms.OpenFileDialog
    $dlg.Title = 'Select Farming Simulator 25 user game.xml'
    $dlg.Filter = 'Farming Simulator 25 game.xml|game.xml|XML files (*.xml)|*.xml|All files (*.*)|*.*'
    $dlg.FileName = 'game.xml'
    $dlg.CheckFileExists = $true
    $dlg.CheckPathExists = $true
    $dlg.Multiselect = $false
    try {
        $resolved = Resolve-GameXml $xmlBox.Text
        if ($resolved) { $dlg.InitialDirectory = Split-Path -Parent $resolved }
        else {
            $defaultXml = Get-DefaultGameXmlPath
            if ($defaultXml) { $dlg.InitialDirectory = Split-Path -Parent $defaultXml }
        }
    } catch {}
    if ($dlg.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
        $xmlBox.Text = $dlg.FileName
        Save-LastPaths
        Refresh-Status
        Log-Line "Selected game.xml: $($dlg.FileName)" $blue
        return $true
    }
    return $false
}


$openMfgPage.Add_Click({ Start-Process $MfgModUrl })

$installMfg.Add_Click({
    Refresh-Status
    if (-not $script:CurrentExe) { return }
    if ((Get-GpuFamily $script:CurrentGpu) -ne 'rtx40') {
        [Windows.Forms.MessageBox]::Show('Native DLSS MFG for Ada GPUs (mod 2038) is intended for RTX 40-series GPUs.',$AppName,[Windows.Forms.MessageBoxButtons]::OK,[Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        return
    }
    if (Test-ProcessRunning) {
        [Windows.Forms.MessageBox]::Show('Farming Simulator 25 is running. Close the game before installing the MFG helper.',$AppName,[Windows.Forms.MessageBoxButtons]::OK,[Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
        return
    }
    $dlg = New-Object Windows.Forms.OpenFileDialog
    $dlg.Title = 'Select downloaded Native DLSS MFG for Ada GPUs file'
    $dlg.Filter = 'Downloaded mod (version.dll or ZIP)|version.dll;*.zip|version.dll|version.dll|ZIP archives (*.zip)|*.zip|All files (*.*)|*.*'
    $dlg.CheckFileExists = $true
    $dlg.CheckPathExists = $true
    $dlg.Multiselect = $false
    if ($dlg.ShowDialog() -ne [Windows.Forms.DialogResult]::OK) { return }
    try {
        $x64 = Split-Path -Parent $script:CurrentExe
        if (-not (Test-WriteAccess $x64)) {
            $r = [Windows.Forms.MessageBox]::Show('The x64 folder is not writable. Restart the unlocker as Administrator?',$AppName,[Windows.Forms.MessageBoxButtons]::YesNo,[Windows.Forms.MessageBoxIcon]::Question)
            if ($r -eq [Windows.Forms.DialogResult]::Yes) { Restart-Elevated $pathBox.Text $xmlBox.Text }
            return
        }
        Log-Line ("Installing user-selected MFG helper: {0}" -f $dlg.FileName) $blue
        $result = Install-MfgBridge $script:CurrentExe $dlg.FileName
        if ($result.AlreadyPresent) {
            Log-Line 'MFG helper is already installed (same version.dll).' $accent
            [Windows.Forms.MessageBox]::Show('The selected version.dll is already installed next to FarmingSimulator2025Game.exe.',$AppName,[Windows.Forms.MessageBoxButtons]::OK,[Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        } else {
            Log-Line 'SUCCESS: Ada MFG helper installed as x64\\version.dll.' $accent
            [Windows.Forms.MessageBox]::Show("MFG helper installed successfully.`r`n`r`nThe selected third-party version.dll was copied next to FarmingSimulator2025Game.exe.`r`nThe file is not bundled with this unlocker and remains property of its original author.",$AppName,[Windows.Forms.MessageBoxButtons]::OK,[Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        }
        Refresh-Status
    } catch {
        Log-Line ("MFG HELPER ERROR: " + $_.Exception.Message) $red
        [Windows.Forms.MessageBox]::Show($_.Exception.Message,$AppName,[Windows.Forms.MessageBoxButtons]::OK,[Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    }
})

$browse.Add_Click({
    $dlg = New-Object Windows.Forms.OpenFileDialog
    $dlg.Title = 'Select FarmingSimulator2025Game.exe'
    $dlg.Filter = 'Farming Simulator 25 executable|FarmingSimulator2025Game.exe|Executable files (*.exe)|*.exe|All files (*.*)|*.*'
    $dlg.FileName = 'FarmingSimulator2025Game.exe'
    $dlg.CheckFileExists = $true
    $dlg.CheckPathExists = $true
    $dlg.Multiselect = $false
    try {
        $resolved = Resolve-GameExe $pathBox.Text
        if ($resolved) { $dlg.InitialDirectory = Split-Path -Parent $resolved }
        elseif ($pathBox.Text -and (Test-Path -LiteralPath $pathBox.Text -PathType Container)) { $dlg.InitialDirectory = $pathBox.Text }
    } catch {}
    if ($dlg.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
        $pathBox.Text = $dlg.FileName
        Save-LastPaths
        Refresh-Status
        Log-Line "Selected: $($dlg.FileName)" $blue
    }
})

$browseXml.Add_Click({ [void](Select-GameXmlDialog) })
$pathBox.Add_Leave({ Save-LastPaths; Refresh-Status })
$pathBox.Add_KeyDown({ if ($_.KeyCode -eq [Windows.Forms.Keys]::Enter) { Save-LastPaths; Refresh-Status } })
$xmlBox.Add_Leave({ Save-LastPaths; Refresh-Status })
$xmlBox.Add_KeyDown({ if ($_.KeyCode -eq [Windows.Forms.Keys]::Enter) { Save-LastPaths; Refresh-Status } })
$github.Add_LinkClicked({ Start-Process $AuthorUrl })

$install.Add_Click({
    Refresh-Status
    if ($script:CurrentState -eq 'patched-compatible' -or $script:CurrentState -eq 'mixed') {
        [Windows.Forms.MessageBox]::Show('This executable is already patched or partially patched. Restore the original before enabling again.',$AppName,[Windows.Forms.MessageBoxButtons]::OK,[Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
        return
    }
    $forceMode = ($script:CurrentState -eq 'incompatible')
    if ($forceMode) {
        $match = Get-PatchMatchSummary $script:CurrentExe
        $warning = "This game build does NOT match the tested patch layout.`r`n`r`nThe unlocker can still TRY the closest embedded patch layout at its known offsets. This is EXPERIMENTAL and may make the game fail to start if GIANTS changed those areas.`r`n`r`nA byte-for-byte backup of FarmingSimulator2025Game.exe will be created first, and RESTORE ORIGINAL will remain available.`r`n`r`nSelected template: $($script:PatchDefinition.Version).`r`nDetected original signatures: $($match.Old)/$($match.Total).`r`n`r`nTry anyway?"
        $r = [Windows.Forms.MessageBox]::Show($warning,$AppName,[Windows.Forms.MessageBoxButtons]::YesNo,[Windows.Forms.MessageBoxIcon]::Warning)
        if ($r -ne [Windows.Forms.DialogResult]::Yes) { return }
    } elseif ($script:CurrentState -ne 'original-compatible') {
        [Windows.Forms.MessageBox]::Show('The selected file cannot be patched.',$AppName,[Windows.Forms.MessageBoxButtons]::OK,[Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
        return
    }
    if (-not $script:CurrentGameXml) {
        $r = [Windows.Forms.MessageBox]::Show("The FS25 user game.xml was not found automatically.`r`n`r`nSelect it now?",$AppName,[Windows.Forms.MessageBoxButtons]::YesNo,[Windows.Forms.MessageBoxIcon]::Question)
        if ($r -ne [Windows.Forms.DialogResult]::Yes -or -not (Select-GameXmlDialog)) { return }
        Refresh-Status
    }
    if ((Get-DevControlsState $script:CurrentGameXml) -eq 'invalid') {
        [Windows.Forms.MessageBox]::Show('The selected game.xml could not be parsed. Select the correct FS25 user game.xml and try again.',$AppName,[Windows.Forms.MessageBoxButtons]::OK,[Windows.Forms.MessageBoxIcon]::Error) | Out-Null
        return
    }
    if (Test-ProcessRunning) {
        [Windows.Forms.MessageBox]::Show('Farming Simulator 25 is running. Close the game and try again.',$AppName,[Windows.Forms.MessageBoxButtons]::OK,[Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
        return
    }
    $x64 = Split-Path -Parent $script:CurrentExe
    $xmlFolder = Split-Path -Parent $script:CurrentGameXml
    if (-not (Test-WriteAccess $x64) -or -not (Test-WriteAccess $xmlFolder)) {
        $r = [Windows.Forms.MessageBox]::Show('One of the required folders is not writable. Restart the patcher as Administrator?',$AppName,[Windows.Forms.MessageBoxButtons]::YesNo,[Windows.Forms.MessageBoxIcon]::Question)
        if ($r -eq [Windows.Forms.DialogResult]::Yes) { Restart-Elevated $pathBox.Text $xmlBox.Text }
        return
    }

    $exeTmp = "$script:CurrentExe.mfg56.tmp"
    $xmlTmp = "$script:CurrentGameXml.mfg56.tmp"
    $exeWritten = $false
    $xmlWritten = $false
    try {
        Log-Line 'Running executable compatibility check...' $blue
        $beforeHash = Get-SHA256 $script:CurrentExe
        $liveState = Get-PatchLayoutState $script:CurrentExe
        if ($forceMode) {
            if ($liveState -ne 'incompatible') { throw 'Executable state changed since scan. Please scan again.' }
            Log-Line 'EXPERIMENTAL MODE: layout mismatch accepted by user; closest embedded patch offsets will be attempted.' $amber
        } else {
            if ($liveState -ne 'original-compatible') { throw 'Executable changed since scan. Please scan again.' }
        }

        $versionInfo = Get-GameVersionInfo $script:CurrentExe
        if (-not $versionInfo.Version -or $versionInfo.Version -ne $TestedVersion) {
            if ($forceMode) { Log-Line 'Untested game build: forced closest-layout patch attempt selected. Creating exact backups first.' $amber }
            else { Log-Line 'Untested game build: required patch-byte layout matches. Proceeding with backups.' $amber }
        }

        $exeBak = "$script:CurrentExe.mfg56.bak"
        [void](Backup-CurrentFile $script:CurrentExe $exeBak)
        Log-Line 'Exact pre-patch executable backup created and hash recorded.' $accent

        $xmlBak = "$script:CurrentGameXml.mfg56.bak"
        [void](Backup-CurrentFile $script:CurrentGameXml $xmlBak)
        Log-Line 'Exact pre-patch game.xml backup created and hash recorded.' $accent

        [byte[]]$data = [IO.File]::ReadAllBytes($script:CurrentExe)
        if ($forceMode) { $data = Apply-PatchBytesForce $data }
        else { $data = Apply-PatchBytes $data $true }
        [IO.File]::WriteAllBytes($exeTmp, $data)
        if ((Get-PatchLayoutState $exeTmp) -ne 'patched-compatible') { throw 'Patched executable validation failed.' }

        Write-DevControlsUnlock $script:CurrentGameXml $xmlTmp
        if ((Get-DevControlsState $xmlTmp) -ne 'enabled') { throw 'Development-controls game.xml validation failed.' }

        Copy-Item -LiteralPath $exeTmp -Destination $script:CurrentExe -Force
        $exeWritten = $true
        Copy-Item -LiteralPath $xmlTmp -Destination $script:CurrentGameXml -Force
        $xmlWritten = $true
        if ((Get-PatchLayoutState $script:CurrentExe) -ne 'patched-compatible') { throw 'Final executable verification failed.' }
        if ((Get-DevControlsState $script:CurrentGameXml) -ne 'enabled') { throw 'Final game.xml verification failed.' }

        Remove-Item -LiteralPath $exeTmp -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $xmlTmp -Force -ErrorAction SilentlyContinue
        if ($forceMode) { Log-Line 'SUCCESS: experimental forced patch written; 5X/6X and development controls enabled. Test the game; RESTORE ORIGINAL is available.' $accent } else { Log-Line 'SUCCESS: 5X/6X unlocked and development controls enabled.' $accent }
        Refresh-Status
        $gpuFamily = Get-GpuFamily $script:CurrentGpu
        $bridgeMissing = $false
        if ($gpuFamily -eq 'rtx40') {
            $bridgePaths = Get-MfgBridgePaths $script:CurrentExe
            $bridgeMissing = -not (Test-Path -LiteralPath $bridgePaths.Target -PathType Leaf)
        }
        if ($bridgeMissing) {
            $r = [Windows.Forms.MessageBox]::Show("Patch installed successfully.`r`n`r`nFS25 now exposes 5X and 6X, but an RTX 40-series GPU was detected and the Ada MFG enabler is missing.`r`n`r`nOpen Nexus Mods page for 'Native DLSS MFG for Ada GPUs' now? After downloading, use INSTALL DOWNLOADED FILE... in this window and select version.dll or the ZIP archive.",$AppName,[Windows.Forms.MessageBoxButtons]::YesNo,[Windows.Forms.MessageBoxIcon]::Information)
            if ($r -eq [Windows.Forms.DialogResult]::Yes) { Start-Process $MfgModUrl }
        } else {
            [Windows.Forms.MessageBox]::Show("Patch installed successfully.`r`n`r`nFS25 now exposes 5X and 6X under DLSS Frame Generation.`r`nDevelopment controls were enabled in the user game.xml for FPS above the normal in-game limiter.",$AppName,[Windows.Forms.MessageBoxButtons]::OK,[Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        }
    } catch {
        Remove-Item -LiteralPath $exeTmp -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $xmlTmp -Force -ErrorAction SilentlyContinue
        # Best-effort rollback only for files actually replaced during this attempt.
        try {
            $exeBak = "$script:CurrentExe.mfg56.bak"
            if ($exeWritten -and (Test-Path -LiteralPath $exeBak)) { Copy-Item -LiteralPath $exeBak -Destination $script:CurrentExe -Force }
            $xmlBak = "$script:CurrentGameXml.mfg56.bak"
            if ($xmlWritten -and (Test-Path -LiteralPath $xmlBak)) { Copy-Item -LiteralPath $xmlBak -Destination $script:CurrentGameXml -Force }
        } catch {}
        Log-Line ("ERROR: " + $_.Exception.Message) $red
        Refresh-Status
        [Windows.Forms.MessageBox]::Show($_.Exception.Message,$AppName,[Windows.Forms.MessageBoxButtons]::OK,[Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    }
})

$restore.Add_Click({
    Refresh-Status
    if (-not $script:CurrentExe) { return }
    $exeBakForGate = "$script:CurrentExe.mfg56.bak"
    if ($script:CurrentState -ne 'patched-compatible' -and $script:CurrentState -ne 'mixed' -and -not (Test-Path -LiteralPath $exeBakForGate -PathType Leaf)) { return }
    if (Test-ProcessRunning) {
        [Windows.Forms.MessageBox]::Show('Farming Simulator 25 is running. Close the game and try again.',$AppName,[Windows.Forms.MessageBoxButtons]::OK,[Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
        return
    }
    $x64 = Split-Path -Parent $script:CurrentExe
    $restoreXmlNeeded = $false
    $restoreXmlFolder = $null
    if ($script:CurrentGameXml -and (Test-Path -LiteralPath "$script:CurrentGameXml.mfg56.bak")) {
        $restoreXmlNeeded = $true
        $restoreXmlFolder = Split-Path -Parent $script:CurrentGameXml
    }
    if (-not (Test-WriteAccess $x64) -or ($restoreXmlNeeded -and -not (Test-WriteAccess $restoreXmlFolder))) {
        $r = [Windows.Forms.MessageBox]::Show('One of the folders required for restore is not writable. Restart the patcher as Administrator?',$AppName,[Windows.Forms.MessageBoxButtons]::YesNo,[Windows.Forms.MessageBoxIcon]::Question)
        if ($r -eq [Windows.Forms.DialogResult]::Yes) { Restart-Elevated $pathBox.Text $xmlBox.Text }
        return
    }
    try {
        $exeBak = "$script:CurrentExe.mfg56.bak"
        if (Test-Path -LiteralPath $exeBak) {
            if (-not (Restore-VerifiedBackup $exeBak $script:CurrentExe)) { throw 'Executable backup could not be restored.' }
            Log-Line 'Exact pre-patch executable restored from verified backup.' $accent
        } elseif ($script:CurrentState -eq 'patched-compatible') {
            [byte[]]$data = [IO.File]::ReadAllBytes($script:CurrentExe)
            $data = Apply-PatchBytes $data $false
            $tmp = "$script:CurrentExe.mfg56.tmp"
            [IO.File]::WriteAllBytes($tmp, $data)
            if ((Get-PatchLayoutState $tmp) -ne 'original-compatible') { throw 'Reverse-patch verification failed.' }
            Copy-Item -LiteralPath $tmp -Destination $script:CurrentExe -Force
            Remove-Item -LiteralPath $tmp -Force
            Log-Line 'Original executable restored using embedded reverse patch.' $accent
        } else {
            throw 'No valid EXE backup or recognized patched executable was found.'
        }

        if ($script:CurrentGameXml) {
            $xmlBak = "$script:CurrentGameXml.mfg56.bak"
            if (Test-Path -LiteralPath $xmlBak) {
                if (-not (Restore-VerifiedBackup $xmlBak $script:CurrentGameXml)) { throw 'game.xml backup could not be restored.' }
                Log-Line 'Original game.xml restored from verified backup.' $accent
            }
        }

        $bridgeRestore = Restore-MfgBridgeIfManaged $script:CurrentExe
        switch ($bridgeRestore) {
            'restored-original' { Log-Line 'Original version.dll restored; helper installed by this tool was removed.' $accent }
            'removed-installed' { Log-Line 'MFG helper installed by this tool was removed.' $accent }
            'changed-since-install' { Log-Line 'Managed version.dll changed since installation; left untouched for safety.' $amber }
            'restore-error' { Log-Line 'Could not restore/remove the managed MFG helper; version.dll was left untouched.' $amber }
        }

        Refresh-Status
        [Windows.Forms.MessageBox]::Show('Original FarmingSimulator2025Game.exe restored. The game.xml backup was restored when available. If this tool installed the RTX 40 MFG helper, it was also restored/removed when safe to do so.',$AppName,[Windows.Forms.MessageBoxButtons]::OK,[Windows.Forms.MessageBoxIcon]::Information) | Out-Null
    } catch {
        Log-Line ("ERROR: " + $_.Exception.Message) $red
        [Windows.Forms.MessageBox]::Show($_.Exception.Message,$AppName,[Windows.Forms.MessageBoxButtons]::OK,[Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    }
})

$openFolder.Add_Click({
    if ($script:CurrentExe) { Start-Process explorer.exe -ArgumentList ('"{0}"' -f (Split-Path -Parent $script:CurrentExe)) }
})

$form.Add_FormClosing({ Save-LastPaths })

if ($GamePath) {
    $pathBox.Text = $GamePath
} elseif (Test-Path -LiteralPath $SettingsFile) {
    try { $pathBox.Text = [IO.File]::ReadAllText($SettingsFile).Trim() } catch {}
}

if ($GameXmlPath) {
    $xmlBox.Text = $GameXmlPath
} elseif (Test-Path -LiteralPath $GameXmlSettingsFile) {
    try { $xmlBox.Text = [IO.File]::ReadAllText($GameXmlSettingsFile).Trim() } catch {}
}
if ([string]::IsNullOrWhiteSpace($xmlBox.Text) -or -not (Resolve-GameXml $xmlBox.Text)) {
    $defaultXml = Get-DefaultGameXmlPath
    if ($defaultXml) { $xmlBox.Text = $defaultXml }
}

Refresh-Status
Log-Line "$AppName v$AppVersion ready." $accent
Log-Line 'Game build is read from the VERSION file in the FS25 installation root.' $muted
Log-Line 'RTX 40 helper: mod 2038 is never bundled; the tool only opens Nexus and installs a file selected by the user.' $muted
if ($script:CurrentGameXml) { Log-Line ("Detected game.xml: {0}" -f $script:CurrentGameXml) $muted }
else { Log-Line 'User game.xml was not found automatically; select it before enabling.' $amber }
if ($script:CurrentGpu) { Log-Line ("Detected GPU: {0}" -f $script:CurrentGpu) $muted }

[void]$form.ShowDialog()
