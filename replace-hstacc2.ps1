# ===============================================================
# replace-hstacc2.ps1
# Reemplaza <HSTACC2> por <HSTACC> en XMLs
# ===============================================================

$XmlPath = ""
$LogPath = ""
$BackupPath = "$XmlPath\_backup"

# ================= Carpetas =================
if (-not (Test-Path $LogPath))   { New-Item -ItemType Directory -Path $LogPath | Out-Null }
if (-not (Test-Path $BackupPath)) { New-Item -ItemType Directory -Path $BackupPath | Out-Null }

$LogFile = Join-Path $LogPath ("replace-hstacc2-{0:yyyyMMdd}.log" -f (Get-Date))

function Log {
    param([string]$msg)
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $msg
    Add-Content -Path $LogFile -Value $line
    Write-Host $msg
}

Log "=== INICIO PROCESO XML ==="

$XmlFiles = Get-ChildItem -Path $XmlPath -Filter "*.xml" -File

foreach ($file in $XmlFiles) {
    try {
        $fullPath = $file.FullName
        $backup   = Join-Path $BackupPath $file.Name

        # Backup del XML original
        Copy-Item $fullPath $backup -Force

        # Leer contenido SIN modificar formato
        $content = Get-Content $fullPath -Raw -Encoding Default

        # Reemplazo EXACTO de etiqueta
        if ($content -match "<HSTACC2>") {
            $content = $content `
                -replace "<HSTACC2>", "<HSTACC>" `
                -replace "</HSTACC2>", "</HSTACC>"

            Set-Content -Path $fullPath -Value $content -Encoding Default

            Log "OK: $($file.Name) → etiqueta reemplazada"
        } else {
            Log "INFO: $($file.Name) → no contiene HSTACC2"
        }
    } catch {
        Log "ERROR: $($file.Name) - $($_.Exception.Message)"
    }
}

Log "=== FIN PROCESO XML ==="
Write-Host "Proceso finalizado correctamente."
