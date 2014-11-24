---
layout: post
title: javascript性能优化笔记
---

## 前言

网站慢也确实是个机会，不然也不会这么快就接触性能方面的。服务器端性能优化知识多、难度大，相比之下，客户端性能就好操作多了。

## 关于性能

瀑布图，解析完成和加载完成，渲染引擎(Gecko, webkit等)，js解析引擎(SpiderMonkey, v8)，基准测试，运行时性能、可视化

性能优化大师: [steve souders](http://stevesouders.com/) & <http://httparchive.org/>

工具: Firebug, Yslow, Page Speed(google的chrome插件), [webpagetest](http://www.webpagetest.org) 

比较感兴趣的是webpagetest，似乎可以搭建服务器器进行测试和使用，收集的资料的地址如下: 

* 在线测试版本: <http://www.webpagetest.org>
* github源代码: <https://github.com/WPO-Foundation/webpagetest>
* 桌面版工具: <pagetest.sourceforge.net>
* 文档: <https://sites.google.com/a/webpagetest.org/docs/private-instances>

备注: 已有的工具有Firebug, Yslow。关于性能的起步，是没有问题的。webpagetest使用在线版的也没什么太大的问题。
