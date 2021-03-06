---
layout: post
title: Thin服务器
---

## 缘起
----
9月29,距离国庆还有1天多。从昨天开始，就没有发心思放在工作上。一直在鼓捣自己的新博客。一直以为自己的开发时使用的是webrick服务器，没想到居然使用的Thin。以下，翻译自Thin项目的Readme文件，翻译的目的，就是为了自己参考着来的方便，实际发现，翻译过后，自己都是不看的。

## 简介

Tiny - 快速有趣的HTTP服务器。

Thin 是组合了web史上最好的三个Ruby库形成的web服务器:

  * The Mongrel parser: Mongrel服务器速度和安全性的根源
  * Event Machine: 高扩展，高性能，高可靠的网络I/O库 
  * Rack: 在web服务器和Ruby框架之间的最小接口

组合这三个Ruby库，使得Thin成为有趣的，安全的，稳定的，快速的并具有扩展性的Ruby的web服务器。

## 安装

存在多个种安装thin的方法，gem包手动安装，通过Github源代码安装，以及结合Rails通过bundle进行安装:

1. gem包手动安装

`gem install thin`

2. Github源代码安装

```
git clone git://github.com/macournoyer/thin.git
cd thin
rake install
```

3. 在Gemfile中写上`gem thin`, 然后通过`bundle install`按装

## 使用
----

**thin**脚本提供了简单启动Rack应用程序的方法:

```
cd to/your/app
thin start
```

如果在Rails应用程序中使用，需要添加
When using with Rails and Bundler, make sure to add `gem 'thin'`
to your Gemfile.

See example directory for samples.

### 命令行样例

Use a rackup file and bind to localhost port 8080:

```
thin -R config.ru -a 127.0.0.1 -p 8080 start
```

Store the server process ID, log to a file and daemonize:

```
thin -p 9292 -P tmp/pids/thin.pid -l logs/thin.log -d start
```

Thin is quite flexible in that many options can be specified at the command line (see below for usage).

### 配置文件

可创建yaml格式的配置文件，然后，通过`thin -C config.yml`调用。下面是配置的样例文件:

    --- 
    user: www-data
    group: www-data
    pid: tmp/pids/thin.pid
    timeout: 30
    wait: 30
    log: log/thin.log
    max_conns: 1024
    require: []
    environment: production
    max_persistent_conns: 512
    servers: 1
    threaded: true
    no-epoll: true
    daemonize: true
    socket: tmp/sockets/thin.sock
    chdir: /path/to/your/apps/root
    tag: a-name-to-show-up-in-ps aux

### 命令行选项

通过`thin -h`命令可以获得thin的全部命令行帮助: 

> Usage: thin [options] start|stop|restart|config|install

    Server options:
        -a, --address HOST               bind to HOST address (default: 0.0.0.0)
        -p, --port PORT                  use PORT (default: 3000)
        -S, --socket FILE                bind to unix domain socket
        -y, --swiftiply [KEY]            Run using swiftiply
        -A, --adapter NAME               Rack adapter to use (default: autodetect)
                                         (rack, rails, ramaze, merb, file)
        -R, --rackup FILE                Load a Rack config file instead of Rack adapter
        -c, --chdir DIR                  Change to dir before starting
            --stats PATH                 Mount the Stats adapter under PATH
    
    SSL options:
            --ssl                        Enables SSL
            --ssl-key-file PATH          Path to private key
            --ssl-cert-file PATH         Path to certificate
            --ssl-disable-verify         Disables (optional) client cert requests
    
    Adapter options:
        -e, --environment ENV            Framework environment (default: development)
            --prefix PATH                Mount the app under PATH (start with /)
    
    Daemon options:
        -d, --daemonize                  Run daemonized in the background
        -l, --log FILE                   File to redirect output (default: /home/robert/log/thin.log)
        -P, --pid FILE                   File to store PID (default: tmp/pids/thin.pid)
        -u, --user NAME                  User to run daemon as (use with -g)
        -g, --group NAME                 Group to run daemon as (use with -u)
            --tag NAME                   Additional text to display in process listing
    
    Cluster options:
        -s, --servers NUM                Number of servers to start
        -o, --only NUM                   Send command to only one server of the cluster
        -C, --config FILE                Load options from config file
            --all [DIR]                  Send command to each config files in DIR
        -O, --onebyone                   Restart the cluster one by one (only works with restart command)
        -w, --wait NUM                   Maximum wait time for server to be started in seconds (use with -O)
    
    Tuning options:
        -b, --backend CLASS              Backend to use, full classname
        -t, --timeout SEC                Request or command timeout in sec (default: 30)
        -f, --force                      Force the execution of the command
            --max-conns NUM              Maximum number of open file descriptors (default: 1024)
                                         Might require sudo to set higher than 1024
            --max-persistent-conns NUM   Maximum number of persistent connections
                                         (default: 100)
            --threaded                   Call the Rack application in threads [experimental]
            --threadpool-size NUM        Sets the size of the EventMachine threadpool.
                                         (default: 20)
            --no-epoll                   Disable the use of epoll
    
    Common options:
        -r, --require FILE               require the library
        -q, --quiet                      Silence all logging
        -D, --debug                      Enable debug logging
        -V, --trace                      Set tracing on (log raw request/response)
        -h, --help                       Show this message
        -v, --version                    Show version

## License

Ruby License, http://www.ruby-lang.org/en/LICENSE.txt.

## 更多信息

*  email: macournoyelr@gmail.com.
*  Site:  http://code.macournoyer.com/thin/
*  Group: http://groups.google.com/group/thin-ruby/topics
*  Bugs:  http://github.com/macournoyer/thin/issues
*  Code:  http://github.com/macournoyer/thin
*  IRC:   #thin on freenode

## 后记

关于应用服务器，尤其是Ruby的应用服务器，也算接触好几个了(Passenger, Mongrel, Thin, Unicorn)，但都没用过，也没配过。就认识上而言，Mongrel存在集群，Thin也是可以有集群的，Unicorn使用了master/worker，以及pull request的方式，也是可以借鉴到Thin和Mongrel中的。

最重要的事情是，要对现有的Thin服务器的性能和工作原理要有个深入的理解。
