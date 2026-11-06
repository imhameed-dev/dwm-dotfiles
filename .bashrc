#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Arrow turns green after success, red after failure (built-in only, no extra process)
__ec() { if [ $? -eq 0 ]; then ARROWC=$'\e[38;2;184;187;38m'; else ARROWC=$'\e[38;2;251;73;52m'; fi; }
PROMPT_COMMAND=__ec

# Nerd Font icons: user, desktop, folder, Arch logo; box lines
i_user=$'\xef\x80\x87'
i_host=$'\xef\x84\x88'
i_dir=$'\xef\x81\xbb'
i_arch=$'\xef\x8c\x83'
l_top=$'\xe2\x95\xad\xe2\x94\x80'
l_bot=$'\xe2\x95\xb0\xe2\x94\x80'
arrow=$'\xe2\x9d\xaf'

PS1='\n\[\e[38;2;146;131;116m\]'"$l_top"' \[\e[38;2;254;128;25m\]'"$i_user"' \u \[\e[38;2;146;131;116m\]'"$l_top"' \[\e[38;2;142;192;124m\]'"$i_host"' \h \[\e[38;2;146;131;116m\]'"$l_top"' \[\e[38;2;250;189;47m\]'"$i_dir"' \W\n\[\e[38;2;146;131;116m\]'"$l_bot"' \[\e[38;2;131;165;152m\]'"$i_arch"' \[${ARROWC}\]'"$arrow"'\[\e[0m\] '
unset i_user i_host i_dir i_arch l_top l_bot arrow
