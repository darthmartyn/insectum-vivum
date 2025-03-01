param ([string[]]$debugger = 'gdb')

function Write-GSPY {
    param ([string[]]$script = '')
    Out-File -FilePath ".\obj\gs.py" -Force -Append -Encoding "ascii" -InputObject $script
}

$Component_1 = Join-Path $PSScriptRoot "\obj\myprocess.exe"

if (Test-Path -Path $($Component_1))
{
    Start-Process -FilePath $Component_1
    $Component_1_PID = (get-process | Where-Object {$_.Path -eq $Component_1}).id
    Start-Sleep -Seconds 2
    
    if ($debugger -eq "gdb")
    {   
        Start-Process gdb -ArgumentList "-iex=""attach $($Component_1_PID)"" --command=gdb.script" -NoNewWindow -Wait
        Start-Sleep -Seconds 1
        Get-Process | Where-Object {$_.id -eq $Component_1_PID} | Select-Object -First 1 | Stop-Process
    }
    elseif ($debugger -eq "gnatstudio")
    {
        Get-ChildItem obj -Include gs.py -Recurse | Remove-Item

        Write-GSPY -script "import GPS;"
        Write-GSPY -script "d = GPS.Debugger.get(1)"
        Write-GSPY -script "d.send(""file \obj\myprocess.exe"")"
        Write-GSPY -script "f = GPS.File(""myprocess.adb"")"
        Write-GSPY -script "d.send(""attach $($Component_1_PID)"")"
        Write-GSPY -script "d.break_at_location (f,15)"
        Write-GSPY -script "d.break_at_location (f,22)"
        Write-GSPY -script "d.send(""continue"")"

        Start-Process gnatstudio -ArgumentList "--debug --load=python:""obj\gs.py"" -P debugging.gpr" -Wait

        Start-Sleep -Seconds 1
        Get-Process | Where-Object {$_.id -eq $Component_1_PID} | Select-Object -First 1 | Stop-Process
    }
    elseif ($debugger -eq "vscode")
    {
        Get-ChildItem .vscode -Include launch-.json -Recurse | Remove-Item
        $launch = Get-ChildItem .vscode -Include launch-template.json -Recurse | Get-Content -Raw | ConvertFrom-Json

        $launch.configurations[0].processid = "$($Component_1_PID)"
        ConvertTo-Json -InputObject $launch -Depth 10 | Set-Content -Path ".vscode\launch.json"
        Start-Sleep -Seconds 1

        Start-Process code -ArgumentList "--wait --new-window --goto .\src\myprocess.adb:20 $($PSScriptRoot)" -Wait

        Start-Sleep -Seconds 1
        Get-Process | Where-Object {$_.id -eq $Component_1_PID} | Select-Object -First 1 | Stop-Process
    }
}