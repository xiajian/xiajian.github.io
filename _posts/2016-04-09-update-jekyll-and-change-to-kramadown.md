---
layout: post
title: 切换 Markdown 处理器为 kramdown
description: 'payments rouge，jekyll, github-pages, kramdown'
category: note
---

## 前言

最近，推送博客后，总是收到如下的邮件： 

```
The page build completed successfully, but returned the following warning:

You are attempting to use the 'pygments' highlighter, which is currently unsupported on GitHub Pages. Your site will use 'rouge' for highlighting instead. To suppress this warning, change the 'highlighter' value to 'rouge' in your '_config.yml'. For more information, see https://help.github.com/articles/page-build-failed-config-file-error/#fixing-highlighting-errors.

GitHub Pages was recently upgraded to Jekyll 3.0. It may help to confirm you're using the correct dependencies:

 https://github.com/blog/2100-github-pages-now-faster-and-simpler-with-jekyll-3-0

```

期初，没在意，后来发现 6 月份就不支持 Redcarpet, 乘现在有时间，就改一下吧。

## 介绍

实际操作上，其实也没改多少。 主要就两个文件的修改： 

1. Gemfile

```yml
# 静态站点生成器: https://github.com/jekyll/jekyll
gem 'jekyll'  
gem 'jekyll-sitemap'  # 站点图分析
gem 'kramdown'        # markdown 解析器
gem 'jemoji'          # GitHub风格的表情符号插件, 看来没啥用
# 纯 Ruby 的语法高亮: https://github.com/jneen/rouge
# 解决需要依赖 python 的问题
gem 'rouge'

# https://github.com/github/pages-gem
gem 'github-pages'    # 配合和同步githu-pages 的配置
```


2. _config.yml

``` yml
# 高亮的语法处理配置
highlighter: rouge
markdown: kramdown

redcarpet:
  extensions: ["fenced_code_blocks", "tables", "highlight", "strikethrough"]
  
kramdown:
  input:         GFM
  auto_ids:      true
  auto_id_prefix: 'id-'
  syntax_highlighter: rouge
```

修改过程中，最痛苦的就是。原本使用 `Redcarpet`, 本地和远程的环境是同步的，现在，不同步了。 为此，添加 `gem 'github-pages'` 同步两者的环境。

使用了 github-pages, blog 项目的使用的总 gem， 从 46 到 54 个, 有机会看一研究看看。

```
Using RedCloth 4.2.9
Using i18n 0.7.0
Using json 1.8.3
Using minitest 5.8.4
Using thread_safe 0.3.5
Using tzinfo 1.2.2
Using activesupport 4.2.6
Using addressable 2.4.0
Using coffee-script-source 1.10.0
Using execjs 2.6.0
Using coffee-script 2.4.1
Using colorator 0.1
Using ffi 1.9.10
Using ethon 0.8.1
Using multipart-post 2.0.0
Using faraday 0.9.2
Using gemoji 2.1.0
Using net-dns 0.8.0
Using sawyer 0.7.0
Using octokit 4.3.0
Using public_suffix 1.5.3
Using typhoeus 0.8.0
Using github-pages-health-check 1.1.0
Using sass 3.4.22
Using jekyll-sass-converter 1.3.0
Using rb-fsevent 0.9.7
Using rb-inotify 0.9.7
Using listen 3.0.6  # 监听文件系统变化
Using jekyll-watch 1.3.1
Using kramdown 1.10.0
Using liquid 3.0.6
Using mercenary 0.3.6 # An easier way to build your command-line scripts in Ruby.
Using rouge 1.10.1
Using safe_yaml 1.0.4
Using jekyll 3.0.3
Using jekyll-coffeescript 1.0.1
Using jekyll-feed 0.4.0
Using jekyll-gist 1.4.0 # 配合 Github 的 Gist
Using jekyll-github-metadata 1.10.0
Using mini_portile2 2.0.0
Using nokogiri 1.6.7.2
Using html-pipeline 2.3.0
Using jekyll-mentions 1.1.2
Using jekyll-paginate 1.1.0
Using jekyll-redirect-from 0.10.0
Using jekyll-seo-tag 1.3.3
Using jekyll-sitemap 0.10.0
Using jekyll-textile-converter 0.1.0
Using jemoji 0.6.2
Using rdiscount 2.1.8
Using redcarpet 3.3.3
Using terminal-table 1.5.2
Using github-pages 68
Using bundler 1.10.6
``` 

还有一点，其实我，不太清楚高亮代码格式，到底是个啥玩意，什么构成原理，怎么整出来的。

## Jekyll 3.0 

Github 那篇申明表达了如下的一些信息： 

1. 统一了 markdown 生成器，kramdown 是其他 Markdown 的超集。
2. 统一了 语法高亮功能，不在依赖 Python 和 Pyments
3. Jekyll 3.0 渲染更快，支持增量构建，支持监控 Liquid 模板

总之， Github Pages 变得更快，更强，更直观。

PS: 更新了自己启动 jekyll 的 shell 函数:

```shell
function js() {
  if [[  $# ==  0  ]] ; then
     echo "默认执行"
     jekyll serve -w --incremental --profile
  else
     jekyll "$@"
  fi
}

```

## 后记

正是不知道未来会发生什么， 世界才会如此的吸引人。 比如，我今天把激荡三十年下卷看完了。 比如，我整了3个小时博客markdown 解析器的迁移，以及写这篇什么玩意。

## 参考

1. <http://rouge.jayferd.us/demo> - 高亮的代码语言的名字稍微有些差别

2. [Syntax Highlighting in Jekyll With Rouge](https://sacha.me/articles/jekyll-rouge/)

3. <http://noyobo.com/2014/10/19/jekyll-kramdown-highlight.html>

4. <http://blog.javachen.com/2015/06/30/jekyll-kramdown-config.html>

5. kramdown文档： <http://pikipity.github.io/blog/kramdown-syntax-chinese-1.html>