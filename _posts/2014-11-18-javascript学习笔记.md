---
layout: post
title: javascript标准参考教程学习笔记
category : web
---

## 前言

《javascript标准参考教程》来源自阮一峰，恰好涉及到了，就学习学习。

## 导言

学习js的理由: 

* 操控浏览器的能力
* 广泛的使用领域: 浏览器平台化，Node.js，数据库，跨移动平台，内嵌脚本语言，跨平台桌面应用程序
* 易学性: 环境广泛，简单，类主流语言语法
* 强大的性能: 语法灵活，表达力强，编译运行，事件驱动和非阻塞式设计
* 开放性和社区支持

V8 - 2008， Node.js、CoffeScript、PhoneGap - 2009 ，NPM、BackboneJS、RequireJS - 2010，AngularJS、Ember单页面应用程序框架 - 2012

JavaScript的子集和超集: TypeScript, asm.js

> 阮一峰读书多，见识广，实在是自愧不如。以后，有空要多看看他的文章。

## 语法

变量提升，块域不做单独的作用域，switch/case语句中使用表达式，===和==比较，switch语句可用对象代替: 

switch语句: 

```javascript
switch (fruit) {
    case "banana":
        // ...
        break;
    case "apple":
        // ...
        break;
    default:
        // ...
}
```

对象实现的switch语句:

```javascript
var o = {
    banana: function (){ return },
    apple: function (){ return },
    default: function (){ return }
};

if (o[fruit]){
    o[fruit]();
} else {
    o['default']();
}
```

Javascirpt允许语句存在label，与break和continue配合，感觉类似goto语句。

eval函数可以对字符串求值: `eval('var x = 10')`

this对象类似Ruby中的self关键字，this很灵活，易滥用，可固定(call, apply, bind)

## 后记

js属于可深入发展的点，但不是目前的当务之急，来日有空再学习吧。
