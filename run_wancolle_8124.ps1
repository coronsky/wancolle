$projectRoot = 'C:\Users\hiro\dog_friend_manager'
$flutter = 'C:\src\flutter\bin\flutter.bat'
$stdout = Join-Path $projectRoot 'flutter_8124.log'
$stderr = Join-Path $projectRoot 'flutter_8124.err'

Set-Location $projectRoot

& $flutter run -d web-server --web-port 8124 --web-hostname 127.0.0.1 1>> $stdout 2>> $stderr
