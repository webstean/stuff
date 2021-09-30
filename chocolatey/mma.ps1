
# MMA Agent - permanent download links
# Windows 64-bit agent - https://go.microsoft.com/fwlink/?LinkId=828603
# Windows 32-bit agent - https://go.microsoft.com/fwlink/?LinkId=828604

# "c:\MMA-Agent\MMASetup-AMD64.exe" /C:"setup.exe /qn ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_ID=44059d47-2bc9-45ea-a5ea-fab50d502a6c OPINSIGHTS_WORKSPACE_KEY=TuOq3w1Ag8Y+8uQl+L9a5mHE1u4/5XAAzhHbUTmA4m34l5sLuimLeVWd+3+33UKKKI+686qsl/gM5XIczuoILQ== AcceptEndUserLicenseAgreement=1"

choco install microsoft-monitoring-agent -y
$workspaceId = "74328598-0b07-4a05-92d8-f0fbb9271c20"
$workspaceKey = "2ul7XdqK4bCQfAJEg/iNhPbqWoRABHdozUWChMHx3mmMTLSW1i78sQ+WujUNvtmi88MkDcklgT/v5FbzIlAJvQ=="
$mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
$mma.AddCloudWorkspace($workspaceId, $workspaceKey)
$mma.ReloadConfiguration()

# install sysmon
choco install wget -y
wget https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml -o 'C:\Program Files\Microsoft Monitoring Agent\sysmonconfig-export.xml'
sysmon.exe -accepteula -i 'C:\Program Files\Microsoft Monitoring Agent\sysmonconfig-export.xml'

# update sysmon 
sysmon.exe -c 'C:\Program Files\Microsoft Monitoring Agent\sysmonconfig-export.xml'
