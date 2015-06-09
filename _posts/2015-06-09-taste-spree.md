---
layout: post
title:  "尝试spree"
description: "开元的电商平台 spree 的尝试，顺便总结在某公司的体验"
category: note
---

## 前言

离开天厚后，加入了一个电商平台的公司。用上了 Mac 和 RubyMine(D版的)。 装了一周环境，复制了两天代码，感觉复制代码好无趣啊。去找了一下，相关的开源电扇平台。

## 介绍

仔细想想，电子商务的网站，随处可见。热拍，蜜桃，乐淘，一大坨，这个时代，电子商务，是不是太过火爆了。

我所知道的利用 Ruby 搭建电商的项目有: shopify, spree。网上建站买东西的项目: 友好速搭。 今天，我尝试一下 [spree](https://github.com/spree/spree)。 操作命令如下: 

```
rvm use 2.1.5@spree
gem install rails -v 4.2.1
gem install spree
gem install spree_cmd
rails -b new my_store
cd my_store &&  sed -i 's!https://rubygems.org!http://ruby.taobao.org!' Gemfile  # 利用 sed 将 gemfile 中 gem 包得源换为 ruby.taobao.org
# 最好在gemfile 中添加 `quest_assets` 和 `thin`
spree install -A
bundle install         # 非常的缓慢
rails g spree:install  # 
rs  -p 5000
firefox http://localhost:5000/ 和 http://localhost:5000/admin/
```

默认生成的管理员用户名和密码是: Email [spree@example.com],和 Password [spree123]。

感觉上，spree 做的还不错，界面干净整洁，还利用 bootstrap 做了自适应，也利用了各种型高级的 ui 工具库。 上图: 

<div class="pic">
  <img src="/assets/images/spree.png" alt="spree 主界面"/>
</div>

后台界面: 

<div class="pic">
  <img src="/assets/images/spree1.png" alt="spree 后台界面"/>
</div>


## 参考文献

1. [Spree 源码导读](https://ruby-china.org/topics/24472)
1. [Spree 官方](https://github.com/spree/spree)
