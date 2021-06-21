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



