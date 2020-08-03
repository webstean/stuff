@echo off

netsh interface portproxy add v4tov4 listenport=3000 listenaddress=0.0.0.0 connectport=3000 connectaddress=172.19.222.37
netsh interface portproxy add v4tov4 listenport=6600 listenaddress=0.0.0.0 connectport=6600 connectaddress=172.19.222.37
netsh interface portproxy add v4tov4 listenport=6600 listenaddress=0.0.0.0 connectport=55555 connectaddress=172.19.222.37

@rem netsh interface portproxy reset

netsh interface portproxy dump



