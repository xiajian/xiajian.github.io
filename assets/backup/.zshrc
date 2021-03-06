# Path to your oh-my-zsh installation.
export ZSH=/home/xiajian/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git bundler rake ruby coffee rails rvm)

# User configuration

# export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/home/xiajian/.rvm/bin:/home/xiajian/.rvm/bin:/home/xiajian/software/zed:/home/xiajian/software/sublime:/home/xiajian/.rvm/bin"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshconfig="vi ~/.zshrc"
alias ohmyzsh="cd ~/.oh-my-zsh && vi "

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

# rvm与zsh集成
[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

# Nodejs环境变量
export NVM_DIR="/home/xiajian/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

[[ -s ~/.autojump/etc/profile.d/autojump.zsh ]] && . ~/.autojump/etc/profile.d/autojump.zsh  
eval "$(grunt --completion=zsh)"
# set ssh alias ssh
export LD_LIBRARY_PATH='/usr/local/instantclient'
alias s99='ssh root@192.168.1.99'
alias s88='ssh root@192.168.1.88'
alias sweb='ssh deploy@114.80.67.240'
alias scalc='ssh deploy@114.80.67.207'
alias s115='ssh root@115.28.165.58'
alias s93='ssh root@115.29.52.93'
alias shutdown='sudo shutdown -h now '
alias ack='ack-grep'

# Just for fun
echo "Did you know that:" ; whatis $(ls /bin | shuf -n 1 )

function ngrok() { /home/xiajian/software/ngrok -authtoken 30YEx/1xB5S9UN/rTRFk $@ ; }

# 全功能的css和js替换函数
function replace() {
  if [ "$1" == "test" ] ; then
    HTML_PATH='/home/xiajian/works/test/tophold-html'
    TH_PATH='/home/xiajian/works/test/tophold-web'
    echo "show the different bewteen"
  else
    HTML_PATH='/home/xiajian/works/html'
    TH_PATH='/home/xiajian/works/web'
  fi
  cp ${HTML_PATH}/css/*.css ${TH_PATH}/app/assets/stylesheets/.
  cp ${HTML_PATH}/js/*.js ${TH_PATH}/app/assets/javascripts/.
  cp ${HTML_PATH}/bootstrap/*.css ${TH_PATH}/app/assets/stylesheets/.
  cp ${HTML_PATH}/bootstrap/*.js ${TH_PATH}/app/assets/javascripts/.
  cp ${HTML_PATH}/datepicker/*.css ${TH_PATH}/app/assets/stylesheets/.
  cp ${HTML_PATH}/datepicker/*.js ${TH_PATH}/app/assets/javascripts/.
  cp -rf ${HTML_PATH}/images/* ${TH_PATH}/app/assets/images/.
  cp -rf ${HTML_PATH}/email/images/* ${TH_PATH}/app/assets/images/email/.
  # sed 流编辑器的批量处理文件的能力还是值得称赞的，这一点vim，也已可以做到，不过不太熟悉非交互式的vim就是。
  sed -i 's/\.\.\/images/\/assets/' ${TH_PATH}/app/assets/stylesheets/*.css
  # unix2mac ${TH_PATH}/app/assets/stylesheets/*.css
  # 禁用比较的原因是，diff之后的输入比较的杂
  # echo "show some change in cp and sed" 
  # for file in ${TH_PATH}/app/assets/stylesheets/*.css  ; do
  #   file1=${HTML_PATH}/css/$(basename $file)
  #   echo "----show different between $file and $file1"
  #   diff $file $file1
  # done
  # 这里rm的文件是由于上面全盘复制时，引入的无用的文件，所以需要删除。
  rm ${TH_PATH}/app/assets/javascripts/jquery-1.8.3.min.js
  rm ${TH_PATH}/app/assets/javascripts/jquery*
  rm ${TH_PATH}/app/assets/javascripts/bootstrap.min.js
  rm ${TH_PATH}/app/assets/javascripts/date.js
  rm ${TH_PATH}/app/assets/javascripts/bootstrap-modal-extend.js
}

# 在全部的四个项目中查找某个
function gfind() {
  if [  $# ==  0  ] ; then
    echo "Usage: gfind函数需要一个参数"
    return
  fi
  dir=("/home/xiajian/works/engine" "/home/xiajian/works/bjobs" "/home/xiajian/works/mobile" /home/xiajian/works/mobile_ios /home/xiajian/works/web)
  for d in ${dir[*]}; do 
    cd $d
    echo "Find $@ in "$(pwd)
    git grep $@
  done
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
    git add -A $(pwd) && git ci -m"$1" && git push
  fi
}

# 显示并打开特定的gem包
function gem-show() {
  if [ $# == 0 ] ; then
    echo "描述: gem-show是用来编辑特定gem包的函数"
    echo "Usage: gem-show [gem name]"
  else
    if [[  $(bundle show $1) =~ "Could not" ]] ; then
      echo "当前环境中不包含$1"
    else
      cd $(bundle show $1)
      vi
    fi
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

function cc() {
  if [ $# == 1 ] ; then
    echo "=== 将"$1"繁转简"
    opencc -i $1 -c zht2zhs.ini
  else
    opencc -i $1 -o $2 -c zht2zhs.ini
  fi
}

# python启动本地服务器的命令是: python -m SimpleHTTPServer 8888
function ruby-local-server(){
  if [ $# == 0 ] ; then
    port=8080
  else
    port=$1
  fi
  echo "启动本地server: http://localhost:"$port"/"
  ruby -run -e httpd . -p $port
}

function db() {
  mysql -ulodestone  -ptophold_3306 -h192.168.1.88
}

# 简单的包装 yeoman 
function yeoman() {
  if [ $# == 0 ] ; then
    echo "[usage]: yeoman project_name"
  else
    mkdir $1 && cd $1 
    echo "Now ,we are in $1, and yeoman will generate $1 project"
    yo angular $1
  fi
}

# 编写YUI的辅助函数
function yui() {
  yui_dir=/home/xiajian/software/yuicompressor/build/yuicompressor-2.4.8.jar
  java -jar ${yui_dir}  "$@"
}

# add path for zed
#export PATH= ${PATH}:$HOME/software/zed
#写了几个别名，这样可以少敲点字
work_space=/home/xiajian/works/
alias web='cd ${work_space}web'
alias engine='cd ${work_space}engine'
alias bjobs='cd ${work_space}bjobs'
alias html='cd ${work_space}html'
alias wind='cd ${work_space}windtalker'
alias cywin='cd ${work_space}cywin'
alias tst='cd ${work_space}test'
alias blog='cd ${work_space}blog'
alias wblog='cd ${work_space}wblog'
alias cpanel='cd ${work_space}cpanel'
alias gitlab='cd ${work_space}gitlab-ce'
alias redmine='cd ${work_space}redmine'
alias rhg-zh='cd ${work_space}rhg-zh'
alias rbp-zh='cd ${work_space}rbp-zh'
alias mongoid-zh="cd ${work_space}mongoid-zh"
alias mobile="cd ${work_space}mobile_ios"
alias mweb="cd ${work_space}mobile"
alias grape='cd ${work_space}grape'
alias rack='cd ${work_space}rack'
alias h5bp='cd ${work_space}h5bp'
alias githuber='cd ${work_space}githuber'
alias amazeui='cd ${work_space}amazeui'
alias emapi='cd /home/xiajian/works/EMAPI'
alias emf='cd /home/xiajian/works/EMFramework'
alias rguide='cd /home/xiajian/works/rails_guides'
alias vbundle='cd /home/xiajian/.vim/bundle'
alias down='cd /home/xiajian/Downloads'
alias brc='vi ~/.zshrc'
alias vrc='vi ~/.vimrc'
alias rc='rails c'
alias rs='rails s'
alias redis='redis-cli'
alias sb='source ~/.zshrc'
alias ggrep='git grep'
alias gdiff='git diff'
alias img='sshfs root@192.168.1.99:/web/staging/th/current/public/uploads/ ${web}/public/uploads'
# 网上说：卸载远程文件系统可以使用umount和fusermount,前者不起作用,后者用来卸载fufs(用户空间的文件系统)
alias unimg='fusermount -u ${web}/public/uploads'
alias mlog='tail -f /var/log/mongodb/mongodb.log'
alias mdata='cd /var/lib/mongodb/'
alias mdb='mongo --host 192.168.1.88'
alias disc='cd /home/xiajian/works/discourse'

# 关连文件名后缀与编辑器
alias -s html=vi   # 在命令行直接输入后缀为 html 的文件名，会在 TextMate 中打开
alias -s rb=vi     # 在命令行直接输入 ruby 文件，会在 TextMate 中打开
alias -s py=vi       # 在命令行直接输入 python 文件，会用 vim 中打开，以下类似
alias -s js=vi
alias -s c=vi
alias -s java=vi
alias -s txt=vi
alias -s log=less
alias -s gz='tar -xzvf'
alias -s tgz='tar -xzvf'
alias -s zip='unzip'
alias -s bz2='tar -xjvf'
