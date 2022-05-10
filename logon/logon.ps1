
function Test-Administrator {
    $User = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

$ScriptDirectory = $env:APPDATA + "\Intune"
# Check if directory already exists.
if (!(Get-Item -Path $ScriptDirectory)) {
    New-Item -Path $env:APPDATA -Name "Intune" -ItemType "directory"
}

# Logfile
$ScriptLogFilePath = $ScriptDirectory + "\ConnectAzureFileShare.log"


if (Test-Administrator) {
    # If running as administrator, create scheduled task as current user.
    Add-Content -Path $ScriptLogFilePath -Value ((Get-Date).ToString() + ": " + "Running as administrator.")

    $ScriptFilePath = $ScriptDirectory + "\ConnectAzureFileShare_K.ps1"

    $Script = '$connectTestResult = Test-NetConnection -ComputerName temporaryfile.file.core.windows.net -Port 445
    if ($connectTestResult.TcpTestSucceeded) {
        # Save the password so the drive will persist on reboot
        cmd.exe /C "cmdkey /add:`"example.file.core.windows.net`" /user:`"Azure\example`" /pass:`"mlkfquivIPIUHeljvPIUVeepReallycomplicatedstring==`""
        # Mount the drive
        New-PSDrive -Name K -PSProvider FileSystem -Root "\\example.file.core.windows.net\example" -Persist
    } else {
        Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
    }'

    $Script | Out-File -FilePath $ScriptFilePath

    $PSexe = Join-Path $PSHOME "powershell.exe"
    $Arguments = "-file $($ScriptFilePath) -WindowStyle Hidden -ExecutionPolicy Bypass"
    $CurrentUser = (Get-CimInstance –ClassName Win32_ComputerSystem | Select-Object -expand UserName)
    $Action = New-ScheduledTaskAction -Execute $PSexe -Argument $Arguments
    $Principal = New-ScheduledTaskPrincipal -UserId (Get-CimInstance –ClassName Win32_ComputerSystem | Select-Object -expand UserName)
    $Trigger = New-ScheduledTaskTrigger -AtLogOn -User $CurrentUser
    $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal

    Register-ScheduledTask ConnectAzureFileShare_K -Input $Task
    Start-ScheduledTask ConnectAzureFileShare_K
}

Else {
    # Not running as administrator. Connecting directly with Azure script.
    Add-Content -Path $ScriptLogFilePath -Value ((Get-Date).ToString() + ": " + "Not running as administrator.")

    $connectTestResult = Test-NetConnection -ComputerName temporaryfile.file.core.windows.net -Port 445
    if ($connectTestResult.TcpTestSucceeded) {
        # Save the password so the drive will persist on reboot
        cmd.exe /C "cmdkey /add:`"example.file.core.windows.net`" /user:`"Azure\example`" /pass:`"mlkfquivIPIUHeljvPIUVeepReallycomplicatedstring==`""
        # Mount the drive
        New-PSDrive -Name K -PSProvider FileSystem -Root "\\example.file.core.windows.net\example" -Persist -Scope "Global"
    } else {
        Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
    }
}

If (Get-PSDrive -Name K) {
    Add-Content -Path $ScriptLogFilePath -Value ((Get-Date).ToString() + ": " + "K-Drive mapped successfully.")
}

Else {
    Add-Content -Path $ScriptLogFilePath -Value ((Get-Date).ToString() + ": " + "Please verify installation.")
}
