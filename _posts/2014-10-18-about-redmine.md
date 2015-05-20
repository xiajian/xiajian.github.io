---
layout: post
title: 关于Redmine
---

## 前提
----
其实，10月18号那天，根本没有写任何一个字。只是，一直在看着动漫而已。那天中午，吃了一顿非常难吃的午饭，是在易捷买的，12块9，非常的难吃。

## 简介
Redmine是一个项目管理软件。其安装依赖如下的软件: 

* Ruby 1.8.7, 1.9.2, 1.9.3 or 2.0.0
* RubyGems
* Bundler `>= 1.0.21`
* 数据库：MySQL, PostgreSQL, SQLite3, SQLServer
* 可选的: 源代码控制软件(代码库浏览)和ImageMagick(导出甘地图)

## 安装

前提条件:

* 解压的redmine程序代码
* 空的UTF8编码的名为"redmine"的数据库

安装步骤:

* 配置config/database.yml中的数据库参数
* 安装所需的gem包: `bundle install --without development test` - 仅安装生产过程中需要的gem包  
**注意**: 
   -  在修改config/database.yml中的数据库适配器驱动，别忘了重新运行`bundle install`
   -  如果没有安装ImageMagick，则可以跳过rmagick的安装

* 生成会话存储的密码: `rake generate_secret_token`。这是由于Redmine默认将会话数据存放在cookies中
* 创建数据库结构: `rake db:migrate RAILS_ENV="production"`，将会创建所有的表和管理员账户(admin/admin)。
* 设置权限: 运行Redmine的用户必须具有写如下文件的权限: files, log, tmp, public/plugin_assets

        sudo chown -R redmine:redmine files log tmp public/plugin_assets
        sudo chmod -R 755 files log tmp public/plugin_assets

此时，安装已经完成，可以通过运行服务来测试安装，一旦web服务器启动了，可以通过<http://localhost:3000/>使用Redmine了。

可以通过编辑config/configuration.yml文件来调整SMTP设置。

## 问题

尝试安装了一下Redmine的开发环境，一些步骤记录如下： 

* 设置datebase.yml中的mysql的数据库名和密码
* bundle
* `mysql -u root -p`进入mysql控制台，创建数据库`redmine_development(create database redmine_development`)
* 运行rake db:migrate, 恢复数据库
* `rake generate_secret_token` 生成会话token，其中`generate_session_store`已被遗弃

至此，基本的环境已经搭建完成了。

测试注册，创建用户：jhqy2011@sina.com ，密码：8个1。

出现的问题： 

*  安装rmagick失败，解决方案：`sudo apt-get install imagemagick libmagickwand-dev`
*  运行rails server和rake db:migrate出错，原因是缺乏数据库。`mysql -u root -p`进入控制台，创建数据库`redmine_development(create database redmine_development`)。
*  注册完成之后，发现一个问题：**Your account was created and is now pending administrator approval.** 寻找管理员账户，后来，在doc目录中的install中找到管理员的用户名和密码：admin-admin。


        use redmine_development;
        show tables;
        显示的表名如下: 
        +-------------------------------------+
        | Tables_in_redmine_development       |
        +-------------------------------------+
        | attachments                         |
        | auth_sources                        |
        | boards                              |
        | changes                             |
        | changeset_parents                   |
        | changesets                          |
        | changesets_issues                   |
        | comments                            |
        | custom_fields                       |
        | custom_fields_projects              |
        | custom_fields_roles                 |``
        | custom_fields_trackers              |
        | custom_values                       |
        | documents                           |
        | enabled_modules                     |
        | enumerations                        |
        | groups_users                        |
        | issue_categories                    |
        | issue_relations                     |
        | issue_statuses                      |
        | issues                              |
        | journal_details                     |
        | journals                            |
        | member_roles                        |
        | members                             |
        | messages                            |
        | news                                |
        | open_id_authentication_associations |
        | open_id_authentication_nonces       |
        | projects                            |
        | projects_trackers                   |
        | queries                             |
        | queries_roles                       |
        | repositories                        |
        | roles                               |
        | schema_migrations                   |
        | settings                            |
        | time_entries                        |
        | tokens                              |
        | trackers                            |
        | user_preferences                    |
        | users                               |
        | versions                            |
        | watchers                            |
        | wiki_content_versions               |
        | wiki_contents                       |
        | wiki_pages                          |
        | wiki_redirects                      |
        | wikis                               |
        | workflows                           |
        +-------------------------------------+


## 后记

使用.ruby-version和.ruby-gemset控制环境真是相当的方便。为了能够同时研究Redmine和Gitlab的源代码，但又要隔离彼此的gem包，使用rvm的gemsets处理，真是相当的便捷。

查看官方文档，然后安装，可以避免很多问题。
