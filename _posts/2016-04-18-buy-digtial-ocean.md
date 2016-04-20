---
layout: post
title: 购买 Digital Ocean VPS 主机    
description: 'digital ocean 主机， 美国主机，ubuntu'
category: note
---

## 前言

第一次消费美元，很是激动不已。 

在 Linode 和 Digital Ocean 之间， 选择了 Digital Ocean，原因是 Linode 没有 5 美元的套餐， 而且 DO 有优惠券.

## 安装

初始安装的软件： 

```
sudo apt-get update
sudo apt-get install nginx mysql-server tmux
sudo apt-get install 
```

## 经验

优惠码地址: <http://digitalocean.youhuima.cc/>

Digital Ocean 没有 VPN 就完全们不能访问啊。 页面内添加了 ssh key，不一定能 添加到 authorize_keys 中。

do 的 ssh 的 session 不能维持很久,  sshd 具有自动保护的的自动断开机制。

中国到洛杉矶的网络太渣了，在新加坡上新建了一个主机：

对比节点：

```
ping 188.166.209.243
PING 188.166.209.243 (188.166.209.243): 56 data bytes
64 bytes from 188.166.209.243: icmp_seq=0 ttl=52 time=80.403 ms
64 bytes from 188.166.209.243: icmp_seq=1 ttl=52 time=70.927 ms
64 bytes from 188.166.209.243: icmp_seq=2 ttl=52 time=70.049 ms
64 bytes from 188.166.209.243: icmp_seq=3 ttl=52 time=70.746 ms
^C
--- 188.166.209.243 ping statistics ---
4 packets transmitted, 4 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 70.049/73.031/80.403/4.269 ms

ping 107.170.247.92
PING 107.170.247.92 (107.170.247.92): 56 data bytes
64 bytes from 107.170.247.92: icmp_seq=0 ttl=50 time=202.570 ms
64 bytes from 107.170.247.92: icmp_seq=1 ttl=50 time=200.645 ms
64 bytes from 107.170.247.92: icmp_seq=2 ttl=50 time=200.148 ms
64 bytes from 107.170.247.92: icmp_seq=3 ttl=50 time=198.629 ms
^C
--- 107.170.247.92 ping statistics ---
5 packets transmitted, 4 packets received, 20.0% packet loss
round-trip min/avg/max/stddev = 198.629/200.498/202.570/1.408 ms
```

时延整整多个了2倍多，那还是在链接了 vpn 的情况。

以下是在不连 VPN 的情况: 

```
# ping 域名：

ping www.xuewb.com
PING www.xuewb.com (188.166.209.243): 56 data bytes
64 bytes from 188.166.209.243: icmp_seq=0 ttl=50 time=368.295 ms
64 bytes from 188.166.209.243: icmp_seq=1 ttl=50 time=389.148 ms
64 bytes from 188.166.209.243: icmp_seq=2 ttl=50 time=310.213 ms
64 bytes from 188.166.209.243: icmp_seq=3 ttl=50 time=319.688 ms
64 bytes from 188.166.209.243: icmp_seq=4 ttl=50 time=465.953 ms
64 bytes from 188.166.209.243: icmp_seq=5 ttl=50 time=447.602 ms

# ping IP 地址：

ping 188.166.209.243
PING 188.166.209.243 (188.166.209.243): 56 data bytes
64 bytes from 188.166.209.243: icmp_seq=0 ttl=50 time=280.277 ms
64 bytes from 188.166.209.243: icmp_seq=1 ttl=50 time=314.589 ms
64 bytes from 188.166.209.243: icmp_seq=2 ttl=50 time=351.342 ms
64 bytes from 188.166.209.243: icmp_seq=3 ttl=50 time=349.678 ms
64 bytes from 188.166.209.243: icmp_seq=4 ttl=50 time=374.985 ms
64 bytes from 188.166.209.243: icmp_seq=5 ttl=50 time=287.467 ms
```

计算以下， 也就是存在 60-80ms 的 DNS 解析的时延。


## 后记

写的乱糟糟的。 最近，觉得花钱消费还是相当的不错的。 只要，愿意花钱，总能买到有用的东西。
