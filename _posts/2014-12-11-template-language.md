---
layout: post
title: 模板语言
---

## 前言

自工作以来，接触了相当多的东西。其中，变化最多的要数模板语言。细数一下，我用过的模板语言有这样的几种：erb， mustache， Liquid， markdown，haml。其中，日用的有erb，markdown(写笔记)，haml。

模板语言之间，除了语法的不同外，是否支持复杂逻辑也是一个重要的评估标准。以下介绍mustache和erb。

## mustache

Mustache的github地址：<https://github.com/mustache/mustache>

Mustache是一种少逻辑的模板,支持的语言很多（Ruby, JavaScript, P/ython,Erlang, PHP, Perl, Objective-C, Java等），语法简洁明了。

> 支持语言的含义：存在对应语言的编译器。其中，ruby的编译器是[mustache](https://github.com/mustache/mustache); javascript的编译器为[hogan.js](https://github.com/twitter/hogan.js), [handlebars.js](https://github.com/wycats/handlebars.js)

Mustache含义有两种：

* mustache命令行工具（参考<http://mustache.github.io/mustache.1.html>） 
* mustache模板语言（参考<http://mustache.github.io/mustache.5.html>）

### 典型用法

通过`{{}}`引入变量，可以用在包括html，配置文件，源代码之类的地方。通过hash或对象渲染模板中的变量，无if-else，for-loop逻辑，只有tag。

区域渲染通过{{#person}} ... {{/person}}，若提供一组非空列表，模板将会重复渲染列表或数组中的每一项。

支持**闭包**：即哈希表中可以使用函数。

**注释**

```
{{! 这是注释}}
```

**导入别的文件**：

```html
//base.mustache:
<h2>Names</h2>
{{#names}}
  {{> user}}
{{/names}}

//user.mustache:
<strong>{{name}}</strong>  
```
**模板**

模板可以是如下的这些表示形式: 

1. 模板可以是一个html文件。

例如：模板文件.html

```html
<h1>Hello {{name}}, it is {{timeNow}}.</h1>
```

2. 模板可以是值为html代码的js变量

```javascript
var template = "<p>Hello {{name}}, it is {{timeNow}}.</p>";
```

3. 模板可以是一个script片段

```html
<script id="tpl-greeting" type="text/html">
  <dl>
    <dt>Name</dt>
    <dd>{{name}}</dd>
    <dt>Time</dt>
    <dd>{{timeNow}}</dd>
  </dl>
</script>
```

**变量表示**

变量标记将当前上下文的变量通过模板渲染，如果当前上下文不存在该变量，则渲染为空串。

默认变量会被经过 HTML 编码处理，如需显示原始值，用三个大括号或者在模板标记的初始加入 & 符号: `{{&变量名 }}` ，`{{{变量名 }}`

1. 如果当前键为基本或对象，则渲染一次，如果为数组，则渲染数组长度次数。节点以 # 号开始，以 / 结束。

```
{{#stooges}}<b>{{name}}</b><br>{{/stooges}}"
json: {"stooges":[{"name":"王升"},{"name":"梁文彦"},{"name":"石洋"}]};
```

2. 填充数组节点以 # 号开始，以 / 结束,则渲染数组长度次数。

模板模式: `{{#数组}}{{数组内的key}}{{/数组}}`

代码示例:

```javascript
var template = "{{#stooges}}<b>{{name}}</b><br>{{/stooges}}";
var view = {"stooges":[{"name":"王升"},{"name":"梁文彦"},{"name":"石洋"}]}
```

3. 函数作为模板的变量,该函数会在当前列表的每一个元素的上下文迭代执行。

```javascript
var template = "{{#beatles}}* {{name}}<br/>{{/beatles}}";

var view = {
  "beatles": [
    { "firstName": "John", "lastName": "Lennon" },
    { "firstName": "Paul", "lastName": "McCartney" },
    { "firstName": "George", "lastName": "Harrison" },
    { "firstName": "Ringo", "lastName": "Starr" }],
  "name": function () { return this.firstName + " " + this.lastName;}
};
```

如果节点键的值为函数，注意该函数在执行时的两个参数，第一个为该节点变量的直接值，第二个为函数，其执行的上下文对应视图对象。

```javascript
var template = "{{#bold}}Hi {{name}} {{lastName}}.{{/bold}}";
var view = { "name": "John",
             "lastName": "Lennon",
             "bold": function () {
                  return function (text, render) {return "<b>" + render(text) + "</b>";}
              }
           }
```

注意: json数据的key跟模板的变量对应就会填充。模板变量和json的key对应不上就不填充, 生成展示代码没填充的变量不显示

`Mustache.render(template, view)`方法填充数据生成展示代码, 其中view:为json数据，作为模板上下文，template:为模板对象。以下是代码示例:

```javascript
//模板
var template = "<p>Hello {{name}}, it is {{{ignore name}}}.it is {{&name}}</p>";

//数据
var date = new Date();
var view = {name: "<b>Jonny</b>",timeNow: date.getHours() + ':' + date.getMinutes() };

//使用模板文件要用该方法填充数据生成展示代码
$.get('模板文件', function(templates) {
  var template = $(templates).html();
  $Mustache.render(template, view);
});
```

## erb

erb为在Html中嵌入ruby代码，其本身存在很多不同的实现: ERB, eruby, Erubis，其中，erb是纯ruby实现的，eruby和Erubis都是c实现的。所谓，熟悉的地方没有风景。我一直以为Rails中erb模板是由ruby自带的erb处理器编译的，没想到，居然是Erubis。

更多参考<a href="/2014/12/11/Erubis user guide/">Erubis user guide</a>

## haml

## 后记


