---
layout: post
title: netty异步框架简洁
description: 'java, netty'
category: note
---

# netty 项目简介

## 简介

Netty project - an event-driven asynchronous network application framework 。
Netty 是一个事件驱动的异步网络应用程序框架。

Netty is an asynchronous event-driven network application framework for rapid development of maintainable high performance protocol servers & clients.

官方网站地址：  http://netty.io/ 。

github 地址: https://github.com/netty/netty。

Netty is a NIO client server framework which enables quick and easy development of network applications such as protocol servers and clients. It greatly simplifies and streamlines network programming such as TCP and UDP socket server.

Netty 是一个事件驱动的异步网络应用程序框架， 主要用来快速开发，可维护的高性能的协议的服务器 & 客户端。 简化了 流式网络编程，比如 TCP 和 UDP socket 的服务器。

'Quick and easy' doesn't mean that a resulting application will suffer from a maintainability or a performance issue. Netty has been designed carefully with the experiences earned from the implementation of a lot of protocols such as FTP, SMTP, HTTP, and various binary and text-based legacy protocols. As a result, Netty has succeeded to find a way to achieve ease of development, performance, stability, and flexibility without a compromise.

快速且容易，并不意味着应用程序将遭受 可维护性 或者性能的问题。 Netty 从很多协议，以及诸多遗留的 二进制的遗留协议中学习，并仔细设计过。 结果就是， Netty 成功的找到一个条在 开发，性能，可靠性，灵活性之间的平衡。

## Features 特性

### Design 设计

* Unified API for various transport types - blocking and non-blocking socket
* 对于阻塞 和 非阻塞的 socket 使用统一的多样性装换类型
* Based on a flexible and extensible event model which allows clear separation of concerns
* 基于灵活的、可扩展的事件模型， 从而清晰的分离关注点
* Highly customizable thread model - single thread, one or more thread pools such as SEDA
* 高度可定制的线程模型 -  单线程，一个或多个线城池，与 SEDA 类似
* True connectionless datagram socket support (since 3.1)
* 真正无链接的 数据块 socket 支持（自从 3.1）

### Ease of use 使用

* Well-documented Javadoc, user guide and examples
* 完全文档化的 Javadoc， 用户指南，以及 样例

* No additional dependencies, JDK 5 (Netty 3.x) or 6 (Netty 4.x) is enough JDK 5 或者 6 就足够了

* Note: Some components such as HTTP/2 might have more requirements. Please refer to the Requirements page for more information.

> 注意：一部分 HTTP/2 的组件，可能会有更高的依赖。具体，需要参考相应的需求的页面。  

### Performance 性能

* Better throughput, lower latency
* 更好的吞吐量，和 更低的时延
* Less resource consumption
* 更少的资源消耗
* Minimized unnecessary memory copy
* 最小化的内存拷贝

### Security 安全性


* Complete SSL/TLS and StartTLS support
* 完善的 SSL/TLS 以及 StartTLS 的支持

### Community 社区

* Release early, release often
* 早发布，持续发布

* The author has been writing similar frameworks since 2003 and he still finds your feed back precious!
* 作者很早之前写过类似的框架，并且， 会持续诊视别人的反馈。

