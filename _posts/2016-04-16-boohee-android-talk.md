---
layout: post
title: 薄荷 Android 的分享
description: 'android, DNS, qq, 运营商， Gradle 构建系统'
category: note
---

## 前言

之前，机缘巧合得知了薄荷有分享，然后就去了听了一下。 到了展想广场后，发现这个商业区还是相当的繁华的。 个人也是第一次站到了 21 楼上徘徊，相当的得意的说。

##  Strom Zhang

问题： 

1. 购物车不能删除 -  有些运营商 Rest API DELETE 方法不支持
2. 页面插入广告的 - 运行商 DNS 劫持
3. APP 不能打开 

运营商劫持根本原因: 

1. 跨网之间的流量计算非常的昂贵
1. 运营商缓存内容的算法比较 lost

劫持的手段:

1. 插入广告
2. 解析成错误的 IP 地址

劫持发生的地方： 四川 和 重庆

解决方法: 

1. 使用公用的 DNS 解析， 比如 114DNS，以及 google 的 public DNS(8.8.8.8 和 8.8.8.4)，
2. 使用 HTTPS， 解决内容劫持，不能解决 DNS 劫持
3. 使用 HTTPDNS - 使用 DNSPod 免费服务 - 支持百万用户

直接跳过运营商的解析， 直接请求自己的 DNS 服务器。 HTTPDNS 服务器，返回最右的服务。 使用了第三方的 HTTPDNS 服务器。

> PS: 鹅厂的域名是 10 万级别的。

> PS: Storm 张 维护了中国最好的安卓公众号。

## 贾吉鑫

Android 组件化的思想， 按业务逻辑进行分库的实践 ：

Android 项目包含的内容： 资源（？画布局， View等等之类），代码，Mainfest xml 文件。


1. 编译速度快
2. 组件复用
3. 。。。

Android 的包的管理： 使用 代码构建系统 [Gradle](https://github.com/gradle/gradle)，与 MVN 相似。

问题： 

1. Layout 布局，资源，优先级的。 导致编译失败。
2. 多人协作提交 Github 的问题， 使用了 Gerrit 这样的集权审核管理。
3. mainfest 版本依赖的，以及编译时线程卡死

AR 是啥？？Android Repo？？

经验：

> doing then better project。 不追求绝对的完美主义。

热加载 - [numa](https://github.com/jasonross/Nuwa)。 安卓代码的热替换(HotFix).

Nvma相关的文档下载： http://7fviov.com1.z0.glb.clouddn.com/Nuwa.pdf

作者介绍： 前 58 工程师， 现在自己创业。 个人博客： <http://jiajixin.cn/>

## 后记

下午， 我想去听青云的吹牛。

听别人说，下午分享的关于 Android 内容有：  

1. 如何处理内存泄露相关的
2. Reative Native 构建应用

## 参考

1. [HttpDNS 服务详解](https://www.ttlsa.com/web/httpdns-detailed-service/)
2. [e厂原始地址](http://mp.weixin.qq.com/s?__biz=MzA3ODgyNzcwMw==&mid=201837080&idx=1&sn=b2a152b84df1c7dbd294ea66037cf262&scene=2&from=timeline&isappinstalled=0#rd)
3. 