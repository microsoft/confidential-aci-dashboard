$pidFile="C:\check_loop.pid"
if (Test-Path $pidFile) {
  $child_pid=Get-Content $pidFile
  (Get-Process -Id $child_pid).Kill()
  Remove-Item $pidFile
}
