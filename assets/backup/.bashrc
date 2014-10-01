# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export PATH="$PATH:$HOME/.rvm/bin:$HOME/software/zed:$HOME/software/sublime" # Add RVM to PATH for scripting
# set ssh alias ssh
alias s239='ssh xiajian@192.168.1.239'
alias s99='ssh root@192.168.1.99'
alias sweb='ssh lodestone@114.80.67.240'
alias scalc='ssh lodestone@114.80.67.207'
function sd235() { ssh root@192.168.0.235 "shutdown -h now" ; }
# set shutdown commandline ailas
alias shutdown='sudo shutdown -h now '
alias ack='ack-grep'

# Just for fun
echo "Did you know that:" ; whatis $(ls /bin | shuf -n 1 )

#Handle some warming about gvim
function gvim() { (/usr/bin/gvim -f "$@" & ) }

#Handle some warming about gvim
function sub() { (/home/xiajian/software/sublime/sublime -f "$@" & ) }
function ngrok() { /home/xiajian/software/ngrok $@ ; }
#function rp() { pwd ; bash /home/xiajian/works/replace.sh $@  ;  }

#由于末尾追加新行的问题，上述脚本不能工作，编写了一个简单的替换的shell函数+附加替换图片
function rp() {
  echo "替换样式文件$1.css，注意不需要写后缀名"
  HTML_PATH='/home/xiajian/works/html'
  TH_PATH='/home/xiajian/works/web'
  cp ${HTML_PATH}/css/$1.css  ${TH_PATH}/app/assets/stylesheets/
  # 替换图片
  cp -rf ${HTML_PATH}/images/* ${TH_PATH}/app/assets/images/.
  sed -i 's/\.\.\/images/\/assets/' ${TH_PATH}/app/assets/stylesheets/$1.css
  diff ${HTML_PATH}/css/$1.css  ${TH_PATH}/app/assets/stylesheets/$1.css
}

# 自写自用的jekyll函数 - js
function js() {
  if [  $# ==  0  ] ; then
     echo "默认执行"
     jekyll serve -w
  else
     jekyll "$@"
  fi
}

# git-one:添加并提交
function git-one() {
  if [ $# == 0 ] ; then
    echo "Usage: git-one [提交说明]"
    git st
  else
    echo "提交"$(pwd)"下的修改"
    git add $(pwd) && git ci -m"$1" && git push
  fi
}

# cap部署函数, 获得经验，不要取使用rvm安装获得的gem包的命令行工具同名的函数
# 这样会引起冲突，并使得bash进程崩溃。估计，gem包提供的命令也是以函数的形式存在的
function deploy() {
  if [ $# == 0 ] ; then
    echo "cap函数，默认部署staging"
    cap staging deploy
  else
    cap "$1" deploy
  fi
}

# add path for zed
#export PATH= ${PATH}:$HOME/software/zed
#写了几个别名，这样可以少敲点字
web=/home/xiajian/works/web
alias web='cd ${web}'
alias engine='cd /home/xiajian/works/engine'
alias bjobs='cd /home/xiajian/works/bjobs'
alias html='cd /home/xiajian/works/html'
alias wind='cd /home/xiajian/works/windtalker'
alias tst='cd /home/xiajian/works/test'
alias blog='cd /home/xiajian/works/blog'
alias gitlab='cd /home/xiajian/works/gitlab-ce'
alias vbundle='cd /home/xiajian/.vim/bundle'
alias down='cd /home/xiajian/Downloads'
alias rhg-zh='cd /home/xiajian/works/rhg-zh'
alias rbp-zh='cd /home/xiajian/works/rbp-zh'
alias mongoid-zh="cd /home/xiajian/works/mongoid-zh"
alias mobile="cd /home/xiajian/works/mobile_ios"
alias mweb="cd /home/xiajian/works/mobile"
alias brc='vi ~/.bashrc'
alias rc='rails c'
alias rs='rails s'
alias redis='redis-cli'
alias node='nodejs'
alias sb='source ~/.bashrc'
alias ggrep='git grep'
alias gdiff='git diff'
alias img='sshfs root@192.168.1.99:/web/staging/th/current/public/uploads/ ${web}/public/uploads'
# 网上说：卸载远程文件系统可以使用umount和fusermount,前者不起作用,后者用来卸载fufs(用户空间的文件系统)
alias unimg='fusermount -u ${web}/public/uploads'
alias mlog='tail -f /var/log/mongodb/mongodb.log'
alias mdata='cd /var/lib/mongodb/'
