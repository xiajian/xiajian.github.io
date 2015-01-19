---
layout: post
title: jQuery-Autocomplete
---

## 前言

我原本指望typeahead能一劳永逸的解决自动补全的问题的，结果，太过复杂，即使看完文档，还是一头雾水。后来，某些人说，要统一全站的自动提示的功能。
其实，我之前就觉得这些预输入的提示有些问题，行为很怪异。刚好，想要避开jQuery-UI，所以，找了个新的插件: [jQuery-Autocomplete](https://github.com/devbridge/jQuery-Autocomplete)。

## 简介

Ajax Autocomplete for jQuery allows you to easily create autocomplete/autosuggest boxes for text input fields.

jQuery Ajax Autocomplete可以给文本输入框创建自动补全/自动推荐，其仅依赖jQuery。

> 提示输入方面的事，利用之前的代码就搞定，现在的问题就是要不要研究这个插件，研究还是不研究。

## API

使用方式: 

```javascript
$(selector).autocomplete(options); //为输入域启动自动补全
```

其中，`options`为一个对象字面值，为自动补全插件定义相关设置，具体的设置项如下: 

* `serviceUrl`: 服务器端URL，或者返回为服务器端URL的函数，如果提供了本地数据，则该选项是可选的。
* `ajaxSettings`: 任何可以配置jQuery Ajax请求的附加的[Ajax设置](http://api.jquery.com/jquery.ajax/#jQuery-ajax-settings)
* `lookup`: 推荐的查询的数据。可以是字符串数组或者`suggestion`字面值对象
    * `suggestion`: 带有如下格式的对象字面值`{ value: 'string', data: any }`.
* `lookupFilter`: 本地查询的过滤函数，其格式为`function (suggestion, query, queryLowerCase) {}`。默认实现为部分字符串匹配，区分大小写
* `lookupLimit`: 本地查询显示的最大结果数，默认情况下没有限制。
* `onSelect`: 当用户选择推荐项的回调函数`function (suggestion) {}`，回调函数中的`this`指向输入框元素(HtmlElement)
* `minChars`: 触发自动推荐的最小字符数，默认为`1`.
* `maxHeight`: 推荐框的最大高度(单位为像素)，默认为: `300`.
* `deferRequestBy`: 推迟ajax请求的毫秒数，默认为: `0`.
* `width`: 推荐框的最大宽度(单位为像素)，例如: 300. 默认为`auto`，即输入框的宽度。
* `params`: 传递给请求的附加参数，可选。
* `formatResult`: 用来格式化推荐容器中的推荐实体的定制化参数，函数原型为`function (suggestion, currentValue) {}`，可选。
* `delimiter`: 字符串或正则表达式，用来分割输入值，并将最后的部分用作推荐查询。在需要，填充以逗号分隔的输入值时，非常的有用。
  Useful when for example you need to fill list of  coma separated values.
* `zIndex`: 推荐容器的'z-index'属性，默认为: `9999`.
* `type`: 获取推荐的Ajax请求类型，默认为: `GET`.
* `noCache`: 表明是否缓存推荐结果的布尔值，默认为: `false`, 即缓存推荐结果。
* `onSearchStart`: `function (query) {}` 函数在ajax请求之前调用，`this`绑定为输入元素。
* `onSearchComplete`: `function (query, suggestions) {}` 函数在ajax请求之后调用，`this`绑定为输入元素。`suggestions`为包含结果的数组。
* `onSearchError`: `function (query, jqXHR, textStatus, errorThrown) {}` 在ajax请求失败之后调用，`this`绑定为输入元素。
* `onInvalidateSelection`: 在作出选择后，修改输入时调用，`this`绑定为输入元素。
* `triggerSelectOnValidInput`: Boolean value indicating if `select` should be triggered if it matches suggestion. Default `true`.
* `preventBadQueries`: Boolean value indicating if it shoud prevent future ajax requests for queries with the same root if no results were returned. E.g. if `Jam` returns no suggestions, it will not fire for any future query that starts with `Jam`. Default `true`. 
* `beforeRender`: `function (container) {}` called before displaying the suggestions. You may manipulate suggestions DOM before it is displayed.
* `tabDisabled`: 是否使用tab选择推荐项。默认为 `false`。
* `paramName`: 包含查询的请求参数名，默认为 `query`。
* `transformResult`: 在查询结构准备好之后调用，将结果转换为`response.suggestions`格式，函数原型为`function(response, originalQuery) {}`
* `autoSelectFirst`: if set to `true`, first item will be selected when showing suggestions. Default value `false`.
* `appendTo`: container where suggestions will be appended. Default value `document.body`. 可以为jQuery对象，选择符，或者html对象。确保为对象设置`position: absolute`或`position: relative`
* `dataType`: 从服务器端返回的数据类型。可以是'text'或者'jsonp'。如果使用`jsonp`，autocomplete将在回调函数中使用从服务器端返回的json对象。
* `showNoSuggestionNotice`: Default `false`.  不存在的匹配结果时，显示通知标签。
* `noSuggestionNotice`: Default `No results`. Text or htmlString or Element or jQuery object for no matching results label.
* `forceFixPosition`: Default: `false`. Suggestions are automatically positioned when their container is appended to body (look at `appendTo` option), in other cases suggestions are rendered but no positioning is applied.
   Set this option to force auto positioning in other cases.
* `orientation`: Default `bottom`. Vertical orientation of the displayed suggestions, available values are `auto`, `top`, `bottom`.
  If set to `auto`, the suggestions will be orientated it the way that place them closer to middle of the view port.
* `groupBy`: property name of the suggestion `data` object, by which results should be grouped.
* `preserveInput`: if `true`, input value stays the same when navigating over suggestions. Default: `false`.

自动补全实例拥有如下的方面: 

* `setOptions(options)`: 该方法可在任何时候更新选项，所有选项列出如上。
* `clear`: 清除推荐缓存以及当前的推荐结果。clears suggestion cache and current suggestions suggestions.
* `clearCache`: 清除推荐缓存
* `disable`: deactivate autocomplete.
* `enable`: activates autocomplete if it was deactivated before.
* `hide`: hides suggestions.
* `dispose`: destroys autocomplete instance. All events are detached and suggestion containers removed.

存在两种调用自动补全的方法，一种是直接在jQuery对象上调用，并方法名作为字符串字面值参数。如果方法有参数，则参数将在随后提供:

```javascript
$('#autocomplete').autocomplete('disable');
$('#autocomplete').autocomplete('setOptions', options);
```

Or you can get Autocomplete instance by calling autcomplete on jQuery object without any parameters and then invoke desired method.

或者，在jQuery对象上调用autcomplete获取补全实例，然后调用其方法。

```javascript
$('#autocomplete').autocomplete().disable();
$('#autocomplete').autocomplete().setOptions(options);
```

##Usage

Html:

```html
<input type="text" name="country" id="autocomplete"/>
```

Ajax lookup:

```javascript
$('#autocomplete').autocomplete({
    serviceUrl: '/autocomplete/countries',
    onSelect: function (suggestion) {
        alert('You selected: ' + suggestion.value + ', ' + suggestion.data);
    }
});
```

Local lookup (no ajax):

```javascript
var countries = [
    { value: 'Andorra', data: 'AD' },
    // ...
    { value: 'Zimbabwe', data: 'ZZ' }
];

$('#autocomplete').autocomplete({
    lookup: countries,
    onSelect: function (suggestion) {
        alert('You selected: ' + suggestion.value + ', ' + suggestion.data);
    }
});
```

## Styling

Generated HTML markup for suggestions is displayed bellow. You may style it any way you'd like.

生成的HTML内容显示如下，可以使用任意喜欢的样式: 

```html
<div class="autocomplete-suggestions">
    <div class="autocomplete-group"><strong>NHL</strong></div>
    <div class="autocomplete-suggestion autocomplete-selected">...</div>
    <div class="autocomplete-suggestion">...</div>
    <div class="autocomplete-suggestion">...</div>
</div>
```

样式的样例如下: 

```css
.autocomplete-suggestions { border: 1px solid #999; background: #FFF; overflow: auto; }
.autocomplete-suggestion { padding: 2px 5px; white-space: nowrap; overflow: hidden; }
.autocomplete-selected { background: #F0F0F0; }
.autocomplete-suggestions strong { font-weight: normal; color: #3399FF; }
.autocomplete-group { padding: 2px 5px; }
.autocomplete-group strong { display: block; border-bottom: 1px solid #000; }
```

## Response Format

Response from the server must be JSON formatted following JavaScript object:

服务器传递过来的响应必须是json格式的js对象: 

```javascript
{
    // Query is not required as of version 1.2.5
    "query": "Unit",
    "suggestions": [
        { "value": "United Arab Emirates", "data": "AE" },
        { "value": "United Kingdom",       "data": "UK" },
        { "value": "United States",        "data": "US" }
    ]
}
```

Data can be any value or object. Data object is passed to formatResults function 
and onSelect callback. Alternatively, if there is no data you can
supply just a string array for suggestions:

Data可以是任何值或者对象。Data对象将会传递给`formatResults`函数，以及`onSelect`回调函数。
如果，没有任何数据，可简单提供一个字符串的数组。


```json
{
    "query": "Unit",
    "suggestions": ["United Arab Emirates", "United Kingdom", "United States"]
}
```

## 非标准的查询/结果

如果ajax服务的期望查询使用不同的格式，并且返回数据也与标准响应不同，此时可以使用`paramName`和`transformResult`选项: 

```javascript
$('#autocomplete').autocomplete({
    paramName: 'searchString',
    transformResult: function(response) {
        return {
            suggestions: $.map(response.myData, function(dataItem) {
                return { value: dataItem.valueField, data: dataItem.dataField };
            })
        };
    }
})
```

## Grouping Results

如果希望结果以分组的形式显示，可以使用`groupBy`选项。例如，设置`groupBy: 'category'`，并提供如下的数据格式: 

```javascript
[
    { value: 'Chicago Blackhawks', data: { category: 'NHL' } },
    { value: 'Chicago Bulls', data: { category: 'NBA' } }
]
```

Results will be formatted into two groups **NHL** and **NBA**.

##Known Issues

如果使用了jQuery UI库，其中有一个名为`autocomplete`的插件。此时，可以使用当前的插件的别名`devbridgeAutocomplete`:

```javascript
$('.autocomplete').devbridgeAutocomplete({ ... });
```

## 后记

我把jQuery-ui中，除了autocomplete依赖的组件，其他的都去掉了。这是第一步，其次将其替换为devbridgeAutocomplete。
