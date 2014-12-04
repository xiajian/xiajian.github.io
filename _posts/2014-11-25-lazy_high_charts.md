---
layout: post
title: lazy_high_charts
---

## 前言

网站中的highchart的使用乱七八糟的，js的使用，ruby的gem包的使用，下决心整理一下。首先，从了解`lazy_high_charts`开始。

## LazyHighCharts

LazyHighCharts提供了简单且灵活的方法，从而在Ruby中使用HighCharts。其本身已在Rails，Sinatra中测试使用。

* github地址: <https://github.com/michelson/lazy_high_charts>
* highchart地址: <http://www.highcharts.com/>

### 安装

为了安装`lazy_high_charts`，需要在Gemfile中添加`gem 'lazy_high_charts'`，然后运行`bundle install`。

### 使用

使用主要是分为两块，一个是控制器中的代码，一个是view中的代码。

控制器中的代码样例为: 

```ruby
@chart = LazyHighCharts::HighChart.new('graph') do |f|
  f.title(:text => "Population vs GDP For 5 Big Countries [2009]")       # 参数赋值的另一种方法: f.options[:title][:text] 
  f.xAxis(:categories => ["United States", "Japan", "China", "Germany", "France"])
  f.series(:name => "GDP in Billions", :yAxis => 0, :data => [14119, 5068, 4985, 3339, 2656])
  f.series(:name => "Population in Millions", :yAxis => 1, :data => [310, 127, 1340, 81, 65])

  f.yAxis [
    {:title => {:text => "GDP in Billions", :margin => 70} },
    {:title => {:text => "Population in Millions"}, :opposite => true},
  ]

  f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical',)
  f.chart({:defaultSeriesType=>"column"})
end
```
> 思: 图标的绘制存在几个要素，标题、x轴和y轴，序列化的线。传递的参数就是一个巨大的选项hash数组。

视图中的代码:

```erb
<%= high_chart("some_id", @chart) %>
```

演示程序包含Nanoc App，Rails App和Sinatra App。升级js库使用`rake highcharts:update`, 其代码会自动从<http://code.highcharts.com/>中下载。

### demo研究

demo的地址: <https://github.com/xiaods/highcharts-bootstrap>

使用需要在application.js中添加如下的js:

```javascript
//= require highcharts/highcharts
//= require highcharts/highcharts-more
//= require highcharts/highstock
```

**注意**: 看样子highcharts和highstock似乎是不同的东西，搜了一下，知道用来设置并查看不同的效果。此外，英文版的

highcharts提供了折线图，饼图，多对称轴之类的功能。

demo应用程序中使用的gem包: 

* [rails_12factor](https://github.com/heroku/rails_12factor): 名字这么奇怪的gem包到底是啥，看起来好像和<http://12factor.net/>有关。此外，再次接触Heroku
* sass-rails, uglifier, coffee-rails 都是Sprockets相关的gem包
* [figaro](https://github.com/laserlemon/figaro): 简单，Heroku友好的Rails应用程序配置gem包
* [high_voltage](https://github.com/thoughtbot/high_voltage): 在Rails中包含静态页面
* puma和thin类似，都是web应用服务器
* [simple_form](https://github.com/plataformatec/simple_form): 表单的DSL，下一步的工作重点就是修改项目中的表单。
* development分组中, [hub](https://github.com/github/hub)的gem包没听说过，hub是添加了Github感知的git的命令行包装。没想到挺出名的，Github旗下的开源项目。

遇到问题:  File to import not found or unreadable: bootstrap-responsive

> 解决方案: bootstrap-sass的版本太高了，bootstrap-sass的3.xx的版本移除了bootstrap-responsive，所以需要使用2.xx的版本。Gemfile中精确的版本控制确实很重要。

经验: 遇到问题上Ruby China和Stackflow，bing搜索效果还可以，puma服务器性能不错-Tcp连接。

代码阅读经验: 

* affix 粘着位样式只能相对于页面的特定位置
* link_to的remote属性，可以远程请求js，link_to中的代码块设置的是其第一个属性 - 显示属性。
* 几个新的标签: header, main, footer, section等
* `high_stock`函数第一个参数是插入的div的id，远程插入div的js代码为: 

```javascript
# append默认是追加到dom元素的底部
$('#line_ajax').append("<%= escape_javascript(high_chart('chart_line_ajax', @chart)) -%>")
```

由于是demo，数据的构建是直接写在model中的。最大的收获就是，link_to中的remote属性，看起来是利用`data-remote`实现的。

觉的项目中的highchart使用乱糟糟的，决定升级一下lazy_high_charts，期望不要出什么差错。

问题: http://www.highcharts.com/errors/16 - 存在多个Highcharts。

> 解决: highcharts和highstock是两个不同的东西。high_stock对应highstock.js， high_chart对应highcharts.js/highcharts-more.js。

原生highchart的使用方法: Highcharts(使用`git grep`在代码库中查找)。data属性可以携带很多数据。
