
MMA Agent
Windows 64-bit agent - https://go.microsoft.com/fwlink/?LinkId=828603
Windows 32-bit agent - https://go.microsoft.com/fwlink/?LinkId=828604

"c:\MMA-Agent\MMASetup-AMD64.exe" /C:"setup.exe /qn ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_ID=44059d47-2bc9-45ea-a5ea-fab50d502a6c OPINSIGHTS_WORKSPACE_KEY=TuOq3w1Ag8Y+8uQl+L9a5mHE1u4/5XAAzhHbUTmA4m34l5sLuimLeVWd+3+33UKKKI+686qsl/gM5XIczuoILQ== AcceptEndUserLicenseAgreement=1"


https://go.microsoft.com/fwlink/?LinkId=828603

# install
sysmon.exe -accepteula -i sysmonconfig-export.xml

# update 
sysmon.exe -c sysmonconfig-export.xml

https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml


$workspaceId = "<Your workspace Id>"
$workspaceKey = "<Your workspace Key>"
$mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
$mma.AddCloudWorkspace($workspaceId, $workspaceKey)
$mma.ReloadConfiguration()
