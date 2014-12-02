---
layout: post
title: typeahead.js
---

## 前言

存在这么个需求: 有个输入框，他要智能提示输入。然后，我找到了这个js - [typeahead.js](https://github.com/twitter/typeahead.js)。然后，开始研究一下，如何去使用。

## 简介

灵感来自twitter的自动补全搜索功能，typeahead.js是实现预输入的强大灵活的javascript库。Typeahead.js库包含了两个组件：推荐引擎[Bloodhound](https://github.com/twitter/typeahead.js/blob/master/doc/bloodhound.md)以及UI视图[typeahead](https://github.com/twitter/typeahead.js/blob/master/doc/jquery_typeahead.md)。

推荐引擎负责对给定的查询计算推荐结果，UI视图渲染推荐并处理DOM交互。这两者都可分开使用，但是，结合使用可以提供丰富的预输入的体验。以下，分别介绍两者。

## Bloodhound

Bloodhound是typeahead.js的推荐引擎，健壮且灵活，而且还提供诸如预取，智能缓存，快速查找，远程数据回填。下面，从特性和使用方面分别介绍，使用则从API、选项、预取等方面介绍。

其特性如下: 

* 可使用硬编码数据
* 初始化是预取数据，从而减少推荐时延
* 智能使用本地存储从而减少网络请求
* 从远程源中回填建议项
* 对远程请求的速率限制并缓存网络请求，从而减轻负载

具体的使用，按API，选项，数据集，定制事件和 Look and Feel介绍。

### API

* `new Bloodhound(options)`是构造函数，其接受哈希选项作为唯一的参数。

```javascript
var engine = new Bloodhound({
  name: 'animals',
  local: [{ val: 'dog' }, { val: 'pig' }, { val: 'moose' }], // 本地数据源
  remote: 'http://example.com/animals?q=%QUERY',             // 远程数据源
  datumTokenizer: function(d) {
    return Bloodhound.tokenizers.whitespace(d.val);
  },
  queryTokenizer: Bloodhound.tokenizers.whitespace
});
```

* `Bloodhound#initialize(reinitialize)`启动了推荐引擎。其启动过程包括处理有`local`以及`prefetch`提供的数据。初始化完成前，其他方法均不起作用; 初始化完成后，返回一个 [jQuery promise] 。

```javascript
var promise = engine.initialize();

promise
.done(function() { console.log('success!'); })
.fail(function() { console.log('err!'); });
```

After the initial call of `initialize`, how subsequent invocations of the method
behave depends on the `reinitialize` argument. If `reinitialize` is false, the
method will not execute the initialization logic and will just return the same 
jQuery promise returned by the initial invocation. If `reinitialize` is truthy,
the method will behave as if it were being called for the first time.

在`initialize`调用之后，后续调用方法的行为依赖于`reinitialize`参数。如果`reinitialize`为false，函数不执行初始化逻辑，并仅仅返回和最初调用相同的jQuery promise。如果`reinitialize`为真，初始化就重新执行。

```javascript
var promise1 = engine.initialize();
var promise2 = engine.initialize();
var promise3 = engine.initialize(true);

promise1 === promise2; // 相等性判断
promise3 !== promise1 && promise3 !== promise2;
```

* `Bloodhound#add(datums)`获取一个数据参数datums，其中的数据将被添加到搜索索引中，从而增强推荐引擎。

```javascript
engine.add([{ val: 'one' }, { val: 'two' }]);
```

* `Bloodhound#clear()` 从搜索引擎中移除所有推荐。

```javascript
engine.clear();
```

* `Bloodhound#clearPrefetchCache()` 如果使用了`prefetch`选项，数据将会缓存到本地存储中，从而减少不必要的网络请求。`clearPrefetchCache`提供了可编程移除缓存的方法。

```javascript
engine.clearPrefetchCache();
```

* `Bloodhound#clearRemoteCache()` 如果使用了`remote`选项，Bloodhound将会缓存最近10条响应，从而提供最佳的用户体验。`clearRemoteCache`提供编程清除缓存的方法。

```javascript
engine.clearRemoteCache();
```

* `Bloodhound.noConflict()` 返回Bloodhound构造器的引用，并返回`window.Bloodhound`的先前的值。可以用来避免命名冲突。

```javascript
var Dachshund = Bloodhound.noConflict();
```

<!-- section links -->

[jQuery promise]: http://api.jquery.com/Types/#Promise

* `Bloodhound#get(query, cb)` 为`query`计算一组建议。`cb`为之前提到datums。`cb`总是与在客户端可用的建议一起同步调用。如果客户端的不够，将会考虑`remote`。`cb`也可以异步的方式，混合着客户端和`remote`端数据进行调用。注： 例子中显示，`cb`为函数。

```javascript
bloodhound.get(myQuery, function(suggestions) {
  suggestions.each(function(suggestion) { console.log(suggestion); });
});
```

### Options


当实例化一个Bloodhund推荐引擎时，存在如下的选项可配置: 

* `datumTokenizer` – 将datum转换为字符串token的数组的函数，其签名为`(datum)`。**必须**
* `queryTokenizer` – 将查询转换为字符串token的数组的函数，其签名为`(query)`。**必须**
* `limit` – `Bloodhound#get`方法返回的最大的建议数目. 如果不够，就用远程的数据回填。默认为5个。
* `dupDetector` – 如果设置该选项，其值为带有`(remoteMatch, localMatch)`选项的冗余检测函数，即数据中存在冗余，则返回为true，否则返回为false。如果不设置，则不执行冗余检测。
* `sorter` – 用来为给定查询所匹配的数据进行排序。
* `local` – datums数组或返回datums数组的函数。
* `prefetch` – 可以是包含datums数组的JSON文件的URL，更多信息，参考[prefetch]哈希选项。
* `remote` – 当`local`和`prefetch`提供的数据不充分，或需要更多的可配置性时，用来从远程获取建议的URL。

<!-- section links -->

[compare function]: <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort>

### Prefetch

在初始化过程中，预取并处理数据。如果浏览器支持本地存储，处理数据将被缓存，从而避免后续页面加载中额外的网络请求。

**警告** 尽管小数据集可以不用预取缓存，并且预取不意味着包含整个数据集。相反的，需将其看作推荐的一级缓存。如果不谨记在心，可能会触及本地缓存限制。

当配置`prefetch`时，如下选项亦可用:

* `url` – 链接到包含datums数组的JSON文件的URL。**必须**
* `cacheKey` – 存储在本地的数据的key。默认为`url`的值
* `ttl` – 预取的数据缓存在本地存储中的时间(毫秒)，默认为`86400000` (1天)
* `thumbprint` – 用作预取数据的数据指纹。如果和本地缓存的数据不匹配，数据将会被重新获取
* `filter` – 将响应体转换成datums的数组的函数，其签名为`filter(parsedResponse)`，返回值为datums数组。
* `ajax` – 传递给`jQuery.ajax`的ajax设置

<!-- section links -->

[local storage limits]: http://stackoverflow.com/a/2989317
[ajax settings object]:http://api.jquery.com/jQuery.ajax/#jQuery-ajax-settings

### Remote

远程数据仅在`local`和`prefetch`提供的数据不充分时，才会使用。为了避免到远程端过于繁琐的请求数，请求被限速了。

当配置`remote`时，如下的选项是可用的: 

* `url` – 当`local`和`prefetch`的数据不足时，发出请求的URL。**必须**
* `wildcard` - `url`中的模式，当发出请求时，将会被替换为用户的查询。默认为`%QUERY`
* `replace` – 用来覆盖请求URL的函数, 其方法签名为`replace(url, query)`，返回值为一合法的URL。如果设置，将不对URL执行任何替换？
* `rateLimitBy` – 该方法用来实时显示网络请求数目。其值为`debounce`或`throttle`，默认为`debounce`。
* `rateLimitWait` – `rateLimitBy`所使用的时间间隔(毫秒)，默认为`300`
* `filter` – 将响应体转换为数组datums的函数，其方法签名为`filter(parsedResponse)`，返回值为datums数组
* `ajax` – 传给`jQuery.ajax`ajax设置对象

<!-- section links -->

[ajax settings object]: http://api.jquery.com/jQuery.ajax/#jQuery-ajax-settings

### Datums

Datums are JavaScript objects that hydrate the pool of possible suggestions.
Bloodhound doesn't expect datums to contain any specific properties as any
operations performed on datums are done using functions defined by the user i.e.
`datumTokenizer`, `dupDetector`, and `sorter`.

### Tokens

The algorithm used by bloodhounds for providing suggestions for a given query 
is token-based. When `Bloodhound#get` is called, it tokenizes `query` using 
`queryTokenizer` and then invokes `cb` with all of the datums that contain those 
tokens.

For a quick example, if a datum was tokenized into the following set of 
tokens...

```javascript
['typeahead.js', 'typeahead', 'autocomplete', 'javascript'];
```

...it would be a valid match for queries such as:

* `typehead`
* `typehead.js`
* `autoco`
* `java type`

## typeahead

typeahead.js的UI组件是一个jQuery插件，其负责渲染建议并处理DOM交互。其特性如下: 

* 在用户输入时，显示建议
* 将顶层推荐显示为hint(例如，背景文字)
* 支持可定制的模板
* 同RTL语言和输入编辑器工作良好
* 高亮匹配的查询
* 触发定制事件

### 规范

为了最大程度的利用用户现有的关于typeahead.js的知识，typeahead.js UI的行为是仿照谷歌的搜索框。下面的伪代码，介绍UI界面如何处理相关事件的。

预输入需要考虑的事件有: 聚焦是失焦，值的改变，方向键，Tab键，Esc键

**输入控件聚焦**

```
activate typeahead  //激活typeahead
```

**输入控件失去焦点**

```
deactivate typeahead //失效typeahead
close dropdown menu  //关闭下拉菜单
remove hint          //移除hint
clear suggestions from dropdown menu //清理下拉菜单中的推荐
```

**输入控件中的值的改变**

```
IF query satisfies minLength requirement THEN  //查询满足最小长度需求
  request suggestions for new query            //为新的查询请求推荐

  IF suggestions are available THEN  
    render suggestions in dropdown menu
    open dropdown menu 
    update hint
  ELSE
    close dropdown menu 
    clear suggestions from dropdown menu
    remove hint
  ENDIF
ELSE
  close dropdown menu 
  clear suggestions from dropdown menu
  remove hint
ENDIF
```

**按下Up键**

```
IF dropdown menu is open THEN
  move dropdown menu cursor up 1 suggestion
ELSE
  request suggestions for current query

  IF suggestions are available THEN
    render suggestions in dropdown menu
    open dropdown menu 
    update hint
  ENDIF
ENDIF
```

**按下Down键**

```
IF dropdown menu is open THEN
  move dropdown menu cursor down 1 suggestion
ELSE
  request suggestions for current query

  IF suggestions are available THEN
    render suggestions in dropdown menu
    open dropdown menu 
    update hint
  ENDIF
ENDIF
```

**左箭头按下**

```
IF detected query language direction is right-to-left THEN
  IF hint is being shown THEN
    IF text cursor is at end of query THEN
      autocomplete query to hint
    ENDIF
  ENDIF
ENDIF
```

**右箭头按下**

```
IF detected query language direction is left-to-right THEN
  IF hint is being shown THEN
    IF text cursor is at the end of the query THEN
      autocomplete query to hint
    ENDIF
  ENDIF
ENDIF
```

**按Tab键**

```
IF dropdown menu cursor is on suggestion THEN
  close dropdown menu
  update query to display key of suggestion
  remove hint
ELSIF hint is being shown THEN
  autocomplete query to hint
ENDIF
```

**Enter按键**

```
IF dropdown menu cursor is on suggestion THEN
  close dropdown menu
  update query to display key of suggestion
  remove hint
  prevent default browser action e.g. form submit
ENDIF
```

**Esc按键**

```
close dropdown menu
remove hint
```

**点击推荐项**

```
update query to display key of suggestion
close dropdown menu
remove hint
```

### API

* `jQuery#typeahead(options, [\*datasets])`

Turns any `input[type="text"]` element into a typeahead. `options` is an 
options hash that's used to configure the typeahead to your liking. Refer to 
[Options](#options) for more info regarding the available configs. Subsequent 
arguments (`*datasets`), are individual option hashes for datasets. For more 
details regarding datasets, refer to [Datasets](#datasets).

将任何`input[type="text"]`元素转换成typehead。`options`参数hash将typeahead配置为你所喜欢的，`*datasets`参数是配置数据集的独立选项hash。更多关于选项的信息参考下文。

```javascript
$('.typeahead').typeahead({
  minLength: 3,
  highlight: true,
},
{
  name: 'my-dataset',
  source: mySource
});
```

* `jQuery#typeahead('destroy')` 移除typeahead功能，并将`input`元素的状态重置为原始状态。

```javascript
$('.typeahead').typeahead('destroy');
```

* `jQuery#typeahead('open')` 打开typeahead下拉菜单。 注意，打开菜单不意味着菜单可见。仅当其打开并存在内容时，菜单才可见。

```javascript
$('.typeahead').typeahead('open');
```

* `jQuery#typeahead('close')` 关闭typeahead的下拉菜单。

```javascript
$('.typeahead').typeahead('close');
```

* `jQuery#typeahead('val')` 返回typeahead的当前值，该值为用户输入到`input`元素中的文本。

```javascript
var myVal = $('.typeahead').typeahead('val');
```

* `jQuery#typeahead('val', val)` 设置typeahead的值，要来替代`jQuery#val`函数。

```javascript
$('.typeahead').typeahead('val', myVal);
```

* `jQuery.fn.typeahead.noConflict()` 返回typeahead插件的引用，并将`jQuery.fn.typeahead`重置为先前值。这可以用来避免命名冲突。

```javascript
var typeahead = jQuery.fn.typeahead.noConflict();
jQuery.fn._typeahead = typeahead;
```

### 选项(Options)

当初始化typeahead时，存在如下的可配置的选项:

* `highlight` – 设置为`true`时，当建议渲染时，在文本节点中，匹配查询模式的文字将被带有`tt-highlight` class的`strong`元素包裹。默认设置为`false`。
* `hint` – 设置为`false`时，typeahead 将不会显示hint。默认为`true`.
* `minLength` – 推荐引擎开始渲染所需要的最小字符。默认为 `1`.

### 数据集(Datasets)

A typeahead is composed of one or more datasets. When an end-user modifies the
value of a typeahead, each dataset will attempt to render suggestions for the
new value. 

`typeahead`可以由一个或多个数据集组成。但用户修改typeahead的值时，每个数据集都会

For most use cases, one dataset should suffice. It's only in the scenario where
you want rendered suggestions to be grouped in the dropdown menu based on some 
sort of categorical relationship that you'd need to use multiple datasets. For
example, on twitter.com, the search typeahead groups results into recent 
searches, trends, and accounts – that would be a great use case for using 
multiple datasets.

Datasets can be configured using the following options.

* `source` – The backing data source for suggestions. Expected to be a function 
  with the signature `(query, cb)`. It is expected that the function will 
  compute the suggestion set (i.e. an array of JavaScript objects) for `query` 
  and then invoke `cb` with said set. `cb` can be invoked synchronously or 
  asynchronously. A Bloodhound suggestion engine can be used here, to learn 
  how, see [Bloodhound Integration](#bloodhound-integration). **Required**.

* `name` – The name of the dataset. This will be appended to `tt-dataset-` to 
  form the class name of the containing DOM element.  Must only consist of 
  underscores, dashes, letters (`a-z`), and numbers. Defaults to a random 
  number.

* `displayKey` – For a given suggestion object, determines the string 
  representation of it. This will be used when setting the value of the input
  control after a suggestion is selected. Can be either a key string or a 
  function that transforms a suggestion object into a string. Defaults to 
  `value`.

* `templates` – A hash of templates to be used when rendering the dataset. Note
  a precompiled template is a function that takes a JavaScript object as its
  first argument and returns a HTML string.

  * `empty` – Rendered when `0` suggestions are available for the given query. 
  Can be either a HTML string or a precompiled template. If it's a precompiled
  template, the passed in context will contain `query`.

  * `footer`– Rendered at the bottom of the dataset. Can be either a HTML 
  string or a precompiled template. If it's a precompiled template, the passed 
  in context will contain `query` and `isEmpty`.

  * `header` – Rendered at the top of the dataset. Can be either a HTML string 
  or a precompiled template. If it's a precompiled template, the passed in 
  context will contain `query` and `isEmpty`.

  * `suggestion` – Used to render a single suggestion. If set, this has to be a 
  precompiled template. The associated suggestion object will serve as the 
  context. Defaults to the value of `displayKey` wrapped in a `p` tag i.e. 
  `<p>{{value}}</p>`.

### Custom Events

The typeahead component triggers the following custom events.

* `typeahead:opened` – Triggered when the dropdown menu of a typeahead is 
  opened.

* `typeahead:closed` – Triggered when the dropdown menu of a typeahead is 
  closed.

* `typeahead:cursorchanged` – Triggered when the dropdown menu cursor is moved
  to a different suggestion. The event handler will be invoked with 3 
  arguments: the jQuery event object, the suggestion object, and the name of 
  the dataset the suggestion belongs to.

* `typeahead:selected` – Triggered when a suggestion from the dropdown menu is 
  selected. The event handler will be invoked with 3 arguments: the jQuery 
  event object, the suggestion object, and the name of the dataset the 
  suggestion belongs to.

* `typeahead:autocompleted` – Triggered when the query is autocompleted. 
  Autocompleted means the query was changed to the hint. The event handler will 
  be invoked with 3 arguments: the jQuery event object, the suggestion object, 
  and the name of the dataset the suggestion belongs to. 

All custom events are triggered on the element initialized as a typeahead.

### Look and Feel

Below is a faux mustache template describing the DOM structure of a typeahead 
dropdown menu. Keep in mind that `header`, `footer`, `suggestion`, and `empty` 
come from the provided templates detailed [here](#datasets). 

```html
<span class="tt-dropdown-menu">
  {{#datasets}}
    <div class="tt-dataset-{{name}}">
      {{{header}}}
      <span class="tt-suggestions">
        {{#suggestions}}
          <div class="tt-suggestion">{{{suggestion}}}</div>
        {{/suggestions}}
        {{^suggestions}}
          {{{empty}}}
        {{/suggestions}}
      </span>
      {{{footer}}}
    </div>
  {{/datasets}}
</span>
```

When an end-user mouses or keys over a `.tt-suggestion`, the class `tt-cursor` 
will be added to it. You can use this class as a hook for styling the "under 
cursor" state of suggestions.

## Bloodhound Integration

Because datasets expect their `source` to be a function, you cannot directly
pass a Bloodhound suggestion engine in as `source`. Rather, you'll need to 
pass the suggestion engine's typeahead adapter:

```javascript
var engine = new Bloodhound({ /* options */ });

engine.initialize();

$('.typeahead').typeahead(null, {
  displayKey: myDisplayKey // if not set, will default to 'value',
  source: engine.ttAdapter()
});
```

## 小结

看完之后，觉得预输入这种东西，还真是强大的不得了啊，需要监听的事件不少啊。自己结合这jquery ui的autocomplete的实现实在是太挫了。
