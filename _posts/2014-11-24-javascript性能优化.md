---
layout: post
title: javascript性能优化笔记
---

## 前言

网站慢也确实是个机会，不然也不会这么快就接触性能方面的。服务器端性能优化知识多、难度大，相比之下，客户端性能就好操作多了。仔细想想，公司小也是件好事，整个网站的开发工作，从前端到后端，从rails到javascript，自己都涉及到了。在不久的将来，还会涉及Redis和数据库缓存。

## 关于性能

瀑布图，解析完成和加载完成，渲染引擎(Gecko, webkit等)，js解析引擎(SpiderMonkey, v8)，基准测试，运行时性能、可视化

性能优化大师: [steve souders](http://stevesouders.com/) & <http://httparchive.org/>

工具: Firebug, Yslow, Page Speed(google的chrome插件), [webpagetest](http://www.webpagetest.org) 

比较感兴趣的是webpagetest，似乎可以搭建服务器器进行测试和使用，收集的资料的地址如下: 

* 在线测试版本: <http://www.webpagetest.org>
* github源代码: <https://github.com/WPO-Foundation/webpagetest>
* 桌面版工具: <pagetest.sourceforge.net>
* 文档: <https://sites.google.com/a/webpagetest.org/docs/private-instances>

除此以外，收集到两篇不错的关于前端性能监控的文章，主讲[webpagetest](http://www.webryan.net/2013/01/use-webpagetest-to-analyze-web-performance/)和[phantomJS](http://www.webryan.net/2013/02/web-page-test-based-on-phontomjs/)。

> 备注: 已有的工具有Firebug, Yslow。关于性能的起步，是没有问题的。webpagetest使用在线版的也没什么太大的问题。

## 后记

在搜索webpagetest时，发现[郭亨的博客](http://www.webryan.net/)。仔细阅读了其web前端知识拓扑图之后，发现，原来玩前端的要懂这么多东西啊，看来前端工程师是想干掉后端工程师的吧，直接前端+DB就搞定了。

其总结的拓扑图如下: 

* javascript: js编码规范和设计模式，amd和cmd，jQuery/requirejs等常用库
* 页面开发: css/sass/less, compass, 图片类型和方案选择, seo, html, 响应式布局和浏览器兼容性
* 网络知识: HTTP, SPDY, CDN, dns, ssl&tls, 代理和反向代理, cache, cookie, 本地存储
* 安全知识: xss, csrf, sql injection, 域名和内容劫持, hijacking等
* 浏览器相关: bom, dom, 渲染机制，js runtime，内存管理, CPU Profile/GPU, reflow/repaint
* 开发调试: 前端开发工具和方法，badjs/tryjs，fiddler/willow, weinre, jslint
* 发布流程: 发布系统，分支管理，构建工具
* 性能检测: pagespeed/yslow, webpagetest, dynatrace
* 运营相关: 测速，监控等

了解前端的流程，对自己能力的发展也是有益的补充，毕竟，服务器端的也有自己不可替代的优势。
