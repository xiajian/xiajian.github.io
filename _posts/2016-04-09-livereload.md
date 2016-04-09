---
layout: post
title: 学习和使用 LiveReload
description: '网络，断网，ICMP'
category: note
---

## 前言

人呀，要是过分在细节上纠结, 就容易看不清楚远方。 蝇营狗苟，人生在世。还有有个积极的心态比较好。

昨天，看了《俺妹的 黑猫篇》， 高板京介最后还是和“黑猫”在一起了，还生了双胞胎女儿。尽管如此，我还是喜欢田村麻奈实，萌青梅竹马和平凡妹的属性。当然，琉璃酱也是非常的喜欢，毕竟 暗黑女神中二属性比较匹配。 不小心， 次元穿越了。。。

最近，次元穿越频繁发生，导致自己几乎不能思考了。 其实，就是漫画看过度了。在看 js 数据推送时， 偶然接触到了 websocket 。决心花点时间了解一下，看到socket 可以应用在 LiveReload 中，

## 介绍

官方地址： http://livereload.com

有 App 和 浏览器插件。

## 安装 和 使用

首先： 在项目中 `Gemfile` 添加： 

```
group :development do
  # https://github.com/guard/guard
  gem 'guard'
  # https://github.com/guard/guard-livereload
  gem 'guard-livereload', '~> 2.5', require: false
end
```

bundle 过后，然后，在项目根目录运行： `guard init livereload`

运行之后，启动 Guard server(通过 gurad 命令)，随后，安装浏览器插件。

浏览器插件 安装地址： http://livereload.com/extensions/ 

<https://addons.mozilla.org/en-US/firefox/addon/livereload/>

**备注**: 直接从官方地址中下载 xpi 文件安装，Firefox 验证不通过，不能安装。


## 实现

利用了某种监控文件变化 gem，监控特定文件，比如 css，js，将监听的变化已 websocket 的形式，发送给浏览器插件，浏览器自动刷新页面。
从而避免手动刷新。

Guard 的输出： 

```
16:41:59 - INFO - LiveReload is waiting for a browser to connect.
16:41:59 - INFO - Guard is now watching at '/Users/xiajian/works/test-weui'
[1] guard(main)> 16:42:20 - INFO - Browser connected.
16:42:37 - INFO - Reloading browser: app/views/sockets/index.html.slim
16:42:49 - INFO - Reloading browser: app/views/sockets/index.html.slim
17:31:19 - INFO - Reloading browser: app/views/sockets/index.html.slim
```

意料之外，情理之中的 websocket 的使用。由于都是开发者，其浏览器不可能是 IE 之流的

## 后记

正是不知道未来会发生什么， 世界才会如此的吸引人。