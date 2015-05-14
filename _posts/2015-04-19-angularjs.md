---
layout: post
title: 学习angularjs
description: "angularjs，js框架"
---

## 前言

自从过年来后，明显感觉到自己身上发现了一些变化。第一，身体变得越来越差了。第二，看的书变的高深了。我一个特点： 看高深的理论书时，容易走神，看着看着就去看漫画了。

整天看着这些理论书，搞得我自己神经兮兮的，光说不练假把式，我决定回到前端，从页面开始，做一些有用有价值的事情(立马见效的事情)。

## 正文

angularjs应用自动接管一切DOM事件。

npm也存在一个类似的国内的淘宝镜像，可以用来加快下载速度。

临末了，体验了一下利用yeoman生成和安装一个js的应用程序，感觉很沮丧，居然比Rails还慢。而且，一上来就安装了一堆莫名奇妙的东西，并卡在莫名奇妙的地方一点反应也没有。

然后就是，发现npm的全局安装对特定的应用程序不可见，这算是什么狗屁情况啊。

遇到的问题: 

1. `http://errors.angularjs.org/1.3.15/$injector/nomod?p0=ngRoute` 。解决，缺少某些模块，使用`bower install`安装即可解决。

## 探索

发现一个不错的资源，利用angular-ui实现的bootstrap，用手机体验了一下，发现交互和响应有明显的延迟。

偶然想到，阿里云的控制后台也是利用AngularJS实现的。从上手的难易程度来看，Ng非常的容易上手。

接触到一个项目，发现Ng的项目是前后分离的，即NodeJS一般用作API，Ng项目用作前端，难道，所谓的前后分离就是两个项目进行分离？

## 学习

学习和了解Rails项目，首先看Gemfile，然后看routes.rb。这个经验可以推广到AngularJS中，先找`bower.json/package.json`，然后阅读其中的路由。

### package.json

首先是package.json，后端API部分，依赖如下的这些包: 

* express - 基于nodejs的轻量级、快速的web框架
* underscore - 类似Ruby的工具函数语法的web框架
* mongoose - nodejs中mongodb的orm
* body-parser - 报文体的解析器中间件，可以解析JSON、文本以及URL编码的报文
* config - 在应用程序开发时，用来层次化的组织配置文件
* connect - connect 是用来粘合多个中间件处理请求的中间件
* cookie-parser - 解析Cookie头部，并以cookie的名为键，将对象存放到`req.cookies`中
* cors - 提供connect/express的中间件，并用其来处理跨域请求
* moment - 解析，验证，操作，格式化日历的轻量级js库
* needless - 从`require`cache中移除模块
* q - 就是嵌套方法调用的流式调用版
* uuid - 生成RFC4122版本的UUID

前端部分的package.json，基本无依赖，只有对执行引擎(nodejs)有些依赖。

package.json的依赖可通过`npm install`进行安装，不过，这样如何理解bower的作用？？

### bower.json

bower.json以及bower工具，似乎主要是用来处理浏览器相关的包的依赖的。

前端的bower.json给出的依赖内容: 

* angular-animate - ng的动画切换
* angular-bootstrap - ng重写bootstrap的，没有jquery的依赖
* angular-cookies - ng中Cookies相关的模块
* angular-file-upload - ng文件上传的模块
* angular-i18n - ng国际化相关的模块
* angular-md5 - ng md5相关的模块
* angular-resource - ng resource 路由相关的模块
* angular-route - ng的路由
* angular-sanitize - ng用来清理html相关的模块，主要是为了预防html的注入攻击
* angular-ui-calendar - ng中日历相关的组件
* angular-ui-tree - 页面中树形结构相关组件
* angular - ng的主库
* async - 提供异步js相关的工具模块。
* bootstrap - 最最熟悉的bootstrap框架
* es5-shim - es5的垫片js
* fullcalendar - 全尺寸，拖拽型的事件日历。项目地址: https://github.com/arshaw/fullcalendar
* highcharts - 绘图专用的js库
* jquery-ui - 笨重的jQuery UI，没什么好的印象
* jquery - 名声在外的js，用来操作
* mockjs - 用来mock ajax的请求的js工具库
* moment - 解析，验证，操作，格式化日历的轻量级js库
* ng-csv - 用来解析csv的ng插件，主要显示想诸如excel之类的界面
* requirejs-text - 加载文本资源的amd加载插件
* requirejs - amd 加载工具
* underscore - 类似Ruby的工具函数语法的web框架

> 备注: 了解了一下bower和npm这两个包管理器的区别。npm是node模块的包管理器，bower是前端包管理器，两者之间有些重合的地方。npm是树状的依赖关系，和原生支持`commonJS`。bower是tiwtter出品，比较灵活。

此外，遇到一个问题，Ng前端项目中左侧的导航栏，使用 http://localhost/ 就不能显示，而使用 http://127.0.0.1/ 就能显示。咨询了一下说，这是
因为把cookie直接写到了ip下的原因。具体的就不太了解，以后，有机会多学习学习。

## 后记

内功心法和外在招式不可偏废，内外兼修。

将angularjs和Rails结合，不要去折腾那个坑爹的NodeJS。基本上，两者(NodeJS和Rails)工作领域相似。

知乎真心挺不错的。

## 参考文献

1. [npm spm bower这三个包管理器，哪个比较好用？](http://www.zhihu.com/question/24414899)
