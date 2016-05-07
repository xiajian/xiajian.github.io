---
layout: post
title: CacheCloud - 搜狐 TV 的 cache 管理
description: 'redis， java， maven'
category: note
---

## 前言

好几个项目中，使用了 Redis，这事就涉及一个管理的工具。 


## 安装

CacheCloud环境需求

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

## 后记

> 吃的越差，女人越丑，国家的人民就越奋斗，经济越发达。 - 晓说

## 参考文献

1. [Mysql Root 用户密码重置](http://jingyan.baidu.com/article/63f236280a11680208ab3d91.html)