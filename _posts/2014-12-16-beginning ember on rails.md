---
layout: post
title: Beginning Ember.js on Rails
---

## 前言

为了学习Ember.js，从而找到的英文资料(<http://www.cerebris.com/blog/tags/emberjs/>)，翻译如下。
 
## 温习Ember.js

作为一个客户端框架，Ember.js已经存在相当长的历史。其起源于Sproutcore项目，并作为Sproutcore 1.x(Apple用来构建MobileMe和iCloud的重量级组件)的精简的现代的继任者。当Sproutcore 2变得不再完全兼容Sproutcore 1.x时，项目更名为Amber.js，为了避免与Smalltalk项目Amber引起冲突，又更名为Ember.js(幸亏没取SproutcoreCore.js这个名字)。

### 这不是历史课

那么Ember.js中，有何特别之处？ 其特别之处在于**同步**。

对象可以相互的观察和更新，计算属性可以限制到一个或多个其他的属性，视图中的元素属性由对象属性来约束，视图可以管理其他视图的创建和移除，
事件可以关联到视图的动作中。等等

换而言之，Ember维持应用中的组件的同步，从而使开发者集中处理应用程序对象的定义及其之间的关系，而不是花时间维持之间关系。

### 会变慢吗

毫无疑问，Ember的同步代码会导致性能的耗损。不过，MVC框架可以减少监听事件、更新数据和HTML的代码。

记住： **任何客户端框架都是由javascript和HTML构成的，以及理性的看待抽象层**。 这一点从Ember默认使用[Handlebars](https://github.com/wycats/handlebars.js)模板中看出，其中可以随意的混合HTML。

### 听着不错，但实用吗

Ember的核心成员Yehuda Katz说: “一些诸如ZenDesk，BazaarVoice和LivingSocial的大公司使用了Ember”。此外，开源的持续继承项目[Travis CI](http://travis-ci.org/)也是用了Ember。

Cerebris正在将Ember集成到下一代的Syncd中。

Ember本身依然在持续开发，并且其中有些部分依然处于变动中。文档持续进行，但不可能触及框架中所有有用的部分。阅读[Github上的议题](https://github.com/emberjs/ember.js)，以及[StackOverflow上的问题](http://stackoverflow.com/questions/tagged/emberjs)，成效卓越。

### 特性X, Y, Z ?

起初，Ember缺乏其他JavaScript的MVC框架中的某些功能，比如RESTful的持久层以及客户端路由。但是，这些问题都很快就被解决了。

下面的部分将对Ember.js的绑定功能、计算性能、以及自动更新模板进行介绍，最终拼凑成一个简单的支持CRUD的Rails程序。

## Beginning Ember.js on Rails: Part 1

Ember.js并不依赖任何服务器端应用。实际上，它可用来控制单页面web应用或PhoneGap手机应用。开始学习Ember时，可以通过结合Rails来编写一个简单的CRUD程序。
