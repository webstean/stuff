$localprograms = choco list --localonly
if ($localprograms -like "*github-desktop*")
{
    choco upgrade github-desktop -y
}
Else
{
    choco install github-desktop -y
}
