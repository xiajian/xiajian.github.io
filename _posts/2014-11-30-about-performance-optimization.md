---
layout: post
title: 关于性能优化
---

## 前言

网站慢，全栈式programmer等的动机下，我涉足了性能优化的领域。其实，我对Rails、服务器设置、mysql等方面都不是很了解，就贸然进行所谓的性能优化。结果，只做到css置顶js置低这一条，其他的，目前都不再掌控范围内。在这期间，倒是买了些本书。

* 《web性能权威指南》，这本书名翻译的有问题，英文名是《High Proformance Browser Networking》。讨论的都是底层原理部分，TCP，HTTP，XHR，websocket之类，适合心静下来时看看
* 《HTTP权威指南》，相当不错的书，对web基本协议HTTP的讲解非常的深刻，涉及内容多且深
* 《构建高性能web站点》，国人出品的书，就涵盖的性能优化方面而言，有一定的广度和实践性
* 《JavaScript性能优化》，不厚，关注实践和方法论，很不错的书
* 《web站点优化》，两方面入手，SEO/SEM和站点优化，角度很新颖，就是没时间细看


看书是我主要的学习方式，光看书不实践是不行的。性能中，最重要的是度量，度量就必须要有相应的工具和方法。以下，是对相关工具进行的探索。

## 黑盒测试工具

ab, httpref以及autobench。其中，直接可用的工具为ab，以下，以本地测试的环境，使用ab进行测试。

测试测试服务器的网站: ab -n1000 -c10 http://redmine.tophold.com/

```
Server Software:        nginx/1.6.1
Server Hostname:        redmine.tophold.com
Server Port:            80

Document Path:          /
Document Length:        2808 bytes

Concurrency Level:      10
Time taken for tests:   11.304 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      3516000 bytes
HTML transferred:       2808000 bytes
Requests per second:    88.46 [#/sec] (mean)
Time per request:       113.041 [ms] (mean)
Time per request:       11.304 [ms] (mean, across all concurrent requests)
Transfer rate:          303.75 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.1      0       1
Processing:    23  112  73.0     98    1389
Waiting:       23  111  73.1     98    1389
Total:         23  113  73.0     98    1389

Percentage of the requests served within a certain time (ms)
  50%     98
  66%    130
  75%    145
  80%    146
  90%    150
  95%    165
  98%    218
  99%    233
 100%   1389 (longest request)
```

注： 在运行服务器的本地进行测试，发现，1000请求/1.52秒

测试测试服务器的网站: ab -n1000 -c10  http://staging.tophold.com/

```
Server Software:        nginx/1.6.1
Server Hostname:        staging.tophold.com
Server Port:            80

Document Path:          /
Document Length:        45142 bytes

Concurrency Level:      10
Time taken for tests:   81.822 seconds
Complete requests:      1000
Failed requests:        999
   (Connect: 0, Receive: 0, Length: 999, Exceptions: 0)
Total transferred:      45472198 bytes
HTML transferred:       44937923 bytes
Requests per second:    12.22 [#/sec] (mean)
Time per request:       818.225 [ms] (mean)
Time per request:       81.822 [ms] (mean, across all concurrent requests)
Transfer rate:          542.72 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.6      0       6
Processing:   276  816 437.9    659    4055
Waiting:      272  811 437.8    656    4051
Total:        276  816 437.9    661    4055

Percentage of the requests served within a certain time (ms)
  50%    661
  66%    776
  75%   1298
  80%   1359
  90%   1440
  95%   1456
  98%   1496
  99%   1963
 100%   4055 (longest request) 
```

调整了一下worker_processes，之后，发现处理的请求数目有所提高。又测了一下，请求又下降了，看来配置上的处理都是小幅度的变化，
不是制约性能的主要部分。找到系统的瓶颈才是关键，找不到瓶颈，就在那里瞎猜，到底是成不了事的。

测试本地开发: ab -n1000 -c10  http://0.0.0.0:3000/

```
Server Software:        thin
Server Hostname:        0.0.0.0
Server Port:            3000

Document Path:          /
Document Length:        48932 bytes

Concurrency Level:      10
Time taken for tests:   504.689 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      49373000 bytes
HTML transferred:       48932000 bytes
Requests per second:    1.98 [#/sec] (mean)
Time per request:       5046.888 [ms] (mean)
Time per request:       504.689 [ms] (mean, across all concurrent requests)
Transfer rate:          95.54 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.1      0       1
Processing:  1028 5038 1094.5   5010    9119
Waiting:      885 4158 917.9   4416    5504
Total:       1028 5039 1094.5   5011    9119

Percentage of the requests served within a certain time (ms)
  50%   5011
  66%   5114
  75%   5164
  80%   5283
  90%   6635
  95%   7390
  98%   8188
  99%   8492
 100%   9119 (longest request)
```

注: 本地请求低于5 req/s，确实存在一定的问题，但是，如何进行优化。

删除了一些gem包之后，本地的请求速度得到了提高，平均2.78个req/s，这个提升还是很明显的，结果显示如下: 

```
Server Software:        thin
Server Hostname:        0.0.0.0
Server Port:            3000

Document Path:          /
Document Length:        48680 bytes

Concurrency Level:      10
Time taken for tests:   348.371 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      49121000 bytes
HTML transferred:       48680000 bytes
Requests per second:    2.87 [#/sec] (mean)
Time per request:       3483.715 [ms] (mean)
Time per request:       348.371 [ms] (mean, across all concurrent requests)
Transfer rate:          137.70 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.1      0       1
Processing:  1813 3475 776.3   3421    6477
Waiting:      722 2909 677.2   3087    5162
Total:       1813 3475 776.3   3421    6477

Percentage of the requests served within a certain time (ms)
  50%   3421
  66%   3498
  75%   3613
  80%   3772
  90%   4640
  95%   5163
  98%   5692
  99%   6060
 100%   6477 (longest request)
```

正式服务器的测试: ab -c10 -n1000 http://www.tophold.com/

```
Server Software:        nginx/1.6.0
Server Hostname:        www.tophold.com
Server Port:            80

Document Path:          /
Document Length:        52047 bytes

Concurrency Level:      10
Time taken for tests:   119.196 seconds
Complete requests:      1000
Failed requests:        1
   (Connect: 0, Receive: 0, Length: 1, Exceptions: 0)
Total transferred:      52583001 bytes
HTML transferred:       52047001 bytes
Requests per second:    8.39 [#/sec] (mean)
Time per request:       1191.963 [ms] (mean)
Time per request:       119.196 [ms] (mean, across all concurrent requests)
Transfer rate:          430.81 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:       33   64  41.6     54    1071
Processing:   413 1123 618.5   1000   15340
Waiting:      238  805 350.9    720    2132
Total:        499 1187 615.9   1058   15424

Percentage of the requests served within a certain time (ms)
  50%   1058
  66%   1220
  75%   1355
  80%   1440
  90%   1721
  95%   1921
  98%   2137
  99%   2294
 100%  15424 (longest request)
```

对个人host在github上的站点进行测试，结果如下: 

```
Document Path:          /
Document Length:        25958 bytes

Concurrency Level:      10
Time taken for tests:   25.756 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      26400328 bytes
HTML transferred:       25958000 bytes
Requests per second:    38.83 [#/sec] (mean)
Time per request:       257.556 [ms] (mean)
Time per request:       25.756 [ms] (mean, across all concurrent requests)
Transfer rate:          1001.01 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:       56   85  63.5     81    1087
Processing:   116  172  42.4    167     682
Waiting:       57   84  17.8     83     242
Total:        175  257  77.4    249    1262

Percentage of the requests served within a certain time (ms)
  50%    249
  66%    256
  75%    260
  80%    262
  90%    268
  95%    300
  98%    409
  99%    597
 100%   1262 (longest request)
```

备注: 本地运行的博客，使用ab测试，处理速度平均为 449.53 req/sec。结果如下: 

```
Concurrency Level:      10
Time taken for tests:   2.225 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      25857000 bytes
HTML transferred:       25611000 bytes
Requests per second:    449.53 [#/sec] (mean)
Time per request:       22.245 [ms] (mean)
Time per request:       2.225 [ms] (mean, across all concurrent requests)
Transfer rate:          11351.05 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    1  31.5      0     996
Processing:     6   20  25.7     16     240
Waiting:        4   17  25.5     13     238
Total:          6   21  40.6     16    1013
```

以上的ab测试，让我对服务器请求处理的能力有了个基本的认识。目前，需要处理的是，到底这些时间花费在什么地方，
性能为何如此的不堪，替换应用服务器带来的提升会有多大? 

> 意识到单机小并发ab测试是一种安全的测试。多机、分布式、大并发的ab测试，就是DDos。Web应用的安全性也是个重要的
> 话题。有空，多研究研究。

API项目，某请求URL的测试:  ab -n100 -c10 http://api.tophold.com/ando/articles/company

结果如下: 

```
Server Software:        nginx/1.6.0
Server Hostname:        api.tophold.com
Server Port:            80

Document Path:          /ando/articles/company
Document Length:        3136 bytes

Concurrency Level:      10
Time taken for tests:   11.948 seconds
Complete requests:      100
Failed requests:        0
Total transferred:      356000 bytes
HTML transferred:       313600 bytes
Requests per second:    8.37 [#/sec] (mean)
Time per request:       1194.817 [ms] (mean)
Time per request:       119.482 [ms] (mean, across all concurrent requests)
Transfer rate:          29.10 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:       27  119 288.4     29    1042
Processing:   124 1014 406.4   1021    2509
Waiting:      123  881 298.1    874    2331
Total:        151 1133 491.0   1111    2916
```

> 备注: 使用`ab -n1000 -c10 http://api.tophold.com/ando/articles/company`，服务器居然挂掉了，吓了我一跳，难道是Mongodb的压力太大？？

## 日志分析工具

Request-log-analyzer : 日志分析工具，可以分析多种格式的日志。简单用法为: 

oink : 日志分析，找出VM堆栈消耗最大的action，但是，其需要使用`hodel_3000_compliant_logger`日志格式。

日志文件处理工具: logrotate , 可以用来压缩访问日志，不知道如何配置。

## 代码优化工具

ruby-prof : <https://github.com/ruby-prof/ruby-prof>

使用newrelic查看sql访问性能时发现，Rails的应用程序嵌套过深！！！虽说每个嵌套都花不了多长时间，但是组合起来，就相当的费时间了。

## 数据库优化工具

bullet : 解决应用中的N+1查询的问题, https://github.com/flyerhzm/bullet

`slim_scrooge` : 优化数据库交互，sql查询相关, <https://github.com/sdsykes/slim_scrooge>

`lol_dba` : 优化数据库索引, <https://github.com/plentz/lol_dba>

`query_reviewer` :  运行"EXPLAIN"，优化表查询的结构, 

数据库(特指MySQL)的性能，可以简单的从配置文件开始，与性能相关的部分就是mysqld相关的配置。

## 后记

秉承自己求快的愿望，我在性能领域迈出自己一小步。以性能为纲，实现全栈式工程师。
