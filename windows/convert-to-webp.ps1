# image-to-webp (Windows) — Convert to WebP via "Send to"
# Receives selected files as arguments from the SendTo context menu.
#
# Requires: cwebp.exe (downloads via install.ps1) and Windows PowerShell 5.1+.
#
# Usage (normally invoked by the SendTo .cmd):
#   powershell -NoProfile -ExecutionPolicy Bypass -File convert-to-webp.ps1 <file1> <file2> ...
param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Files
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
$Choices = @(
    @{ Label = '40% - Low (2 core)';  Q = 40; N = 2  },
    @{ Label = '40% - Mid (4 core)';  Q = 40; N = 4  },
    @{ Label = '40% - High (8 core)'; Q = 40; N = 8  },
    @{ Label = '50% - Low (2 core)';  Q = 50; N = 2  },
    @{ Label = '50% - Mid (4 core)';  Q = 50; N = 4  },
    @{ Label = '50% - High (8 core)'; Q = 50; N = 8  },
    @{ Label = '65% - Low (2 core)';  Q = 65; N = 2  },
    @{ Label = '65% - Mid (4 core)';  Q = 65; N = 4  },
    @{ Label = '65% - High (8 core)'; Q = 65; N = 8  }
)
$DefaultIndex = 5   # "50% - High (8 core)"
$ValidExt = @('.jpg', '.jpeg', '.png', '.tiff', '.bmp')

# ---------------------------------------------------------------------------
# Locate cwebp.exe
# ---------------------------------------------------------------------------
function Find-Cwebp {
    # 1. In PATH
    $inPath = Get-Command cwebp.exe -ErrorAction SilentlyContinue
    if ($inPath) { return $inPath.Source }

    # 2. Alongside this script
    $local = Join-Path $PSScriptRoot 'cwebp.exe'
    if (Test-Path $local) { return $local }

    # 3. Installed location from install.ps1
    $installed = Join-Path $env:LOCALAPPDATA 'image-to-webp\cwebp.exe'
    if (Test-Path $installed) { return $installed }

    return $null
}

# ---------------------------------------------------------------------------
# GUI dialog (Windows Forms)
# ---------------------------------------------------------------------------
function Show-ChoiceDialog {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Convert to WebP'
    $form.Size = New-Object System.Drawing.Size(360, 330)
    $form.StartPosition = 'CenterScreen'
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.KeyPreview = $true

    $label = New-Object System.Windows.Forms.Label
    $label.Text = 'Pilih kualiti & mode:'
    $label.Location = New-Object System.Drawing.Point(16, 16)
    $label.Size = New-Object System.Drawing.Size(320, 24)
    $label.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($label)

    $list = New-Object System.Windows.Forms.ListBox
    $list.Location = New-Object System.Drawing.Point(16, 46)
    $list.Size = New-Object System.Drawing.Size(310, 180)
    $list.Font = New-Object System.Drawing.Font('Segoe UI', 10)
    foreach ($c in $Choices) { [void]$list.Items.Add($c.Label) }
    $list.SelectedIndex = $DefaultIndex
    $form.Controls.Add($list)

    $ok = New-Object System.Windows.Forms.Button
    $ok.Text = 'OK'
    $ok.Location = New-Object System.Drawing.Point(148, 240)
    $ok.Size = New-Object System.Drawing.Size(84, 30)
    $ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $ok
    $form.Controls.Add($ok)

    $cancel = New-Object System.Windows.Forms.Button
    $cancel.Text = 'Cancel'
    $cancel.Location = New-Object System.Drawing.Point(242, 240)
    $cancel.Size = New-Object System.Drawing.Size(84, 30)
    $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancel
    $form.Controls.Add($cancel)

    $hint = New-Object System.Windows.Forms.Label
    $hint.Text = 'Enter = pilih · Esc = batal'
    $hint.Location = New-Object System.Drawing.Point(16, 278)
    $hint.Size = New-Object System.Drawing.Size(310, 20)
    $hint.ForeColor = [System.Drawing.Color]::Gray
    $hint.Font = New-Object System.Drawing.Font('Segoe UI', 8)
    $form.Controls.Add($hint)

    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK -and $list.SelectedIndex -ge 0) {
        return $Choices[$list.SelectedIndex]
    }
    return $null
}

# ---------------------------------------------------------------------------
# Notifications
# ---------------------------------------------------------------------------
function Show-Toast([string]$Title, [string]$Message) {
    Add-Type -AssemblyName System.Windows.Forms
    $notify = New-Object System.Windows.Forms.NotifyIcon
    $notify.Icon = [System.Drawing.SystemIcons]::Information
    $notify.Visible = $true
    $notify.ShowBalloonTip(3000, $Title, $Message, [System.Windows.Forms.ToolTipIcon]::Info)
    Start-Sleep -Milliseconds 3000
    $notify.Dispose()
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
if (-not $Files -or $Files.Count -eq 0) {
    Show-Toast 'Convert to WebP' 'Tiada fail dipilih.'
    exit 0
}

$cwebp = Find-Cwebp
if (-not $cwebp) {
    Show-Toast 'Convert to WebP' 'cwebp.exe tidak dijumpai. Jalankan install.ps1 dulu.'
    exit 1
}

# Filter to valid image extensions
$images = @($Files | Where-Object {
    $ext = [System.IO.Path]::GetExtension($_).ToLowerInvariant()
    $ValidExt -contains $ext
})

if ($images.Count -eq 0) {
    Show-Toast 'Convert to WebP' 'Tiada fail imej yang sah (jpg/png/tiff/bmp).'
    exit 0
}

$choice = Show-ChoiceDialog
if (-not $choice) {
    exit 0   # user cancelled
}

$Q = $choice.Q
$N = $choice.N

# Run cwebp in parallel, N at a time (one file per core)
$jobs = @()
$running = @()

foreach ($img in $images) {
    $dir   = [System.IO.Path]::GetDirectoryName($img)
    $base  = [System.IO.Path]::GetFileNameWithoutExtension($img)
    $out   = Join-Path $dir ($base + '.webp')

    # Wait if we already have N running
    while ($running.Count -ge $N) {
        $finished = @($running | Where-Object { $_.HasExited })
        if ($finished.Count -gt 0) {
            $running = @($running | Where-Object { -not $_.HasExited })
        } else {
            Start-Sleep -Milliseconds 100
        }
    }

    $p = Start-Process -FilePath $cwebp `
        -ArgumentList @('-q', [string]$Q, "`"$img`"", '-o', "`"$out`"") `
        -NoNewWindow -PassThru
    $jobs += $p
    $running += $p
}

# Wait for all to finish
foreach ($j in $jobs) { $j.WaitForExit() | Out-Null }

$converted = @($jobs | Where-Object { $_.ExitCode -eq 0 }).Count

Show-Toast 'Convert to WebP' "$converted/$($images.Count) fail ditukar ke WebP (kualiti $Q%)."
