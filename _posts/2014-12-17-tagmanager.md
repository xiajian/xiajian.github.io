---
layout: post
title: tagmanager.js
---

## 前言

某个需求的需要使用tagmanager.js和以及一个预输入提示(autocomplete或使用typeahead.js)，然后，我一直以学习typeahead为借口，一直拖着。昨天，看样子终于拖不下去了，于是，转而自写的ajax请求和tagmanager结合使用。很快就搞定了，以下深入学习一下tagmanger.js。

## 简介

Tags Manager是用来创建输入域tag的jQuery插件(依赖jQuery)，与[Typeahead.js](http://twitter.github.io/typeahead.js/)以及[Bootstrap](https://github.com/twbs/bootstrap)

## 实例

### 简单实例

tagmanager.js的简单实例(在Rails中)

```erb
<!-- typeahead.js以及tagmanager.js、tagmanger.css都是通过响应的资源文件控制的 -->
<input type="text" name="tags" id="tags" class="tm-input input-medium input-info" placeholder="Tags" >

<input class="input-medium tm-input tm-input-success tm-input-small tt-query" type="text"  placeholder="Tags" id="test-typeahead" />
<script type="text/javascript" charset="utf-8">
  $(document).ready(function(){
    $("#tags").tagsManager({
       prefilled: ["Apple", "Google"]
       });
     var tagApi = jQuery("#test-typeahead").tagsManager({
      prefilled: ["Angola", "Laos", "Nepal"]
    });
    $("#test-typeahead").typeahead({
      name: 'countries',
      limit: 15,
      source: [ "Russia", "France", "Ukraine", "Spain", "Sweden", "Norway", "Germany", "Finland", "Poland", "Italy", "United Kingdom", "Romania", "Belarus", "Kazakhstan", "Greece", "Bulgaria", "Iceland", "Hungary", "Portugal", "Serbia", "Austria", "Czech Republic", "Republic of Ireland", "Georgia", "Lithuania", "Latvia", "Croatia", "Bosnia and Herzegovina", "Slovakia", "Estonia", "Denmark", "Netherlands", "Switzerland", "Moldova", "Belgium", "Albania", "Macedonia", "Turkey", "Slovenia", "Montenegro", "Azerbaijan", "Luxembourg", "Andorra", "Malta", "Liechtenstein", "San Marino", "Monaco", "Vatican City", "efe" ]
      }).on('typeahead:selected', function(e,d){
        tagApi.tagsManager("pushTag", d.value);
        });
    })
</script>
```

查看源代码之后，这其实就是个界面效果的插件，文本框中输入的值是通过隐藏的input标签保存并最终提交给服务器，隐藏标签显示如下: 

```html
<input type="hidden" name="hidden-tags" value="Google,exit">
```

**注**: 隐藏input的`name`的值默认为`hidden-申明input的name`。如果，申明的input没有指定name，则为`hidden-undefined`。可以通过`hiddenTagListName`属性进行配置。

### 复杂实例

上面的例子中，使用的typeahead的source属性，预取本地的数据。可以使用Ajax，function等数据源。

可以使用Ajax推送tags，从而在用户指定的终点创建或者删除tag。使用`AjaxPushAllTags`在每次更新时，将所有的tag都推送上去，而不是递增的推送每一个tag。使用`AjaxPushParameters`选项，可以在每次ajax请求时，附加额外选项。代码示例如下:

```
$(".tm-input").tagsManager({
  AjaxPush: '/ajax/countries/push',
  AjaxPushAllTags: true,
  AjaxPushParameters: { 'authToken': 'foobar' }  //这里提供授权码
})
