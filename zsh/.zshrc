# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

eval "$(starship init zsh)"

source <(fzf --zsh)

alias f="source ~/.config/scripts/startfuzzyfinder.sh" 
alias vim="nvim" 
alias ls="eza --icons --group-directories-first" 

alias background="~/.config/wallpapers/randombackground.sh 0" 

alias sudogui="sudo -E "
# alias dushs="sudo du * -sh | sort -h" 
alias dushs="parallel --gnu 'sudo du -sh {}' ::: * | sort -h" 
alias dushas="sudo du .* * -sh | sort -h" 
alias cleanup="sudo paccache -rk1; yay -Sc --aur --noconfirm;"

alias swindowsvm='VBoxManage startvm "WindowsVM"'

export PATH=$PATH:~/.bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:~/.config/scripts

export EDITOR='nvim'
export PAGER='bat'
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_QPA_PLATFORM=wayland
export XDG_CURRENT_DESKTOP=hyprland

mkcd() {
    mkdir -p "${1}"
    cd "${1}"
}

not(){
    start=$(date +%s)
    "$@"
    [ $(($(date +%s) - start)) -le 1 ] || notify-send "Notification" "Long\
 running command \"$(echo $@)\" took $(($(date +%s) - start)) seconds to finish" 
}

notcrit(){
    start=$(date +%s)
    "$@"
    [ $(($(date +%s) - start)) -le 1 ] || notify-send -u critical "Critical Notification" "Long\
 running command \"$(echo $@)\" took $(($(date +%s) - start)) seconds to finish" 
}


alias matlabmakecontainer2025b='docker run -it -p 5901:5901 -p 6080:6080 -v "$HOME/projects":/home/matlab/projects --shm-size=512M --name=matlab2025b mathworks/matlab:r2025b -vnc'
alias matlab2025b="docker start matlab2025b; sleep 1 && vncviewer localhost:1 -passwd ~/matlab-docker/passwd; docker stop matlab2025b"

# alias matlabmakecontainer2023b='docker run -it -p 5901:5901 -p 6080:6080 -v "$HOME/projects":/home/matlab/projects --shm-size=512M --name=matlab2023b mathworks/matlab:r2023b -vnc'
# alias matlab2023b="docker start matlab2023b; sleep 1 && vncviewer localhost:1 -passwd ~/matlab-docker/passwd; docker stop matlab2023b"
#
# alias matlabmakecontainer2023a='docker run -it -p 5901:5901 -p 6080:6080 -v "$HOME/projects":/home/matlab/projects --shm-size=512M --name=matlab2023a mathworks/matlab:r2023a -vnc'
# alias matlab2023a="docker start matlab2023a; sleep 1 && vncviewer localhost:1 -passwd ~/matlab-docker/passwd; docker stop matlab2023a"

alias matlabmakecontainer2022b='docker run -it -p 5901:5901 -p 6080:6080 -v "$HOME/projects":/home/matlab/projects --shm-size=512M --name=matlab2022b mathworks/matlab:r2022b -vnc'
alias matlab2022b="docker start matlab2022b; sleep 1 && vncviewer localhost:1 -passwd ~/matlab-docker/passwd; docker stop matlab2022b"

alias matlabmakecontainer2020b='docker run -it -p 5901:5901 -p 6080:6080 -v "$HOME/projects":/home/matlab/projects --shm-size=512M --name=matlab2020b mathworks/matlab:r2020b -vnc'
alias matlab2020b="docker start matlab2020b; sleep 1 && vncviewer localhost:1 -passwd ~/matlab-docker/passwd; docker stop matlab2020b"

alias cdure="cd /run/user/1000/gvfs/smb-share:server=wtbfiler.campus.tue.nl,share=university%20racing/2025\ -\ 2026\ \(URE20\)/"
alias cdureme="cd /run/user/1000/gvfs/smb-share:server=wtbfiler.campus.tue.nl,share=university%20racing/2025\ -\ 2026\ \(URE20\)/01_Tech/07_Autonomous_Systems/AS_02_Framework_Engineer "
# smb://wtbfiler.campus.tue.nl/university%20racing/2025%20-%202026%20(URE20)/01_Tech/07_Autonomous_Systems/AS_02_Framework_Engineer/Documentation/log_book
# /run/user/1000/gvfs/smb-share:server=wtbfiler.campus.tue.nl,share=university%20racing/2025 - 2026 (URE20)/01_Tech/07_Autonomous_Systems/AS_02_Framework_Engineer/Documentation/log_book

