param(
  [Parameter()][string]$additionalChecksScript = "",
  [Parameter()][int]$checkInterval = 30
)
Set-Alias -Name crictl -Value C:\ContainerPlat\crictl.exe
Set-Alias -Name shimdiag -Value C:\ContainerPlat\shimdiag.exe

while ($true) {
  try {
    $time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    echo "Starting check at $time"

    $lcow_dirs = (Get-Item C:\lcow* |% { $_.Name })
    if (!$lcow_dirs) {
      Write-Error "ERROR: No lcow* found in C:\"
      exit 1
    }

    foreach ($lcow_dir_name in $lcow_dirs) {
      $LASTEXITCODE=0
      & "C:\$lcow_dir_name\check.ps1"
      if ($LASTEXITCODE -ne 0) {
        Write-Error "ERROR: C:\$lcow_dir_name\check.ps1 exited with code $LASTEXITCODE"
      } else {
        Write-Output "Checked $lcow_dir_name"
      }
    }

    cd C:\vm_helpers
    if ($additionalChecksScript) {
      $LASTEXITCODE=0
      & ".\$additionalChecksScript"
      if ($LASTEXITCODE -ne 0) {
        Write-Error "ERROR: $additionalChecksScript exited with code $LASTEXITCODE"
      }
    }

    sleep $checkInterval
  } catch {
    Write-Output "ERROR: $_.Exception.ToString()"
    continue
  }
}
