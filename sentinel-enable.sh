#!/bin/sh

# install ruby
sudo apt install ruby-full
ruby --version

# install fluent gem
sudo gem install fluentd -v "~> 0.13.0"
sudo fluent-gem install fluent-plugin-azure-loganalytics

# edit fluent.conf
/usr/local/bin/fluentd -c /etc/fluent.conf -o /var/log/fluent.log

# Option #2 - 
