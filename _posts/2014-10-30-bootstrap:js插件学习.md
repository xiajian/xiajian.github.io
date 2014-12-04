---
layout: post
title: Bootstrap:JS插件学习
category : javascript
---

由于，自己的Jekyll博客上，使用了Bootstrap，所以，想要学习并了解Bootstrap相关的js插件，然后，有空给自己的博客添加一些动态效果。注意：boostrap中的js插件并不需要额外的引入新的js文件，而是其boostrap.js中本身就包含了这些js插件。插件的调用也非常的简单，通常只要设置一下data属性即可，感觉相当的方便

## 概述

Bootstrap的js插件可以逐个引入，也可以一起全部引入。一些使用建议: 

* 使用压缩的js文件
* 组件的data属性: 不要在同一元素叠太多插件属性
* 注意插件之间的依赖关系

插件的使用，除了使用data api，还可以使用js api。js api接受options的js对象作为参数，不提供时使用默认值。插件通过`Constructor`属性暴露其原始构造函数: `$.fn.popover.Constructor`(其中popover是插件名)。插件实例的获取: `$('[rel="popover"]').data('popover')`，其中，`popover`为插件的名字。

插件可以通过修改自身`Constructor.DEFAULTS`对象，从而改变插件的默认设置。通过`.noConflict`方法避免命名冲突。Boostrap的大多数插件提供自定以事件，事件动词原型表示时间开始时触发，过去式表示动作执行后触发。bs 3.0后，使用的命名空间的方式。

`<noscript>`标签向用户解释如何启用js。

## 过度效果：transition.js

只需要简单的引入，是对css过度效果的模拟，也被用来检测当前浏览器对css过渡效果是否支持。 还有就是可以用作其他的插件中使用的效果。

## 模态框：modal.js

通过设定：

-  data-toggle="modal"设定模态操作
-  data-target="选择器"设定对应操作的模态DOM
-  href="选择器"即可

可访问性：

-  role="dialog"
-  aria-labelledby="id"对话框标题
-  aria-describedby="id"对话框描述信息
-  aria-hidden="true"忽略该DOM元素

js调用：

```javascript
$('选择器').modal(option|string);
```

option：

-  backdrop：背景遮罩层 true：显示背景遮罩层 false：关闭背景遮罩层
-  static：显示北京遮罩层，并且点击层不关闭模态对话框
-  keyboard：用esc关闭模态框 true：启用 false：关闭
-  show：初始化后显示模态框 true：启用 false：暂不显示
-  remote：读取异步页面数据 false：不读取
-  string： toggle：启动或者关闭模态框 show：启动模态框 hide：关闭模态框

事件：

-  show.bs.modal:启用模态框前
-  shown.bs.modal:启用模态框后
-  hide.bs.modal:关闭模态框前
-  hidden.bs.modal:关闭模态框后

存在的问题就是，可能不支持ajax请求填充内容。这一点，可以通过<https://github.com/jschr/bootstrap-modal>进行扩展。

## 下拉菜单：dropdown.js

> 可以为所有东西添加下拉菜单：导航条，标签页，胶囊式按钮

HTML：

-  在需要显示下拉菜单的元素后添加

通过设定：

- data-toggle="dropdown"设定下拉框操作
- data-target="#"用来保证连接的可访问性，替代href="#"

可访问性：

- role="menu"

js调用：

```javascript
$('选择器').dropdown(string);
```

string:

- toggle：打开或者关闭下拉菜单

事件：

-  show.bs.dropdown:启用下拉菜单前
-  shown.bs.dropdown:启用下拉菜单后
-  hide.bs.dropdown:关闭下拉菜单前
-  hidden.bs.dropdown:关闭下拉菜单后

## 滚动监听：scrollspy.js

通过设定：

*  data-spy="scroll"添加监听功能
*  data-target="选择器"为Bootstrap中.nav组件的父元素
*  导航内的链接#xxx,页面必须存在与该锚点相同id的DOM元素

js调用：

```javascript
$('选择器').scrollspy(option|string);
```

选项：

* target：监听所对应的对象
* offset：从上滚动的偏移量，可以设置在data-offset
* string：
  * refresh：每当页面中增加删除页面元素时，都需要调用该操作

事件：

*  activate.bs.scrollspy:当滚动监听到某个元素为active时

## 标签页：tab.js

HTML：

-  为ul添加.nav .nav-tabs即可赋予Bootstrap的标签页样式
-  为ul添加.nav .nav-pills即可赋予Bootstrap的胶囊式标签页样式
-  切换的内容包裹在<div class="content"></div>
-  每个内容添加.tab-pane
-  添加.fade开启淡入特效
-  添加.in让初始化时具有淡入特效

通过设定：

* data-toggle="tab"为该元素绑定标签功能
* data-toggle="pill"为该元素绑定标签功能
* 导航内的连接为#xxx,必须存在与该锚点相同id的DOM元素，并且在tab-content内

js调用：

```javascript
$('选择器').tab(string);
$('#myTab a[href="#profile"]').tab('show') // Select tab by name
$('#myTab a:first').tab('show') // Select first tab
$('#myTab a:last').tab('show') // Select last tab
$('#myTab li:eq(2) a').tab('show') // Select third tab (0-indexed)
```
其参数字符串:

-  show：激活单独标签页

事件：

-  show.bs.tab:激活单独标签页前
-  shown.bs.tab:激活单独标签页后

## 工具提示：tooltip.js

tooltip.js的data-api需要单独初始化。注：提示类的插件需要仔细学习认证学习一下。确实，存在一些需要提示功能的地方。

注：

*  btn-group或input-group内的元素，需要添加container:'body'
*  disabled元素需要包裹在<div>中，然后对该div使用提示

js调用：

```javascript
$('选择器').tooltip(option|string);
```

option:

    animation：开启过度动画
        true：开启
        false：关闭
    html：添加html提示，false会调用jQuery的text方法添加内容（如果担心XSS攻击使用text）
        true：开启
        false：关闭
    placement：提示位置
    top,bottom,left,right:定位
    auto：动态设置：auto left
    selector：选择器
        false：为当前元素
    selector：以该元素为对象显示tooltip
    title：设置title，如果默认title属性没有设置则调用该值
    trigger：触发事件,可以设置多个触发事件，用空格连接
        click|hover|focus|manual：该事件触发tooltip显示
    delay：显示和隐藏的延迟时间，默认是0
    container：将tooltip添加到该元素内
        false：当前元素
    string:
        toggle：启动或者关闭提示
        show：启动提示
        hide：关闭提示
        destroy：关闭并销毁提示

事件：

*  show.bs.tooltip:在显示提示前
*  shown.bs.tooltip：在显示提示后
*  hide.bs.tooltip:在关闭提示前
*  hide.bs.tooltip:在关闭提示后

## 弹出框：popover.js

与tooltip.js类似，data-api需要单独初始化）

依赖：依赖于tooltip.js插件

注：

*  btn-group或input-group内的元素，需要添加container:'body'
*  disabled元素需要包裹`<div>`在中，然后对该div使用提示

js调用：

```javascript
$('选择器').popover(option|string);
```

选项:

    animation：开启过度动画
        true：开启
        false：关闭
    html：添加html提示，false会调用jQuery的text方法添加内容（如果担心XSS攻击使用text）
        true：开启
        false：关闭
    placement：提示位置
        top,bottom,left,right:定位
    auto：动态设置：auto left
    selector：选择器
        false：为当前元素
    selector：以该元素为对象显示tooltip
    title：设置title，如果默认title属性没有设置则调用该值
    trigger：触发事件,可以设置多个触发事件，用空格连接
        click|hover|focus|manual：该事件触发tooltip显示
    delay：显示和隐藏的延迟时间，默认是0
    container：将tooltip添加到该元素内
        false：当前元素
    string:
        toggle：启动或者关闭提示
        show：启动提示
        hide：关闭提示
        destroy：关闭并销毁提示

事件：

*  show.bs.popover:在显示弹出前
*  shown.bs. popover ：在显示弹出后
*  hide.bs. popover :在关闭弹出前
*  hide.bs. popover :在关闭弹出后

## 警告框：alert.js

HTML：

*  为警告框添加动画效果
*  添加.fade开启淡入特效
*  添加.in让初始化时具有淡入特效

通过设定：

    data-dismiss="alert"为警告框添加关闭功能

js调用：

```javascript
$('选择器').alert(string);
```
    为所有警告框添加关闭功能

string：

    close：关闭警告框

事件：

*  close.bs.alert：关闭警告框前
*  closed.bs.alert：关闭警告框后

## 按钮：button.js

    （完善按钮的状态控制）

注：

    添加autocomplete="off"解决火狐的按钮自动禁用的状态

通过设定：

    加载状态：data-loading-text='加载文字'，按钮设置为禁用状态，并将文字切换为加载文字
    状态切换：data-toggle="button"，按钮可以通过点击切换状态

对于单选和多选控件：

    将其包裹在<div class="btn-group" data-toggle="buttons"></div>中
    并对将input包裹在<label class="btn btn-primary"></label>

js调用：

```
$('选择器').button(string);
```

string:

*  toggle：开启或者关闭按钮状态
*  loading：将按钮设定为加载状态
*  reset：重置按钮状态
*  string：重置按钮状态，并设定按钮文本为传入值

## 折叠：collapse.js

支持折叠功能的组件，添加样式和灵活的支持：accordions和导航。

依赖：依赖于transition.js

通过设定：

*  data-toggle="collapse"开启折叠页面元素的能力
*  data-target="选择器"
*  href="选择器"也可
*  为可折叠的页面元素添加collapse
*  data-parent="选择器"，实现切换折叠效果，赋予统一的父元素

js调用：

```javascript
$('选择器').collapse(option|string);
```

option：

    parent：实现切换折叠效果，赋予统一的父元素
    toggle：是否开启折叠效果
        true：开启
        false：不开启
    string：
        toggle：切换折叠状态
        show：展开该元素
        hide：隐藏该元素

事件：

* show.bs.collapse:折叠显示前
* shown.bs.collapse:折叠显示后
* hide.bs.collapse:折叠隐藏前
* hidden.bs.collapse:折叠隐藏后

## 轮播：carousel.js

**注**： IE8/9不支持过度动画效果

HTML：

```html
<div class="carousel slide">
  <div class="carousel-inner">
    <div class="item"><img alt="" /></div>
    </div>
  </div>
</div>
<div class="carousel-caption"></div>
```

通过设定：

*  data-ride="carousel":启动轮播功能
*  data-target="选择器"设定操作轮播的对象
*  href=

左右控件：

* data-slide="prev"绑定左切换
* data-slide="next"绑定右切换

单项切换：

*  dataslide-to="int"从0开始，绑定每个元素
*  active：当前激活样式

js调用：

```javascript
$('选择器').carousel(option|string);
```

option:

    interval:轮换等待事件，默认：5000(ms)
        false:不自动开始循环
    pause：暂停的触发事件
    hover：鼠标停留则暂停，离开则启动
    wrap：是否持续循环
        true：开启
        false：关闭
    string：
        cycle：从左到右循环
        pause：暂停轮播
        number：指定到对应帧，从0开始
            prev：返回到上一帧
            next：转到下一帧

事件：

*  slide.bs.carousel:切换前调用
*  slid.bs.carousel:播放完成后调用

## 页面定位：affix.js

尝试使用了一下，没能做到自己想要的效果，稍微感觉有点沮丧。

通过设定：

*  data-spy="affix" 开启affix
*  data-offset-top="200" 定位浮动

注：

*  需要设定affix，affix-top，affix-bottom3种状态的样式，插件不设定
*  affix是正常时的样式，fixed定位
*  affix-top是初始状态的样式
*  affix-bottom是停止时的样式，absolute定位

js调用：

```javascript
$('选择器').affix(option);
```

选项: offset:{top:,bottom:}

## 参考文献

[1]. <http://www.ueffort.com/bootstrap-js-cha-jian-xue-xi/>
[2]. <http://www.bootcss.com/>
