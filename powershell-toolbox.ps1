# PowerShell-ToolBox.ps1 (GUI Entry Point, Output im Terminal + Logfile)

[CmdletBinding()]
param(
    [string]$ConfigPath = (Join-Path $PSScriptRoot "config"),
    [string]$LogPath    = (Join-Path $PSScriptRoot "logs")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Bootstrap folders/logfile
if (-not (Test-Path -Path $LogPath -PathType Container)) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
}
$LogFile = Join-Path $LogPath ("log_{0}.txt" -f (Get-Date -Format "yyyyMMdd_HHmmss"))

function Write-Log {
    param(
        [ValidateSet("INFO","WARN","ERROR","DEBUG")]
        [string]$Level,
        [Parameter(Mandatory)]
        [string]$Message
    )
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] [$Level] $Message"

    # Terminal output (live sichtbar)
    switch ($Level) {
        "ERROR" { Write-Host $line -ForegroundColor Red }
        "WARN"  { Write-Host $line -ForegroundColor Yellow }
        "DEBUG" { Write-Host $line -ForegroundColor DarkGray }
        default { Write-Host $line }
    }

    # File output
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

function Show-UiError {
    param([string]$Title, [string]$Message)
    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
}

function Safe-Run {
    param(
        [string]$Name,
        [scriptblock]$Action
    )
    try {
        Write-Log -Level "INFO" -Message "Starte: $Name"
        & $Action
        Write-Log -Level "INFO" -Message "Fertig:  $Name"
    } catch {
        Write-Log -Level "ERROR" -Message ("Fehler in {0}: {1}" -f $Name, $_.Exception.Message)
        Show-UiError -Title "Fehler: $Name" -Message $_.Exception.Message
    }
}

# --- Load modules
$ModuleRoot = Join-Path $PSScriptRoot "modules"
foreach ($m in @("install_apps.ps1","cleanup.ps1","tweaks.ps1","custom_runner.ps1")) {
    $path = Join-Path $ModuleRoot $m
    if (Test-Path $path -PathType Leaf) {
        . $path
        Write-Log -Level "INFO" -Message "Modul geladen: $m"
    } else {
        Write-Log -Level "WARN" -Message "Modul fehlt (ok während Aufbau): $m"
    }
}

Write-Log -Level "INFO" -Message "PowerShell-ToolBox GUI gestartet."
Write-Log -Level "INFO" -Message "ConfigPath: $ConfigPath"
Write-Log -Level "INFO" -Message "LogFile:    $LogFile"

# ---------------------------
# Main Form
# ---------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "PowerShell-ToolBox"
$form.StartPosition = "CenterScreen"
$form.Size = New-Object System.Drawing.Size(700, 420)

# Tabs: Apps / Cleanup / Tweaks / Custom
$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Dock = "Fill"

$tabApps    = New-Object System.Windows.Forms.TabPage; $tabApps.Text    = "Apps"
$tabCleanup = New-Object System.Windows.Forms.TabPage; $tabCleanup.Text = "Cleanup"
$tabTweaks  = New-Object System.Windows.Forms.TabPage; $tabTweaks.Text  = "Tweaks"
$tabCustom  = New-Object System.Windows.Forms.TabPage; $tabCustom.Text  = "Custom"

$tabs.TabPages.AddRange(@($tabApps, $tabCleanup, $tabTweaks, $tabCustom))
$form.Controls.Add($tabs)

# Global WhatIf checkbox (oben in jedem Tab sichtbar sinnvoll)
$chkWhatIf = New-Object System.Windows.Forms.CheckBox
$chkWhatIf.Text = "Testmodus (WhatIf)"
$chkWhatIf.AutoSize = $true
$chkWhatIf.Location = New-Object System.Drawing.Point(20, 20)

# --- Apps tab
$btnInstallApps = New-Object System.Windows.Forms.Button
$btnInstallApps.Text = "Apps installieren / updaten"
$btnInstallApps.Size = New-Object System.Drawing.Size(250, 35)
$btnInstallApps.Location = New-Object System.Drawing.Point(20, 60)

$btnInstallApps.Add_Click({
    Safe-Run -Name "Apps installieren" -Action {
        if (-not (Get-Command Invoke-InstallApps -ErrorAction SilentlyContinue)) {
            throw "Invoke-InstallApps nicht gefunden. Implementiere modules/install_apps.ps1."
        }

        # Live sichtbar im Terminal:
        Write-Host "---- Apps Installation gestartet ----" -ForegroundColor Cyan

        Invoke-InstallApps -ConfigPath $ConfigPath -LogPath $LogPath -WhatIf:$($chkWhatIf.Checked) -Verbose

        Write-Host "---- Apps Installation beendet ----" -ForegroundColor Green
    }
})

$tabApps.Controls.AddRange(@($chkWhatIf, $btnInstallApps))

# --- Cleanup tab
$btnCleanup = New-Object System.Windows.Forms.Button
$btnCleanup.Text = "Cleanup starten"
$btnCleanup.Size = New-Object System.Drawing.Size(250, 35)
$btnCleanup.Location = New-Object System.Drawing.Point(20, 60)

$btnCleanup.Add_Click({
    Safe-Run -Name "Cleanup" -Action {
        if (-not (Get-Command Invoke-Cleanup -ErrorAction SilentlyContinue)) {
            throw "Invoke-Cleanup nicht gefunden. Implementiere modules/cleanup.ps1."
        }

        Write-Host "---- Cleanup gestartet ----" -ForegroundColor Cyan

        Invoke-Cleanup -ConfigPath $ConfigPath -LogPath $LogPath -WhatIf:$($chkWhatIf.Checked) -Verbose

        Write-Host "---- Cleanup beendet ----" -ForegroundColor Green
    }
})

$tabCleanup.Controls.AddRange(@($chkWhatIf, $btnCleanup))

# --- Tweaks tab
$btnTweaks = New-Object System.Windows.Forms.Button
$btnTweaks.Text = "Tweaks anwenden"
$btnTweaks.Size = New-Object System.Drawing.Size(250, 35)
$btnTweaks.Location = New-Object System.Drawing.Point(20, 60)

$btnTweaks.Add_Click({
    Safe-Run -Name "Tweaks" -Action {
        if (-not (Get-Command Invoke-Tweaks -ErrorAction SilentlyContinue)) {
            throw "Invoke-Tweaks nicht gefunden. Implementiere modules/tweaks.ps1."
        }

        Write-Host "---- Tweaks gestartet ----" -ForegroundColor Cyan

        Invoke-Tweaks -ConfigPath $ConfigPath -LogPath $LogPath -WhatIf:$($chkWhatIf.Checked) -Verbose

        Write-Host "---- Tweaks beendet ----" -ForegroundColor Green
    }
})

$tabTweaks.Controls.AddRange(@($chkWhatIf, $btnTweaks))

# --- Custom tab
$btnCustom = New-Object System.Windows.Forms.Button
$btnCustom.Text = "CustomScripts ausführen"
$btnCustom.Size = New-Object System.Drawing.Size(250, 35)
$btnCustom.Location = New-Object System.Drawing.Point(20, 60)

$btnCustom.Add_Click({
    Safe-Run -Name "CustomScripts" -Action {
        if (-not (Get-Command Invoke-CustomScripts -ErrorAction SilentlyContinue)) {
            throw "Invoke-CustomScripts nicht gefunden. Implementiere modules/custom_runner.ps1."
        }

        Write-Host "---- CustomScripts gestartet ----" -ForegroundColor Cyan

        Invoke-CustomScripts -ConfigPath $ConfigPath -LogPath $LogPath -WhatIf:$($chkWhatIf.Checked) -Verbose

        Write-Host "---- CustomScripts beendet ----" -ForegroundColor Green
    }
})

$tabCustom.Controls.AddRange(@($chkWhatIf, $btnCustom))

# Show
[void]$form.ShowDialog()
