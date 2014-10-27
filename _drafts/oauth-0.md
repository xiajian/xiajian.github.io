---
layout: post
title: OAuth 2.0教程: Grape API 整合 Doorkeeper 
---

最近我要实作使用 OAuth 2 认证的 API ，我先是看了 Spec (RFC 6740 、 RFC 6750），然后研究了既有的 Rails solution ，但因为 API 是用 Grape 盖的，又 Doorkeeper / Rack::OAuth2 / Grape 内建的 OAuth 2 认证全都无法直接拿来用，所以只好自己实现 API 认证这部份。

我把实现的过程写成了教程：<http://blog.yorkxin.org/posts/2013/10/10/oauth2-tutorial-grape-api-doorkeeper>

简单来说是这样：

- 用 Devise 造 User (Resource Owner) 系统
- 用 Grape 造 API (Resource Server)
- 用 Doorkeeper 造 OAuth 2 Provider (Authorization Server)
- 自己用 Rack::OAuth2 接 Grape 来造出 API 上的 Guard

其中第四项我搞最久，希望可以帮后来的同学省到时间 :)

应要求全文转贴 :) 不过很抱歉是繁体的，原本想用 OpenCC 转换却不会用它的命令列工具…

这篇文章示范如何使用 OAuth 2 保护 API ，其中 API 是用 Grape 造出来的，挂在 Rails 底下。

整个实作流程会造出这些东西：

    Resource Owner - 可以授权给第三方 App 的角色，也就是 User。
    Authorization Server - 用来处理与 OAuth 2 授权有关的事务，像是：
        Clients - 需要有 Clients (Apps) 的 CRUD 。
        Access Token (Model) - 需要有个 Model 来储存 Access Token 。
        Authorization Endpoint - 这里来处理 Auth Code Grant 和 Implicit Grant 。
        Token Endpoint - 这里来真正核发 Token 。
    Resource Server - 给 App 存取的地方，也就是 API ，一部份需要 Access Token 才能存取的叫做 Protected Resource 。
        Resource Server 上面的 Guard - 用途是「保护某些 API ，必须要带 Access Token 才能存取」，俗称保全。

本文使用这些套件来实作：

    Resource Owner (User) - Devise
    Authorization Server (OAuth 2 Provider) - Doorkeeper
    Resource Server (API) - Grape
    Guard - 用 Rack::OAuth2 来整合 Grape

因为 Doorkeeper 的 doorkeeper_for 只能用在 Rails ，而 Guard 只是一个 Rack Middleware ，所以这里要自己拼凑。详情请见先前的文章 〈Ruby / Rails 的 OAuth 2 整合方案简单评比〉。

所有过程我都会放在 chitsaou/oauth2-api-sample 这个 repository ，各 step 有对应的 step-x tag ，例如 Step 1 完成的结果可以在 step-1 这个 tag 看到。
Step 1: 造 Resource Owner 逻辑 (User)

用 Devise 做。这个应该是 Rails Developer 的基本功，所以不解释了，请见 step-1 tag。

可以试著打开 /pages/secret ，会要求登入。
Step 2: 造 Resource Server (API)

用 Grape 是因为不想要让 API 经过太多 Rails 的 stack。

这个不难，而且不是本文的重点，所以直接看官方文件就好了。成品可以看 step-2 tag 。
Step 3: 造 Authorization Server (Provider)

既然底是 Rails ，那么就直接上 Doorkeeper 就好了。可以看 step-3 tag 。

RailsCasts 有 tutorial ，若有买 Pro 不妨去看看。不过其实照官方文件做也不难：

安装 Doorkeeper Gem

gem 'doorkeeper'

别忘了跑 bundle install 。

然后跑这些来安装：

$ rails generate doorkeeper:install
$ rails generate doorkeeper:migration
$ rake db:migrate

再照他文件说的去接 Devise 来认证 Resource Owner：

  # 认证 Resource Owner 的方法，直接接 Devise
  resource_owner_authenticator do
    current_user || warden.authenticate!(:scope => :user)
  end

这样就好了。

Doorkeeper 会建这些 model:

    OauthApplication - Clients 的注册资料库
    OauthAccessGrant - Auth Code 流程第一步产生的 Auth Grants 的资料库
    OauthAccessToken - 真正核发出去的 Access Tokens，包含对应的 Refresh Token （预设关闭）

Doorkeeper 开的 Routes 有这些：

| Method (REST) | Path                               | 用途                                |
|---------------|------------------------------------|------------------------------------|
| new           | /oauth/authorize                   | Authorization E