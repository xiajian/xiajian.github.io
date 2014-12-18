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

问题: 在Firebug中看到`$.browser is undefined`这样的报错信息，进去一看我，居然是bootstrap-typeahead.js中的出现的问题。我一直以为自己用的是最新的twitter-typeahead，搞了半天，原来是bootstrap-typeahead.js，并且同项目中jquery的版本冲突了。原来，2.x的Boostrap自带了typeahead的插件！！

果然，精确的版本控制是一个非常的重要的问题。版本依赖和兼容问题，可真是地狱啊。

### 复杂实例

上面的例子中，使用的typeahead的source属性，预取本地的数据。可以使用Ajax(prefecth等)，function等数据源。

可以使用Ajax推送tags，从而在用户指定的终点创建或者删除tag。使用`AjaxPushAllTags`在每次更新时，将所有的tag都推送上去，而不是递增的推送每一个tag。使用`AjaxPushParameters`选项，可以在每次ajax请求时，附加额外选项。代码示例如下:

```
$(".tm-input").tagsManager({
  AjaxPush: '/ajax/countries/push',
  AjaxPushAllTags: true,
  AjaxPushParameters: { 'authToken': 'foobar' }  //这里提供授权码
})
```

> 可以通过FireBug的控制台查看XHR ajax请求。

### 使用API

Tagmanger拥有相当不错的API，可编程式的添加或移除tag，更多完整的选项参考配置章节。

文档的使用api的代码例子令人感到迷惑，代码居然和上述使用Ajax的一样。觉得很奇怪，去文档的html上查看了一下，果然存在响应的事件代码。具体的代码如下:

```html
<h3>Tagmanager API的测试实例:</h3>
<form class="form-inline">
  <input type="text" name="tags" id="tag-api" class="tm-input input-medium tm-input-warning" placeholder="Tags" >
  <button id="addtag" class="btn">添加</button>
  <button id="removetag" class="btn">移除</button>
</form>

<script type="text/javascript" charset="utf-8">
    var testtagapi = $("#tag-api").tagsManager();
    $('#addtag').click(function (e) {
      e.preventDefault();
      var tag = "";
      var albet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
      for (var i = 0; i < 5; i++)
        tag += albet.charAt(Math.floor(Math.random() * albet.length));
      testtagapi.tagsManager('pushTag', tag);
    });
    $('#removetag').click(function (e) {
      e.preventDefault();
      testtagapi.tagsManager('popTag');
    });
</script>
```

## Tagmanager配置

如下的代码显示3.0的Tagmanager所有可配置的选项: 

```javascript
jQuery(".tm-input").tagsManager({
  prefilled: null,              // 预填充数据
  CapitalizeFirstLetter: false, // 大写第一个字母
  preventSubmitOnEnter: true, // 在输入回车时，阻止提交。弃用
  isClearInputOnEsc: true, // 输入Esc时，清空输入框。弃用
  AjaxPush: null,        // Ajax提交的地址
  AjaxPushAllTags: null, // 提交所有的Tag
  AjaxPushParameters: null, // 提交tag参数
  delimiters: [9, 13, 44], // tag的分隔符: tab, enter, comma
  backspace: [8], 
  maxTags: 0,
  hiddenTagListName: null, // 隐藏Tag的input的名字。弃用
  hiddenTagListId: null, // deprecated
  replace: true,
  output: null,
  deleteTagsOnBackspace: true, // 退格删除Tag。弃用
  tagsContainer: null, 
  tagCloseIcon: 'x',
  tagClass: '',    // tag的样式
  validator: null, //验证器
  onlyTagList: false
});
```

* prefilled: 构成最初的tag的值，默认为null，允许的格式如下:

    * 字符串数组
    * 对象数组(如果externalTagId设置为true，使用prefillIdFieldName和prefillValueFieldName来配置)
    * 使用分隔符分隔的字符串(默认为逗号)
    * 返回数组的函数
    * 如果没有提供预填充，就使用output。注意，output中的值为分隔符分隔的字符串(默认为逗号)

* CapitalizeFirstLetter:  为真则所有的tags的第一个字符都将大写
* AjaxPush: 可以从Ajax源处pull或push。该参数提供了url，并且其他tag用作POST的参数
* AjaxPushAllTags 	If true, enables a mode to sync the entire tag state via AJAX (rather than incrementally) each time a tag is added/deleted. Default: false.
* AjaxPushParameters: Adds an additional parameter payload to push with each AJAX request, for example server authentication parameters. Default: null.
* delimiters: Default: [9,13,44] (tab, enter, comma). Delimiters should be numeric ASCII char codes. Please note the following:

   *  The following values are handled as key codes: 9 (tab), 13 (enter), 16 (shift), 17 (ctrl), 18 (alt), 19 (pause/break), 37 (leftarrow), 38 (uparrow), 39 (rightarrow), 40 (downarrow)
   *  Note that codes 45 (key = insert, char = -) and 46 (key = delete, char = .) are handled as chars, so currently insert and delete keys cannot be used as delimiters
   *  The first char code (non-key code) specified in the array will be used as the base delimiter for parsing tags to/from the hidden field "list string". This will default to comma if not specified.
   *  See http://unixpapa.com/js/key.html for a full explanation of ASCII versus key codes.

* backspace: When the input field is empty, and some tags are rendered on the left of the input field, and the user hit the backspace the plugin remove the rightest tag (which is the last the user entered).
With this option you can provide an array of char codes (like the delimiters above) you want the system to use in place of the backspace (char code 8), or provide an empty array if you don't want this feature at all.
* blinkBGColor_1和blinkBGColor_2 	When a duplicate tag is entered the user is notified with a blinking of the corresponding (duplicate) tag, here you can configure the colors. Note this is working only if you also include jQuery UI in your project.
* output 	Should be a valid CSS selector, if present this input field will receive the comma separated list of tags entered; tag manager does not check if this selector is really an input field, just tries to fill the value with jQuery .val().
* replace 	(true|false) If set, the element name of the input field will be transfered to the hidden input field storing the comma separated list of tags entered; in other words if you have `<input name="tags"/>` and you turn it into a tagmanager with this parameter true on form submit you will find the tags posted with name="tag".
* maxTags 	Optionally defines the maximum number of tags accepted. Default: 0 (no limit)
* tagCloseIcon 	Sets the HTML string to be used as the tag close icon. Default: ×
* tagsContainer 	Optional jQuery selector for the element to contain the tags. Default: tags appear immediately before the tag input.
* tagClass 	Optional class to be applied to all tags. Please as see note about automatic tag styling. Default: none
* validator 	An optional callback function to validate the user input. Takes the tag string as input, and must return true or false. Default: null (no validation function used).
* onlyTagList 	If true, rejects tags which do not appear in the typeahead list. Default: false
* externalTagId 	Optionally instead of incrementing id of tags, you could pass it as argument to pushTag and use it later. (.tagsManager('pushTag','I_am_a_new_tag', false, 1);) Default: false
* prefillIdFieldName 	Optional. If externalTagId and prefilled is set to true: This option will be used to get Tag Id from prefilled objects. Default: 'Id'
* prefillValueFieldName 	Optional. If externalTagId and prefilled is set to true: This option will be used to get Tag Value(name) from prefilled objects. Default: 'Value'
* fillInputOnTagRemove 	If true, fills back the content of the removed tag to the input field. Default: false

## TagManager的方法

Tag的管理的方法与栈操作类似，包括压栈，弹出，清空，以及检索，且其元素必须是唯一的。具体的方法如下: 

* `tagsManager('popTag')`: 弹出最新添加的tag，即最右边显示的
* `tagsManager('pushTag','I_am_a_new_tag')`: 压入一个新的tag
* `tagsManager('empty')`: 清空所有的标签
* `tagsManager('tags')`: 检索列出的所有tag

注: 第一个参数的都是js方法名。

## TagManager样式

TagManager捆绑了Bootstrap主题集的颜色和样式，并提供了多种定义tag的样式的方法: 

1. 基本样式`tm-tag`应用到所有的标签上。
2. 赋值给input的样式，可以用来推断出tag样式的语义，例如，`<input class='tm-input tm-input-success tm-input-small'/>`将在tag上应用`tm-tag-success`和`tm-tag-small`样式。
3. 通过`tagClass`参数，可以对tag使用定制的样式。

<div class="pic">
  <img src="/assets/imags/tagmanager.png" alt="TagManager的样式图片"/>
</div>

为了正确的对其，推荐使用`tm-tag`样式，如果在Bootstrap的控制器分组容器中使用TagManager，务必在容器节点中添加`tm-group`样式。

## 历史 

原作者最初是做在线个人财经工具，想要一个简单的类似stackoverflow中管理tag的解决方案。

## 其他可选项

在开发自己的tags管理器前，插件作者花了很多时间来调查其他可用的解决方案，并解释了为何最终自己开发tag管理器。

* [Tag it! by Levy Carneiro Jr](http://levycarneiro.com/projects/tag-it/example.html), one of the very first one as far as I know, which inspired all the others.
* [Tag Handler by ioncache](http://ioncache.github.com/Tag-Handler/), in my opinion is probably the best general purpose tags manager around.
* [jQuery Tags Input Plugin](http://xoxco.com/projects/code/tagsinput/), it's really very cute.
* [Stack Overflow Tag Manager](http://stackapps.com/questions/2062/stack-overflow-tag-manager), if you want to mimic StackOverflow behavior.

tagmanager插件作者认为上述的四个是相当不错的，但是出于如下的原因，他开发了Tagmanager： 

1. 简单，不需要hover的铅笔标志
2. 不需要就地编辑
3. 不想在表单中生成太多html
4. 与bootstrap和typeahead紧密集成

> 这几点要求确实相当的实在，我也信奉相同的原则。

## 后记

居然看完了，为了某个一次性的输入提示的一次性需求。不过，也因此接触和学习不少有趣的东西，比如jQuery插件的写法。
