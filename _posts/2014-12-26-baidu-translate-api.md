---
layout: post
title: "百度翻译api使用"
description: "百度翻译API"
category: 翻译
---

## 前言

大量外文资料，自己英语不行，复制粘贴蛋疼，借助翻译API。想想自己也是干web的，小试一下身后。

现代的社会，进入了API经济时代，各种各样的API，web的开放协作，真是通过API来实现的。

## 简介

接口URL: <http://openapi.baidu.com/public/2.0/bmt/translate>

百度推出了新的api整合平台: http://apistore.baidu.com ， 意在整合第三方 API 服务，并推出了即用API，翻译部分的API 有所变化，变得更加好用了。

以下是用curl的调用身份证简单的示例：

```
# 成功
~$ curl -H "apikey:  91fed2c9b145d8629a6221edbf38acd2" http://apis.baidu.com/apistore/idservice/id?id=321284199110041896
{"errNum":0,"retMsg":"success","retData":{"address":"\u6c5f\u82cf\u7701\u6cf0\u5dde\u5e02\u59dc\u5830\u5e02","sex":"M","birthday":"1991-10-04"
# 失败
~$ curl -H "apikey:  91fed2c9b145d8629a6221edbf38acd2"  -H "Content-Type: text/html; charset=utf-8" http://apis.baidu.com/apistore/idservice/id?id=3212841991100418
{"errNum":-1,"retMsg":"\u8eab\u4efd\u8bc1\u53f7\u7801\u4e0d\u5408\u6cd5\uff01","retData":[]}
```

返回的是json数据，而且默认是utf-8。

## 后记

看了几眼，想了想，还是算了吧，以后，有空再做这件事。

著名的API，都存在某些人编写的API客户端。比如，github，gitlab之流，之前看到的Restclient，其实就是HTTP协议的ruby
客户端。

如果，能将HTTP看作API，那web上一切就都是API了。以接口的眼光看世界，世界到处都是接口(社会，科学，人际交往)，然后，我们的人生就是编写和安装"客户端"。Nice Idea ！！
