# DevOps Install - Part 2 of 2
# Andrew Webster

choco feature enable -n allowGlobalConfirmation

$localprograms = choco list --localonly
if ($localprograms -like "*wsl-alphine*")
{
    choco upgrade wsl-alpine -y
}
Else
{
    choco install wsl-alpine -y
}
#### choco install wsl-alpine -y
choco install vscode-wsl -y



