---
layout: post
title: 关于passenger
description: "ruby, passenger, nginx 部署"
---

## 前言

对现有的功能和实现不了解，总是想着改来该去，这种做法是不对的。我应该先对现有的实现充分的了解和认知，理解其优缺点，理解现有
架构的瓶颈，然后再对症下药，这样才是正确的做法。

不迷信，不盲从，理性思考。

## 正文

硬件环境： Ubuntu 14.04 + Nginx，passenger安装和使用主要参考[Phusion Passenger for Nginx users guide](https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html)。

Passenger是Nginx的一个模块，模块名为: passenger-install-nginx-module。

### 安装

命令集合:

```sh
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
sudo apt-get install apt-transport-https ca-certificates  # https的源的支持
echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main # Ubuntu 14.04" > /etc/apt/sources.list.d/passenger.list
sudo chown root: /etc/apt/sources.list.d/passenger.list
sudo chmod 600 /etc/apt/sources.list.d/passenger.list    # 注意文件权限，不然不能识别
sudo apt-get update
sudo apt-get install nginx-extras passenger
```

> 备注: passenger的依赖项颇多，即  
  The following NEW packages will be installed:  
  crash-watch gdb libc6-dbg libev4 libjs-jquery liblua5.1-0 libperl5.18  
  libpython3.4 libruby1.9.1 libruby2.0 nginx-extras passenger passenger-dev  
  passenger-doc ruby ruby-daemon-controller ruby-rack ruby1.9.1 ruby2.0  
  rubygems-integration  
  感觉有点夸张，不过passenger的源升级了一下Nginx，可以尝试最新的Nginx，这一点还是相当不错的。

然后，nginx.conf的配置文件: 

```
http {
  ...
  passenger_root /path-to-locations.ini;
  passenger_ruby /path-to-ruby;
  ...
}
```

### 现有做法

看到passenger文档中的配置那么麻烦，想要了解公司现有的做法，于是去请教了一番: 

前辈的做法如下: 

```
ruby -> gem -> rails -> passenger -> nginx
gem i rails -v 3.2.13 --no-ri --no-rdoc # 生产环境不安装文档
gem install passenger
passenger-install-nginx-module # 安装nginx
```

使用的配置文件: 

```
http {
  passenger_root /usr/local/lib/ruby/gems/1.9.1/gems/passenger-4.0.50;
  passenger_ruby /usr/local/bin/ruby;

  server {
    listen 80;
    server_name xxx.com;
    root /path-to-project; # 即Ruby项目的主目录
    passenger_enabled on;
    ...
  }
}
```

仔细对比了一下我自己的做法: nginx -> passenger -> nginx , rvm -> ruby -> rails。我的做法比较的凌乱，算了，
原本就是试验性的，乱就乱吧，反正计划扔掉一个和复盘。

看到公司的web服务器上，配置文件采用的策略和ubuntu的包安装使用的策略相似，根据功能进行职权分离。不过，实战中的配置文件感觉好复杂。

## Raptor

passenger 5的代号为Raptor，据说相当的快。其中，使用三种I/O模型: 多进程阻塞I/O, 多线程阻塞I/O, 事件I/O。

默认使用多进程阻塞I/O模型，类似Unicorn，内置反向代理缓存(C++编写，事件I/O)。Raptor使得反向代理变的简单，且开箱即用。

HTTP parser使用的是Nginx的HTTP Parser(NodeJS也使用的这个parser)，HTTP server使用的是Nginx的HTTP server(做了优化，去掉了不要的功能)

> slow client问题: modern用户，以及现在的mobile用户。可通过方向代理缓存进行处理。

看起来就像在说，我们提供的功能更多，特性更强，性能更好。。。。

我还是喜欢只做一件事，并将其做好的这种设计哲学。

> 照passenger自己这么自吹自擂的话，也就是passenger完全可以使用在开发模式中，有机会尝试尝试。

## 后记

passenger好复杂，真的好复杂，我要放弃它搞passenger，搞Unicorn吧，此外，对应用架构的方式还是心存疑虑。

选择过多就会造成选择性困难，所以，做选择时，需要考虑从什么角度和方向出发，权衡利弊。

升级一下，就会有更好的体验，看起来更加的容易一点。

## 参考文献

1. [为什么我们开发的Raptor比Unicorn快4倍，比Puma，Torquebox快2倍](http://ohcoder.com/blog/2014/11/11/raptor-part-1/)
