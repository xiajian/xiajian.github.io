---
layout: post
title: 环境配置
description: '项目的环境配置'
category: note
---

## 前言

使用 docker 或者 vagrant 配置开发环境更加好。

## 环境配置

打开终端，按顺序输入如下的命令: 

homebrew 安装：

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

扩展：http://www.brewformulas.org/

数据库安装: 

brew install mysql

安装完 mysql 之后，注意建议设置开机自启动，命令如下：  

      launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
      launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist     

通过 ps -ef | grep mysql， 查看到有如下的进程，说明 postgresql 在运行： 

      501  1845     1   0 三05下午 ??         0:00.03 /bin/sh /usr/local/opt/mysql/bin/mysqld_safe --bind-address=127.0.0.1 --datadir=/usr/local/var/mysql
      501  1980  1845   0 三05下午 ??         0:58.25 /usr/local/Cellar/mysql/5.6.26/bin/mysqld --basedir=/usr/local/Cellar/mysql/5.6.26 --datadir=/usr/local/var/mysql --plugin-dir=/usr/local/Cellar/mysql/5.6.26/lib/plugin --bind-address=127.0.0.1 --log-error=/usr/local/var/mysql/xiajiandeMacBook-Pro.local.err --pid-file=/usr/local/var/mysql/xiajiandeMacBook-Pro.local.pid

brew install redis

安装完 redis 之后，注意建议设置开机自启动，命令如下：  

      launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
      launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist      

通过 ps -ef | grep redis 查看 redis: 

      501   313     1   0  4:23下午 ??         0:00.34 /usr/local/opt/redis/bin/redis-server 127.0.0.1:6379  

**注意**： redis 的版本必须要要高于 2.8 以上，这是 sidekiq 的需要

个人本地配置的 redis，有可能配置了密码，也有可能没有配置密码， 需要通过如下的命令查看： 

      cat /usr/local/etc/redis.conf | grep requirepass


oh-my-zsh 安装: 

sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

资产编译相关工具的安装：

brew install advancecomp gifsicle jhead jpegoptim jpeg optipng pngcrush pngquant

brew install node  # 安装 Node 环境

npm install svgo -g 

imageoptim 安装: 

**备注** homebrew-cask 升级并内嵌到 homebrew 中，需要运行如下的迁移的命令: `brew update; brew cask cleanup; brew uninstall --force brew-cask;`

brew cask install imageoptim

测试编译： `environments/bin/compile_assets.sh`

ruby 环境安装:

rvm 安装： 

brew install gpg

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3

\curl -sSL https://get.rvm.io | bash -s stable

配置和切换 gem 源： 

gem sources --add https://ruby.taobao.org/ --remove https://rubygems.org/

bundle config mirror.https://rubygems.org https://ruby.taobao.org

sed -i .bak -E 's!https?://cache.ruby-lang.org/pub/ruby!https://ruby.taobao.org/mirrors/ruby!' $rvm_path/config/db

参考： https://ruby.taobao.org/

rvm install 2.3.0

## cd 创建 可能的相应的目录

git clone xxx.github

cd ../xxx

## 主要开发分支

cd config && ./lnfs_files.sh {各种环境} && cd ../

gem install bundler && bundle


## pngout 的问题

brew cask install imageoptim

操作步骤：

首先，locate imageoptim,  到相应的目录：

```
# 或者其他的目录
cd /opt/homebrew-cask/Caskroom/imageoptim/1.6.0/ImageOptim.app/Contents/Frameworks/ImageOptimGPL.framework/Versions/A/Resources/

for file in $(ls); do
    if [[ -e /usr/local/bin/$file ]]; then
        echo $file" is exist"
    else
        echo 'I will link '$file
        ln -sf $(pwd)/$file /usr/local/bin/$file
    fi
done
```

## 部署脚本

部署脚本如下:

```
function _exec_sh() {
  if [[ -f  $1 ]]; then
    echo '-----------------------------------------'
    cat $1
    echo '\n-----------------------------------------'
    bash $1
  fi
}

function _deploy_usage() {
  echo "cap函数， 使用方式, deploy [dit|sit|prod] [0|1|2]"
  echo "dit - 开发环境，sit - 测试环境，prod - 正式环境"
  echo "0 - 冷部署， 1 - 快速部署，2 - 重启, 默认冷部署"
}

# cap部署函数, 获得经验，不要取使用rvm安装获得的gem包的命令行工具同名的函数
# 这样会引起冲突，并使得bash进程崩溃。估计，gem包提供的命令也是以函数的形式存在的
function deploy() {
  if [[ $1 == 'kjg' ]]; then
    ruby environments/bin/capsh.rb $@
    return
  fi
  cold=environments/bin/cap_deploy_cold_$1.sh
  quick=environments/bin/cap_deploy_quick_$1.sh
  restart=environments/bin/cap_restart_$1.sh
  if [[ $# < 2 ]] ; then
    _deploy_usage
    _exec_sh $cold
  else
    case $2 in
      0)  
        echo "执行冷部署，执行脚本为$cold"
        _exec_sh $cold
        ;;
      1) 
        echo "执行快速部署，执行脚本为$quick"
        _exec_sh $quick
        ;;
      2) 
         echo "执行重启，执行脚本为$restart"
         _exec_sh $restart
         ;;
      *) 
         echo "输入参数非法"
         _deploy_usage
         ;;
    esac
  fi
}
```

部署方式： `deploy sit`。

## 后记

将这些知识封装成一个 docker 镜像。

