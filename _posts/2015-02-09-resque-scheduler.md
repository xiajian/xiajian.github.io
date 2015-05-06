---
layout: post
title: 关于resque-scheduler
description: "ruby, resque-scheduler, 后台任务"
---

## 前言

循着依赖关系查找，发现[resque-scheduler](https://github.com/resque/resque-scheduler)依赖项目还是挺多的。以下是依赖
关系的介绍: 

* resque-scheduler: redis, resque, rufus-scheduler
* resque的依赖项: `mono_logger`, `multi_json` , `redis-namespace`(依赖redis) , sinatra , vegas(rack)

如下是，官方Readme文档的翻译。

## 介绍

Resque-scheduler是[Resque](http://github.com/defunkt/resque)的扩展，并在将来提供列表查询的功能。

下表解释了Redis的版本的需求:

| resque-scheduler version | required redis version|
|:-------------------------|----------------------:|
| >= 2.0.0                 | >= 2.2.0              |
| >= 0.0.1                 | >= 1.3                |


Job安排支持两种不同的方式： 经常性(预先安排)和延迟。

预先安排的Job很像cron job，在一定基础上安排。 延迟job就是那些可能在将来的某个时间点运行的resque任务。
job的安排语法具有好的解释性: 

    Resque.enqueue_in(5.days, SendFollowupEmail) # run a job in 5 days
    # or
    Resque.enqueue_at(5.days.from_now, SomeJob) # run SomeJob at a specific time

### Documentation

README中覆盖了大多数人需要知道的，如果想要更多关于特定方法的细节，可以参考[rdoc](http://rdoc.info/github/bvandenbos/resque-scheduler/master/frames)。

### Installation

安装命令: 

    gem install resque-scheduler

Gemfile中需要显式指定`:require`：

    gem 'resque-scheduler', :require => 'resque_scheduler'

然后，在rake任务中添加`resque:scheduler`：

    require 'resque_scheduler/tasks'

There are three things `resque-scheduler` needs to know about in order to do
it's jobs: the schedule, where redis lives, and which queues to use.  The
easiest way to configure these things is via the rake task.  By default,
`resque-scheduler` depends on the "resque:setup" rake task.  Since you
probably already have this task, lets just put our configuration there.
`resque-scheduler` pretty much needs to know everything `resque` needs
to know.

对于需要处理的job， `resque-scheduler` 需要了解三件事情: 任务安排表，redis，以及使用的队列。 最简单的方法是通过rake任务进行配置。默认情况下，`resque-scheduler`依赖"resque:setup"的rake任务。 由于可能已经使用了这个任务，这里配置一下即可。`resque-scheduler`完美的知道，`resque`需要知道的一切。


    # Resque tasks
    require 'resque/tasks'
    require 'resque_scheduler/tasks'

    namespace :resque do
      task :setup do
        require 'resque'
        require 'resque_scheduler'
        require 'resque/scheduler'

        # 配置redis
        Resque.redis = 'localhost:6379' 

        # 动态的改变任务安排的配置开关。动态任务安排可以通过`Resque::Scheduler.set_schedule`和`remove_schedule`方法
        # 进行更新。启动动态变化后，任务安排进程将查找schedule的变化，然后即刻应用。
        # **注意**: 该特性需要2.0以上的`resque-scheduler`版本。
        #Resque::Scheduler.dynamic = true

        # schedule可以YAML或hash的形式存储，但YAML更为简单。
        Resque.schedule = YAML.load_file('your_resque_schedule.yml')

        # If your schedule already has +queue+ set for each job, you don't
        # need to require your jobs.  This can be an advantage since it's
        # less code that resque-scheduler needs to know about. But in a small
        # project, it's usually easier to just include you job classes here.
        # So, something like this:
        require 'jobs'
      end
    end

scheduler进程仅仅是一个rake任务，其负责从schedule中查询项目，从延迟队列中轮询项目，并将其推送到工作队列中。
因此，该进程永不退出。

    $ rake resque:scheduler

Supported environment variables are `VERBOSE` and `MUTE`.  If either is set to
any nonempty value, they will take effect.  `VERBOSE` simply dumps more output
to stdout.  `MUTE` does the opposite and silences all output. `MUTE`
supersedes `VERBOSE`.

支持的环境变量是`VERBOSE`和`MUTE`，用来表示输出的信息的详细程度。


### Delayed jobs

延迟jobs是存放在队列中，并在将来某个时间点执行的一次性任务。 典型的例子是发送邮件: 

    Resque.enqueue_in(5.days, SendFollowUpEmail, :user_id => current_user.id)

This will store the job for 5 days in the resque delayed queue at which time
the scheduler process will pull it from the delayed queue and put it in the
appropriate work queue for the given job and it will be processed as soon as
a worker is available (just like any other resque job).

上面代码先将job存放在resque延迟队列中五天，然后scheduler进程从延迟对立中将其取出，并将其放置到
特定job的相应的工作队列中，并在worker进程可用时立即处理。


**注意**: 延迟Job并不会支持在**精确**的时间触发。 而是，在那个时间点之后的某空闲的实现。

Also supported is `Resque.enqueue_at` which takes a timestamp to queue the
job, and `Resque.enqueue_at_with_queue` which takes both a timestamp and a
queue name.

`Resque.enqueue_at`方法需要时间戳来安排任务。`Resque.enqueue_at_with_queue`方法继续要时间戳，也需要队列名。

The delayed queue is stored in redis and is persisted in the same way the
standard resque jobs are persisted (redis writing to disk). Delayed jobs differ
from scheduled jobs in that if your scheduler process is down or workers are
down when a particular job is supposed to be queue, they will simply "catch up"
once they are started again.  Jobs are guaranteed to run (provided they make it
into the delayed queue) after their given queue_at time has passed.

delayed queue存储在Redis中，并以标准的resque job的方式持久化(redis写入磁盘中)。 Delayed jobs不同与scheduled jobs的一点是，前者
肯定会执行，即使scheduler进程和worker进程挂了，再次启动时，也一定会执行。scheduled jobs过了时间点，大概就不会再执行了。


One other thing to note is that insertion into the delayed queue is O(log(n))
since the jobs are stored in a redis sorted set (zset).  I can't imagine this
being an issue for someone since redis is stupidly fast even at log(n), but full
disclosure is always best.

另一件需要注意的事情是，delayed queue的存储结构是redis有序集合，其插入操作的时间复杂度是O(log(n))。原作者
不想别人问起是否redis会比log(n)更快，过量提示总是好的。

#### Removing Delayed jobs

If you have the need to cancel a delayed job, you can do like so:

如果想要取消延迟任务，可以这样做: 

    # 安排一个任务
    Resque.enqueue_at(5.days.from_now, SendFollowUpEmail, :user_id => current_user.id)
    # 使用相同的参数移除任务
    Resque.remove_delayed(SendFollowUpEmail, :user_id => current_user.id)

### Scheduled Jobs (Recurring Jobs)

Scheduled (or recurring) jobs和标准的cron job没什么不同，其以启动时设置的精确的安排表执行任务。

安排表是一组带有参数、安排频度(cron语法)。 schedule是hash，但通常以YAML文件存储。

    CancelAbandonedOrders:
      cron: "*/5 * * * *"

    queue_documents_for_indexing:
      cron: "0 0 * * *"
      # you can use rufus-scheduler "every" syntax in place of cron if you prefer
      # every: 1hr
      # By default the job name (hash key) will be taken as worker class name.
      # If you want to have a different job name and class name, provide the 'class' option
      class: QueueDocuments
      queue: high
      args:
      description: "This job queues all content for indexing in solr"

    clear_leaderboards_contributors:
      cron: "30 6 * * 1"
      class: ClearLeaderboards
      queue: low
      args: contributors
      description: "This job resets the weekly leaderboard for contributions"

The queue value is optional, but if left unspecified resque-scheduler will
attempt to get the queue from the job class, which means it needs to be
defined.  If you're getting "uninitialized constant" errors, you probably
need to either set the queue in the schedule or require your jobs in your
"resque:setup" rake task.

队列的值是可选的。不指定队列时，resque-scheduler将尝试从job类中获取队列，这意味着，队列必须要定义。如果遇到了
"uninitialized constant"错误，则需要在schedule中设置队列，或在"resque:setup"rake任务中require 相应的job。

可以通过数组提供"every"或"cron"的选项:

    clear_leaderboards_moderator:
      every: ["30s", :first_in => '120s']
      class: CheckDaemon
      queue: daemons
      description: "This job will check Daemon every 30 seconds after 120 seconds after start"


NOTE: Six parameter cron's are also supported (as they supported by
rufus-scheduler which powers the resque-scheduler process).  This allows you
to schedule jobs per second (ie: "30 * * * * *" would fire a job every 30
seconds past the minute).

**注意**: cron的6个参数的形式由resque-scheduler进程中rufus-scheduler支持。这使得可以在秒级安排jobs。(例如："30 * * * * *"将会在每30秒启动一个job )。

[rufus-scheduler](http://github.com/jmettraux/rufus-scheduler) 是实际的处理调度引擎。

#### Time zones

Note that if you use the cron syntax, this will be interpreted as in the server time zone
rather than the `config.time_zone` specified in Rails.

如果使用cron语法，任务将会以服务器的时区执行，而不是Rails中`config.time_zone`指定的时区。

You can explicitly specify the time zone that rufus-scheduler will use:

当然，可以使用如下的语法显式指定时区:

    cron: "30 6 * * 1 Europe/Stockholm"

Also note that `config.time_zone` in Rails allows for a shorthand (e.g. "Stockholm")
that rufus-scheduler does not accept. If you write code to set the scheduler time zone
from the `config.time_zone` value, make sure it's the right format, e.g. with:

    ActiveSupport::TimeZone.find_tzinfo(Rails.configuration.time_zone).name

A future version of resque-scheduler may do this for you.

#### 钩子方法(Hooks)

与Resque(>= 1.19.1)中提供的`before_enqueue`和`after_enqueue`钩子方法类似:

* `before_schedule`: Called with the job args before a job is placed on
  the delayed queue. If the hook returns `false`, the job will not be placed on
  the queue.
* `before_schedule`: 在job被放置到延迟队列中之前，包含job的参数进行调用。如果hook方法返回为`false`，job将不会被放置到队列中。
* `after_schedule`: Called with the job args after a job is placed on the
  delayed queue. Any exception raised propagates up to the code with queued the
  job.
* `after_schedule`: 在任务被放置到延迟队列之后，带job参数进行调用。 任何异常将会传播到安排队列的job中。
* `before_delayed_enqueue`: 在job已经从延迟队列中移除之后还未放置通常的队列之前，带参调用。其在`before_enqueue`钩子之前，但在
  某些job实例中，可能和`before_enqueue`一起调用。返回值将会被忽略。

#### Support for resque-status (and other custom jobs)

Some Resque extensions like
[resque-status](http://github.com/quirkey/resque-status) use custom job
classes with a slightly different API signature.  Resque-scheduler isn't
trying to support all existing and future custom job classes, instead it
supports a schedule flag so you can extend your custom class and make it
support scheduled job.

一些Resque扩展，比如[resque-status](http://github.com/quirkey/resque-status)，使用带有轻微不同的API签名的特定的job类。
Resque-scheduler不尝试支持所有现存的或将来的定制化job类，而是通过schedule标识扩展特定类，从而使其支持scheduled job。

Let's pretend we have a JobWithStatus class called FakeLeaderboard

假设有个称为FakeLeaderboard的JobWithStatus的类: 

    class FakeLeaderboard < Resque::JobWithStatus
      def perform
        # do something and keep track of the status
      end
    end

然后，添加schedule: 

    create_fake_leaderboards:
      cron: "30 6 * * 1"
      queue: scoring
      custom_job_class: FakeLeaderboard
      args:
      rails_env: demo
      description: "This job will auto-create leaderboards for our online demo and the status will update as the worker makes progress"

如果扩展不支持安排job，需要扩展特定的job，从而支持 #scheduled 方法: 

    module Resque
      class JobWithStatus
        # Wrapper API to forward a Resque::Job creation API call into
        # a JobWithStatus call.
        def self.scheduled(queue, klass, *args)
          create(*args)
        end
      end
    end

### 冗余和失效转移(Redundancy and Fail-Over)

> 仅限 2.0.1以上的版本，2.0.1之前的版本，不推荐在多个机器上运行resque-scheduler进程，会导致重复jobs。

You may want to have resque-scheduler running on multiple machines for 
redudancy.  Electing a master and failover is built in and default.  Simply
run resque-scheduler on as many machine as you want pointing to the same
redis instance and schedule.  The scheduler processes will use redis to
elect a master process and detect failover when the master dies.  Precautions are
taken to prevent jobs from potentially being queued twice during failover even
when the clocks of the scheduler machines are slightly out of sync (or load affects
scheduled job firing time).  If you want the gory details, look at Resque::SchedulerLocking.

出于冗余考虑，可能在需要在多台机器上运行resque-scheduler。仲裁master和失效转移是内建支持且默认的。
使用相同的Redis实例和任务安排(schedule)，然后简单的在多个机器上运行resque-scheduler。 调度进程(scheduler processes)
会使用redis选出主进程，并在主进程挂了后进行失效转移。在失效转移期间，通过一些防范措施确保jobs不会被安排两次。更多细节，
参考 Resque::SchedulerLocking。

If the scheduler process(es) goes down for whatever reason, the delayed items
that should have fired during the outage will fire once the scheduler process
is started back up again (regardless of it being on a new machine).  Missed
scheduled jobs, however, will not fire upon recovery of the scheduler process.
Think of scheduled (recurring) jobs as cron jobs - if you stop cron, it doesn't fire
missed jobs once it starts back up.

如果scheduler进程不小心挂了，在其重新启动(可能在一台新机器上)之后，那些延迟jobs都会被触发执行。
而错过的scheduled jobs，就不会再触发执行了，这和cron job的逻辑类似。

### resque-web Additions

Resque-scheduler also adds to tabs to the resque-web UI.  One is for viewing
(and manually queueing) the schedule and one is for viewing pending jobs in
the delayed queue.

Resque-scheduler向resque-web UI中添加了两个新的tabs。 一个用来查看(手动排序)schedule，另一个用来查看
未决定的延迟队列。


#### How do I get the schedule tabs to show up???

To get these to show up you need to pass a file to `resque-web` to tell it to
include the `resque-scheduler` plugin and the resque-schedule server extension
to the resque-web sinatra app.  Unless you're running redis on localhost, you
probably already have this file.  It probably looks something like this:



    require 'resque' # include resque so we can configure it
    Resque.redis = "redis_server:6379" # tell Resque where redis lives

Now, you want to add the following:

    # This will make the tabs show up.
    require 'resque_scheduler'
    require 'resque_scheduler/server'

That should make the scheduler tabs show up in `resque-web`.


#### Changes as of 2.0.0

As of resque-scheduler 2.0.0, it's no longer necessary to have the resque-web
process aware of the schedule because it reads it from redis.  But prior to
2.0, you'll want to make sure you load the schedule in this file as well.
Something like this:

    Resque.schedule = YAML.load_file(File.join(RAILS_ROOT, 'config/resque_schedule.yml')) # load the schedule

Now make sure you're passing that file to resque-web like so:

    resque-web ~/yourapp/config/resque_config.rb

### Running in the background

(Only supported with ruby >= 1.9). There are scenarios where it's helpful for
the resque worker to run itself in the background (usually in combination with
PIDFILE).  Use the BACKGROUND option so that rake will return as soon as the
worker is started.

    $ PIDFILE=./resque-scheduler.pid BACKGROUND=yes \
        rake resque:scheduler

### 抄袭警告(Plagiarism alert)

This was intended to be an extension to resque and so resulted in a lot of the
code looking very similar to resque, particularly in resque-web and the views. I
wanted it to be similar enough that someone familiar with resque could easily
work on resque-scheduler.

## 后记

最近，开始重新学习Redis，虽然以前没开始认真学习过。
