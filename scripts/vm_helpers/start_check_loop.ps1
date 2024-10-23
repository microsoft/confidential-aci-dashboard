param(
  [Parameter()][string]$checkArgs = ""
)
$proc=Start-Process powershell -ArgumentList /c,"C:\vm_helpers\check_loop.ps1 $checkArgs >> C:\check_loop.log 2>&1" -PassThru
$child_pid=$proc.Id.ToString()
echo "$child_pid" > C:\check_loop.pid
