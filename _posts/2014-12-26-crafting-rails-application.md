---
layout: post
title: "crafting rails application"
description: "crafting rails application阅读笔记"
category:  rails
---

## 前言

处于深入学习Rails的目的，更深入的了解Rails，学习《crafting rails application》。《crafting rails application》提供关于
如何Plug-in的API，从而更好的理解Rails。

《Crafting Rails application》最初的版本，使用Enginex(适用Rails 3.0，3.1之后，使用`rails plugin`)。书中内容: 

1. 创建自己的Render - Rails rendering Stack(view)
2. 构建Model - 使用 ActiveModel 构建Model
3. 从定制的存储(比如，数据库)中获取模板 - 更快的控制器
4. 发送多个邮件的模板处理器
5. 客户端异步的SSE - 预先加载和线程安全
6. 使用Responder自制控制器
7. 使用挂载Engine管理应用程序事件
8. 使用键值后端，转换应用

看完简介后，我觉得，整本书其实在讨论如何深入的理解Rails Engine。

