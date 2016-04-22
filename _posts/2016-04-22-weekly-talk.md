---
layout: post
title: 本周分享
description: '分享，生活，lunchy，master password, 微信读书，生活'
category: note
---

## 前言

坚持就是胜利！！胜利就是彼岸之花！

## lunchy

类似 ubuntu 和 debian 中的 service ，以及 centos 中的 systemctl

安装： `brew install Caskroom/cask/lunchy`

使用：

```
$ lunchy
Lunchy 0.2.1, the friendly launchctl wrapper
Usage: lunchy [start|stop|restart|list|status|install|show|edit|remove|scan] [options]

✗ lunchy ls
com.google.keystone.agent
com.tencent.xin.WeChatHelper
homebrew.mxcl.elasticsearch
homebrew.mxcl.memcached
homebrew.mxcl.mongodb
homebrew.mxcl.mysql
homebrew.mxcl.nginx
homebrew.mxcl.openresty
homebrew.mxcl.postgresql
homebrew.mxcl.redis
org.getlantern
org.virtualbox.vboxwebsrv

使用演示

➜  camp git:(sit) ✗ ps aux | grep memcached
xiajian          1829   0.0  0.0  2484720    244   ??  S    三05下午   0:01.89 /usr/local/opt/memcached/bin/memcached -l localhost
xiajian         49888   0.0  0.0  2435864    800 s008  S+   11:05上午   0:00.00 grep --color=auto --exclude-dir=.bzr --exclude-dir=CVS --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn memcached
➜  camp git:(sit) ✗ lunchy stop memcached
stopped homebrew.mxcl.memcached
➜  camp git:(sit) ✗ ps aux | grep memcached
xiajian         49925   0.0  0.0  2444056    808 s008  S+   11:05上午   0:00.00 grep --color=auto --exclude-dir=.bzr --exclude-dir=CVS --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn memcached
```

## master password

类似 1Password 之类的密码管理工具，离线的。

```
$ brew install mpw

# 使用
✗ mpw
Your full name: test
Site name: test.com
Your master password:
test's password for test.com:
[ ╔░╗♚ ]: HakvJirySako2_
```

帮助命令介绍，使用说明：

```
✗ mpw -h
Usage: mpw [-u name] [-t type] [-c counter] site
```

生成密码 和 查看密码：

```
✗ mpw test.com
Your full name: test
Your master password:
test's password for test.com:
[ ╰░╯♔ ]: Kupu3$BexoJovh
✗ mpw  -u test test.com
Your master password:
test's password for test.com:
[ ╰░╯♔ ]: Kupu3$BexoJovh
```

## APP

喜马拉雅 FM：

收听的电台：

- 吴晓波频道
- 逻辑思维
- 极客电台
- 老汪谈职场

微信读书

## 书籍

- 《Rework》- 37Signals， 热衷于副产品
- 《激荡三十年 上下卷》- 吴晓波， 如何看待中国企业
- 《万物生长》- 冯唐
- 《OpenResty 最佳实践》 - 结合 Lua 和 Nginx 这两大利器
- 《货币战争》 - 宋鸿兵编辑，去年被大妈揍了

## 后记

生活就像山谷里的回想，你这么对待她，她就怎么回你。 所以， 我对它媚眼相对，暗送秋波，眉目传情，希望她能爱上我。