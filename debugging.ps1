Get-ChildItem .vscode -Include launch-.json -Recurse | Remove-Item
$launch = Get-ChildItem .vscode -Include launch-template.json -Recurse | Get-Content -Raw | ConvertFrom-Json

$launch.configurations[0].processid = "$($Component_1_PID)"
ConvertTo-Json -InputObject $launch -Depth 10 | Set-Content -Path ".vscode\launch.json"
Start-Sleep -Seconds 1

Start-Process code -ArgumentList "--wait --new-window --goto .\src\myprocess.adb:20 $($PSScriptRoot)" -Wait

Start-Sleep -Seconds 1
Get-Process | Where-Object {$_.id -eq $Component_1_PID} | Select-Object -First 1 | Stop-Process
