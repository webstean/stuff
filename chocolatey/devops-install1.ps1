# DevOps Install - Part 1 of 2
# Andrew Webster

choco feature enable -n allowGlobalConfirmation

choco list --download-cache

$localprograms = choco list --localonly
if ($localprograms -like "*vscode*")
{
    choco upgrade vscode -y
    choco upgrade git -y
}
Else
{
    choco install vscode -y
    choco install git -y
}

### Explorer addins
choco install gitextensions -y 

### Powertoys
choco install powertoys -y 

### More Devops
choco install ilspy -y 
choco install filezilla -y  
choco install putty -y 

### Powershell v7
choco install powershell-core --install-arguments='"ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 REGISTER_MANIFEST=1 ENABLE_PSREMOTING=1"'

# DEV
choco install fiddler -y
choco install baretail -y
# github desktop
choco install github -y

# Programming
choco install nodejs.install -y

#### VS Code Extensions
choco install onedarkpro-vscode -y
choco install azureaccount-vscode -y
choco install vscode-azure-deploy -y
choco install vscode-gitlens -y
choco install vscode-powershell -y
choco install vscode-settingssync -y

#### Windows Admin / Azure Migration
choco install windows-admin-center /port: 443 -y 

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

