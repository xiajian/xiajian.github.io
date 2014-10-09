---
layout: post
title: Passenger vs. Unicorn
---

Use Unicorn unless you need to run multiple applications on the same host, such as testing environments or shared CMS instances.

Unicorn and Passenger fundamentally differ in how they operate. There are a few similarities, however. Both have a master process that can spawn workers; both fork off workers from the master process; and both run Rack-based applications in addition to supporting older rails versions. What follows is a summary of the way the two application servers work, their benefits and problems.

## Passenger
----

Passenger is a module that can be integrated into either Apache or Nginx; it's modeled on mod_php and mod_ruby. Here at Engine Yard we use Nginx, for various reasons; performance, simple configuration file formats, and because it uses less memory than Apache. When started as part of Nginx, Passenger creates a master process that spawns workers as requests come in. It does this relatively quickly, but there's a warm up time while the Rails code loads. The startup time is usually less than five seconds, but for some applications as long as thirty seconds.

There is a limit to the number of Passenger worker processes, set in the Nginx configs, and they stay alive as long as requests keep coming in. Each application only has as many workers as it needs to serve requests, down to the minimum number of workers configured. The upshot is that you're only using memory for the number of workers needed to serve requests; so if one application only needs one worker, that's all the memory it uses, and the rest of the memory is free for your other applications.

While being able to run several applications under one setup is useful, Passenger has several faults. It's difficult to monitor; If one of the workers has a problem and dies, it sits there stuck in memory until someone or something clears it out. Here at Engine Yard, that would be a Support Engineer or our passenger_monitor cron job. Some applications seem to have this problem more than others; it really depends on load and request volume. Also, when Passenger is restarted, sometimes the old application processes do not respond to the master Passenger's kill signal, and there's currently no automation in place on Cloud to kill them. This is especially a problem when a server is experiencing high load.

All of those issues aside, there are three problems that are really major for people: The warm up time, the inability (or at best extreme hackishness) to do seamless deploys, and the fact that since it's compiled into the web server, you can't configure proxies in the detailed and custom ways that you can with other application servers like Unicorn.

## Unicorn
----

Unicorn, on the other hand, works somewhat differently. Unicorn runs independently of the other parts of your stack. It has a master process responsible for several things:1. Keeps a running copy of the code in memory. 2. Monitors how long the workers take to fulfill requests. 3. Kills workers that take too long to fulfill requests, and forks off new workers very quickly, on the order of milliseconds. 4. Can gracefully restart with new code. That is, you can update your code, send it a USR2 signal, and it'll boot a new master and new workers, let the old workers finish their requests, and then stop them. This is what allows “zero downtime” deploys.

Unicorn has a set number of workers alive in memory. On Engine Yard Cloud, this number is set based on instance size. These all take requests via the accept(2) kernel method through a socket as they come in. This means that load balancing is managed by the kernel, which is very efficient. Since this is a relatively static setup, you can use Monit (or another process monitor like god) to monitor CPU and memory usage as well.

Memory consumption can be considered a disadvantage for Unicorn. It takes up whatever memory is required for your code, plus the unicorn master overhead, times the number of workers. In a clustered environment, this isn't as bad as it sounds, but it does effectively limit the number of applications you can run to one, unless you're willing to do a bunch of custom work.

## 进一步阅读:

- http://unicorn.bogomips.org/ 
- http://www.modrails.com/documentation/Users%20guide%20Nginx.html 
- http://tomayko.com/writings/unicorn-is-unix/

