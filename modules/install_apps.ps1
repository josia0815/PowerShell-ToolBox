# --- Apps-Tab: Select All / Deselect All pro Kategorie + zwei Action-Buttons ---
# Ersetzt deinen aktuellen Apps-Tab Block.
# Erwartet: config/app_list.json und modules/install_apps.ps1 mit Invoke-ManageApps (aus meiner letzten Antwort).

# Panel + Scroll
$appsPanel = New-Object System.Windows.Forms.Panel
$appsPanel.Location = New-Object System.Drawing.Point(20, 60)
$appsPanel.Size = New-Object System.Drawing.Size(630, 240)
$appsPanel.AutoScroll = $true
$appsPanel.BorderStyle = "FixedSingle"

# WhatIf
$chkAppsWhatIf = New-Object System.Windows.Forms.CheckBox
$chkAppsWhatIf.Text = "Testmodus (WhatIf) – keine Änderungen"
$chkAppsWhatIf.AutoSize = $true
$chkAppsWhatIf.Location = New-Object System.Drawing.Point(20, 20)

# Buttons (schönere Wortwahl)
$btnInstallSelected = New-Object System.Windows.Forms.Button
$btnInstallSelected.Text = "Auswahl installieren / aktualisieren"
$btnInstallSelected.Size = New-Object System.Drawing.Size(300, 35)
$btnInstallSelected.Location = New-Object System.Drawing.Point(20, 320)

$btnUninstallSelected = New-Object System.Windows.Forms.Button
$btnUninstallSelected.Text = "Auswahl deinstallieren"
$btnUninstallSelected.Size = New-Object System.Drawing.Size(300, 35)
$btnUninstallSelected.Location = New-Object System.Drawing.Point(350, 320)

function Initialize-AppsCheckboxUI {
    param(
        [Parameter(Mandatory)][string]$ConfigPath,
        [Parameter(Mandatory)][System.Windows.Forms.Panel]$TargetPanel
    )

    $configFile = Join-Path $ConfigPath "app_list.json"
    if (-not (Test-Path $configFile)) {
        throw "app_list.json nicht gefunden unter: $configFile"
    }

    $cfg = (Get-Content -Path $configFile -Raw -Encoding UTF8) | ConvertFrom-Json
    $TargetPanel.Controls.Clear()

    $y = 10

    foreach ($groupProp in $cfg.PSObject.Properties) {
        $groupName = $groupProp.Name
        $apps = $groupProp.Value

        if ($null -eq $apps) { continue }
        if ($apps -isnot [System.Collections.IEnumerable] -or $apps -is [string]) { continue }

        $gb = New-Object System.Windows.Forms.GroupBox
        $gb.Text = $groupName
        $gb.Location = New-Object System.Drawing.Point(10, $y)
        $gb.Size = New-Object System.Drawing.Size(590, 10)

        # --- Select/Deselect pro Kategorie
        $btnSelectAll = New-Object System.Windows.Forms.Button
        $btnSelectAll.Text = "Alle markieren"
        $btnSelectAll.Size = New-Object System.Drawing.Size(110, 23)
        $btnSelectAll.Location = New-Object System.Drawing.Point(15, 18)

        $btnDeselectAll = New-Object System.Windows.Forms.Button
        $btnDeselectAll.Text = "Auswahl löschen"
        $btnDeselectAll.Size = New-Object System.Drawing.Size(110, 23)
        $btnDeselectAll.Location = New-Object System.Drawing.Point(130, 18)

        $gb.Controls.AddRange(@($btnSelectAll, $btnDeselectAll))

        $innerY = 48

        foreach ($app in $apps) {
            if ($null -eq $app) { continue }
            if ([string]::IsNullOrWhiteSpace($app.name) -or [string]::IsNullOrWhiteSpace($app.wingetId)) { continue }

            $cb = New-Object System.Windows.Forms.CheckBox
            $cb.Text = $app.name
            $cb.AutoSize = $true
            $cb.Location = New-Object System.Drawing.Point(15, $innerY)

            $cb.Tag = [pscustomobject]@{
                Group    = $groupName
                Name     = $app.name
                WingetId = $app.wingetId
                Category = $app.category
            }

            $gb.Controls.Add($cb)
            $innerY += 25
        }

        # Events: select/deselect in dieser GroupBox
        $btnSelectAll.Add_Click({
            foreach ($c in $gb.Controls) {
                if ($c -is [System.Windows.Forms.CheckBox] -and $null -ne $c.Tag) {
                    $c.Checked = $true
                }
            }
        })

        $btnDeselectAll.Add_Click({
            foreach ($c in $gb.Controls) {
                if ($c -is [System.Windows.Forms.CheckBox] -and $null -ne $c.Tag) {
                    $c.Checked = $false
                }
            }
        })

        $gb.Height = [Math]::Max(70, $innerY + 10)
        $TargetPanel.Controls.Add($gb)

        $y += ($gb.Height + 10)
    }
}

function Get-SelectedAppsFromUI {
    param([Parameter(Mandatory)][System.Windows.Forms.Panel]$TargetPanel)

    $selected = New-Object System.Collections.Generic.List[object]

    foreach ($ctrl in $TargetPanel.Controls) {
        if ($ctrl -is [System.Windows.Forms.GroupBox]) {
            foreach ($c in $ctrl.Controls) {
                if ($c -is [System.Windows.Forms.CheckBox] -and $c.Checked -and $null -ne $c.Tag) {
                    $selected.Add($c.Tag) | Out-Null
                }
            }
        }
    }

    return $selected
}

# Initial UI bauen
Initialize-AppsCheckboxUI -ConfigPath $ConfigPath -TargetPanel $appsPanel

# Install/Update Button
$btnInstallSelected.Add_Click({
    try {
        $selected = Get-SelectedAppsFromUI -TargetPanel $appsPanel
        if (($selected | Measure-Object).Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show(
                "Bitte mindestens eine Applikation markieren.",
                "Keine Auswahl",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            ) | Out-Null
            return
        }

        if (-not (Get-Command Invoke-ManageApps -ErrorAction SilentlyContinue)) {
            throw "Invoke-ManageApps nicht gefunden. Implementiere modules/install_apps.ps1 entsprechend."
        }

        Write-Host ""
        Write-Host "---- Installation/Aktualisierung gestartet ($($selected.Count)) ----" -ForegroundColor Cyan
        $selected | ForEach-Object { Write-Host ("- {0} ({1})" -f $_.Name, $_.WingetId) }

        Invoke-ManageApps -Apps $selected -Mode "install" -LogPath $LogPath -WhatIf:$($chkAppsWhatIf.Checked) -UpgradeIfInstalled -Verbose

        Write-Host "---- Installation/Aktualisierung beendet ----" -ForegroundColor Green
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            "Fehler",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
})

# Uninstall Button
$btnUninstallSelected.Add_Click({
    try {
        $selected = Get-SelectedAppsFromUI -TargetPanel $appsPanel
        if (($selected | Measure-Object).Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show(
                "Bitte mindestens eine Applikation markieren.",
                "Keine Auswahl",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            ) | Out-Null
            return
        }

        if (-not (Get-Command Invoke-ManageApps -ErrorAction SilentlyContinue)) {
            throw "Invoke-ManageApps nicht gefunden. Implementiere modules/install_apps.ps1 entsprechend."
        }

        $confirm = [System.Windows.Forms.MessageBox]::Show(
            "Ausgewählte Applikationen wirklich deinstallieren?",
            "Bestätigung",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )

        if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) {
            return
        }

        Write-Host ""
        Write-Host "---- Deinstallation gestartet ($($selected.Count)) ----" -ForegroundColor Cyan
        $selected | ForEach-Object { Write-Host ("- {0} ({1})" -f $_.Name, $_.WingetId) }

        Invoke-ManageApps -Apps $selected -Mode "uninstall" -LogPath $LogPath -WhatIf:$($chkAppsWhatIf.Checked) -Verbose

        Write-Host "---- Deinstallation beendet ----" -ForegroundColor Green
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            "Fehler",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
})

# Apps-Tab bestücken
$tabApps.Controls.Clear()
$tabApps.Controls.AddRange(@($chkAppsWhatIf, $appsPanel, $btnInstallSelected, $btnUninstallSelected))
