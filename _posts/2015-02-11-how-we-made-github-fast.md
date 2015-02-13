---
layout: post
title: 关于Github加速实践
description: "github"
---

## 前言

Github也是使用的Rails的架构，所以，其网站加速的经验非常的值得借鉴。

文章来源: <https://github.com/blog/530-how-we-made-github-fast>


## 正文

Now that things have settled down from the move to Rackspace, I wanted to take some time to go over the architectural changes that we’ve made in order to bring you a speedier, more scalable GitHub.

In my first draft of this article I spent a lot of time explaining why we made each of the technology choices that we did. After a while, however, it became difficult to separate the architecture from the discourse and the whole thing became confusing. So I’ve decided to simply explain the architecture and then write a series of follow up posts with more detailed analyses of exactly why we made the choices we did.

There are many ways to scale modern web applications. What I will be describing here is the method that we chose. This should by no means be considered the only way to scale an application. Consider it a case study of what worked for us given our unique requirements.

## Understanding the Protocols

We expose three primary protocols to end users of GitHub: HTTP, SSH, and Git. When browsing the site with your favorite browser, you’re using HTTP. When you clone, pull, or push to a private URL like git@github.com:mojombo/jekyll.git you’re doing so via SSH. When you clone or pull from a public repository via a URL like git://github.com/mojombo/jekyll.git you’re using the Git protocol.

The easiest way to understand the architecture is by tracing how each of these requests propagates through the system.

## Tracing an HTTP Request

For this example I’ll show you how a request for a tree page such as http://github.com/mojombo/jekyll happens.

The first thing your request hits after coming down from the internet is the active load balancer. For this task we use a pair of Xen instances running ldirectord. These are called lb1a and lb1b. At any given time one of these is active and the other is waiting to take over in case of a failure in the master. The load balancer doesn’t do anything fancy. It forwards TCP packets to various servers based on the requested IP and port and can remove misbehaving servers from the balance pool if necessary. In the event that no servers are available for a given pool it can serve a simple static site instead of refusing connections.

For requests to the main website, the load balancer ships your request off to one of the four frontend machines. Each of these is an 8 core, 16GB RAM bare metal server. Their names are fe1, …, fe4. Nginx accepts the connection and sends it to a Unix domain socket upon which sixteen Unicorn worker processes are selecting. One of these workers grabs the request and runs the Rails code necessary to fulfill it.

Many pages require database lookups. Our MySQL database runs on two 8 core, 32GB RAM bare metal servers with 15k RPM SAS drives. Their names are db1a and db1b. At any given time, one of them is master and one is slave. MySQL replication is accomplished via DRBD.

If the page requires information about a Git repository and that data is not cached, then it will use our Grit library to retrieve the data. In order to accommodate our Rackspace setup, we’ve modified Grit to do something special. We start by abstracting out every call that needs access to the filesystem into the Grit::Git object. We then replace Grit::Git with a stub that makes RPC calls to our Smoke service. Smoke has direct disk access to the repositories and essentially presents Grit::Git as a service. It’s called Smoke because Smoke is just Grit in the cloud. Get it?

The stubbed Grit makes RPC calls to smoke which is a load balanced hostname that maps back to the fe machines. Each frontend runs four ProxyMachine instances behind HAProxy that act as routing proxies for Smoke calls. ProxyMachine is my content aware (layer 7) TCP routing proxy that lets us write the routing logic in Ruby. The proxy examines the request and extracts the username of the repository that has been specified. We then use a proprietary library called Chimney (it routes the smoke!) to lookup the route for that user. A user’s route is simply the hostname of the file server on which that user’s repositories are kept.

Chimney finds the route by making a call to Redis. Redis runs on the database servers. We use Redis as a persistent key/value store for the routing information and a variety of other data.

Once the Smoke proxy has determined the user’s route, it establishes a transparent proxy to the proper file server. We have four pairs of fileservers. Their names are fs1a, fs1b, …, fs4a, fs4b. These are 8 core, 16GB RAM bare metal servers, each with six 300GB 15K RPM SAS drives arranged in RAID 10. At any given time one server in each pair is active and the other is waiting to take over should there be a fatal failure in the master. All repository data is constantly replicated from the master to the slave via DRBD.

Every file server runs two Ernie RPC servers behind HAProxy. Each Ernie spawns 15 Ruby workers. These workers take the RPC call and reconstitute and perform the Grit call. The response is sent back through the Smoke proxy to the Rails app where the Grit stub returns the expected Grit response.

When Unicorn is finished with the Rails action, the response is sent back through Nginx and directly to the client (outgoing responses do not go back through the load balancer).

Finally, you see a pretty web page!

The above flow is what happens when there are no cache hits. In many cases the Rails code uses Evan Weaver’s Ruby memcached client to query the Memcache servers that run on each slave file server. Since these machines are otherwise idle, we place 12GB of Memcache on each. These servers are aliased as memcache1, …, memcache4.

## BERT and BERT-RPC

For our data serialization and RPC protocol we are using BERT and BERT-RPC. You haven’t heard of them before because they’re brand new. I invented them because I was not satisfied with any of the available options that I evaluated, and I wanted to experiment with an idea that I’ve had for a while. Before you freak out about NIH syndrome (or to help you refine your freak out), please read my accompanying article Introducing BERT and BERT-RPC about how these technologies came to be and what I intend for them to solve.

If you’d rather just check out the spec, head over to http://bert-rpc.org.

For the code hungry, check out my Ruby BERT serialization library BERT, my Ruby BERT-RPC client BERTRPC, and my Erlang/Ruby hybrid BERT-RPC server Ernie. These are the exact libraries we use at GitHub to serve up all repository data.

## Tracing an SSH Request

Git uses SSH for encrypted communications between you and the server. In order to understand how our architecture deals with SSH connections, it is first important to understand how this works in a simpler setup.

Git relies on the fact that SSH allows you to execute commands on a remote server. For instance, the command ssh tom@frost ls -al runs ls -al in the home directory of my user on the frost server. I get the output of the command on my local terminal. SSH is essentially hooking up the STDIN, STDOUT, and STDERR of the remote machine to my local terminal.

If you run a command like git clone tom@frost:mojombo/bert, what Git is doing behind the scenes is SSHing to frost, authenticating as the tom user, and then remotely executing git upload-pack mojombo/bert. Now your client can talk to that process on the remote server by simply reading and writing over the SSH connection. Neat, huh?

Of course, allowing arbitrary execution of commands is unsafe, so SSH includes the ability to restrict what commands can be executed. In a very simple case, you can restrict execution to git-shell which is included with Git. All this script does is check the command that you’re trying to execute and ensure that it’s one of git upload-pack, git receive-pack, or git upload-archive. If it is indeed one of those, it uses exec to replace the current process with that new process. After that, it’s as if you had just executed that command directly.

So, now that you know how Git’s SSH operations work in a simple case, let me show you how we handle this in GitHub’s architecture.

First, your Git client initiates an SSH session. The connection comes down off the internet and hits our load balancer.

From there, the connection is sent to one of the frontends where SSHD accepts it. We have patched our SSH daemon to perform public key lookups from our MySQL database. Your key identifies your GitHub user and this information is sent along with the original command and arguments to our proprietary script called Gerve (Git sERVE). Think of Gerve as a super smart version of git-shell.

Gerve verifies that your user has access to the repository specified in the arguments. If you are the owner of the repository, no database lookups need to be performed, otherwise several SQL queries are made to determine permissions.

Once access has been verified, Gerve uses Chimney to look up the route for the owner of the repository. The goal now is to execute your original command on the proper file server and hook your local machine up to that process. What better way to do this than with another remote SSH execution!

I know it sounds crazy but it works great. Gerve simply uses exec(3) to replace itself with a call tossh git@<route> <command> <arg>. After this call, your client is hooked up to a process on a frontend machine which is, in turn, hooked up to a process on a file server.

Think of it this way: after determining permissions and the location of the repository, the frontend becomes a transparent proxy for the rest of the session. The only drawback to this approach is that the internal SSH is unnecessarily encumbered by the overhead of encryption/decryption when none is strictly required. It’s possible we may replace this this internal SSH call with something more efficient, but this approach is just too damn simple (and still very fast) to make me worry about it very much.

## Tracing a Git Request

Performing public clones and pulls via Git is similar to how the SSH method works. Instead of using SSH for authentication and encryption, however, it relies on a server side Git Daemon. This daemon accepts connections, verifies the command to be run, and then uses fork(2) and exec(3) to spawn a worker that then becomes the command process.

With this in mind, I’ll show you how a public clone operation works.

First, your Git client issues a request containing the command and repository name you wish to clone. This request enters our system on the load balancer.

From there, the request is sent to one of the frontends. Each frontend runs four ProxyMachine instances behind HAProxy that act as routing proxies for the Git protocol. The proxy inspects the request and extracts the username (or gist name) of the repo. It then uses Chimney to lookup the route. If there is no route or any other error is encountered, the proxy speaks the Git protocol and sends back an appropriate messages to the client. Once the route is known, the repo name (e.g. mojombo/bert) is translated into its path on disk (e.g. a/a8/e2/95/mojombo/bert.git). On our old setup that had no proxies, we had to use a modified daemon that could convert the user/repo into the correct filepath. By doing this step in the proxy, we can now use an unmodified daemon, allowing for a much easier upgrade path.

Next, the Git proxy establishes a transparent proxy with the proper file server and sends the modified request (with the converted repository path). Each file server runs two Git Daemon processes behind HAProxy. The daemon speaks the pack file protocol and streams data back through the Git proxy and directly to your Git client.

Once your client has all the data, you’ve cloned the repository and can get to work!

## Sub- and Side-Systems

In addition to the primary web application and Git hosting systems, we also run a variety of other sub-systems and side-systems. Sub-systems include the job queue, archive downloads, billing, mirroring, and the svn importer. Side-systems include GitHub Pages, Gist, gem server, and a bunch of internal tools. You can look forward to explanations of how some of these work within the new architecture, and what new technologies we’ve created to help our application run more smoothly.

## Conclusion

The architecture outlined here has allowed us to properly scale the site and resulted in massive performance increases across the entire site. Our average Rails response time on our previous setup was anywhere from 500ms to several seconds depending on how loaded the slices were. Moving to bare metal and federated storage on Rackspace has brought our average Rails response time to consistently under 100ms. In addition, the job queue now has no problem keeping up with the 280,000 background jobs we process every day. We still have plenty of headroom to grow with the current set of hardware, and when the time comes to add more machines, we can add new servers on any tier with ease. I’m very pleased with how well everything is working, and if you’re like me, you’re enjoying the new and improved GitHub every day!

## 后记

