# .bash_profile is executed for login shells, e.g. console login or ssh

if [ ${#BD_HOME} -gt 0 ] && [ -f "${BD_HOME}/.bashrc" ]; then
    . "${BD_HOME}/.bashrc"
else
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi
fi
