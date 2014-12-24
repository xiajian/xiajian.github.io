---
layout: post
title: "rails performance笔记"
description: "Rails, performance, advice"
category: rails
---

## 前言

之前，由于觉得网站慢。从而，搜集过来的关于Rails性能的资料。包括，性能实践和rails实践。

## Rails 性能

### Rails最坏实践

* 过早优化
* 瞎猜
* 缓存一切
* 与框架争高下

### 性能指导原则

* 算法的提升优于代码技巧
* 可维护性高于性能
* 8/2原则，只优化相关的部分
* 测量两次，削减一次
* 在灵活性和可维护性之间平衡

### 如何提高性能

* 寻找基准线
* 了解自己在哪
* 分析，从而发现瓶颈
* 移除瓶颈
* 重复上述过程

### 议程

- 分析和度量
- 编写优美高效的Ruby代码
- 使用REE 1.8.7 或 Ruby 1.9以上
- 使用更快的Ruby库
- 缓存
- SQL 和 ActiveRecord
- 考虑NoSQL存储
- 使用Rack和Rails Metal
- 对静态资源使用HTTP Server
- 前端web性能
- 使用扩展程序或内联C代码


### 发现问题: 分析

服务器日志分析: <http://github.com/wvanbergen/request-log-analyzer>，其分析的结果项如下: 

* 每小时的请求分布
* 最多请求的
* HTTP方法及其返回状态
* Rails动作缓存的命中率
* 请求持续时间
* 视图渲染时间
* 数据库时间
* 阻塞进程
* 失败的进程

商业的产品: New Relic和Scout。

`Rack::Bug` : 通过浏览器给出通知消息的Rails中间件

[memorylogic](http://github.com/binarylogic/memorylogic) : 内存分析, 通过在日志中添加进程id 及其相关的内存使用量，用来追踪
内存泄漏。

[oink](http://github.com/noahd1/oink) : 日志分析，从而分析出那些动作显著提升VM的堆大小

[ruby-prof](https://github.com/ruby-prof/ruby-prof) : 快速的Ruby代码剖析工具，其特性包含: 

  * 速度 - C 扩展
  * Modes(模式) - 调用时间、内存使用以及对象分配
  * 报告 - 生成文本和交叉引用的HTML报告
  * 线程 - 支持多线程同步
  * 递归调用 - 支持递归方法的调用

具体的使用，参考ruby-prof的代码地址。

Rails 命令行 : profiler命令, 貌似，Rails 3.x 不存在该命令。

### 性能测试 : 度量

Benchmark 标准库 : 可以使用命令benchmark(貌似，Rails 3.x 不存在该命令), 也可在程序中，使用benchmark(类名.benchmark do ... end)。

`rake -T`: 查看所有Rake任务，看到`rake about`。没想到，js运行时居然是`therubyracer`。

通用工具(黑盒测试) : [httpref](http://www.hpl.hp.com/research/linux/httperf/), ab(apache 服务器的性能工具,可以用于任意的web
服务器测试)

> httpref: HP开发的web服务器，官方地址为<http://www.hpl.hp.com/research/linux/httperf/>。与httpref相关的工具为autobench - 包装
httpref的perl脚本，其将测试结果保存为csv格式的文件，具体的安装使用，参考<http://www.oschina.net/question/12_65396> 以及
<http://www.oschina.net/question/12_65398>

### 服务器能多快响应请求

* 使用web服务器响应静态文件作为基准度量
* 不要在相同的服务器中运行(I/O和CPU)
* 从尽可能近的地方运行
* 需要统计比较的有: 平均值，标准差，置信区间

### 高效的Ruby代码

* 实例变量快于访问器
* 操作字符串(字符串插值)快于`+`操作符
* 就地更新
* 模块和类的定义只执行一次
* 将数据缓存在实例或Class变量中
* 少用 `.nil?`
* 不要使用`&block`参数

Ruby中缓存: 

* 变量缓存: `ActiveSupport::Memoizable` : Ruby中缓存方式
* 方法缓存: Ruby在执行method查询时，会使用缓存的方法。在运行时，避免使用如下这些会清除缓存的方法: def/undef, Module#define_
method, `alias/Module#alias_method`, Object#extend, Module#include, public/private/protected/`module_function`
* 常量缓存: 不要在运行时重定义常量，少定义新的常量

### 可维护的Rails代码

* 将代码从控制器移入模型中
* 使用RESTful
* Model/Controller/View

### Ruby慢？

语言的微观性能基准 != 复杂系统中的性能

性能的其他因素: 

* 应用程序架构
* 高层抽象的能力
* Rails快于很多PHP框架

### 使用更快的Ruby库

* XML parser : http://nokogiri.org/
* JSON parser : http://github.com/brianmario/yajl-ruby/
* CSV parser : http://www.toastyapps.com/excelsior/
* HTTP client : http://github.com/pauldix/typhoeus
* Date : http://github.com/rtomayko/date-performance

### Caching

关于缓存: 

* 缓存一切则过于丑陋
* 易出bug，难于测试
* 复杂: expire , security
* 限制用户接口选项

Rails中Cache的存储，存在多种选项。

view caching : 

* Page Caching(caches_page/expire_page)
* Action Caching(caches_action/expire_action)
* Fragment Caching(cache do...end 以及 expire_fragment)
* 使用sweeper来提取过期的逻辑

### 使用memcached 

* Free & open source, high-performance, distributed memory object caching system
* an in-memory key-value store for small chunks of arbitrary data (strings, objects)
from results of database calls, API calls, or page rendering.
* key: 256字节
* Data: 1MB
* Caching secret: key命名以及过期

### SQL and ActiveRecord

ORM is a high-level library that it’s easy to forget about efficiency until it becomes a problem.

EngineYard的文章: [That's Not a Memory Leak, It's Bloat ](https://blog.engineyard.com/2009/thats-not-a-memory-leak-its-bloat/)

ORM的问题: 

* N+1 查询的问题
* 添加 :include, [Bullet插件](https://github.com/flyerhzm/bullet)
* 索引缺失, [rails_indexes](https://github.com/eladmeidar/rails_indexes)
* 只选择需要的, SQL查询优化, [Scrooge](https://github.com/methodmissing/scrooge)
* 某些情况，将`:include`替换为`:join`
* 批量查询
* 为成组的操作设置成事务
* SQL query planner， 利用Explain关键字，[query_reviewer](https://github.com/nesquena/query_reviewer)
* 全文搜索引擎: Sphinx，Ferret
* 对领域数据采用常量
* 设置Counter cache， :counter_cache
* 使用cron和rake来存储报表
* AR缓存插件, cache-money, interlock, cache_fu 。使用这些方案时，需要额外小心

### 考虑NoSQL存储

* 高性能的键值存储: Redis, Tokyo Cabinet, Flare
* 大型数据的文档型存储: MongoDB, CouchDB
* Record store for high scalability and availability

存储非关键数据、点击数，下载数，在线用户记录时，不要使用RDBMS

[Moneta](https://github.com/minad/moneta) : 键值对存储的同一界面，支持很多的键/值数据库，统一API为: 

* `#[](key)`
* `#[]=(key, value)`
* #delete(key)
* #key?(key)
* #store(key, value, options)
* #update_key(key, options):
* #clear

Rails Metal : rack 中间件的子集，合并了routes和控制器，比controller快2到3倍，适合那些不需要ActionView的API项目。

### 静态文件使用web服务器或CDN

* web server比Ruby应用程序服务器快 10 倍以上
* 在启用了mod_xsendfile的Apache或者Lighttpd中，设置x_sendfile为真

### web前端分析

工具: yslow, page-speed 以及 Yahoo!提出的14条性能加速建议: 

* Make Fewer HTTP Requests
* Add an Expires Header
* Use a Content Delivery Network
* Gzip Components
* Put Stylesheets at the Top
* Put Scripts at the Bottom
* Avoid CSS Expressions
* Make JavaScript and CSS External
* Reduce DNS Lookups
* Minify JavaScript
* Avoid Redirects
* Remove Duplicates Scripts
* Configure ETags
* Make Ajax Cacheable ??

以及《High Performance web Sites》和《Even Faster Web Sites》。

### 内嵌C/C++代码

* [RubyInline](https://github.com/seattlerb/rubyinline): Write foreign code within ruby code
* [Rice](https://github.com/jameskilton/rice): Ruby Interface for C++ Extensions
* [Ruby-FFI](https://github.com/ffi/ffi): a ruby extension for programmatically loading dynamic libraries

## 参考文献

1. Advanced Rails Chap.6 Performance (O’Reilly)
2. Rails Rescue Handbook
3. Writing Efficient Ruby Code (Addison-Wesley)
4. Ruby on Rails Code Review (Peepcode)
5. Rails 2 Chap. 13 Security and Performance Enhancements (friendsof)
6. Deploying Rails Application Chap.9 Performance (Pragmatic)
7. http://guides.rubyonrails.org/caching_with_rails.html
8. http://guides.rubyonrails.org/performance_testing.html
9. http://railslab.newrelic.com/scaling-rails
10. http://antoniocangiano.com/2007/02/10/top-10-ruby-on-rails-performance-tips/
11. http://www.engineyard.com/blog/2009/thats-not-a-memory-leak-its-bloat/
12. http://jstorimer.com/ruby/2009/12/13/essential-rails-plugins-for-your-inner-dba.html
13. http://asciicasts.com/episodes/161-three-profiling-tools
14. http://robots.thoughtbot.com/post/163627511/a-grand-piano-for-your-violin
