
#!/bin/sh

# Check to make sure git is configured with your name, email and custom settings.
git config --list

# Sanity check to see if you can run some of the tools we installed.

# Ruby
if which ruby; then
    echo Ruby *Installed*
    ruby --version
else    
    echo Ruby *Not Installed*
fi

# Node
if which node; then
    node --version
else
    echo node *Not Installed*
fi

# Ansible
if which ansible; then
    ansible --version
else
    echo ansible *Not Installed*
fi

# AWS
if which aws; then
    aws --version
else
    echo aws *Not Installed*
fi

# Terraform
if which terraform; then
    terraform --version
else    
    echo terraform *Not Installed*
fi

# If you're using Docker Desktop with WSL 2, these should be accessible too.
if which docker; then
    docker info
    docker-compose --version
else
    echo Docker *Not Installed*
fi

if which sqlplus; then
    sqlplus -v
else
    echo Oracle Database Client *Not Installed*
fi
     
