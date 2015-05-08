---
layout: post
title:  学习capistrano-resque
description: "capistrano和resque的结合，Capfile文件，部署相关"
---

## 前言

在学习启动邮件后台任务的过程中，处于对如下的代码的学习，进而想了解一下capistrano-resque这个gem包，以下是对其文档的学习。

```ruby
require "capistrano-resque"
role :resque_worker, "192.168.1.239"
role :resque_scheduler, "192.168.1.220"
set :workers, { "mailer,async_mailer" => 1,  # 1表示worker进程的数量
                "recommend_email_create,recommend_email_send,sitemap_refresh,email_login_notice, email_month_notice" => 1
              }
              
before "deploy:restart", "resque:restart"
before "deploy:restart", "resque:scheduler:restart"
```
## 使用capistrano-resque

capistrano-resque 将在Cap中增加基本的Resque任务。完全兼容Capistrano 2.x和3.x。 当前版本，支持Resque 1.x, 对Resque 2.0的支持，依然在工作中。

在Gemfile中，添加`gem "capistrano-resque", "~> 0.2.2", require: false`。

在`lib/tasks`，需要需要确保应用已经包含了Resque的rake任务。例如，需要在`lib/tasks`中的任意文件，比如`lib/tasks/resque.rake`，添加`require 'resque/tasks'`。

在Capfile中，在capistrano自生的require/load语句(特别是`load 'deploy'`)之后，添加如下行: 

```
require "capistrano-resque" 
```

在`deploy.rb`文件中，添加如下内容: 

```
role :resque_worker, "app_domain"
role :resque_scheduler, "app_domain"

set :workers, { "my_queue_name" => 2 }
```

可以指定多个队列，以及每个队列的worker进程的数量: 

```
set :workers, { "archive" => 1, "mailing" => 3, "search_index, cache_warming" => 1 }
```

上面代码将启动5个工作进程: `archive`队列1个，`search_index, cache_warming` 队列1个，`mailing`队列3个。

### 多服务器/角色支持

可以在多个多服务器/角色中启动worker: 

```ruby
role :worker_server_A,  <server-ip-A>
role :worker_servers_B_and_C,  [<server-ip-B>, <server-ip-C>]  # 一个角色可以支持多个ip

set :workers, {
  worker_server_A: {
    "archive" => 1,
    "mailing" => 1
  },
  worker_servers_B_and_C: {
    "search_index" => 1,
  }
}
```

如上配置将启动4个worker, Server A上`archive`和`mailing`各有一个， Server B和Server C均启动了`search_index`。

### Rails Environment

在Rails，Resque需要加载整个Rails环境的task，从而获得访问模型的权限，例如: (e.g. QUEUE=* rake environment resque:work). However, Resque is often used without Rails (and even if you are using Rails, you may not need/want to load the Rails environment). As such, the environment task is not automatically included.

If you would like to load the environment task automatically, add this to your deploy.rb:

set :resque_environment_task, true

If you would like your workers to use a different Rails environment than your actual Rails app:

set :resque_rails_env, "my_resque_env"

## 工作任务

运行`cap -vT | grep resque`，可以看到resque支持的所有的任务。

```
➔ cap -vT | grep resque
cap resque:status    # Check workers status
cap resque:start     # Start Resque workers
cap resque:stop      # Quit running Resque workers
cap resque:restart   # Restart running Resque workers
cap resque:scheduler:restart #
cap resque:scheduler:start   # Starts Resque Scheduler with default configs
cap resque:scheduler:stop    # Stops Resque Scheduler
```

> `cap -T`不会列出没有描述，或仅在其他任务内部使用的任务。

## Restart on deployment

如果想要在`cap deploy:restart`执行之后，重启worker，可以添加如下内容: 

```
after "deploy:restart", "resque:restart"
```

## 日志(Logging)

后台任务和日志是当前的面对的问题。使用1.x版本的可以使用一些新的日志函数。

在Gemfile中，如此指定: 

```
gem 'resque', :git => 'git://github.com/defunkt/resque.git', :branch => '1-x-stable'
```

然后，添加日志设置: 

```
Resque.logger = Logger.new("new_resque_log_file")
```

## Redirecting output

Due to issues in the way Resque 1.x handles background processes, we automatically redirect stderr and stdout to /dev/null.

If you'd like to capture this output instead, just specify a log file:

    set :resque_log_file, "log/resque.log"

You can also disable the VERBOSE option to reduce the amount of log output:

    set :resque_verbose, false

## Limitations

Starting workers is done concurently via capistrano and you are limited by ssh connections limit on your server (default limit is 10)

in order to use more workers please change your sshd configurtion (/etc/ssh/sshd_config)

    MaxStartups 100
