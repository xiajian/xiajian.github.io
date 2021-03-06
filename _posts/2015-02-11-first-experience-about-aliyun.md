---
layout: post
title: 阿里云的初体验
description: "阿里云，nginx，ab测试"
---

## 前言

昨天，买了青岛的1核1G的阿里ECS，想想用来干啥呢？ 用来测试和部署吧。以下是探索经过程。

## 探索

安装nginx，apache2-utils(包含ab测试工具)，rbenv，ruby等。部署测试的应用程序是Discourse(太过庞大了，放弃配置)。

> Discourse的依赖项和安装环境都太过复杂了，1G1核根本玩不下去。在思考阿里云的基础虚拟化到底是怎么做到了时
> 想到，不会是使用的xen吧，还是直接购买的VMware的虚拟化服务，不过后者看起来不太可能。毕竟装机量实在太大了。
> 若干天后，发现都不是，是基于[OpenStack](http://www.openstack.org/)搭建的。此外，发现RackSpace相当厉害。

## 挂载购买的数据盘

fdisk, mount, mkfs.ext4(居然真的有这种命令), df -h

备注：后来，发现ECS文档中有提供相应的介绍。

### ab测试

命令: ab -n1000 -c10 http://115.28.165.58/

结果: 

本地测试服务器效果: 

```
Server Software:        nginx/1.4.6
Server Hostname:        115.28.165.58
Server Port:            80

Document Path:          /
Document Length:        612 bytes

Concurrency Level:      10
Time taken for tests:   10.100 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      853000 bytes
HTML transferred:       612000 bytes
Requests per second:    99.01 [#/sec] (mean)
Time per request:       100.996 [ms] (mean)
Time per request:       10.100 [ms] (mean, across all concurrent requests)
Transfer rate:          82.48 [Kbytes/sec] received
```

服务器本地测试结果:

```
Server Software:        nginx/1.4.6
Server Hostname:        115.28.165.58
Server Port:            80

Document Path:          /
Document Length:        612 bytes

Concurrency Level:      10
Time taken for tests:   0.149 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      853000 bytes
HTML transferred:       612000 bytes
Requests per second:    6720.66 [#/sec] (mean)
Time per request:       1.488 [ms] (mean)
Time per request:       0.149 [ms] (mean, across all concurrent requests)
Transfer rate:          5598.36 [Kbytes/sec] received
```

> 上面的结果还是很不错的，虽然只是请求简单的静态首页。毕竟，机器的配置(1核1G)不怎么样。

设置较多界面元素的HTML页面测试: 

```
Server Software:        nginx/1.6.2
Server Hostname:        115.28.165.58
Server Port:            80

Document Path:          /
Document Length:        28152 bytes

Concurrency Level:      10
Time taken for tests:   208.945 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      28387000 bytes
HTML transferred:       28152000 bytes
Requests per second:    4.79 [#/sec] (mean)
Time per request:       2089.454 [ms] (mean)
Time per request:       208.945 [ms] (mean, across all concurrent requests)
Transfer rate:          132.67 [Kbytes/sec] received
```

> 备注: 修改了几个配置项(epoll选项，worker_connections等)，发现每秒处理的请求数不升反降(4.79, 4.78, 4.75 )，云服务器的网络监控图如下: 

<div class="pic">
  <img src="/assets/images/netmonitor.png" alt="阿里云网络监控图"/>
</div>

仔细观察一下，可以发现，这是由于自己购买的云服务的1M带宽的限制，从图中的上升趋势来看，加大worker数确实能提高请求处理的速度。遗憾的就是，
自建的服务器没有建立一套实时的网络浏览监控体系，只能通过ab测试得到统计的平均数据。

对静态页面做ab测试，怀疑是带宽限制了速度，升级了几个小时的带宽(5Mbs)测试一下，其结果如下: 

```
# worker数为2时
Server Software:        nginx/1.6.2
Server Hostname:        115.28.165.58
Server Port:            80

Document Path:          /
Document Length:        28152 bytes

Concurrency Level:      10
Time taken for tests:   41.752 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      28387000 bytes
HTML transferred:       28152000 bytes
Requests per second:    23.95 [#/sec] (mean)
Time per request:       417.520 [ms] (mean)
Time per request:       41.752 [ms] (mean, across all concurrent requests)
Transfer rate:          663.96 [Kbytes/sec] received
```

```
#worker数为8时:
Server Software:        nginx/1.6.2
Server Hostname:        115.28.165.58
Server Port:            80

Document Path:          /
Document Length:        28152 bytes

Concurrency Level:      10
Time taken for tests:   42.266 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      28387000 bytes
HTML transferred:       28152000 bytes
Requests per second:    23.66 [#/sec] (mean)
Time per request:       422.662 [ms] (mean)
Time per request:       42.266 [ms] (mean, across all concurrent requests)
Transfer rate:          655.88 [Kbytes/sec] received
```

从波形图上可以看到，没有达到峰值带宽，看来`-n1000 -c10`的测试实在太小了，来个10倍的(`-n10000 -c100`)，测试结果如下: 

```
#worker数为8
Server Software:        nginx/1.6.2
Server Hostname:        115.28.165.58
Server Port:            80

Document Path:          /
Document Length:        28152 bytes

Concurrency Level:      100
Time taken for tests:   419.144 seconds
Complete requests:      10000
Failed requests:        0
Total transferred:      283870000 bytes
HTML transferred:       281520000 bytes
Requests per second:    23.86 [#/sec] (mean)
Time per request:       4191.442 [ms] (mean)
Time per request:       41.914 [ms] (mean, across all concurrent requests)
Transfer rate:          661.39 [Kbytes/sec] received
```

波形图的对比: 

<div class="pic">
  <img src="/assets/images/netmonitor1.png" alt="阿里云网络监控图"/>
</div>

`ab -n100000 -c100`测试下的处理结果: 

```
#备注: 测试了相当长的时间，大概半个多小时的样子
Server Software:        nginx/1.6.2
Server Hostname:        115.28.165.58
Server Port:            80

Document Path:          /
Document Length:        28152 bytes

Concurrency Level:      100
Time taken for tests:   4180.734 seconds
Complete requests:      100000
Failed requests:        0
Total transferred:      2838700000 bytes
HTML transferred:       2815200000 bytes
Requests per second:    23.92 [#/sec] (mean)
Time per request:       4180.734 [ms] (mean)
Time per request:       41.807 [ms] (mean, across all concurrent requests)
Transfer rate:          663.08 [Kbytes/sec] received
```

> 备注: 10000个请求的本地下载速率为 750kb/s。

反思一下，将带宽从1Mb/s提升到5Mb/s，处理请求从4 req/s 到 23 req/s，提升了5倍左右，由于是静态文件，CPU的负载一直处于10%以下，磁盘的负载也是写大于读。这里得出结论，静态文件处理的瓶颈主要在带宽上。

**注**：找到一个网络流量监控的工具 - iftop ，试了一下，看来不能用在云上，完全没有反应啊。- 可能是虚拟主机的原因，没有实体的eth0接口。

> 备注: Nginx配置的修改没有能带来巨富的变化，看来，对于动态内容，处理的瓶颈不再前端的Nginx服务器上。

修改本地hosts，将自己的阿里云的服务器取名为test.com。

### nginx的配置

nginx的安装有多种方式，我选择的最省事的。网上其他的人貌似选择的是编译源码安装，所以，我在照抄他人配置时遇到了一个问题，就是无论怎么配置都不去起作用。后来发现，
使用deb包安装Nginx时，其配置文件做了一定的分离。即为多个文件组合配置: 

```
...
include /etc/nginx/conf.d/*.conf;
include /etc/nginx/sites-enabled/*; # 站点特定的配置文件，默认的目录为/usr/share/nginx/html，实现配置分离
...
```

> 备注: nginx.conf中的配置是会被覆盖的，之后的覆盖先前的。搞一个下午，最后才想到可能是配置被覆盖的原因。

## ruby和node安装

node安装: 

```
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.23.3/install.sh | bash
nvm install 0.10
nvm alias default 0.10.32
```

ruby安装: 

```
git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
# 用来编译安装 ruby
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
# 用来管理 gemset, 可选, 因为有 bundler 也没什么必要
git clone git://github.com/jamis/rbenv-gemset.git  ~/.rbenv/plugins/rbenv-gemset
# 通过 gem 命令安装完 gem 后无需手动输入 rbenv rehash 命令, 推荐
git clone git://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash
# 通过 rbenv update 命令来更新 rbenv 以及所有插件, 推荐
git clone https://github.com/rkh/rbenv-update.git ~/.rbenv/plugins/rbenv-update

rbenv install 1.9.3
rbenv global 1.9.3
```

rbenv不好用，换回rvm，结果，发现，rvm更加坑爹，安装下载慢的要死，搞得我想换系统，结果没换成。算了，还是继续用rvm吧。

> 之所以慢的原因是，下载地址是https的，好像需要什么证书之类，不然还下载不了。

再次使用rvm时，注意到，RVM是自动安装Ruby的依赖库的，rbenv确不会，所以，前者在使用时，缺少了zlib。此外，rvm的安装的依赖库为: 
gawk, libreadline6-dev, zlib1g-dev, libssl-dev, libyaml-dev, libsqlite3-dev, sqlite3, autoconf, libgdbm-dev, libncurses5-dev, automake, libtool, bison, pkg-config, libffi-dev

> 好长一坨依赖项。此次观察体验，rbenv的编译要比rvm更耗cpu。rvm安装的全局依赖项要多一些，也要省事一些。

将自己blog生成的静态页面放到`/usr/share/nginx/html/`, 请求处理立马下降到了10个每秒。

> 备注: 2月11日，到4点钟为止，所有的探索均为失败的。算了，不想玩这个了。

## linux系统

阿里云的ubuntu镜像意外的对系统进行一定程度的优化？ 比如 `ulimit -a`，难道是服务器操作系统的原因。

> 从系统微观调优上来考虑，centos要比ubuntu在细节上做的好。

su切换root权限太不安全，admin分组和相应用户: groupadd & useradd，仅限开发环境中。

程序的后台运行: & 和 nohup。

系统盘和数据盘的区别：因为自己怕麻烦，分区啊，引导区啊之类的，超麻烦的。所以将整个系统安装到了硬盘上，一个系统只有一个盘。但是考虑到云上，
想到系统盘固定20G，数据盘确可以无限大; 系统盘主要用来安装软件之类，数据盘可以用来存放各种数据(网站，日志，数据库之类)。

> ps: 初创公司需要的云计算服务： 国内App Engine不靠谱，VPS小而美，云存储应对付峰值带宽。

lsmod命令对比，发现阿里提供的镜像中，内核预编译的模块还挺少。只有25个，99测试上53个，本地机器75个。

lsof命令，本地打开的文件超多(14万)，阿里的(9100)，web服务器上(2400)。其中，阿里的数据比较难以理解，nginx打开了7千多个文件。这也太夸张了吧！！

**问题1:** 发现阿里上的redis，不能正常的使用redis-cli，因为连接被拒绝了Connection refused。

疑问，一直不太明白那些奇怪的入网流量，今天，查看Nginx的access.log时，有些奇怪的访问，想到，肯定是那个混蛋把这些坑爹的请求转发给我的服务器的。
后来，想了想，这样也是挺不错的，至少让看到了博客的访问日志，以及发现日志自动的打包的处理。

**问题2:** whatis: can't set the locale; make sure $LC_* and $LANG are correct

解决方法: 

先执行`locale`检查哪个语言设置有问题，然后执行`locale-gen zh_CN.UTF-8`。之后，发现vim中Nerdtree的乱码也搞定了，看来语言设置是个大问题啊。

参考: [解决ubuntu can't set the locale; make sure $LC_* and $LANG are correct的问题](http://www.cnblogs.com/skiloop/archive/2013/02/20/2919266.html)

## 安全运维

系统中的用户: root, daemon, bin, sys,  man, lp, mail, news, uucp, proxy, www-data, backup, list, irc, gnats, nobody, sshd。这里，lp、uucp显然都是用不到的。

查看系统中服务(Ubuntu: sysv-rc-conf, Redhat: chkconfig)

> 经验1：服务器中复制文件时，使用命令行更加方便，向本地复制文件时，使用使用sftp的GUI更加方便。原因是，SFTP删除和复制时，总是先拷贝到本地在处理。

运维果然还是经验更多一些。

## wlog

静态页面的测试已经非常的熟练和详尽了，改找个动态Ruby程序测试测试了。这不，就选[wlog](https://github.com/windy/wblog)了。

尝试成功，参考[尝试unicorn]()。

## OOS

申请到了oss服务，要尝试一下的。

## 升级

尝试升级了两次，一次是临时升级了一下带宽(几个小时)，一次是将内存升级到2GB，升级了之后，使用了`free -m`命令，观察了一下服务器，对比数据如下： 

```
# 升级前，长时间运行
             total       used       free     shared    buffers     cached
Mem:          1001        874        126          0        131        315
-/+ buffers/cache:        428        573
Swap:            0          0          0

# 升级后，重启之后
             total       used       free     shared    buffers     cached
Mem:          2015        366       1649          0         22        121
-/+ buffers/cache:        221       1794
Swap:            0          0          0
```

可以看到，随着使用时间的增长，使用的内存数会越来越多。

## 后记

今天看到，NodeJS分裂项目IoJS，开源人果然好样的，开源才是未来的趋势。

看到青云和美团云，想了解国内的云计算厂商平台，找到[国内云计算厂商及产品介绍](www.jifang360.com/special/cloud20130315/)，
感觉还是相当有趣的，相当的有`钱途`。
