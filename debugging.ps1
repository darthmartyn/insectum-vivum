param ([string[]]$debugger = 'gdb')

$Component_1 = Join-Path $PSScriptRoot "\obj\myprocess.exe"

if (Test-Path -Path $($Component_1))
{
    Start-Process -FilePath $Component_1
    $Component_1_PID = (get-process | Where-Object {$_.Path -eq $Component_1}).id
    Start-Sleep -Seconds 2
    
    if ($debugger -eq "gdb")
    {   
        Start-Process gdb -ArgumentList "-iex=""attach $($Component_1_PID)"" --command=gdb.script" -NoNewWindow -Wait
    }
    elseif ($debugger -eq "gnatstudio")
    {
        Get-ChildItem obj -Include gs.py -Recurse | Remove-Item

        Out-File -FilePath ".\obj\gs.py" -Force -Append -Encoding "ascii" -InputObject "import GPS;"
        Out-File -FilePath ".\obj\gs.py" -Force -Append -Encoding "ascii" -InputObject "d = GPS.Debugger.get(1)"
        Out-File -FilePath ".\obj\gs.py" -Force -Append -Encoding "ascii" -InputObject "d.send(""file \obj\myprocess.exe"")"
        Out-File -FilePath ".\obj\gs.py" -Force -Append -Encoding "ascii" -InputObject "f = GPS.File(""myprocess.adb"")"
        Out-File -FilePath ".\obj\gs.py" -Force -Append -Encoding "ascii" -InputObject "d.send(""attach $($Component_1_PID)"")"
        Out-File -FilePath ".\obj\gs.py" -Force -Append -Encoding "ascii" -InputObject "d.break_at_location (f,15)"
        Out-File -FilePath ".\obj\gs.py" -Force -Append -Encoding "ascii" -InputObject "d.break_at_location (f,22)"
        Out-File -FilePath ".\obj\gs.py" -Force -Append -Encoding "ascii" -InputObject "d.send(""continue"")"

        Start-Process gnatstudio -ArgumentList "--debug --load=python:""obj\gs.py"" -P debugging.gpr" -Wait
    }
    elseif ($debugger -eq "vscode")
    {
        Get-ChildItem .vscode -Include launch-.json -Recurse | Remove-Item
        $launch = Get-ChildItem .vscode -Include launch-template.json -Recurse | Get-Content -Raw | ConvertFrom-Json

        $launch.configurations[0].processid = "$($Component_1_PID)"
        ConvertTo-Json -InputObject $launch -Depth 10 | Set-Content -Path ".vscode\launch.json"
        Start-Sleep -Seconds 1

        Start-Process code -ArgumentList "-n -g .\src\myprocess.adb:1 $($PSScriptRoot)" -Wait
    }

    Start-Sleep -Seconds 1
    Get-Process | Where-Object {$_.id -eq $Component_1_PID} | Select-Object -First 1 | Stop-Process
}