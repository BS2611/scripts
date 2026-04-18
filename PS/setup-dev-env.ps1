#Requires -RunAsAdministrator
# ============================================================
#  DEV ENVIRONMENT SETUP  |  Interactive & Modular  |  v2.1
#  Run as Administrator in PowerShell
# ============================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "SilentlyContinue"

# winget writes animated progress to the console; piping it to Out-Null (or into
# PowerShell cmdlets) often looks "stuck" or actually deadlocks. Always run
# winget via Start-Process, or with no stdout/stderr redirection.
$script:WingetCommonArgs = @(
    '--disable-interactivity'
    '--accept-source-agreements'
)

# ── Colour helpers ───────────────────────────────────────────
function Write-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "  =====================================================" -ForegroundColor Cyan
    Write-Host "       DEV ENVIRONMENT SETUP  |  Interactive v2.1      " -ForegroundColor Cyan
    Write-Host "  =====================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step   { param($msg) Write-Host "  >> $msg" -ForegroundColor Cyan }
function Write-Ok     { param($msg) Write-Host "  [OK]  $msg" -ForegroundColor Green }
function Write-Skip   { param($msg) Write-Host "  [--]  $msg" -ForegroundColor DarkGray }
function Write-Warn   { param($msg) Write-Host "  [!!]  $msg" -ForegroundColor Yellow }
function Write-Fail   { param($msg) Write-Host "  [XX]  $msg" -ForegroundColor Red }
function Write-Header { param($msg) Write-Host "`n  ==  $msg  ==" -ForegroundColor Magenta }

# ── Log file ─────────────────────────────────────────────────
$LogFile = "$env:USERPROFILE\dev-setup-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
function Write-Log { param($msg) Add-Content -Path $LogFile -Value "[$(Get-Date -Format 'HH:mm:ss')] $msg" }

# ════════════════════════════════════════════════════════════
#  APP CATALOGUE
# ════════════════════════════════════════════════════════════
$AppCategories = [ordered]@{

    "Browsers" = @(
        @{ name = "Google Chrome";                  id = "Google.Chrome" }
        @{ name = "Mozilla Firefox";                id = "Mozilla.Firefox" }
        @{ name = "Firefox Developer Edition";      id = "Mozilla.Firefox.DeveloperEdition" }
        @{ name = "Brave Browser";                  id = "Brave.Brave" }
        @{ name = "Microsoft Edge";                 id = "Microsoft.Edge" }
    )

    "IDEs and Editors" = @(
        @{ name = "Visual Studio Code";             id = "Microsoft.VisualStudioCode" }
        @{ name = "IntelliJ IDEA Community";        id = "JetBrains.IntelliJIDEA.Community" }
        @{ name = "PyCharm Professional";           id = "JetBrains.PyCharm.Professional" }
        @{ name = "WebStorm";                       id = "JetBrains.WebStorm" }
        @{ name = "Notepad++";                      id = "Notepad++.Notepad++" }
        @{ name = "Neovim";                         id = "Neovim.Neovim" }
        @{ name = "Cursor";                         id = "Anysphere.Cursor" }
    )

    "Languages and Runtimes" = @(
        @{ name = "Node.js LTS";                    id = "OpenJS.NodeJS.LTS" }
        @{ name = "Python 3.12";                    id = "Python.Python.3.12" }
        @{ name = "Microsoft OpenJDK 21";           id = "Microsoft.OpenJDK.21" }
        @{ name = "Go";                             id = "GoLang.Go" }
        @{ name = "Rust (rustup)";                  id = "Rustlang.Rustup" }
        @{ name = ".NET SDK 8";                     id = "Microsoft.DotNet.SDK.8" }
    )

    "Dev Tools" = @(
        @{ name = "Git";                            id = "Git.Git" }
        @{ name = "GitHub CLI";                     id = "GitHub.cli" }
        @{ name = "Docker Desktop";                 id = "Docker.DockerDesktop" }
        @{ name = "Postman";                        id = "Postman.Postman" }
        @{ name = "Insomnia";                       id = "Kong.Insomnia" }
        @{ name = "Windows Terminal";               id = "Microsoft.WindowsTerminal" }
        @{ name = "Oh My Posh";                     id = "JanDeDobbeleer.OhMyPosh" }
        @{ name = "DBeaver Community";              id = "dbeaver.dbeaver" }
        @{ name = "HeidiSQL";                       id = "HeidiSQL.HeidiSQL" }
        @{ name = "kubectl";                        id = "Kubernetes.kubectl" }
    )

    "Utilities" = @(
        @{ name = "Microsoft PowerToys";            id = "Microsoft.PowerToys" }
        @{ name = "7-Zip";                          id = "7zip.7zip" }
        @{ name = "Adobe Acrobat Reader 64-bit";    id = "Adobe.Acrobat.Reader.64-bit" }
        @{ name = "ShareX";                         id = "ShareX.ShareX" }
        @{ name = "Everything (Fast Search)";       id = "voidtools.Everything" }
        @{ name = "WinSCP";                         id = "WinSCP.WinSCP" }
    )

    "Communication" = @(
        @{ name = "Zoom";                           id = "Zoom.Zoom" }
        @{ name = "Slack";                          id = "SlackTechnologies.Slack" }
        @{ name = "Microsoft Teams";                id = "Microsoft.Teams" }
        @{ name = "Discord";                        id = "Discord.Discord" }
    )
}

# ════════════════════════════════════════════════════════════
#  WINDOWS DEV SETTINGS
# ════════════════════════════════════════════════════════════
$DevSettings = [ordered]@{
    "Show file extensions in Explorer"      = {
        Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" HideFileExt 0
    }
    "Show hidden files and folders"         = {
        Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" Hidden 1
    }
    "Show protected OS files"               = {
        Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ShowSuperHidden 1
    }
    "Show full path in Explorer title bar"  = {
        Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" FullPath 1
    }
    "Enable long path support"              = {
        Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" LongPathsEnabled 1
    }
    "Enable Windows Developer Mode"         = {
        $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
        New-Item -Path $key -Force | Out-Null
        Set-ItemProperty $key AllowDevelopmentWithoutDevLicense 1
    }
    "Enable Hyper-V (required for Docker)"  = {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart | Out-Null
    }
    "Enable WSL2"                           = {
        wsl --install --no-distribution 2>$null
        wsl --set-default-version 2 2>$null
    }
    "Enable Virtual Machine Platform"       = {
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart | Out-Null
    }
    "Set PowerShell execution policy"       = {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    }
    "Add Defender exclusion for dev folders" = {
        Add-MpPreference -ExclusionPath "$env:USERPROFILE\dev" -ErrorAction SilentlyContinue
        Add-MpPreference -ExclusionPath "$env:USERPROFILE\projects" -ErrorAction SilentlyContinue
    }
}

# ════════════════════════════════════════════════════════════
#  INTERACTIVE MULTI-SELECT MENU
#  Up/Down arrows to navigate, SPACE to toggle
#  A = select all, N = clear all, ENTER = confirm
# ════════════════════════════════════════════════════════════
function Show-MultiSelectMenu {
    param(
        [string]   $Title,
        [string[]] $Items,
        [bool[]]   $Selected
    )

    $idx  = 0
    $done = $false

    while (-not $done) {
        Clear-Host
        Write-Banner
        Write-Host "  $Title" -ForegroundColor White
        Write-Host "  Up/Down = Navigate   Space = Toggle   A = All   N = None   Enter = Confirm" -ForegroundColor DarkGray
        Write-Host ""

        for ($i = 0; $i -lt $Items.Count; $i++) {
            $box    = if ($Selected[$i]) { "[X]" } else { "[ ]" }
            $pre    = if ($i -eq $idx)   { "  > " } else { "    " }
            $colour = if ($i -eq $idx)   { "Yellow" } elseif ($Selected[$i]) { "Green" } else { "White" }
            Write-Host "$pre$box  $($Items[$i])" -ForegroundColor $colour
        }

        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        switch ($key.VirtualKeyCode) {
            38 { if ($idx -gt 0) { $idx-- } }
            40 { if ($idx -lt ($Items.Count - 1)) { $idx++ } }
            32 { $Selected[$idx] = -not $Selected[$idx] }
            65 { for ($i = 0; $i -lt $Selected.Count; $i++) { $Selected[$i] = $true } }
            78 { for ($i = 0; $i -lt $Selected.Count; $i++) { $Selected[$i] = $false } }
            13 { $done = $true }
        }
    }
    return , $Selected
}

# ── Yes / No prompt ──────────────────────────────────────────
function Confirm-Step {
    param([string]$msg, [bool]$DefaultYes = $true)
    $hint = if ($DefaultYes) { "[Y/n]" } else { "[y/N]" }
    Write-Host "  $msg $hint " -ForegroundColor White -NoNewline
    $r = Read-Host
    if ($r -eq "") { return $DefaultYes }
    return $r -match "^[Yy]"
}

# ── Run winget without pipeline redirection (avoids hangs) ───
function Invoke-WingetProcess {
    param(
        [Parameter(Mandatory)][string[]] $Arguments,
        [switch] $CaptureOutput
    )
    if ($CaptureOutput) {
        $out = Join-Path $env:TEMP ("winget-out-{0}.txt" -f [Guid]::NewGuid().ToString('n'))
        $err = Join-Path $env:TEMP ("winget-err-{0}.txt" -f [Guid]::NewGuid().ToString('n'))
        try {
            $p = Start-Process -FilePath 'winget' -ArgumentList $Arguments -Wait -PassThru -NoNewWindow `
                -RedirectStandardOutput $out -RedirectStandardError $err
            $stdout = Get-Content -LiteralPath $out -Raw -ErrorAction SilentlyContinue
            $stderr = Get-Content -LiteralPath $err -Raw -ErrorAction SilentlyContinue
            return [PSCustomObject]@{
                ExitCode = $p.ExitCode
                Output   = ($stdout + $stderr)
            }
        } finally {
            Remove-Item -LiteralPath $out, $err -ErrorAction SilentlyContinue
        }
    }

    $p = Start-Process -FilePath 'winget' -ArgumentList $Arguments -Wait -PassThru -NoNewWindow
    return [PSCustomObject]@{ ExitCode = $p.ExitCode; Output = $null }
}

# ── Install one app via winget ────────────────────────────────
function Install-App {
    param([hashtable]$app)
    $listArgs = @(
        'list', '--id', $app.id, '--exact'
    ) + $script:WingetCommonArgs
    $listResult = Invoke-WingetProcess -Arguments $listArgs -CaptureOutput
    if ($listResult.ExitCode -eq 0 -and ($listResult.Output -match [regex]::Escape($app.id))) {
        Write-Skip "Already installed: $($app.name)"
        Write-Log "SKIP: $($app.name)"
        return
    }

    Write-Step "Installing $($app.name)..."
    $installArgs = @(
        'install', '--id', $app.id, '--exact', '--silent',
        '--accept-package-agreements'
    ) + $script:WingetCommonArgs
    $inst = Invoke-WingetProcess -Arguments $installArgs -CaptureOutput
    $code = $inst.ExitCode
    if ($code -eq 0 -or $code -eq -1978335189) {
        Write-Ok "Installed: $($app.name)"
        Write-Log "OK: $($app.name)"
    } else {
        Write-Fail "Failed: $($app.name)  (exit $code)"
        Write-Log "FAIL: $($app.name) exit=$code"
        if ($inst.Output) { Write-Log ($inst.Output.Trim()) }
    }
}

# ── Apply one dev setting ─────────────────────────────────────
function Apply-Setting {
    param([string]$name, [scriptblock]$action)
    try {
        & $action
        Write-Ok $name
        Write-Log "SETTING OK: $name"
    } catch {
        Write-Fail "$name  --  $_"
        Write-Log "SETTING FAIL: $name -- $_"
    }
}

# ════════════════════════════════════════════════════════════
#  MAIN FLOW
# ════════════════════════════════════════════════════════════

Write-Banner
Write-Log "=== Dev Setup Started at $(Get-Date) ==="

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Fail "winget was not found. Install App Installer from the Microsoft Store, then run this script again."
    Write-Log "FAIL: winget missing"
    exit 1
}

# ── 1. Refresh winget ────────────────────────────────────────
Write-Header "Step 1  --  Update Package Sources"
Write-Step "Refreshing winget sources (progress will appear below; first run can take several minutes)..."
$srcArgs = @('source', 'update') + $script:WingetCommonArgs
$src = Invoke-WingetProcess -Arguments $srcArgs
if ($src.ExitCode -eq 0) {
    Write-Ok "Sources up to date"
} else {
    Write-Warn "winget source update finished with exit $($src.ExitCode); continuing anyway."
    Write-Log "WARN: winget source update exit=$($src.ExitCode)"
}

# ── 2. Choose categories ─────────────────────────────────────
$catNames = @($AppCategories.Keys)
$catSel   = @($catNames | ForEach-Object { $true })
$catSel   = Show-MultiSelectMenu -Title "STEP 2  |  Select App Categories" -Items $catNames -Selected $catSel

# ── 3. Choose individual apps ────────────────────────────────
$appsToInstall = [System.Collections.Generic.List[hashtable]]::new()

for ($ci = 0; $ci -lt $catNames.Count; $ci++) {
    if (-not $catSel[$ci]) { continue }

    $catName  = $catNames[$ci]
    $catApps  = $AppCategories[$catName]
    $appNames = @($catApps | ForEach-Object { $_.name })
    $appSel   = @($appNames | ForEach-Object { $true })

    $appSel = Show-MultiSelectMenu -Title "STEP 2  |  [$catName]  --  Pick Apps" -Items $appNames -Selected $appSel

    for ($ai = 0; $ai -lt $catApps.Count; $ai++) {
        if ($appSel[$ai]) { $appsToInstall.Add($catApps[$ai]) }
    }
}

# ── 4. Choose dev settings ───────────────────────────────────
$settingNames = @($DevSettings.Keys)
$settingSel   = @($settingNames | ForEach-Object { $true })
$settingSel   = Show-MultiSelectMenu -Title "STEP 3  |  Windows Developer Settings" -Items $settingNames -Selected $settingSel

# ── 5. Git identity ──────────────────────────────────────────
Clear-Host; Write-Banner
Write-Header "Step 4  --  Git Global Configuration"
$doGit    = Confirm-Step "Configure global Git identity?"
$gitName  = ""
$gitEmail = ""
if ($doGit) {
    Write-Host "  Full Name : " -NoNewline -ForegroundColor Cyan; $gitName  = Read-Host
    Write-Host "  Email     : " -NoNewline -ForegroundColor Cyan; $gitEmail = Read-Host
}

# ── 6. SSH key ───────────────────────────────────────────────
Write-Header "Step 5  --  SSH Key"
$doSSH    = Confirm-Step "Generate a new ed25519 SSH key for GitHub/GitLab?"
$sshEmail = ""
if ($doSSH) {
    Write-Host "  Email for key: " -NoNewline -ForegroundColor Cyan; $sshEmail = Read-Host
}

# ── 7. VS Code extensions ────────────────────────────────────
$vscodeExtensions = @(
    "dbaeumer.vscode-eslint"
    "esbenp.prettier-vscode"
    "ms-python.python"
    "ms-vscode.powershell"
    "eamodio.gitlens"
    "PKief.material-icon-theme"
    "GitHub.copilot"
    "ms-azuretools.vscode-docker"
    "ritwickdey.LiveServer"
    "formulahendry.auto-rename-tag"
    "streetsidesoftware.code-spell-checker"
    "yzhang.markdown-all-in-one"
    "ms-vscode-remote.remote-containers"
)

$doVSCodeExt  = $false
$vsCodeChosen = $appsToInstall | Where-Object { $_.id -eq "Microsoft.VisualStudioCode" }
if ($vsCodeChosen) {
    Write-Header "Step 6  --  VS Code Extensions"
    $doVSCodeExt = Confirm-Step "Install recommended VS Code extensions?"
}

# ── 8. Dev folders ───────────────────────────────────────────
Write-Header "Step 7  --  Project Folder Structure"
$doFolders = Confirm-Step "Create dev folder structure under $env:USERPROFILE\dev ?"

# ── Summary ──────────────────────────────────────────────────
Clear-Host; Write-Banner
Write-Header "Review"
$enabledSettings = ($settingSel | Where-Object { $_ } | Measure-Object).Count
Write-Host "  Apps to install       : $($appsToInstall.Count)" -ForegroundColor White
Write-Host "  Dev settings to apply : $enabledSettings" -ForegroundColor White
if ($gitName)     { Write-Host "  Git identity          : $gitName ($gitEmail)" -ForegroundColor White }
if ($doSSH)       { Write-Host "  SSH key               : will be generated for $sshEmail" -ForegroundColor White }
if ($doVSCodeExt) { Write-Host "  VS Code extensions    : $($vscodeExtensions.Count) extensions" -ForegroundColor White }
if ($doFolders)   { Write-Host "  Dev folders           : will be created" -ForegroundColor White }
Write-Host ""

if (-not (Confirm-Step "Start setup now?")) {
    Write-Warn "Setup cancelled. No changes were made."
    exit 0
}

# ════════════════════════════════════════════════════════════
#  EXECUTE
# ════════════════════════════════════════════════════════════

# -- Install apps ─────────────────────────────────────────────
Write-Header "Installing Applications  ($($appsToInstall.Count) selected)"
foreach ($app in $appsToInstall) { Install-App $app }

# -- Apply Windows dev settings ───────────────────────────────
Write-Header "Applying Developer Settings"
for ($si = 0; $si -lt $settingNames.Count; $si++) {
    if ($settingSel[$si]) {
        Apply-Setting -name $settingNames[$si] -action $DevSettings[$settingNames[$si]]
    }
}

# -- Configure Git ────────────────────────────────────────────
if ($gitName -and $gitEmail) {
    Write-Header "Configuring Git Globals"
    git config --global user.name           "$gitName"
    git config --global user.email          "$gitEmail"
    git config --global core.autocrlf       input
    git config --global core.longpaths      true
    git config --global init.defaultBranch  main
    git config --global pull.rebase         false
    git config --global core.editor         "code --wait"
    Write-Ok "Git configured for $gitName"
    Write-Log "Git configured: $gitName / $gitEmail"
}

# -- Generate SSH key ─────────────────────────────────────────
if ($doSSH -and $sshEmail) {
    Write-Header "Generating SSH Key"
    $sshDir  = "$env:USERPROFILE\.ssh"
    $sshPath = "$sshDir\id_ed25519"

    if (Test-Path $sshPath) {
        Write-Skip "Key already exists at $sshPath -- skipping"
    } else {
        New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
        ssh-keygen -t ed25519 -C "$sshEmail" -f "$sshPath" -N '""'
        Write-Ok "Key written to $sshPath"
        Write-Log "SSH key generated for $sshEmail"

        $pubKey = Get-Content "$sshPath.pub" -Raw
        Write-Host ""
        Write-Host "  +--- Public Key (paste into GitHub -> Settings -> SSH Keys) ---+" -ForegroundColor Cyan
        Write-Host "  $pubKey" -ForegroundColor White
        Write-Host "  +---------------------------------------------------------------+" -ForegroundColor Cyan
        Set-Clipboard -Value $pubKey
        Write-Ok "Public key copied to clipboard!"
    }

    Write-Step "Enabling ssh-agent service..."
    Set-Service ssh-agent -StartupType Automatic -ErrorAction SilentlyContinue
    Start-Service ssh-agent -ErrorAction SilentlyContinue
    ssh-add "$sshPath" 2>$null
    Write-Ok "Key added to ssh-agent"
}

# -- VS Code extensions ───────────────────────────────────────
if ($doVSCodeExt) {
    Write-Header "Installing VS Code Extensions"
    Start-Sleep -Seconds 3
    foreach ($ext in $vscodeExtensions) {
        Write-Step $ext
        code --install-extension $ext --force 2>$null
        if ($LASTEXITCODE -eq 0) { Write-Ok $ext } else { Write-Warn "Could not install $ext (try manually)" }
    }
}

# -- Create project folders ───────────────────────────────────
if ($doFolders) {
    Write-Header "Creating Dev Folder Structure"
    $folders = @(
        "$env:USERPROFILE\dev\projects"
        "$env:USERPROFILE\dev\sandbox"
        "$env:USERPROFILE\dev\tools"
        "$env:USERPROFILE\dev\notes"
        "$env:USERPROFILE\dev\.dotfiles"
    )
    foreach ($f in $folders) {
        New-Item -ItemType Directory -Path $f -Force | Out-Null
        Write-Ok $f
    }
    Write-Log "Dev folders created"
}

# -- Refresh Explorer ─────────────────────────────────────────
Write-Header "Refreshing Windows Shell"
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 1200
Start-Process explorer
Write-Ok "Explorer restarted"

# ════════════════════════════════════════════════════════════
#  DONE
# ════════════════════════════════════════════════════════════
Clear-Host
Write-Banner

Write-Host "  +============================================================+" -ForegroundColor Green
Write-Host "  |                                                            |" -ForegroundColor Green
Write-Host "  |   Setup Complete!  Your machine is dev-ready.             |" -ForegroundColor Green
Write-Host "  |                                                            |" -ForegroundColor Green
Write-Host "  +============================================================+" -ForegroundColor Green
Write-Host ""
Write-Host "  Log saved to: $LogFile" -ForegroundColor DarkGray
Write-Host ""
Write-Warn "Some changes (WSL2, Hyper-V, Developer Mode) require a reboot."
Write-Host ""

if (Confirm-Step "Reboot now to apply all changes?") {
    Restart-Computer -Force
} else {
    Write-Host "  Remember to reboot when ready!" -ForegroundColor Yellow
    Write-Host ""
}
