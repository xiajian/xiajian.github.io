---
layout: post
title: Passenger vs. Unicorn
---

## 缘起
----

62快买的电子书《Rails部署之道》，其中给出了关于Unicorn 和 Passenger的各自优势的博客的链接，权当附加产品，特地过去看看，并翻译过来。

原文地址: <https://blog.engineyard.com/2012/passenger-vs-unicorn>

## 正文

Use Unicorn unless you need to run multiple applications on the same host, such as testing environments or shared CMS instances.

除非需要同一主机上运行多个应用程序，比如测试环境或共享CMS实例，否则，使用Unicorn。

Unicorn and Passenger fundamentally differ in how they operate. There are a few similarities, however. Both have a master process that can spawn workers; both fork off workers from the master process; and both run Rack-based applications in addition to supporting older rails versions. What follows is a summary of the way the two application servers work, their benefits and problems.

Unicorn和 Passenger在如何操作上有着根本性的不同。但是，他们也有相似点，比如： 都有一个用来生成worker进程的主进程; 都是从主进程中fork出worker进程; 都运行着基于Rack的应用程序以此支持老版本的Rail。如下总结了两个应用程序的工作原理，两者各自的优缺点。

## Passenger
----

Passenger is a module that can be integrated into either Apache or Nginx; it's modeled on `mod_php` and `mod_ruby`. Here at Engine Yard we use Nginx, for various reasons; performance, simple configuration file formats, and because it uses less memory than Apache. When started as part of Nginx, Passenger creates a master process that spawns workers as requests come in. It does this relatively quickly, but there's a warm up time while the Rails code loads. The startup time is usually less than five seconds, but for some applications as long as thirty seconds.

Passenger是一个可被集成到Apache或者Nginx中的模块; 其以`mod_php`和`mod_ruby`为原型。Engine Yard使用Nginx，这里有很多的原因: 性能，简单的配置文件格式，以及内存使用少于Nginx。Passenger作为Nginx的一部分启动，其会创建一个用来生成worker的主进程，当请求到来时，生成从进程。Passenger生成进程非常的快，但在加载Rails代码时，速度就减缓下来。启动时间通常少于5秒，但对某些程序而言，将会长于30秒。

> 注: 公司的项目从新启动加载Rails代码，相当的慢。

There is a limit to the number of Passenger worker processes, set in the Nginx configs, and they stay alive as long as requests keep coming in. Each application only has as many workers as it needs to serve requests, down to the minimum number of workers configured. The upshot is that you're only using memory for the number of workers needed to serve requests; so if one application only needs one worker, that's all the memory it uses, and the rest of the memory is free for your other applications.

Passenger的工作进程数目可在Nginx中配置(passenger_min_instances)，并且只要请求持续存在，工作进程就一直存活。应用程序的工作进程数取决于其
需要处理的请求数和设置的最小进程数。要点就是，使用内存数与处理请求的工作进程数有关。如果某个应用程序需要1个工作进程，那它就只需启动一个工作
进程所需的内存数。

While being able to run several applications under one setup is useful, Passenger has several faults. It's difficult to monitor; If one of the workers has a problem and dies, it sits there stuck in memory until someone or something clears it out. Here at Engine Yard, that would be a Support Engineer or our passenger_monitor cron job. Some applications seem to have this problem more than others; it really depends on load and request volume. Also, when Passenger is restarted, sometimes the old application processes do not respond to the master Passenger's kill signal, and there's currently no automation in place on Cloud to kill them. This is especially a problem when a server is experiencing high load.

在启动一次，运行多个程序时，Passenger有很用。但是，Passenger存在一些问题，很难监控。如果工作进程出现了问题或者挂了，除非支持工程师或`passenger_monitor`任务将其清除，
否则它将依然占着内存。此外，当Passenger重启时，一些老的工作进程并不并不响应Passenger 主进程的的kill信号，有没有方法自动将其干掉。在服务器负载很高时，这很成问题。

All of those issues aside, there are three problems that are really major for people: The warm up time, the inability (or at best extreme hackishness) to do seamless deploys, and the fact that since it's compiled into the web server, you can't configure proxies in the detailed and custom ways that you can with other application servers like Unicorn.

## Unicorn
----

Unicorn, on the other hand, works somewhat differently. Unicorn runs independently of the other parts of your stack. It has a master process responsible for several things:

1. Keeps a running copy of the code in memory. 
2. Monitors how long the workers take to fulfill requests. 
3. Kills workers that take too long to fulfill requests, and forks off new workers very quickly, on the order of milliseconds. 
4. Can gracefully restart with new code. That is, you can update your code, send it a USR2 signal, and it'll boot a new master and new workers, let the old workers finish their requests, and then stop them. This is what allows “zero downtime” deploys.

Unicorn has a set number of workers alive in memory. On Engine Yard Cloud, this number is set based on instance size. These all take requests via the accept(2) kernel method through a socket as they come in. This means that load balancing is managed by the kernel, which is very efficient. Since this is a relatively static setup, you can use Monit (or another process monitor like god) to monitor CPU and memory usage as well.

Memory consumption can be considered a disadvantage for Unicorn. It takes up whatever memory is required for your code, plus the unicorn master overhead, times the number of workers. In a clustered environment, this isn't as bad as it sounds, but it does effectively limit the number of applications you can run to one, unless you're willing to do a bunch of custom work.

## 进一步阅读:

- http://unicorn.bogomips.org/ 
- http://www.modrails.com/documentation/Users%20guide%20Nginx.html 
- http://tomayko.com/writings/unicorn-is-unix/

## 后记
----

实际上，我不应该这么小鸡肚肠，我曾经买了本《windows phone 7 应用程序开发》的书，74，就看了几页; 买了本MFC程序设计的书，96，也只看了几页; 买了本《windows 核心编程》的书，73，看了3章。现在，买一本需要用到的电子书，62，应该是可以忍受的。我试着说服自己。
