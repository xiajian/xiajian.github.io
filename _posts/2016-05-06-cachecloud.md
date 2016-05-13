---
layout: post
title: CacheCloud - 搜狐 TV 的 cache 管理
description: 'redis， java， maven'
category: note
---

## 前言

好几个项目中，使用了 Redis，这事就涉及一个管理的工具。 


## 安装

CacheCloud 环境需求

导入数据: 

```
mysql -u root

CREATE DATABASE IF NOT EXISTS `cache-cloud` DEFAULT CHARSET utf8 COLLATE utf8_general_ci;

use cache-cloud;

source script/cachecloud.sql;
```

Ubuntu: 

```
#  Java 7 - 需要 java 编译器 - javac
apt-get install openjdk-7-jdk
#  Maven 3
apt-get install maven
#  MySQL
apt-get install mysql
#  Redis 3
apt-get install redis-server

git clone https://github.com/sohutv/cachecloud
```

项目中内嵌了关于`cachecloud`目录, 需要修改一下用户名和组: 

```
sudo mkdir -p /opt/cachecloud/data
sudo mkdir -p /opt/cachecloud/conf
sudo mkdir -p /opt/cachecloud/logs
sudo mkdir -p /opt/cachecloud/redis
mkdir -p /tmp/cachecloud
sudo chown -R xiajian:staff /opt/cachecloud

sudo mvn spring-boot:run # 运行比较耗时
```

## 忘记 mysqld 密码

```
sudo service mysql stop
mysqld_safe --skip-grant-tables &  # 启动安全模式下的 mysql
mysql -uroot -p # 无需密码
use mysql;
update user set password=PASSWORD('12345678') where user="root";
flush privileges;
quit;
ps axu | grep mysqld_safe 
kill -9 xxx
service mysqld start
mysql -uroot -p 
```

尝试使用复杂的管道命令行，进行处理： `ps axu | grep mysqld | awk  '{print $2}' | xargs echo`;

## 尝试打包 Dockerfile

待处理！！

## 学习

1. 快速启动

  - 初始化数据库，包括 相关的 配置
  - 初始化工程 - 使用 maven 构建
  - 本地启动 - `mvn spring-boot:run`
  - 测试 
  
2. 机器管理

  - 机器处理化 Redis 环境， 使用默认的 
  - 添加机器 

3. 开通应用

  - redis 集群
  - redis 哨兵
  - redis standalone

4. 客户端连接
  
  如何使用，是个关键。

遇到的问题： 

```
- Active log file name: /opt/cachecloud-web/logs/stdout.2016-05-11.log
- File property is set to [null]
- Failed to create parent directories for [/opt/cachecloud-web/logs/stdout.2016-05-11.log]
- openFile(null,true) call failed. java.io.FileNotFoundException: /opt/cachecloud-web/logs/stdout.2016-05-11.log (No such file or directory)
```

解决： 没有创建文件的权限。 `mkdir /opt/cachecloud-web`。

```
// 配置文件 local 是本地启动的配置，online 是在线的配置
cachecloud/cachecloud-open-web/src/main/swap/local.properties
cachecloud/cachecloud-open-web/src/main/swap/online.properties
```

想法： 利用 CacheCloud 搭建云深网络的 redis cache 管理。

配注： 

如下的配置，意味着，所有的机器上都要相同的配置才行， 这个会有很大的问题。

```
cachecloud.machine.username = cachecloud
cachecloud.machine.password = cachecloud
cachecloud.machine.ssh.port = 22
```

CacheCloud 使用了一种 quartz 的库， 进行任务管理。

## 后记

> 吃的越差，女人越丑，国家的人民就越奋斗，经济越发达。 - 晓说

java 部署，就是生成一个 war 包。

尝试并安装了 IntelliJ IDEA,  感觉相当的不错。 也用了一年的 RubyMine，感觉 JetBraints 的 IDE 功能大多类似。 

## 参考文献

1. [Mysql Root 用户密码重置](http://jingyan.baidu.com/article/63f236280a11680208ab3d91.html)