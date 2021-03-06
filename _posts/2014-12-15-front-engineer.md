---
layout: post
title: 关于前端工程师
---

## 前言

成为全栈式的工程师，其中也包含一部分前端工程师，所以，自己也储备了一部分的前端的书:  《Bootstrap用户手册》，《Bootstrap权威》，《HTML5 和 CSS3实例教程》，《jQuery实战》以及一些js的书籍。

此外，郭亨的前端知识拓扑: 

* javascript: js编码规范和设计模式，amd和cmd，jQuery/requirejs等常用库
* 页面开发: css/sass/less, compass, 图片类型和方案选择, seo, html, 响应式布局和浏览器兼容性
* 网络知识: HTTP, SPDY, CDN, dns, ssl&tls, 代理和反向代理, cache, cookie, 本地存储
* 安全知识: xss, csrf, sql injection, 域名和内容劫持, hijacking等
* 浏览器相关: bom, dom, 渲染机制，js runtime，内存管理, CPU Profile/GPU, reflow/repaint
* 开发调试: 前端开发工具和方法，badjs/tryjs，fiddler/willow, weinre, jslint
* 发布流程: 发布系统，分支管理，构建工具
* 性能检测: pagespeed/yslow, webpagetest, dynatrace
* 运营相关: 测速，监控等

> 备注: 上述的这些东西，有一部分我是有涉及的，但不深。

## 简介

> 工欲善其事，必先利其器。

原则: **凡是需要重复做的，都必须使用自动化工具完成。**

软件工具: 

* 版本控制工具 - git
* 单元测试工具 - 各语言框架不同
* 功能测试工具 - PhantomJS - 集成测试工具
* 依赖管理/程序包管理器 - Ruby(bundle, gem), Node(NPM,bower)
* 流程管理/构建工具 - 前端(Grunt, gulp), Ruby(某CI工具，Asssetpipe), Java(Ant)
* [LiveReload](https://github.com/mockko/livereload), 这里引出一个Ruby工具 - [guard](https://github.com/guard/guard)，自动更新，无F5刷新
* 代码质量分析工具 - js(jshint) , Ruby(各种ruby的工具)
* 持续集成 - 实践之后，开发水平达到另一个层次。

## 经验之谈 

willdurand以下是别人如何成为工程师的经验(开发[TravisLight](https://github.com/willdurand/TravisLight)):

首先，前端需要的东西: API和文档。[Grunt](http://gruntjs.com/)是一个js/css编译工具。

其次，**在项目中实践是最佳的编程学习方式**，其他的都是扯淡。相关使用的js的工具: 

* [Lo-Dash](https://lodash.com/) - [Underscore.js](http://documentcloud.github.io/underscore/)的替代品, 灵活的工具库
* [RequireJS](http://www.requirejs.org/) - js代码模块的库
* [Moment.js](http://momentjs.com/) - 在javascript中解析，操作，显示状态
* [Bower](https://github.com/twitter/bower) - web包管理器，css和js
* [Backbone.js](http://backbonejs.org/) - js的MVC框架

下面，详细介绍这些工具。

## Bower

Bower是前端包管理器，可以用来对css/js的版本进行管理。具体需要准备`component.json`文件:

```
{
  "name" : "travis-light",
  "dependencies" : {
    "jquery" : "~1.8.3"
  }
}
```

**对比**: 包管理器这种工具，相当的常见，从前端到后端，从操作系统到编程怨言，都存在相应的包管理。包管理无非涉及这样的几个方面: 软件的安装，卸载，查找，更新。

## Grunt

Grunt属于流程管理和构建工具，是基于任务的命令行Javascript工具，可用Lint验证代码，可缩减js/css代码，可运行单元测试。

##  BackBone.js

Backbone.js为web应用程序提供了层次结构，通过提供键值绑定的模型和定制化事件。其集合拥有丰富的枚举功能的API，其视图带有声明式的事件处理，并且可以通过已存在的API或者RESTful的JSON接口进行交互。

这里，说道javascript的MVC框架，其实个人一直想要引入一个MVC框架，就目前来看，我有这样的几个选择: 

* BackBone.js - 项目中已经使用了underscore.js，就引入文件大小而言，最小
* Ember.js - Yehuda编写的，个人比较倾向这个框架，但其97kb的体积让人担心
* AngularJS - 谷歌出品，国内访问不太便捷，pass

纠结BackBone.js和Ember.js。最终选择了Ember.js，以下是参考的资料: 

参考[12种JavaScript MVC框架之比较](http://www.infoq.com/cn/news/2012/05/js-mvc-framework/)之后，让我更倾向向Ember，毕竟，Yehuda是Rails 3的设计师，且一直活跃在Rails社区中。

1. [12种JavaScript MVC框架之比较](http://www.infoq.com/cn/news/2012/05/js-mvc-framework/)之后，让我更倾向向Ember，毕竟，Yehuda是Rails 3的设计师，且一直活跃在Rails社区中。
2. [Angular.js VS. Ember.js: 谁将称为web开发的新宠?](http://www.csdn.net/article/2013-09-09/2816880-Angular-Ember-Javascript-Frameworks), 看来Ember.js 可以与Angular.js比肩
3. [Ember.js中文指南](http://www.emberjs.cn/guides/), 中文版官方教程，

决定使用Ember之后，存在矛盾转移了: 如何组合Rails和Ember的MVC框架。问题解决了，我找到了如下的资源: 

* [ember-rails](https://github.com/emberjs/ember-rails)
* [Beginning Ember.js on Rails](http://www.cerebris.com/blog/tags/emberjs/)

此外，看到了一些警告: 选择了Angular或Ember，需要使用模板来处理系统，不是所有的都需要使用模板处理的。


## 参考文献

1. [作为 IT 从业人员，你觉得有什么工具大大提高了你的工作效率？](http://www.zhihu.com/question/24429345)
