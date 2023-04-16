# Azure Arc Agent -won't work on WSL VM as they dont run systemd
if [[ ! $(grep Microsoft /proc/version) ]]; then
    cd ~
    wget https://aka.ms/azcmagent -O ~/Install_linux_azcmagent.sh
    bash ~/Install_linux_azcmagent.sh
#    azcmagent connect --resource-group "<resourceGroupName>" --tenant-id "<tenantID>" --location "<regionName>" --subscription-id "<subscriptionID>"
#    azcmagent connect --resource-group "LSCPH-RaspberryPi" --tenant-id "<tenantID>" --location "<regionName>" --subscription-id "2d2089b6-d701-49aa-9600-bc2e3796d53a"
    azcmagent connect \
        --service-principal-id "{serviceprincipalAppID}" \
        --service-principal-secret "{serviceprincipalPassword}" \
        --resource-group "LSCPH-RaspberryPi" \
        --tenant-id "fd72f9ff-96b6-4a20-a870-ceaa17d70bc8" \
        --location "{resourceLocation}" \
        --subscription-id "2d2089b6-d701-49aa-9600-bc2e3796d53a"
fi
