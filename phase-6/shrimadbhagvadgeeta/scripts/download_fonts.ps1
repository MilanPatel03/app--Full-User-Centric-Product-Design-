<#
.SYNOPSIS
    Downloads and installs font files for the Shrimad Bhagavad Gita app.

.DESCRIPTION
    Downloads Inter, Noto Serif, and Noto Serif Devanagari from the official
    Google Fonts GitHub repository into assets/fonts/.

    After running this script:
      1. Open pubspec.yaml
      2. Uncomment the entire "fonts:" section (lines marked with #)
      3. Run: flutter pub get
      4. Run: flutter run — fonts are now fully bundled, zero network required.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts/download_fonts.ps1
#>

$ErrorActionPreference = "Stop"
$root     = Split-Path $PSScriptRoot -Parent
$fontsDir = Join-Path $root "assets\fonts"
$baseGF   = "https://github.com/google/fonts/raw/HEAD"
$baseNoto = "https://github.com/notofonts/noto-serif-devanagari/raw/HEAD"

New-Item -ItemType Directory -Force -Path $fontsDir | Out-Null
Write-Host ""
Write-Host "  Downloading fonts to: $fontsDir" -ForegroundColor Yellow
Write-Host ""

function Get-Font {
    param([string]$Url, [string]$File)
    $dest = Join-Path $fontsDir $File
    Write-Host "  ↓ $File" -NoNewline
    try {
        Invoke-WebRequest -Uri $Url -OutFile $dest -UseBasicParsing
        Write-Host "  ✓" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ FAILED — $_" -ForegroundColor Red
        Write-Host "    Download manually from: fonts.google.com" -ForegroundColor DarkGray
    }
}

# ── Inter (UI utility font) ───────────────────────────────────────────────────
Write-Host "  Inter (UI / Utility)" -ForegroundColor Cyan
Get-Font "$baseGF/ofl/inter/static/Inter-Regular.ttf"   "Inter-Regular.ttf"
Get-Font "$baseGF/ofl/inter/static/Inter-Medium.ttf"    "Inter-Medium.ttf"
Get-Font "$baseGF/ofl/inter/static/Inter-SemiBold.ttf"  "Inter-SemiBold.ttf"
Get-Font "$baseGF/ofl/inter/static/Inter-Bold.ttf"      "Inter-Bold.ttf"

# ── Noto Serif (English wisdom font) ─────────────────────────────────────────
Write-Host ""
Write-Host "  Noto Serif (English Wisdom)" -ForegroundColor Cyan
Get-Font "$baseGF/ofl/notoserif/static/NotoSerif-Regular.ttf" "NotoSerif-Regular.ttf"
Get-Font "$baseGF/ofl/notoserif/static/NotoSerif-Italic.ttf"  "NotoSerif-Italic.ttf"
Get-Font "$baseGF/ofl/notoserif/static/NotoSerif-Medium.ttf"  "NotoSerif-Medium.ttf"
Get-Font "$baseGF/ofl/notoserif/static/NotoSerif-Bold.ttf"    "NotoSerif-Bold.ttf"

# ── Noto Serif Devanagari (Sanskrit shlok font) ───────────────────────────────
Write-Host ""
Write-Host "  Noto Serif Devanagari (Sanskrit)" -ForegroundColor Cyan
Get-Font "$baseNoto/fonts/ttf/NotoSerifDevanagari-Regular.ttf" "NotoSerifDevanagari-Regular.ttf"
Get-Font "$baseNoto/fonts/ttf/NotoSerifDevanagari-Medium.ttf"  "NotoSerifDevanagari-Medium.ttf"
Get-Font "$baseNoto/fonts/ttf/NotoSerifDevanagari-Bold.ttf"    "NotoSerifDevanagari-Bold.ttf"

# ── Done ──────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  Download complete." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor Cyan
Write-Host "    1. Open pubspec.yaml"
Write-Host "    2. Uncomment the 'fonts:' section"
Write-Host "    3. Run: flutter pub get"
Write-Host "    4. Run: flutter run"
Write-Host ""
