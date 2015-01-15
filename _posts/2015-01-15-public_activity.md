---
layout: post
title: "关于public_activity gem包 "
description: "public_activity, rails, gem包"
category: gem
---

## 前言

在手机网站项目中，看到一个奇怪的目录`public_activity/`，该目录下只有部分视图，找了一圈没有找到其控制器，在路由中也没有。向前辈
请教，得知这是一个gem包。以下是对于该gem包的认识和了解。

## 简介

`public_activity`为ActiveRecord, Mongoid 3 以及 MongoMapper模型提供简单方便的活动追踪。其应用场景是，但记录改变或创建时，给用户发送记录的活动，其行为类似github。简单理解，就是记录变更+消息推送。

gem包的在线演示版地址: <http://public-activity-example.herokuapp.com/feed>




