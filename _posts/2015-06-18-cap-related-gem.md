---
layout: post
title:  "部署相关的 gemfile 分组"
description: "部署相关的 gemfile 的搜集和整理"
category: note
---

## 前言

1700 行的 gemfile 中，部署相关的贡献了一百多行。由于，个人之前经验告知，部署仅需要一个 gem 包(capistrano)，没想到，capistrano 周围存在着一坨小伙伴。

## 正文

部署相关的 gem 包，收藏如下: 

```
gem 'backup', '3.4.0'      # 为 UNIX-like 系统提供备份job的 DSL 的写法: https://github.com/backup/backup
gem 'cape'                 # 为 Rake 任务动态生成 cap 食谱: https://github.com/njonsson/cape
gem 'caphub'               # 为多重部署生成部署骨架: https://github.com/railsware/caphub
gem 'capistrano'           # https://github.com/capistrano/capistrano
gem 'capistrano-bundler'   # 为 cap3 提供 bundler 支持: https://github.com/capistrano/bundler
gem 'capistrano-calendar'  # 根据日历服务，创建部署事件: https://github.com/railsware/capistrano-calendar
gem 'capistrano-chruby'    # https://github.com/capistrano/chruby
gem 'capistrano_colors'    # 定制化部署的输出: https://github.com/stjernstrom/capistrano_colors

# 同步远程和本地的数据库: https://github.com/sgruhier/capistrano-db-tasks
gem 'capistrano-db-tasks', require: false

# 为部署中的每个环境添加带时间戳的 Git 标签: https://github.com/mydrive/capistrano-deploytags
gem 'capistrano-deploytags'

# 本地编译资源，然后上传到服务器上: http://www.rubydoc.info/gems/capistrano-precompile-on-local/0.0.2
# 使用本地编译资源的原因是，开发环境的机器使用的 ssh，要比服务器的速度快很多
gem 'capistrano-precompile-on-local'

# 在部署代码时，检测 git 的迁移: https://github.com/mydrive/capistrano-detect-migrations
gem 'capistrano-detect-migrations'

# 如果资源没有变化，则跳过资源编译: https://github.com/capistrano-plugins/capistrano-faster-assets
gem 'capistrano-faster-assets'

# 通过文本界面，来选择要部署的服务器https://github.com/qhwa/capistrano-hostmenu
gem 'capistrano-hostmenu', require: false

# 处理 cap 2.x 中多配置文件的问题: https://github.com/railsware/capistrano-multiconfig
gem 'capistrano-multiconfig'

# 利用 cap 来管理nginx: https://github.com/ivalkeen/capistrano-nginx
# nginx 不是需要 root 权限?
gem 'capistrano-nginx'

# 简单的通知hook: https://github.com/cramerdev/capistrano-notifier
gem 'capistrano-notifier'

# 给常规的部署任务打补丁: https://github.com/railsware/capistrano-patch
gem 'capistrano-patch'

# 为 cap 提供 deploy:pending 和 deploy:pending:diff 任务: 
# https://github.com/a2ikm/capistrano-pending
gem 'capistrano-pending', :require => false

# 为 cap3 提供 puma 的集成: https://github.com/seuros/capistrano-puma
gem 'capistrano3-puma' , group: :development

# 为 cap 提供 Rails 相关的任务的支持: https://github.com/capistrano/rails
gem 'capistrano-rails'

# 为 cap3 提供 rails 相关命令的集合: https://github.com/dei79/capistrano-rails-collection
gem 'capistrano-rails-collection'

# 添加远程的 Rails console: https://github.com/ydkn/capistrano-rails-console
gem 'capistrano-rails-console'

# rbenv的cap的支持: https://github.com/capistrano/rbenv
gem 'capistrano-rbenv'

# https://github.com/seuros/capistrano-sidekiq
gem 'capistrano-sidekiq', github: 'seuros/capistrano-sidekiq'

# https://github.com/tablexi/capistrano3-unicorn
gem 'capistrano3-unicorn'

# 自动检查本地版本库和远程版本库: https://github.com/railsware/capistrano-uptodate
gem 'capistrano-uptodate'

# rvm1.x 与 cap 的集成: https://github.com/rvm/rvm1-capistrano3
gem 'rvm1-capistrano3', require: false

# 对ssh 的包装的支持: https://github.com/capistrano/sshkit
gem 'sshkit'
```

后来，发现这些部署的工具，好像都用到了，虽然，有些觉得很奇怪，但是都用到了，和我之前的经验所有差别，人家说项目的复杂度不同。我觉得，我之前公司的项目也挺复杂的。

## 后记

相比关于可能大的层次的事情，新同事更关注的是，一切以完成任务优先，至于好了什么样的方法，怎么完成的，为何这样做，并不关心。

这就是所谓台面上的(四驱赛车，国内领先)和台面下的文化的区别。
