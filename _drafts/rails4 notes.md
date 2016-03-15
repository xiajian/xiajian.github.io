---
layout: post
title: Rails 4学习笔记
---

* rails new 创建一个rails项目 rails new blog --skip-test-unit
* rails server|s 启动服务器 rs
* rails console 开启控制台 rc

rails generate controller StaticPages home help --no-test-framework 使用 --no-test-framework 选项禁用rspec框架生成测试代码。另外Rails会调用underscore方法把驼峰式的命名修改为蛇底式。例如上面的StatiPages的控制器对应的文件名为：static_pages_controller.rb，这只是一个约定，在命令行中也可以使用蛇底式。

在生成错误的时候可以使用 rails destroy [controller|model|view] [controller_name] [action] [action...] 来删除指定的controller

rake 用来编译构建项目的一个工具，类似于unix下的make命令，可以用 rake -T 命令来查看有什么操作指令。

也可以查看指定的命令的帮助，例如：rake -T db

    rake about # List versions of all Rails frameworks and the...
    rake assets:clean # Remove old compiled assets
    rake assets:clobber # Remove compiled assets
    rake assets:environment # Load asset compile environment
    rake assets:precompile # Compile all the assets named in config.assets...
    rake db:create # Create the database from DATABASE_URL or conf...
    rake db:drop # Drops the database using DATABASE_URL or the ...
    rake db:fixtures:load # Load fixtures into the current environment's ...
    rake db:migrate # Migrate the database (options: VERSION=x, VER...
    rake db:migrate:status # Display status of migrations
    rake db:rollback # Rolls the schema back to the previous version...
    rake db:schema:cache:clear # Clear a db/schema_cache.dump file
    rake db:schema:cache:dump # Create a db/schema_cache.dump file
    rake db:schema:dump # Create a db/schema.rb file that can be portab...
    rake db:schema:load # Load a schema.rb file into the database
    rake db:seed # Load the seed data from db/seeds.rb
    rake db:setup # Create the database, load the schema, and ini...
    rake db:structure:dump # Dump the database structure to db/structure.sql
    rake db:version # Retrieves the current schema version number
    rake doc:app # Generate docs for the app -- also available d...
    rake log:clear # Truncates all *.log files in log/ to zero byt...
    rake middleware # Prints out your Rack middleware stack
    rake notes # Enumerate all annotations (use notes:optimize...
    rake notes:custom # Enumerate a custom annotation, specify with A...
    rake rails:template # Applies the template supplied by LOCATION=(/p...
    rake rails:update # Update configs and some other initially gener...
    rake routes # Print out all defined routes in match order, ...
    rake secret # Generate a cryptographically secure secret ke...
    rake stats # Report code statistics (KLOCs, etc) from the ...
    rake test # Runs test:units, test:functionals, test:integ...
    rake test:all # Run tests quickly by merging all types and no...
    rake test:all:db # Run tests quickly, but also reset db
    rake test:recent # Run tests for {:recent=>["test:deprecated", "...
    rake test:uncommitted # Run tests for {:uncommitted=>["test:deprecate...
    rake time:zones:all # Displays all time zones, also available: time...
    rake tmp:clear # Clear session, cache, and socket files from t...
        rake tmp:create # Creates tmp directories for sessions, cache, ...

    rails generate|g   生成器，可以以不同的指令生成不同形式的模板。

    Rails:
        assets
        controller
        generator
        helper
        integration_test
        jbuilder - json builder 
        mailer
        migration
        model
        resource
        scaffold
        scaffold_controller
        task

    Coffee:
        coffee:assets

    Jquery:
        jquery:install

    Js:
        js:assets

    TestUnit:
        test_unit:plugin

    bundle install：我们使用 -without production 禁止安装生产环境所需的 gem。这个选项会被记住，所以后续调用 Bundler 就不用再指定这个选项，直接运行 bundle install 就可以自动不安装生产环境所需的 gem.

    bundle 

安装ckedit步骤：

    加入gem

    gem 'ckeditor'
    gem 'paperclip' - 上传文件的处理

    生成文件
    rails generate ckeditor:install --orm=active_record --backend=paperclip

    配置 model 环境，打开 application.rb 加入下面
    config.autoload_paths += %W(#{config.root}/app/models/ckeditor)   # 加载路径

    在 routes 里面增加 路由
    mount Ckeditor::Engine => "/ckeditor"

    打开application.js 加入
    //= require ckeditor/init

更多内容请查看：https://github.com/galetahub/ckeditor

开发环境配置

    默认情况下Rails erb输出会转义html标签，如何在rails中不让html标签转义？
    答：使用raw 或者 html_safe  -  转义 html 

    如何过滤掉html、css、js标签？
    答案：可以是用SanitizeHelper，有如下方法：sanitize、strip_css、strip_links、strip_tags

    常用 rake 命令
    rake assets:precompile 编译静态资源文件
    rake routes 列出所有的restful route
    rake stats 查看当前工程情况
    rake secret 生成session 加密指纹 - 用在 devise 的 key

    Rails debug 
    增加下面的代码
    gem debugger
    rails s --debugger
    然后在需要debug的地方加上 debugger 就可以了。

    查看资源路径
    Rails.application.config.assets.paths

Helper 标签

    form_for
    link_to
    image_tag
    assets_tag

Gem命令

    清除老版本的gem
    gem cleanup  - rvm empty xx

    删除所有的已安装的gem
    for i in ‘gem list --no-versions’; do gem uninstall -aIx $i; done

软件安装
Mac 安装libxml2

brew install libxml2 libxslt # 解析库文件
brew link libxml2 libxslt 

MySQL安装：

sudo apt-get install mysql-server

修改密码

mysqladmin -u账号 -p老密码 password 新密码

设置编码格式

create database ``test`` default character set utf8;
PostgreSQL安装配置

http://dhq.me/mac-postgresql-install-usage
Heroku

删除数据库
heroku pg:reset
