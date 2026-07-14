param(
  [switch]$NoOpen
)

$python = 'C:\Users\hiro\AppData\Local\Programs\Python\Python312\python.exe'
$projectRoot = 'C:\Users\hiro\dog_friend_manager'
$webRoot = Join-Path $projectRoot 'build\web'
$url = 'http://127.0.0.1:8123'

if (-not (Test-Path $python)) {
  throw "Python not found: $python"
}

if (-not (Test-Path $webRoot)) {
  throw "Web build not found: $webRoot"
}

Start-Process `
  -FilePath $python `
  -ArgumentList '-m', 'http.server', '8123', '--directory', $webRoot `
  -WorkingDirectory $projectRoot `
  -WindowStyle Hidden
Start-Sleep -Seconds 2

if (-not $NoOpen) {
  Start-Process $url
}
