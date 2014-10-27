---
layout: post
title: OAuth 2.0 笔记 (3) Endpoints 的规格 
---


在 OAuth 2.0 里面，Endpoints （资料传输接点）共有三种：

    Authorization Server 的 Authorization Endpoint
    Client 的 Redirection Endpoint
    Authorization Server 的 Token Endpoint

其规格如下文，不能只看名称来判别其用途，像是 Authorization Endpoint 其实是一点多用，在某些流程里会发 Authorization Grant Code ，有些流程会直接发 Access Token ，有些流程会略过之。

使用的顺序大致上是 Authorization Endpoint → Redirection Endpoint → Token Endpoint 。

可以发现到 Resource Server 上面并没有定义任何 Endpoints ，这是因为取得 Access Token 的流程与 Resource Server 无关， Resource Server 只需要认 Access Token 并且向 Authorization Server 验证 Token 合法就行了。
Authorization Endpoint (Authorization Server)

Authorization Endpoint 主要是给 Client 从 Resource Owner 取得 Authorization Grant 用的，其过程会透过 User-Agent 转向。

在内建的四种流程中，只有 Authorization Code Grant Flow 和 Implicit Grant Flow 才会使用到。

处理过程中，必须先认证 Resource Owner ，但认证方法在 spec 里面不明确定义，或许是帐密、或许是 session cookie 。也就是说要登入这个使用者。

Client 得知 Authorization Endpoint 的方法不定义，通常是直接写在服务的文件里面。
URI 要求

    URI 里面可以有 Query Component（如 ?xxx=yyy），但是当要加入其他 parameter 的时候，必须保留既有的 parameters 。
    URI 里面不可以有 Fragment Component （#zzz）。

HTTP Method

必须支援 GET。可以支援 POST（非必备）。
传递的参数
参数名 	必/选 	意义
response_type 	必 	会 switch 到不同的 flow ，见下文 Response Type 段
state 	建议有 	通用参数，用来维持最初状态，见下文
scope 	选 	通用参数，用来指定存取范围，见下文
Response Type

Response Type 透过 response_type 参数来指定，其值定义如下：
值 	意义
code 	求 Authorization Code (Authorization Code Flow)
token 	求 Access Token (Implicit Flow)
（其他） 	为 extension ，若有多个，可以以空格分开

若 response_type 欠缺或认不得，必须回错误，见下文。
参数解析原则

    留空的参数要当做没有提供 (omitted) 。例如 response_type=code&state= 要当做没给 state 参数。
    认不得的参数必须忽略之。
    每个参数只能出现一次，不可重复出现。若有重复，则要回传错误。

TLS (https) 要求

必须经过 TLS ，因为 response 里面有 credentials 会被看到。
遇到错误的时候的处理方式

所谓错误，像是参数错误、Client 不被授权使用这种 Authorization 、Server 不支援这种 Authorization 等等。虽然 Spec 里面的四种流程，有用到 Authorization Endpoint 的（其实就是 Authorization Code 和 Implicit），其处理方式都一样，但是只使用于内建流程， Extension 可能会使用更多的，所以不写在这篇里面。

你只要知道 spec 里面的内建流程，对于 Authorization Endpoint 的错误处理方式是一模一样的就好了。

Section 3.1, 3.1.1
Redirection Endpoint (Client)

Authorization Server 在完成与 Resource Owner 的互动之后（认证 Resource Owner 、提示 Client 要请求授权之类的），会把 Resource Owner 的 User-Agent 转回 Cilent ，这个转回去的目标就是 Redirection Endopoint 。

在内建的四种流程中，只有 Authorization Code Flow 和 Implicit Flow 才会使用到。

注：本文省略关于多重 Redirection URI 和动态设置 (Dynamic Configuration) 的 spec 的解说，因为一来我看不懂，二来我没用过要指定多个 Redirection URI 的 OAuth 服务，所以不清楚它的用途，我想对于入门来说应该是不需要说明（我也没能力说明）。有兴趣的同学可以看 spec 的 Section 3.1.2.3 。
Client 设定 Redirection Endpoint

Redirection Endpoint 可以在 Client 注