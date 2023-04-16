#certbot
#${INSTALL_CMD}
sudo apt-get install -y snap
sudo snap install core && sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo -H /usr/bin/certbot certonly --standalone -d sbc.lordsomerscamp.org.au -d sbc.lordsomerscamp.com -d sbc.lordsomerscamp.com.au -d sbc.webstean.com

#./letsencrypt-auto --help
# sudo certbot certificates

#if [ -d /etc/apache2 ] ; then
#    sudo -H /usr/local/src/letsencrypt/letsencrypt-auto certonly --apache -d example.com -d www.example.com
#else
#    sudo -H /usr/local/src/letsencrypt/certbot/certbot certonly --standalone -d sbc.lordsomerscamp.org.au -d sbc.lordsomerscamp.com -d sbc.lordsomerscamp.com.au -d sbc.webstean.com
#fi

# WILDCARD: This need a DNS record
# certbot certonly -d 'lordsomerscamp.org.au,*.lordsomercamp.org.au' --server https://acme-v02.api.letsencrypt.org/directory --preferred-challenges dns --agree-tos --email webstean@gmail.com

# WILDCARD: this need a file put on the web server 
# certbot certonly -d -d 'lordsomerscamp.org.au,*.lordsomercamp.org.au' --server https://acme-v02.api.letsencrypt.org/directory --agree-tos --email webstean@gmail.com

# test
# sudo certbot renew --dry-run
