---
layout: post
title: Railscasts-china上的一些课程笔记
category :  note
---

## How Gitlab works

Gitlab的分层结构: backend -- repo access -- presetation layer

* backend: git支持的协议(file, git, ssh, http), 什么可以作为backend，什么不可以。

ssh用来做授权:  
1. authorized_keys 多人协作存在一些权限问题 -- gitosis/gitolite(内部权限系统)
2. gitosis(python)/gitolite(perl)(内部权限系统)
3. patched sshd, twister

HTTP做授权：  
v 2.7 smart HTTP protocol

repo access:  
1. Grit: git的简单的命令行包装
2. Rugged: libgit2的ruby的绑定，支持c绑定语言都可以使用libgit2库

repo browser：
1. git Object model: 四种对象  blob tree commit tag （git show/git cat-file)
2. git encoding strategy: 
比如： filename => tree blob, blob content => blob,commit message =>  commit tag
3. ruby encoding: 编码探测 - the longer the better。

ruby的编码探测： 1. charlock_holmes => libicu  2. rchardet19 => pure ruby。

Ruby不关心编码，Character Set Independent，UCI

Hooks： post-receive , 将event push到Resque中，然后进行处理。Web hooks， 基于grape的API。

Git： pull-request。Gitlab CI - 持续继承的服务器。

## 前端应用开发的工具链

Middle-scale Application: 前端比较重的程序，大量的css和js。

* Loader-加载: LABjs, headjs, yepnodejs
* NameSpace： Single global variables, object literal notation, Nested namespacing, IIFE, Namespace injection，或这 coffescript的方法。
* Dependency： requirejs(AMD，异步)
* Component/widgets(Html&javascript&css)
* Unit/Component test(Fixture)，前端测试，新颖的领域。
* Build(Strategy): r.js, sprockets等，将所有的东西和在一起
* UX(Speed & LiveReload & ) 

Javascript在语言的层面，没有命名空间和模块这种玩意，全局的命令空间，然后各路大神各种方法模拟命名空间。

Crossroad选择： 
* chef or puppet
* gitlab or github
* AMD & UMD & CMD, 同步，异步或真混合。

构建，使用的rake脚本。自己搞小的网站，充分使用bootstrap提高速度和效率。

## Ruby 2.1的特性

* ruby的进化历史
* 新语法
* 核心及标准库的变换
* vm的变化

development和backport的区别，全部变量，RUBY_PATCHLEVEL：dev，rc，p0, p370。

新的版本:

* 语法的不兼容
* 应用程序的二进制(ABI)的不兼容: C-API的改变，binary gem的改变。
* 标准库的移除

新的发布：Ruby kaipi - 日本开的全球性的会议。

Backport： 
1. Bug fixed
2. 相容性的改变，比如添加新的类。

正则表达式，匹配天成文。

**keyword arguement & spilt **

新的语法，使得方法的命名参数变得很变态。

    def f a, b=1, *c, d: 1, **e, &block

`to_h`: 转换为hash, `to_ary`

**Refinements**

问题：将补丁限制在一个文件中。 refine的关键字。

## Rails打造日百万PV的网站架构

应用场景：
* 功能类似Blog以及留言板
* 用户浏览为主且内容一致
* 存在一定交互(投票，留言和私信)
* SEO

简单的数据计算，200ms & 100RPS，

Nginx -- 20个Rails进程(memcached) -- mysql  一台服务器解决问题

观察网站使用的具体的信息，页面的静态内容(页面缓存)和动态内容(Ajax请求处理)的分别加载，

* 最快响应最希望看到的东西
* 子请求不进行模板的渲染
* 子请求可以进行缓存
* 子请求和HTTP API放在一起实现

1000 rps的需求带来的挑战：

* 多台Rails服务器与缓存: caches_page的问题(文件系统，不能共存，内容多查找慢), 将缓存替换为memcache
  -  SuperCache： 使用的Rails.cache
* 缓存的横向扩展： nginx和多台memcache的问题，membase to rescue/couchbase
  - membase的特点: 1.完全兼容memcached协议 2.横向扩展性强 3.**任意节点读取全部数据** 4.GUI操作简便 5.高可用，自动故障转移
* Dog pile Effect(狗桩请求)： Lock机制-分布式锁

NewRelic的第三方监控服务。

> 后记： 提高速度，最重要的就是缓存，关于缓存的数据库，接触了如下的这样一些：memcached和redis，似乎，这两者都存在相应的集群，memcached的集群是membase，redis就不太清楚了。

## Rails初始化过程

Rails继承了Rack的server，并做了一定的覆盖和重写。

**什么是railtie**

* 单例模式
* 提供钩子方法扩展Rails或修改启动流程
* 定义Initializers来添加初始化过程
* 访问config对象，其配置项是在railties和rails application中共享，修改的都是相同变量
* 导入rake任务，以及generator

> 查看Railtie，可以通过`Rails::Railtie.subclasses`, subclasses似乎可以常看类的子类的个数。

rails

**engine**

* engine就是一个迷你的Rails app。包裹各种middleware之后，最后就是routes
* engine的middleware，application中不能访问

## Rails 源码分析 Arel 

Rails 中的 AR 使用的 [Arel](https://github.com/rails/arel) 将 DSL 装换成 SQL。 

Arel 是 一个关系代数，涉及 AST ，语言解析和生成相关的。

类的结构子图： 

* TreeManager: DeleteManger, SelectManger, UpdateManger, InsertManger。
* Node: DeleteStatement,SelectStatement, UpdateStatement, InsertStatement
* Binary: 二元谓词，2个参数 - as, between, join, less than, or, union, except
* Unary: 一元谓词 ，1个参数 - bin,group, having, limit, not, offset, on, ordering, top
* Function: 数据库函数
* Visitor: 观察者模式， DepthFirst, ToSQL(Mysql的适配器, WhereSql, OrderClause), Dot
* Table: 抽象数据库的表结构

通过`scope`进行链式的查询。
