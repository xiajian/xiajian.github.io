---
layout: post
title:  OAuth 2.0 笔记 (1) 世界观 
---

最近需要实作 OAuth 2 认证，不是接别人的 OAuth 2 ，而是自己制作出可以让别人接我们的 OAuth 2 的服务（俗称 Provider）。但看到既有的 OAuth 2 server library 如 rack-oauth2 却都看不懂，所以花了很久的时间来研读 RFC 6749 这份 OAuth 2.0 的 spec ，读完之后总算懂 library 在干嘛了。老板建议我写懒人包，所以就写了这篇，一来笔记，二来让别人可以透过这份懒人包来快速入门 OAuth 2。（不过说懒人包其实也不懒人，完全就是把 spec 翻译出来啊……。）

以下文字尽量注明 RFC 6749 原文的出处。有些原文我可能会省略，例如与 OAuth 1.0 的差异（spec 里面有些段落有提及）、扩充 OAuth 2.0 的功能 (Extension)，这是为了让懒人包 focus 在 OAuth 2.0 的基本使用方式。专有名词基本上不翻译，只适度加注中文，这是为了可以和 library 里面常用的变数名称保持一致。

另外，我有把 spec 原文的 txt 转成 Markdown 来方便阅读。
OAuth 2.0 系列文目录

    (1) 世界观
    (2) Client 的注册与认证
    (3) Endpoints 的规格
    (4.1) Authorization Code Grant Flow 细节
    (4.2) Implicit Grant Flow 细节
    (4.3) Resource Owner Credentials Grant Flow 细节
    (4.4) Client Credentials Grant Flow 细节
    (5) 核发与换发 Access Token
    (6) Bearer Token 的使用方法
    (7) 安全性问题
    各大网站 OAuth 2.0 实作差异

简介 OAuth 2.0

在传统的 Client-Server 架构里， Client 要拿取受保护的资源 (Protected Resoruce) 的时候，要向 Server 出示使用者 (Resource Owner) 的帐号密码才行。为了让第三方应用程式也可以拿到这些 Resources ，则 Resource Owner 要把帐号密码给这个第三方程式，这样子就会有以下的问题及限制：

    第三方程式必须储存 Resource Owner 的帐号密码，通常是明文储存。
    Server 必须支援密码认证，即使密码有天生的资讯安全上的弱点。
    第三方程式会得到几乎完整的权限，可以存取 Protected Resources ，而 Resource Owner 没办法限制第三方程式可以拿取 Resource 的时效，以及可以存取的范围 (subset)。
    Resource Owner 无法只撤回单一个第三方程式的存取权，而且必须要改密码才能撤回。
    任何第三方程式被破解 (compromized)，就会导致使用该密码的所有资料被破解。

OAuth 解决这些问题的方式，是引入一个认证层 (authorization layer) ，并且把 client 跟 resource owner 的角色分开。在 OAuth 里面，Client 会先索取存取权，来存取 Resource Owner 拥有的资源，这些资源会放在 Resource Server 上面，并且 Client 会得到一组不同于 Resource Owner 所持有的认证码 (credentials) 。

Client 会取得一个 Access Token 来存取 Protected Resources ，而非使用 Resource Owner 的帐号密码。Access Token 是一个字串，记载了特定的存取范围 (scope) 、时效等等的资讯。Access Token 是从 Authorization Server 拿到的，取得之前会得到 Resource Owner 的许可。Client 用这个 Access Token 来存取 Resource Server 上面的 Protected Resources 。

实际使用的例子：使用者 (Resource Owner) 可以授权印刷服务 (Client) 去相簿网站 (Resource Server) 存取他的私人照片，而不需要把相簿网站的帐号密码告诉印刷服务。这个使用者会直接授权透过一个相簿网站所信任的伺服器 (Authorization Server) ，核发一个专属于该印刷服务的认证码 (Access Token)。

OAuth 是设计来透过 HTTP 使用的。透过 HTTP 以外的通讯协定来使用 OAuth 则是超出 spec 的范围。

Section 1
OAuth 2.0 的角色定义

    Resource Owner - 可以授权别人去存取 Protected Resource 。如果这个角色是人类的话，则就是指使用者 (end-user)。
    Resource Server - 存放 Protected Resource 的伺服器，可以根据 Access Token 来接受 Protect