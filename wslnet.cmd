@echo off

netsh interface portproxy add v4tov4 listenport=3000 listenaddress=0.0.0.0 connectport=3000 connectaddress=172.27.230.57
netsh interface portproxy add v4tov4 listenport=6600 listenaddress=0.0.0.0 connectport=6600 connectaddress=172.27.230.57



