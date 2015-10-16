---
layout: post
title:  "js 的学习代码片段"
description: "关于js oop 中相关的知识学习"
category: note
---

## 前言

js 的主要的运行场景: 浏览器，Firebug 的终端，以及 nodejs 的运行终端。

在 mooc 网上，学习了一下 js 相关的知识，其中，ppt 中代码的一些，敲了下来。

js中，使用`.`的地方，都可以使用 `[]` 进行替代。

## mock Object create

```
// Object.create 是 es 5 中出现的属性，因而，处于兼容性，考虑使用mock 的方式
if (!Object.create) {
  Object.create = function(proto) {
    function F() {}      // 创建一个空得函数对象
    F.prototype = proto; // 设置原型 __proto__ 属性
    return new F;        // 注意 与 new F() 的区别
  }
}
```

```
// js 动态脚本语言， 没有提供语言层面的支持， 模拟重载，链式调用，模块化
function Person() {
  var args = arguments;
  if(typeof args[0] === 'object' && args[0]){
    if (args[0].name) {
      this.name = args[0].name;
    }
    if (args[0].age) {
      this.age = args[0].age;
    }
  } else {
    if (args[0]) {
      this.name = args[0];
    }

    if (args[1]) {
      this.age = args[1];
    }
  }
}

// 链式调用
function ClassManager() {}
ClassManager.prototype.addClass = function(str) {
  console.log('Class:' + str + ' added.');
  return this;
}

var m = new ClassManager();
m.addClass('a').addClass('b');
```

抽象类 - js 没有机制提供。

什么是动态脚本语言？ 
动态的创建函数和对象。

Object 对象， defineProperty（对属性进行限制）, seal, call, create 

```
// 可以看到 Object 是学习的重点
Object.defineProperty(Person, 'name', {value: true, emunable: false})
```

模块化 - 利用函数作用域, 具体参考 requirejs， seajs 等加载类库。

## 面向对象

```
// js 使用原型模拟面向对象编程 - 继承
// 原型链是学习的重点
function Person(name, age){
  this.name = name;
  this.age = age;
}

Person.prototype.hi = function() {
  console.log("Hi, my name is " + this.name + ", I'm " + this.age + "years old now.");
}

Person.prototype.LEGS_NUM = 2;
Person.prototype.ARMS_NUM = 2;
Person.prototype.walk = function() {
  console.log(this.name + " is walking...");
}

function Student(name, age, className) {
  Person.call(this, name, age);
  this.className = className;
}

//这里不使用 Student.prototype = Person.prototype 的原因
//是 Object.create 基于对象创建了一个空白的对象，使得引用指向不同的对象
// Student.prototype = Person.prototype;
// Student.prototype = new Person();
Student.prototype = Object.create(Person.prototype);
Student.prototype.construtor = Student; // 设置构建函数

// 覆盖基类的函数
Student.prototype.hi = function() {
  console.log("Hi, my name is " + this.name + ", I'm " + this.age + " years old now, and from " + this.className + '.');
}

Student.prototype.learn = function(subject) {
  console.log(this.name + " is learning " + subject + 
             ' at ' + this.className);
}


//Test for object
var bason = new Student('Bosn', 27, "Class 3, Grade 2");
bason.hi();
bason.LEGS_NUM;
bason.walk();
bason.learn("math");

// 思考和理解
// js 中的原型链: 通过 Object.prototype 关联的链式结构
// __proto__: Object.prototype - hasOwnProperty, toString, valueOf
//
// 访问对象的原型: __proto__, Object.getPrototypeOf
```

注意，不是所有函数都有 prototype ，都存在默认的方法。
比如，Object.create(), bind(null), call/bind。

typeof 和 instanceof - 左边是对象，右边是函数 - 这里依然是操作的原型链上

`[] instanceof Array`

## 一个完整利用原型继承的例子

```
// 容器探测器
!function(global) {
  function DetectorBase(configs){
    if (!this instanceof DetectorBase) {
      throw new Error('Do not invoke without new');
    }
    this.configs = configs
    this.analyze();
  }

  DetectorBase.prototype.detect = function () {
    throw new Error("Not implemented");
  }

  DetectorBase.prototype.analyze = function() {
    console.log('analyzing ....');
    this.data = '### data ###';
  }

  function LinkDetector(links) {
    if (!this instanceof LinkDetector) {
      throw new Error('Do not invoke without new');
    }
    this.links = links;
    DetectorBase.apply(this, arguments); // 调用父类的方法
  }

  function ContainerDetector(containers) {
    if (!this instanceof ContainerDetector) {
      throw new Error('Do not invoke without new');
    }

    this.containers = containers;
    DetectorBase.apply(this, arguments);
  }

  // inherit 是 ES 5 中提供的函数，需要自行模拟
  // 先实现继承
  inherit(LinkDetector, DetectorBase);
  inherit(ContainerDetector, DetectorBase);

  LinkDetector.prototype.detect = function() {
    console.log("Loading data: " + this.data);
    console.log("Link detectim started.");
    console.log("Scaning links: " + this.links);
  }

  ContainerDetector.prototype.detect = function() {
    console.log("Loading data: " + this.data);
    console.log("Container detection started.");
    console.log("Scaning containers: " + this.containers);
  }

  // 拒绝修改对象
  Object.freeze(DetectorBase);
  Object.freeze(DetectorBase.prototype);
  Object.freeze(LinkDetector);
  Object.freeze(LinkDetector.prototype);
  Object.freeze(ContainerDetector);
  Object.freeze(ContainerDetector.prototype);

  // 暴露全局对象
  Object.defineProperties(global, {
    LinkDetector: {value: LinkDetector},
    ContainerDetector: {value: ContainerDetector},
    DetectorBase: {value: DetectorBase}
  });

  function inherit(subClass, superClass) {
    subClass.prototype = Object.create(superClass.prototype);
    subClass.prototype.constructor = subClass;
  }
}(this);

// 测试
var cd = new ContainerDetector('#abc #def #ghi');
var id = new LinkDetector('http://www.zhihu.com http://www.u17.com http://www.youku.com');

cd.detect();
id.detect();
```

## 正则表达式

字面值: /xxxx/igm, RegExp('', '')

String 类中提供的关于正则表达式的支持： match，replace。

正则表达式： 字符类，分组，元字符串。

动态语言的正则支持: 特定的正则类 - RegExp，String 中对正则的支持。

正则表达式 是个重要的学习要点，也有很多相关的经典的书籍。

## underscore.js

js 中函数式编程的部分，使用 map/reduce 消除 for-loop，类似 Ruby 中的代码块。

突然，发现了 zsh 中不支持字符类的正则表达式， 如下的命令不能正常工作: 

```
# 感觉像是不太支持Posix类型的正则表达式
cat stock.txt | tr -cs [:alpha] '\n'
```

函数式编程的背后机制：如同 UNIX 下得工具那般，基于通用的数据类型(文本之流)，自底向上完成任务。

* Currying化：返回值为函数的函数
* 高阶函数： 参数中带有函数的函数
* 偏函数：将对象和函数绑定在一起

underscore 提供 compose 将多个函数绑定成一个新函数。

underscore 提供 mixin 方法，对库进行扩充，chain 函数。

> js 真是变得越来越强大了, 自己了解的还是太少了.

jQuery 的 promise 异步对象解决回调函数的诸多问题, 其核心思想是, 让非同步的操作返回对象, 其他操作都针对对象处理.:

## 后记

国庆期间，看了两天半视频，一天半 小说(4本小说 - 《十宗罪》)，真心累得不是人过的日子。看书学习，反而很轻松。

最近，觉得自己对生活的倾入度不深，很不好。看视频电影，体验他人的故事，最终迎来的是无尽的空虚和寂寞。

js 还是很有意思的。
