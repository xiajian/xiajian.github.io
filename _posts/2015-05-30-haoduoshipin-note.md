---
layout: post
title: 好多视频阅读笔记
description: "http://haoduoshipin.com 中的cast的阅读笔记"
category: note
---

## 前言

最近接触了 HappyPeter 的相关视频，仔细观察一下，发现很早就蒙受起泽惠了。好奇猫团队(Peter是其中一员)翻译的 《快乐的Linux命令行》，其录制的视频简短有趣，而又不缺乏知识性。

以下，按分类编排。

## Linux

**vagrant**: 

之前接触的虚拟机管理工具，使用和启动都非常的方便。

**cron**: 

cron是时间的意思，随Linux系统启动的守护进程(`ps aux | grep cron`)，可通过 whenever 从而在Ruby中使用。

**git-it-live**:

Linode, DigitalOcean(5美元服务)。防火墙墙IP，而不是域名。5美元服务，域名和备案服务。

**sendmail**:

sendmail是自配置的邮件服务系统。

**ssh**: 

服务器名太长 or ip 太啰嗦，可以在`/etc/hosts`中写入如下的行: 

```
127.0.0.1       xj
```

ctrl-d 可以干掉当前的终端tab页， ssh-copy-id可以将key上传到服务器上。

```
ssh test.com 'touch abc && sudo apt-get update && souce ~/.bashrc'
```

上面的这个简单的命令演示了在不使用capistrano时，直接使用ssh进行简单的部署。

**rsync**:

scp 如同 cp 那样简单和操作。rsync 最初用来取代 scp。 rsync 只传输两个大目录树的差异文件。

rsync的简单使用: 

```
rsync -r mydir/ root@aliyun:  # 注意，带/和不带/的目录的含义不同
rsync -r --delete mydir root@aliyun:
rsync -rv --delete mydir root@aliyun:  # 操作时，提示信息
rsync -rv --dry-run --delete mydir root@aliyun:  # 不操作，仅提示信息
```

使用scp ，直接使用命令行，使用rsync，倾向编写脚本。
