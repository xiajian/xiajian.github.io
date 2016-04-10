---
layout: post
title: web 站点性能
description: '浏览器，web 站点，性能，数据库'
category: note
---

## 前言

> 天下武功，为快不破。

> 时间就是金钱，效率就是生命。

> web 性能的关键点： Cache， 缓存一切。 计算机的世界中，缓存无处不在。

没有人喜欢慢的应用, 没有人喜欢等待。

## 性能是什么

更快，更高，更强？？ 那是奥运宗旨。 当网站也要处理更快更高强

性能的指标有哪些： 

* 日访问量 
* 最大并发数
* 同时在线人数
* 访问时间 - 页面加载时间

Google 将 web 的站点的页面访问时间作为搜索排名的一项指标。 

Amazon 发现其页面加载时长与其收入成反比。

## 需要性能优化吗？

> 过早优化是万恶之源

优化不是闭着眼睛瞎猜，需要监控和度量的数据支持。 性能监控可以从两个方面： 

1. 黑盒测试： 通过外部的压力测试，获取先有网站的状况。

2. 白合测试： 通过代码插桩的方式，找到执行缓慢的地方。

优化的步骤： 

1. 停下来，先不优化

2. 想清楚，在优化

如果，网站访问量太小，平均一天没1个人看，就不必须考虑优化，毕竟需要考虑成本的。

## 黑盒测试工具

很多，比如 ab，httpref 这类命令行工具。还有 JMeter, LoadManager 等图形界面工具。

ab 测试的输出， 并发数 10，总请求数 100： 

```
ab -n100 -c10 http://www.yundianjia.com/
This is ApacheBench, Version 2.3 <$Revision: 1663405 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking www.yundianjia.com (be patient).....done


Server Software:        nginx/1.8.0
Server Hostname:        www.yundianjia.com
Server Port:            80

Document Path:          /
Document Length:        20475 bytes

Concurrency Level:      10
Time taken for tests:   8.296 seconds
Complete requests:      100
Failed requests:        9
   (Connect: 0, Receive: 0, Length: 9, Exceptions: 0)
Total transferred:      2106718 bytes
HTML transferred:       2047518 bytes
Requests per second:    12.05 [#/sec] (mean)
Time per request:       829.566 [ms] (mean)
Time per request:       82.957 [ms] (mean, across all concurrent requests)
Transfer rate:          248.00 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        6   29 147.1      7    1054
Processing:   395  759 378.0    639    2190
Waiting:      379  718 358.3    599    2181
Total:        402  788 393.0    663    2197

Percentage of the requests served within a certain time (ms)
  50%    663
  66%    807
  75%    903
  80%   1006
  90%   1456
  95%   1601
  98%   2120
  99%   2197
 100%   2197 (longest request)
```

## web 系统涉及的方方面面

试想，用户访问一个网站会涉及多少个方面： 

1.  web 浏览器 以及 网络的最后一公里
2.  DNS 解析服务器
3.  主干网路
4.  站点所在 web 服务器
5.  Application 服务器
6.  数据库服务器
。。。


从上面可以看到涉及的部分可以简单分为三类： 

1. 客户端 - web 浏览器
2. 网络 - 网络环境，主干网之类
3. 服务器 - web， 应用，数据库，文件，缓存。。

整对这三者， 都有相应的优化策略。

## 客户端优化

经典推荐Yslow 的作者提出： Yahoo！14 条军规， <https://developer.yahoo.com/performance/rules.html>

起初，只有前 14 条，后来，作者写了本书《Best Practices for Speeding Up Your Web Site》，增加到了 35 条。

具体建议如下： 

1. 最小化HTTP请求（Minimize HTTP Requests）- Rails 中 asset pipeline 就是这样的实践
2. js 置地，css 置顶
3. 使用 css 图片精灵
4. 充分利用的 HTTP 的缓存头控制
5. 开启 Gzip 
6. 压缩 js 和 css
。。。

详细可以参考： <http://xiajian.github.io/web/2014/11/16/%E7%BD%91%E7%AB%99%E5%8A%A0%E9%80%9F%E5%AE%9E%E8%B7%B5>

## 网络的优化

两个关键概念： 延迟 和 带宽

网络优化的目标： 高带宽，低延迟

* 延迟： 信息从信源到目的地所需要实践， 比如： 
* 带宽： 信道的最大吞吐量

网络的设备盘点： 网线， 网卡， 交换机，集线器(HUB)，路由，光钎

优化的层面： HTTP 协议（比如 HTTP 2.0，保持 HTTP 链接）， TCP协议， UDP协议， 物理设备的升级。

物理设备的升级： 比如，升级服务器所在机房的带宽， 5MB - 10 MB， 使用 BDP 双线机房

## 服务器优化

首先，硬件的优化，比如使用 SSD，装备更大的内存，切换更好的服务器。

其次，网站服务器架构的优化, 这里给出一个复杂的服务器架构： 

<div class="pic">
  <img src="http://images.cnitblog.com/blog/352511/201409/302146262063009.png" alt="404"/>
</div>

大体的操作方针： 

1. 动态内容静态化
1. 使用数据缓存 - 在 varish 缓存静态页面， JIT 缓存生成的动态代码等等
1. 数据库优化 - 缓存查询结果，分表，分库，读写分离，使用 Nosql
1. 使用负载均衡： 硬件负载均衡- F5，软件负载均衡（LVS 和 Nginx， Haproxy），web 服务器集群
1. 分布式计算 - 异步计算， 并行计算（并发模型）

## 最后

非常感谢大家的参与。 个人拙见，仅是抛砖，希望大家投玉。 

我今临表涕零，不知所云。


## 参考书籍

1. 《Web 性能权威指南》

2. 《构建高性能的 web 站点》