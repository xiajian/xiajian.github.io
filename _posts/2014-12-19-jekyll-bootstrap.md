---
layout: post
title: "jekyll bootstrap使用"
description: "Jekyll bootstrap的使用，及其其间出现的问题"
---

## 前言

处于想要在特定的post中引入特定的js和css样式的原因，所以，想要深入了解一下Jekyll bootstrap以及jekyll。

## 正文

将Jekyll简介翻译完成，大概花费了好几天的上班时间。结果，原本想解决的问题，并没有找到在erb中的类似的解决方案。相反的，知道了某些
变量可直接在模板中使用，比如: page、post、content之流。

最后，我的问题通过一个折中的方法解决了： 在default模板中全局引入tagmanger.js以及css，然后，在YAML font Matter中，
设置页面特定的js。想想都觉得很恶心，但是自己有找不到更好的解决方法。对Jekyll的探索，就到此为止了，虽然很有趣，但
毕竟不是本分工作，留下些扩展点: 

* Liquild wiki: <https://github.com/Shopify/liquid/wiki>
* JB: <http://jekyllbootstrap.com/>
* Jekyll: <http://jekyllrb.com/>

## 后记

拖延，拖拉是我的毛病，我要专职去研究Ember.js，没空在拖拉了。
