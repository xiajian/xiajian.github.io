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

学习和了解Rails项目，首先看Gemfile，然后看routes.rb。这个经验可以推广到AngularJS中，先找`bower.json/package.json`，然后阅读其中的路由。

## package.json

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

## bower.json

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

> 关于浏览器的包管理器，存在这样的几个类似功能的工具: [component](https://github.com/componentjs/component), [browserify](https://github.com/substack/node-browserify), [spm](https://github.com/spmjs/spm)。

## requirejs

CommonJS社区，特定功能框架的规范，AMD，RequireJS是AMD规范的实现。相比script标签的方式，以加载顺序解决依赖关系，RequireJS使用基于模块的异步加载js机制，延迟 & 按需加载模块。

AMD规范: `define(id?, dependencies?, factory);` - 该方法定义js模块，将功能模块封装在`define`方法内。

* id 表示模块的标识参数，可选
* dependencies 是一组字符串Array，表示其依赖的模块标识，可选。默认值为`[“require”，”exports”，“module”]`
* factory 用于执行模块的方法，使用 dependencies 里声明的其他依赖模块的返回值作为参数。有返回值且被其他模块依赖，返回值即输出。

RequireJS是AMD较好的实现，体积小，浏览器支持广泛。

RequireJ的S目标，鼓励代码模块化，用模块来组织js代码，以模块ID代替URL地址。 使用js模块可以避免直接访问全局变量。

RequireJS的核心API: define, require, config。

调用方式: `<script data-main="js/main.js" src="/bower_components/requirejs/require.js"></script>`

涉及的文件: main.js - 程序的入口， 配置载入所需的程序模块() , config.js - 配置requirejs 。默认资源为js，可省后缀名。

两个全局变量: 1. requirejs/require: 用来配置requirejs及载入入口模块。 2. define: 定义模块

requirejs.config的支持的配置项: 

1. baseUrl - 模块所在的前置地址
1. paths - 各个模块的地址, 这里可以使用cdn指定
1. shim - 未使用requirejs的定义方式，需要暴露的全局对象
1. map - 模块全局暴露相关，有主模块和无主模块
1. waitSeconds - 加载文件等待的时间
1. packages - 指定符合AMD规范的目录结构
1. config - 将配置信息传给模块

《用AngularJS开发下一代web应用》中，给出应用了requirejs的例子

```
define(['angular', 'controllers/controllers',
  'services/services', 'filters/filters',
  'directives/directives'], function (angular) {
  return angular.module('MyApp', ['controllers', 'services',
    'filters', 'directives']);
});
```

> define 第一个参数是模块数组，第二个参数是回调函数(其中使用模块提供的接口)，要注意参数注入与模块数组顺序一致。注入就是将全局变量当作
> 参数传入，从而避免对全局变量的污染。

**注意事项**: 

1. 一个文件一个模块
1. define中使用模块名，需要将require作为依赖注入到模块中，尽量用注入的方式
1. 生成相对于模块的URL地址： require.toUrl
1. 调试，在`require(["module/name"], function(){})`，使用`require("module/name").callSomeFunction()`。

## 目录结构

书本上，推荐使用yeoman的angular生成器生成目录结构，这样的目录结构是标准的。

yeoman的命令为:  `yo angular test_ng`， 然后就是漫长的等待，注意，yeoman的生成器，会在当前目录中生成文件，也就是这个自动化流程工具都不给你创建一个文件，
存放他生成的那些狗屎文件，而且，生成个文件，执行了一段莫名奇妙的东西，在同一个shell终端，居然记住了上次安装的路径，一遍又一遍的忘错误的地方安装那些模块。

一会儿让你选这个，一会儿又莫名奇妙的卡在哪里，一动不动。每次，卡的地方还不一样。我他妈就不明白，老子生成一下项目和文件，你丫的预编译测试个毛啊。真是狗屎一般的`yo angular`生成器。
发泄归发泄，自己写了简单的包装命令，如下。仔细想想，虽然没给自动生成目录，但，把整个流程走了一遍，还是很有用的。我现在觉得，流程比功能更重要。

```
function yeoman() {
  if [ $# == 0 ] ; then
    echo "[usage]: yeoman project_name"
  else
    mkdir $1 && cd $1 
    echo "Now ,we are in $1, and yeoman will generate $1 project"
    yo angular $1
  fi
}
```

```
▾ app/
  ▸ images/
  ▸ scripts/
  ▸ styles/
  ▸ views/
    404.html
    favicon.ico
    index.html
    robots.txt
▸ test/
  bower.json
  Gruntfile.js
  npm-debug.log
  package.json
  README.md
```

> 某项目中，代码组织结构相当的混乱，这可不是什么好现象。想念Rails中的优良的组织结构。

此外，我看到[github-hunter](https://github.com/numbbbbb/githuber.info)的workflow相当的顺畅: 

* 安装: 
  * `npm install` - 安装`package.json`中的依赖项
  * `bower install` - 安装`bower.json`中的依赖项
* 开发: 
  * `grunt serve` - 配置启动本地开发服务器
  * `grunt build` - 构建发布版本(dist目录)
* 部署: 用capistrano脑补即可。

> 觉得npm和bower这种将依赖特定项目中的做法也挺不错的。

创建合适的工作流涉及的软件: Node, NPM, Bower, Yeoman, Grunt，Compass(css相关)。寻找一个套合适的工作流，
也是人生奋斗的目标之一。

Yeoman的目标: 通过grunt和bower建立易用的工作流。

ng中相关目录的含义: 

* controllers - 控制器模块
* directives - ng中实现的指令
* filters - 过滤器模块
* services - 封装了资源的对象，提供rest方法调用
* utils - 相关的工具函数

## gulp

在构建工具方面，在Grunt和Gulp之间，选择了Gulp。但是，这种选择是否明确。

## 问题

此外，遇到一个问题，Ng前端项目中左侧的导航栏，使用 http://localhost/ 就不能显示，而使用 http://127.0.0.1/ 就能显示。咨询了一下说，这是
因为把cookie直接写到了ip下的原因。具体的就不太了解，以后，有机会多学习学习。


## 后记

内功心法和外在招式不可偏废，内外兼修。

将angularjs和Rails结合，不要去折腾那个坑爹的NodeJS。基本上，两者(NodeJS和Rails)工作领域相似，都是用作后端API。

如果，使用公共的API，然后用ng搭建个客户端。这样也是个不错的学习体验和方式。

知乎真心挺不错的。

## 参考文献

1. [npm spm bower这三个包管理器，哪个比较好用？](http://www.zhihu.com/question/24414899)
1. [使用 RequireJS 优化 Web 应用前端](http://www.ibm.com/developerworks/cn/web/1209_shiwei_requirejs/)
1. [快速理解RequireJs](http://www.tuicool.com/articles/jam2Anv)
