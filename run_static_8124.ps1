$projectRoot = 'C:\Users\hiro\dog_friend_manager'
$python = 'C:\Users\hiro\AppData\Local\Programs\Python\Python312\python.exe'
$webRoot = Join-Path $projectRoot 'build\web'

Set-Location $projectRoot

& $python -m http.server 8124 --directory $webRoot
