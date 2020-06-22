# ~/.bashrc: executed by bash(1) for non-login shells.

# ---------------------------------------------------
# ** BASH SPECIFICS **
# ---------------------------------------------------

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Define just a few colours
BLACK='\e[0;30m'
BLUE='\e[0;34m'
DARKBLUE='\e[1m\e[0;34m'
GREEN='\e[0;32m'
CYAN='\e[0;36m'
RED='\e[0;31m'
PURPLE='\e[0;35m'
BROWN='\e[0;33m'
LIGHTGRAY='\e[0;37m'
DARKGRAY='\e[1;30m'
LIGHTBLUE='\e[1;34m'
LIGHTGREEN='\e[1;32m'
LIGHTCYAN='\e[1;36m'
LIGHTRED='\e[1;31m'
LIGHTPURPLE='\e[1;35m'
YELLOW='\e[1;33m'
WHITE='\e[1;37m'
NC='\e[0m'              # No Color
# Sample Command using color: echo -e "${CYAN}This is BASH ${RED}${BASH_VERSION%.*}${CYAN} - DISPLAY on ${RED}$DISPLAY${NC}\n"


# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# Append the previous command to history each time a prompt is shown
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# Shell Prompt
export PS1='\[\033[01;32m\]\u@`hostname`:\[\033[01;34m\] \w \$\[\033[00m\] '

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

#
# Auto-launch ssh-agent
# Source: https://help.github.com/articles/working-with-ssh-key-passphrases
#

# Note: ~/.ssh/environment should not be used, as it
#       already has a different purpose in SSH.
env=~/.ssh/agent.env

# Note: Don't bother checking SSH_AGENT_PID. It's not used
#       by SSH itself, and it might even be incorrect
#       (for example, when using agent-forwarding over SSH).
agent_is_running() {
    if [ "$SSH_AUTH_SOCK" ]; then
        # ssh-add returns:
        #   0 = agent running, has keys
        #   1 = agent running, no keys
        #   2 = agent not running
        ssh-add -l >/dev/null 2>&1 || [ $? -eq 1 ]
    else
        false
    fi
}

agent_has_keys() {
    ssh-add -l >/dev/null 2>&1
}

agent_load_env() {
    . "$env" >/dev/null
}

agent_start() {
    (umask 077; ssh-agent >"$env")
    . "$env" >/dev/null
}

if ! agent_is_running; then
    agent_load_env
fi

# if your keys are not stored in ~/.ssh/id_rsa.pub or ~/.ssh/id_dsa.pub, you'll need
# to paste the proper path after ssh-add
if ! agent_is_running; then
    agent_start
    ssh-add
elif ! agent_has_keys; then
    ssh-add
fi

unset env

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ---------------------------------------------------
# .bash_profile for Oracle Grid and Database
# ---------------------------------------------------
# OS User:      oracle
# Application:  Oracle Database
#               Oracle Grid Infrastructure
# Version:      Oracle 11g Release 2
# OS types:     Linux, Solaris (sparc and x86)
# ---------------------------------------------------

# Dont allow root - just exit quietly
if [ $user eq 'root' ] ; then
    exit
fi

# Get the aliases and functions
if [ -f ~/.bashrc ] ; then
   . ~/.bashrc
fi

if [ -x /usr/bin/vim ] ; then
  alias vi='/usr/bin/vim'
fi

if [ -x /usr/bin/vim ] ; then
   export EDITOR='/usr/bin/vim'
elif [ -x /bin/nano ]; then
   export EDITOR='/bin/nano'
else
   export EDITOR='/bin/vi'
fi

if [ -x /usr/bin/most ] ; then
   export PAGER='most'
else
   export PAGER='less'
fi

# ---------------------------------------------------
# bash aliases
# ---------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cd..='cd ..'
alias cp='cp -irv'
alias du='du -h --max-depth=1'
alias ll='ls -FGahl --show-control-chars --color=always'
alias ls='ls -AF --show-control-chars --color=always'
alias md='mkdir -p'
alias mv='mv -iv'
alias rm='rm -ir'
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# ---------------------------------------------------
# bash Settings
# ---------------------------------------------------
export HISTFILESIZE=3000 # the bash history should save 3000 commands
export HISTCONTROL=ignoredups #don't put duplicate lines in the history.

# ---------------------------------------------------
# XWindows Display
# ---------------------------------------------------
# set to another host to display
if [ -z "${DISPLAY}" ] ; then DISPLAY=:0.0; export DISPLAY; fi
if [ ! -f /usr/bin/startx ] ; then
   # Set to my Desktop XWindows Server
   DISPLAY=192.168.168.129:0.0 ; export DISPLAY
fi
DISPLAY=192.168.168.129:0.0 ; export DISPLAY

# ---------------------------------------------------
# ** ORACLE DATABASE SPECIFICS **
# ---------------------------------------------------
# Avoid Oracle Clusterware errors
if [ -t 0 ]; then
   stty intr ^C
fi

# ---------------------------------------------------
# ORACLE_BASE
# ---------------------------------------------------
# Specifies the base of the Oracle directory structure
# for Optimal Flexible Architecture (OFA) compliant
# database software installations.
# ---------------------------------------------------
if [ -z "${ORACLE_BASE}" ] ; then ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE ; fi

# ---------------------------------------------------
# GRID_HOME
# ---------------------------------------------------
# Specifies the directory containing the Oracle
# Grid Infrastructure
# ---------------------------------------------------
if [ -z "${GRID_HOME}" ] ; then GRID_HOME=/u01/app/11.2.0/grid; export GRID_HOME ; fi

# ---------------------------------------------------
# ORACLE_HOME
# ---------------------------------------------------
# Specifies the directory containing the Oracle
# Database software.
# ---------------------------------------------------
if [ -z "${ORACLE_HOME}" ] ; then ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1; export ORACLE_HOME ; fi

# ---------------------------------------------------
# ORACLE_SID
# ---------------------------------------------------
# Specifies the Oracle system identifier (SID) for
# the Oracle instance running on this node. When
# using RAC, each node must have a unique ORACLE_SID.
# (i.e. racdb1, racdb2,...)
# ---------------------------------------------------
if [ -z "${ORACLE_SID}" ] ; then ORACLE_SID=orcl; export ORACLE_SID ; fi

# ---------------------------------------------------
# ORACLE_UNQNAME and ORACLE_HOSTNAME
# ---------------------------------------------------
# In previous releases of Oracle Database, you were
# required to set environment variables for
# ORACLE_HOME and ORACLE_SID to start, stop, and
# check the status of Enterprise Manager. With
# Oracle Database 11g Release 2 (11.2) and later, you
# need to set the environment variables ORACLE_HOME,
# ORACLE_UNQNAME, and ORACLE_HOSTNAME to use
# Enterprise Manager. Set ORACLE_UNQNAME equal to
# the database unique name and ORACLE_HOSTNAME to
# the hostname of the machine.
# ---------------------------------------------------
ORACLE_UNQNAME=${ORACLE_SID} ; export ORACLE_UNQNAME
ORACLE_HOSTNAME=`hostname` ; export ORACLE_HOSTNAME

# ---------------------------------------------------
# JAVA_HOME
# ---------------------------------------------------
# Specifies the directory of the Java SDK and Runtime
# Environment.
# ---------------------------------------------------
# Should work on Linux
if [ -d /usr/lib/jvm/jre ] ; then
  JAVA_HOME=/usr/lib/jvm/jre; export JAVA_HOME
fi
# Should work on Solaris
if [ -d /usr/j2se/jre ] ; then
  JAVA_HOME=/usr/j2se/jre; export JAVA_HOME
fi

# ---------------------------------------------------
# ORACLE_TERM
# ---------------------------------------------------
# Defines a terminal definition. If not set, it
# defaults to the value of your TERM environment
# variable. Used by all character mode products.
# ---------------------------------------------------
ORACLE_TERM=xterm; export ORACLE_TERM

# ---------------------------------------------------
# NLS_DATE_FORMAT
# ---------------------------------------------------
# Specifies the default date format to use with the
# TO_CHAR and TO_DATE functions. The default value of
# this parameter is determined by NLS_TERRITORY. The
# value of this parameter can be any valid date
# format mask, and the value must be surrounded by
# double quotation marks. For example:
#
#         NLS_DATE_FORMAT = "MM/DD/YYYY"
#
# ---------------------------------------------------
export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'; export NLS_DATE_FORMAT 

# ---------------------------------------------------
# TNS_ADMIN
# ---------------------------------------------------
# Specifies the directory containing the Oracle Net
# Services configuration files like listener.ora,
# tnsnames.ora, and sqlnet.ora. When using Oracle
# ASM, the TNS listener will be run out of
# GRID_HOME; otherwise the listener will be run out
# ORACLE_HOME.
# ---------------------------------------------------
if [ -d $ORACLE_HOME/network/admin ] ; then TNS_ADMIN=$ORACLE_HOME/network/admin; export TNS_ADMIN ; fi
if [ -d $GRID_HOME/network/admin ] ; then TNS_ADMIN=$GRID_HOME/network/admin; export TNS_ADMIN ; fi

# ---------------------------------------------------
# ORA_NLS11
# ---------------------------------------------------
# Specifies the directory where the language,
# territory, character set, and linguistic definition
# files are stored.
# ---------------------------------------------------
ORA_NLS11=$ORACLE_HOME/nls/data; export ORA_NLS11

# ---------------------------------------------------
# LD_LIBRARY_PATH
# ---------------------------------------------------
# Specifies the list of directories that the shared
# library loader searches to locate shared object
# libraries at runtime.
# ---------------------------------------------------
LD_LIBRARY_PATH=$ORACLE_HOME/lib
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$ORACLE_HOME/oracm/lib
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/lib:/usr/lib:/usr/local/lib
export LD_LIBRARY_PATH

# ---------------------------------------------------
# CLASSPATH
# ---------------------------------------------------
# Specifies the directory or list of directories that
# contain compiled Java classes.
# ---------------------------------------------------
CLASSPATH=$ORACLE_HOME/JRE
CLASSPATH=${CLASSPATH}:$ORACLE_HOME/jlib
CLASSPATH=${CLASSPATH}:$ORACLE_HOME/rdbms/jlib
CLASSPATH=${CLASSPATH}:$ORACLE_HOME/network/jlib
export CLASSPATH

# ---------------------------------------------------
# THREADS_FLAG
# ---------------------------------------------------
# All the tools in the JDK use green threads as a
# default. To specify that native threads should be
# used, set the THREADS_FLAG environment variable to
# "native". You can revert to the use of green
# threads by setting THREADS_FLAG to the value
# "green".
# ---------------------------------------------------
THREADS_FLAG=native; export THREADS_FLAG

# ---------------------------------------------------
# TEMP, TMP, and TMPDIR
# ---------------------------------------------------
# Specify the default directories for temporary
# files; if set, tools that create temporary files
# create them in one of these directories.
# ---------------------------------------------------
export TEMP=/var/tmp
export TMPDIR=$TEMP
export TMP=$TEMP
if [ ! -d ${TEMP} ] ; then mkdir -p ${TEMP} ; fi

# ---------------------------------------------------
# UMASK
# ---------------------------------------------------
# Set the default file mode creation mask
# (umask) to 022 to ensure that the user performing
# the Oracle software installation creates files
# with 644 permissions.
# ---------------------------------------------------
umask 022

# ---------------------------------------------------
# PATH
# ---------------------------------------------------
# Used by the shell to locate executable programs;
# must include the $ORACLE_HOME/bin directory.
# ---------------------------------------------------
PATH=.:${JAVA_HOME}/bin:${PATH}:$HOME/bin:$ORACLE_HOME/bin
PATH=${PATH}:/usr/bin:/bin:/usr/bin/X11
if [ -d /usr/local/bin ] ; then PATH=${PATH}:/usr/local/bin ; fi
if [ -d ${ORACLE_BASE}/dba_scripts/bin ] ; then PATH=${PATH}:{ORACLE_BASE}/dba_scripts/bin ; fi
export PATH

# ---------------------------------------------------
# Oracle bash functions
# ---------------------------------------------------
# Determine Oracle Home version
ohvers () {
   echo -n $ORACLE_HOME | sed -n 's/.*\/\([[:digit:].]\+\)\/.*/\1/p'
}

# Oracle
_setpath() {
    if [ $# -gt 1 ]; then
        p=$(echo $PATH | sed "s#$2##")
    else
        p=$PATH
    fi
    export PATH=$1/bin:$p
}
_oracle_settnsadmin() {
    export TNS_ADMIN=$1
    _oracle_showenv
}
_oracle_showenv() {
    env | grep -Ee "PATH|ORACLE|TNS|NLS" | sort
}
_oracle_setsid() {
    export ORACLE_SID=$1
    export ORACLE_ADMIN=$ORACLE_HOME/admin/$ORACLE_SID
    export ORACLE_UNQNAME=${ORACLE_SID}
    _oracle_showenv
}
_oracle_setbase() {
    export ORACLE_BASE=$1
    _oracle_showenv
    echo "** ATTENTION: Please set ORACLE_HOME with sethome too"
}
_oracle_sethome() {
    OLDORACLE_HOME=$ORACLE_HOME
    export ORACLE_HOME=$ORACLE_BASE/product/$1
    export ORACLE_ADMIN=$ORACLE_HOME/admin/$ORACLE_SID
    export TNS_ADMIN=$ORACLE_HOME/network/admin
    export LD_LIBRARY_PATH=$ORACLE_HOME/lib
    export ORACLE_HOSTNAME=`hostname -f`
    _setpath $OLDORACLE_HOME $ORACLE_HOME
    _oracle_showenv
}

# ---------------------------------------------------
# bash aliases for Oracle
# ---------------------------------------------------
alias setsid='_oracle_setsid '
alias setbase='_oracle_setbase '
alias sethome='_oracle_sethome '
alias settns='_oracle_settnsadmin '

alias sysdba='sqlplus / as sysdba' # Full Admin
alias sysoper='sqlplus / as sysoper' #Subset of admin
alias sysasm='sqlplus / as sysasm' # ASM Management
alias sysrman='sqlplus / as sysbackup' # RMAN Managmeet"
alias sysdg='sqlplus / as sysdg' # Data Guard Management
alias syskm='sqlplus / as syskm' # Encryption Key Management
alias sysrac='sqlplus / as sysrac' # RAC Management

alias cdo='cd \$ORACLE_HOME'
alias cdb='cd \$ORACLE_BASE'

alias asmcmd='asmcmd -p'
alias rmanc='rman target sys/${ORACLE_SID} catalog rman/rman'
alias oenv='env | grep ORACLE | sort'

alias bdump='cd \$ORACLE_BASE/diag/rdbms/\$SDBNAME/\$ORACLE_SID/trace'
alias udump='cd \$ORACLE_BASE/diag/rdbms/\$SDBNAME/\$ORACLE_SID/trace'
alias alert='tail -f -n100 \$ORACLE_BASE/diag/rdbms/\$SDBNAME/\$ORACLE_SID/trace/alert_\$ORACLE_SID.log'

# enable programmable completion features
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

alias colortest='echo -e "${CYAN}This is BASH ${RED}${BASH_VERSION%.*}${CYAN} - DISPLAY on ${RED}$DISPLAY${NC}\n"'

# Skip
alias rsh='ssh'
alias rlogin='ssh'

export PS1=${DARKBLUE}$'\\n$ [ $LOGNAME@\h:$PWD [\\t] [`ohvers` SID:${ORACLE_SID:-"*no sid*"}] ]\\n$ '

if [ ! -f ${ORACLE_HOME}/bin/sqlplus ] ; then
  echo "Warning: ORACLE_HOME (${ORACLE_HOME})"
  echo "         appears to be invalid. Cannot find sqlplus!"
fi

if [ ! "${DISPLAY}" = ":0.0" ] ; then
  echo "Info:    XWindows Display variable set to ${DISPLAY}"
fi

