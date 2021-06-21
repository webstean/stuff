
choco list --download-cache

$localprograms = choco list --localonly
if ($localprograms -like "*vscode*")
{
    choco upgrade git -y
}
Else
{
    choco install git -y
}

### Explorer addins
choco install gitextensions -y 

#### VS Code Extensiosns
choco install vscode -y
choco install onedarkpro-vscode -y
choco install azureaccount-vscode -y
choco install vscode-azure-deploy -y
choco install vscode-gitlens -y
choco install vscode-powershell -y
choco install vscode-settingssync -y

#### Windows Admin / Azure Migration
choco install windows-admin-center -y 

##### Golang
choco install golang -y
# VsCode GoLang extension
choco install vscode-go -y

##### Sysinternals
choco install sysinternals -y 
choco install NirLauncher -y -params "/sysinternals"

#### WSL (Part#1)
choco install -y wsl2 -params "/Version:2 /Retry:true"
#### yep it works


