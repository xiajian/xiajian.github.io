---
layout: post
title: 介绍RMR web架构
---

原文作者：Paul James

原文地址：<http://www.peej.co.uk/articles/rmr-architecture.html>

来源:<http://rubyoffrails.group.iteye.com/group/topic/20670>

## 介绍RMR web 架构

我和很多人谈论REST，但是随着缩写在Web习俗中越来越常见，我经常发现我需要向别人解释他们读到的关于REST，或者他们以为是关于REST的东西实际上是POX，HTTP-RPC或者任何你愿意称呼的名称。

我同样是一位倡导者，呼吁一种观点：REST不仅仅是关于"Web服务"，而且更是一个构建快速的可持续的Web应用程序的模型。就这样，在我教授 REST思想的时候，今天我想概述一条构建Web应用的不同方法，一种RESTful的方法，流行的MVC建模的替代品，一种我称为RMR的模型，或者资 源-方法-表现。

## 模型-视图-控制器

当下流行的构建Web应用的方式是MVC模式。这个模式把应用分割成三部分。

*模型负责建模商业对象，你的应用程序中的“实体”，包装了数据操作和逻辑。
*视图是向客户端的输出。
*控制器管理操作模型和生成视图的程序流程。

这个架构受到Web开发者广泛的采用，虽然它实际上是被设计用于桌面程序。在我关注的范围内，MVC并没有很好的在Web中起到作用，它并没有用一 种便利的方式对资源进行建模和展现。（URL路由是繁琐的，而且动作（actions）是控制器上被暴露为模型的方法，而不是资源自身的HTTP方法）

它并没有对资源进行建模，Web的基础元素被完全的忽略了。那我们怎样可以修复这个问题？

## 资源-方法-表现

我们都同意把代码模块化是一个好主意，分离关注点会让我们更集中精力在手头的具体任务并让维护变得更容易，那么应该怎样在不使用MVC的同时在Web上下文中进行代码分割？

### 资源

我们从资源开始。Web是由资源组成的，为了让我们的程序适用于Web，我们必须对资源进行建模。一个资源是RESTful系统中的一个对象，它包 含信息，由统一资源标识身份（HTTP中是URL），并对标准接口进行响应（HTTP中是标准的HTTP方法比如GET，PUT等等）。
因此在面向对象语言中，一个HTTP资源应该被认为是一个包含私有成员变量和与标准HTTP方法对应的公有方法的对象。对于熟悉MVC的人，资源可以被认为是一个模型被加上了一些控制器的功能。

### 方法

每个请求都被自动地传送至一个资源，因为每个资源都有一个唯一的URL，与HTTP请求方法对应的资源的公有方法将会被运行。这和控制器有点像，运行一些必要的操作来为对请求进行的响应作准备。

### 表现

最后，拼图的最后一部分是响应。在RESTful系统中，响应以表现的形式暴露给客户端。表现本质上是把响应具体化为用于传输的形式。

以你正在看的网页为例，是文章这个资源的HTML表现。同样可以有其他的表现，你可以查看这篇文章的ASCII文本文件表现，或者PDF表现，如果我提供给你了可能性。

所以表现就类似MVC中的视图，我们给它一个资源对象，并告诉它序列化该对象为相应的输出格式。

## RMR实践

那么就让我们开始编写构建RMR系统的样例代码。我们会用伪代码为了快和简单。

### 前端控制器

首先我们需要一个前端控制器，处理所有的请求并做路由。

```ruby
request = readRequestData(); 
resource = loadResourceForThisRequest(request.url); 
response = callRequestMethod(request, resource); 
response.output();
```

这非常类似于MVC控制器，我们从请求读取数据并根据数据内容进行一些处理。真正的问题是，我们从哪里根据URL加载资源？

一个简单的资源可能只是一个类，从某处获得数据，或者不获取数据，因为数据也许存在于表现层（比如HTML页面）。

另一种情况是我们有一个集合需要暴露为资源，比如一系列网志，或者是使用应用的用户，或者是仓库的库存，等等。你也许有了答案，在这种情况下，我们会把我们的集合URL映射到从数据库获取许多列的资源。

### 资源类

为了编写应用程序，我们编写资源类来对应用程序的数据进行建模，一个基本的资源类可能看起来像如下所示

```ruby
class Resource {
	private 
	resourceData = []; 
	method constructor(request, dataSource) {// load data from data source } 
	method get(request) { return new Response(200, getRepresentation(request.url, resourceData)); } 
	method put(request) { return new Response(405); } 
	method post(request) { return new Response(405); } 
	method delete(request) { return new Response(405); } 
}
```

我们的类会在创建时获得数据，然后运行一个请求的方法。和PUT,POST和DELETE对应的方法都会返回一个405响应体（不允许的方法），因为我们默认不想让他们做任何事，GET方法则根据请求的URL和载入资源的数据返回一个表现。

### 路由

拼图的最后一块是如何把传入的请求传送到对应的资源类。这件事有很多方式完成，你可以根据个人爱好选择。

我们可以遵循一个传统，约定“/something”格式的URL被映射到一个叫做Something的资源类，对于集合资源，我们可以约定“/something/item”格式的URL映射到代表集合资源中的个体资源，类名叫SomethingItem。

另一种极端就是把每个URL和集合URL都映射到一个资源类。

## 结论

那么提供了一系列资源类，一些表现和一种把URL映射到类和资源方法到表现，我们可以以RESTful的方式构建Web应用程序。在加上一些HTTP的优点，比如有条件的GET和缓存消息头，我们就可以得到一个非常棒的系统。
