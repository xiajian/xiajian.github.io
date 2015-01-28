---
layout: post
title: 关于trello
---

## 前言

公司内部的项目交流使用的trello, 同事对其实现的历史回退功能很好奇，我就打开Firebug，对其中的js做了一番研究。

## 正文

根据我的了解，Trello是一个单页面web应用程序(SPA), 所以，其实现肯定使用了某种类似客户端MVC的框架。不是那些著名的框架js MVC框架的，就是自己实现的。

找了一圈，没有找到, 倒是发现了这样的一些js: 

**snowplow.js**

Snowplow事件追踪器的客户端js库，可以给web站点和web应用添加分析信息，该js库的github地址为: <https://github.com/snowplow/snowplow-javascript-tracker> 。
其中，[Snowplow](https://github.com/snowplow/snowplow)貌似是一个比较有名的项目，企业强度的用户分析应用。

**quant.js**

[Quantcast](http://en.wikipedia.org/wiki/Quantcast)公司出品，是一家做观众度量和实时广告的技术公司。

**quickload.js**

quickload项目大概是<https://github.com/richthegeek/Quickload>, 异步加载页面的功能。从压缩的代码来看，貌似不是同一事物。

**all.js**

页面中所有事件绑定的所有代码，估计MVC的逻辑也实现这里。

以及其他统计相关的js代码。

## 后记

这样的探索技术的方式也挺不错的。
