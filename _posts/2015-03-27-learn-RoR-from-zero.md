---
layout: post
title: "从零开始学习RoR"
description: "ruby, Rails，web框架"
category: note
---

## 前言

昨天，看到大豆芽的[《从零开始学会Ruby on Rails》](http://dadouya.coding.io/rubyonrails/2)，觉得很有意思，特地将其复制过来，用作反思列表。

## 正文

以下是其提供的步骤: 

1.  安装 Linux 或 Mac， 开发工具使用 Windows & Linux -> Sublime Text 2, Mac -> TextMate 2 当然你也可以用 Vim 或 Sublime text 2;
1.  安装 Ruby 和 Rails 开发环境可以按照这个流程：《[如何快速正确的安装 Ruby, Rails](http://ruby-china.org/wiki/install_ruby_guide)》;
1.  看完 http://guides.rubyonrails.org 这里有 繁体版本；
1.  通过学习 Rails Guides 实现一个博客系统，包涵完整的功能(包括 UI)，预计两周；
1.  从头到尾一字不漏的看完 《应用 Rails 进行敏捷 Web 开发》；
1.  回头审视之前的博客设计和《应用 Rails 进行敏捷 Web 开发》的区别，可以再重新搞个博客;
1.  看完 《[Getting Real](http://gettingreal.37signals.com/GR_chn.php)》,预计两个小时；
1.  搞明白 Gem, RVM, Bundler 是什么；
1.  看完 《Rework》；
1.  学习 Git, 上 http://github.com 并长期使用；
1.  看 http://railscasts.com 的视频教程，从 第一页 开始看，可以学到很多技巧，以免走弯路。

虽然，自己学了Ruby和Rails很长时间，期间干了各种各样的杂事。上面的这些列表中，有些已经一直在做，《Getting Real》和 http://railscasts.com 确实是个不错的资源。

## 错误

今天遇到一个错误，不小心在路由中加中一些重复，本地开发环境没有问题，部署到远程服务器上，直接就挂掉了。幸而使用capistrano的回滚操作，然后在本地staging环境下部署测试，
最后，找到了问题的原因。

## 后记

近来，自己所做的事，貌似有条理，实际上还是乱七八糟的。这可能也算是成长中的烦恼吧。索性，承认自己总是不会一次将事情做好，凡事都要反复个3-5遍。