$debugger = $env:DEBUGGER

$Component_1 = Join-Path $PSScriptRoot "\obj\myprocess.exe"

Start-Process -FilePath $Component_1
$Component_1_PID = (get-process | Where-Object {$_.Path -eq $Component_1}).id

Write-Host "Waiting a few seconds for $($Component_1) to start.."
Start-Sleep -Seconds 2

if ($env:DEBUGGER -eq "gdb") {   
    Start-Process gdb -ArgumentList "-iex=""attach $($Component_1_PID)"" --command=gdb.script" -NoNewWindow -Wait

    Start-Sleep -Seconds 1
    Get-Process | Where-Object {$_.id -eq $Component_1_PID} | Select-Object -First 1 | Stop-Process
}
elseif ($env:DEBUGGER -eq "gnatstudio") {
    Get-ChildItem obj -Include gs.py -Recurse | Remove-Item

    Out-File -FilePath ".\obj\gs.py" -Force -Append -Encoding "ascii" -InputObject "import GPS;"
    Out-File -FilePath ".\obj\gs.py" -Force -Append -Encoding "ascii" -InputObject "d = GPS.Debugger.get(1)"
    Out-File -FilePath ".\obj\gs.py" -Force -Append -Encoding "ascii" -InputObject "d.send(""file \obj\myprocess.exe"")"
    Out-File -FilePath ".\obj\gs.py" -Force -Append -Encoding "ascii" -InputObject "f = GPS.File(""myprocess.adb"")"
    Out-File -FilePath ".\obj\gs.py" -Force -Append -Encoding "ascii" -InputObject "d.send(""attach $($Component_1_PID)"")"
    Out-File -FilePath ".\obj\gs.py" -Force -Append -Encoding "ascii" -InputObject "d.break_at_location (f,15)"
    Out-File -FilePath ".\obj\gs.py" -Force -Append -Encoding "ascii" -InputObject "d.send(""next"")"

    Start-Process gnatstudio -ArgumentList "--debug --load=python:""obj\gs.py"" -P debugging.gpr" -Wait

    Start-Sleep -Seconds 1
    Get-Process | Where-Object {$_.id -eq $Component_1_PID} | Select-Object -First 1 | Stop-Process
}
elseif ($env:DEBUGGER -eq "vscode") {

    New-Item -Path ".vscode" -Force -ItemType Directory | Out-Null
    Get-ChildItem .vscode -Include launch.json -Recurse | Remove-Item

    Out-File -FilePath ".vscode\launch.json" -Force -Append -Encoding "ascii" -InputObject "{"
    Out-File -FilePath ".vscode\launch.json" -Force -Append -Encoding "ascii" -InputObject """configurations"": ["
    Out-File -FilePath ".vscode\launch.json" -Force -Append -Encoding "ascii" -InputObject "{"
    Out-File -FilePath ".vscode\launch.json" -Force -Append -Encoding "ascii" -InputObject """type"": ""ada"","
    Out-File -FilePath ".vscode\launch.json" -Force -Append -Encoding "ascii" -InputObject """request"": ""attach"","
    Out-File -FilePath ".vscode\launch.json" -Force -Append -Encoding "ascii" -InputObject """program"": ""$($Component_1)"","
    Out-File -FilePath ".vscode\launch.json" -Force -Append -Encoding "ascii" -InputObject """processId"": ""$($Component_1_PID)"","   

    Out-File -FilePath ".vscode\launch.json" -Force -Append -Encoding "ascii" -InputObject "}"
    Out-File -FilePath ".vscode\launch.json" -Force -Append -Encoding "ascii" -InputObject "]"
    Out-File -FilePath ".vscode\launch.json" -Force -Append -Encoding "ascii" -InputObject "}"

    Start-Sleep -Seconds 1
    Get-Process | Where-Object {$_.id -eq $Component_1_PID} | Select-Object -First 1 | Stop-Process
}