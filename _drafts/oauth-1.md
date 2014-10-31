---
layout: post
title:  OAuth 2.0 笔记 (1) 世界观 
---
## 缘起

偶然的在Ruby china找到这么好的介绍OAuth的文章，原文是繁体的，特地找了个繁转简的工具转换了一下。注意，

## 正文

最近需要实现 OAuth 2 认证，不是接别人的 OAuth 2 ，而是自己制作出可以让别人接我们的 OAuth 2 的服务（俗称 Provider）。阅读既有的 OAuth 2 server library的源码，比如，[rack-oauth2](https://github.com/nov/rack-oauth2)，却都看不懂。所以花了很长时间来研读[RFC 6749](http://tools.ietf.org/html/rfc6749) 这份 OAuth 2.0 的 spec ，读完之后总算懂 library 的机制。特定记录下来，一来笔记，二来让别人可以透过这篇文章来快速入门 OAuth 2。

以下文字尽量注明 RFC 6749 原文的出处。有些原文我可能会省略，例如与 OAuth 1.0 的差异（spec 里面有些段落有提及）、扩充 OAuth 2.0 的功能 (Extension)，这是为了让文章集中讲解在 OAuth 2.0 的基本使用方式。专有名词基本上不翻译，只适度加注中文，这是为了可以和 [rack-oauth2](https://github.com/nov/rack-oauth2)库中常用的变数名称保持一致。

原作者将 spec 原文的 txt 转成 [Markdown 格式](/assets/backup/rfc6750.md)。

OAuth 2.0 系列文目录

- (1) [世界观]()
- (2) [Client 的注册与认证]()
- (3) [Endpoints 的规格]()
- (4.1) [Authorization Code Grant Flow 细节]()
- (4.2) [Implicit Grant Flow 细节]()
- (4.3) [Resource Owner Credentials Grant Flow 细节]()
- (4.4) [Client Credentials Grant Flow 细节]()
- (5) [生成与换发 Access Token]()
- (6) [Bearer Token 的使用方法]()
- (7) [安全性问题]()
- [各大网站 OAuth 2.0 实现差异]()

## 简介 OAuth 2.0

在传统的 Client-Server 架构里， Client 要访问受保护的资源 (Protected Resoruce) 的时候，要向 Server 出示拥用者 (Resource Owner) 的帐号密码才行。为了让第三方应用程序也可以拿到这些 Resources ，则 Resource Owner 要把帐号密码给这个第三方程序，这样子就会有以下的问题及限制：

-  第三方程序必须储存 Resource Owner 的帐号密码，通常是明文储存。
-  Server 必须支持密码认证，即使密码有天生的信息安全上的弱点。
-  第三方程序会得到几乎完整的权限，可以存取 Protected Resources ，而 Resource Owner 没办法限制第三方程序可以访问 Resource 的时效，以及可以存取的范围 (subset)。
-  Resource Owner 无法只撤回单一个第三方程序的存取权，而且必须要改密码才能撤回。
-  任何第三方程序被破解 (compromized)，就会导致使用该密码的所有资料被破解。

OAuth 解决这些问题的方式，是引入一个认证层 (authorization layer) ，并且把 client 跟 resource owner 的角色分开。在 OAuth 里面，Client 会先索取存取权，来存取 Resource Owner 拥有的资源，这些资源会放在 Resource Server 上面，并且 Client 会得到一组不同于 Resource Owner 所持有的认证码 (credentials) 。

Client 会取得一个 Access Token 来存取 Protected Resources ，而非使用 Resource Owner 的帐号密码。Access Token 是一个字串，记载了特定的存取范围 (scope) 、时效等等的信息。Access Token 是从 Authorization Server 拿到的，取得之前会得到 Resource Owner 的许可。Client 用这个 Access Token 来存取 Resource Server 上面的 Protected Resources 。

实际使用的例子：使用者 (Resource Owner) 可以授权印刷服务 (Client) 去相簿网站 (Resource Server) 存取他的私人照片，而不需要把相簿网站的帐号密码告诉印刷服务。这个使用者会直接授权相簿网站所信任的服务器 (Authorization Server) ，生成一个专属于该印刷服务的认证码 (Access Token)。

OAuth 设计成在 HTTP 使用的。在 HTTP 以外协议中使用 OAuth 则是超出 spec 的范围。

## Section 1

OAuth 2.0 的角色定义

-  Resource Owner - 可以授权别人去存取 Protected Resource 。如果这个角色是人类的话，则就是指使用者 (end-user)。
-  Resource Server - 存放 Protected Resource 的服务器，可以根据 Access Token 来接受 Protected Resource的请求
-  Client - 代表 Resource Owner 去存取 Protected Resource 的应用程序。 "Client" 一词并不指任何特定的实现方式（可以在 Server 上面跑、在一般电脑上跑、或是在其他的设备）。
-  Authorization Server - 在认证 Resource Owner 的许可下，生成 Access Token 的服务器。

Authorization Server 和 Resource Server 的互动方式不在本 spec 的讨论范围内。Authorization Server 跟 Resource Server 可以是同一台，也可以分开。单一台 Authorization Server 生成发的 Access Token ，可以设计成能被多个 Resource Server 所接受。

### Section 1.1 基本流程概观与资料定义

以下是抽象化的流程概观，以比较宏观的角度来描述，不是实际程序运作的流程（图出自 Spec 的 Figure 1）：

    +--------+                               +---------------+
    |        |--(A)- Authorization Request ->|   Resource    |
    |        |                               |     Owner     |
    |        |<-(B)-- Authorization Grant ---|               |
    |        |                               +---------------+
    |        |
    |        |                               +---------------+
    |        |--(C)-- Authorization Grant -->| Authorization |
    | Client |                               |     Server    |
    |        |<-(D)----- Access Token -------|               |
    |        |                               +---------------+
    |        |
    |        |                               +---------------+
    |        |--(E)----- Access Token ------>|    Resource   |
    |        |                               |     Server    |
    |        |<-(F)--- Protected Resource ---|               |
    +--------+                               +---------------+
    
                    Figure 1: Abstract Protocol Flow

上图描述四个角色的互动方式：

(A): Client 向 Resource Owner 请求授权。这个授权请求可以直接向 Resource Owner 发送（如图），或是间接由 Authorization Server 来请求。

(B): Client 得到来自 Resource Owner 的 Authorization Grant （授权许可）。这个 Grant 是用来代表 Resource Owner 的授权，其表达的方式是本 spec 里定义的四种类别 (grant types) 的其中一种（可以扩充）。何种类别，则是依 Client 请求授权的方法、 Authorization Server 支援的类别而异。

(C): Client 向 Authorization Server 请求 Access Token ，Client 要认证自己，并出示 Authorization Grant。

(D): Authorization Server 认证 Client 并验证 Authorization Grant 。如果都合法，就生成 Access Token 。

(E): Client 向 Resource Server 请求 Protected Resource ，Client 要出示 Access Token。

(F): Resource Server 验证 Access Token ，如果合法，就处理该请求。

### Section 1.2 Authorization Grant （授权许可）

**Authorization Grant** 代表了 Resource Owner 授权 Client 可以去取得 Access Token 来存取 Protected Resource 。Grant 不一定是具体的资料，依 spec 里面定义的四种内建流程，有对应不同的 grant type ，甚至在某些流程里面会省略之，不经过 Client。

Client 从 Resource Owner 取得 Authorization Grant 的方式（前段图中的 (A) 和 (B) 流程）会比较偏好透过 Authorization Server 当作中介。见系列文第 3 篇的流程图。

**Access Token** 用来存取 Protected Resource ，是一个具体的字串（string），其代表特定的 scope （存取范围）、时效。概念上是由 Resoruce Owner 授予，Resource Server 和 Authorization Server 共同遵守 (enforced)。

Access Token 可以加上用来取得授权信息的 identifier （编号或识别字等），或内建可以验证的授权信息（如数位签章）。也就是说，可以由 Authorization Server 间接判定这个 Access Token 的 scope 及时效，也可以嵌在 Token 里面，但为了防止窜改，要以加密演算法来实现资料的验证。

Spec 里面只定义抽象层，代替传统的帐密认证，并且 Resource Server 只需要知道 Access Token ，不需要知道其他的认证方式。Access Token 可以有不同的格式、使用方式（如内建加密属性）。Access Token 的内容，以及如何用它来存取 Protected Resource ，则定义在别的文件，像是 RFC 6750 (Bearer Token Usage) 。

### Section 1.3 Access Token Type

Client 要认得 Access Token Type 才能使用之，若拿到认不得的 Type ，则不可以使用之。例如 RFC 6750 定义的 Bearer Token 的用法就是这样：

    GET /resource/1 HTTP/1.1
    Host: example.com
    Authorization: Bearer mF_9.B5f-4.1JqM

### Section 1.5 Refresh Token

Refresh Token 表示用来向 Authorization Server 重新取得一个新的 Access Token 的 Token ，当现有的 Access Token 过期而无效，或是权限不足，需要更多 scopes 才能存取别的 Resource时，就需要使用Refresh Token。在概念上，Refresh Token 代表了 Resource Owner 授权 Client 重新取得新的 Access Token 而不需要再度请求 Resource Owner 的授权。Client 可以自动做这件事，例如 Access Token 过期了，自动拿新的 Token，来让应用程序的流程更顺畅。

需注意新取得的 Access Token 时效可能比以前短、或比 Resource Owner 给的权限更少。

Authorization Server 不一定要生成 Refresh Token ，但若要生成，必须在生成 Access Token 的时候一并合发。某些内建流程会禁止生成 Refresh Token。

Refresh Token 应该只递交到 Authorization Server ，不该递交到 Resource Server 。

Refresh Token 的流程图：

    +--------+                                           +---------------+
    |        |--(A)------- Authorization Grant --------->|               |
    |        |                                           |               |
    |        |<-(B)----------- Access Token -------------|               |
    |        |               & Refresh Token             |               |
    |        |                                           |               |
    |        |                            +----------+   |               |
    |        |--(C)---- Access Token ---->|          |   |               |
    |        |                            |          |   |               |
    |        |<-(D)- Protected Resource --| Resource |   | Authorization |
    | Client |                            |  Server  |   |     Server    |
    |        |--(E)---- Access Token ---->|          |   |               |
    |        |                            |          |   |               |
    |        |<-(F)- Invalid Token Error -|          |   |               |
    |        |                            +----------+   |               |
    |        |                                           |               |
    |        |--(G)----------- Refresh Token ----------->|               |
    |        |                                           |               |
    |        |<-(H)----------- Access Token -------------|               |
    +--------+           & Optional Refresh Token        +---------------+
    
            Figure 2: Refreshing an Expired Access Token

(A) Client 向 Authorizatino Server 出示 Authorization Grant ，来申请 Access Token 。

(B) Authorization Server 认证 Client 并验证 Authorization Grant 。如果都合法，就生成 Access Token 。

(C) Client 向 Resource Server 请求 Protected Resource ，Client 要出示 Access Token。

(D) Resource Server 验证 Access Token ，如果合法，就处理该请求。

(E) 步骤 (C) 和 (D) 一直重复，直到 Access Token 过期。如果 Client 自己知道 Access Token 过期，就跳到 (G)；如则，就发送另一个 Protected Request 的请求。

(F) 因为 Access Token 不合法，Resource Server 回传 Token 不合法的错误。

(G) Client 向 Authorization Server 请求 Access Token ，Client 要认证自己，并出示 Refresh Token。Client 认证的必要与否，端看 Client Type 以及 Authorization Server 的政策。

(H) Authorization Server 认证 Client 、验证 Refresh Token ，如果合法，就生成新的 Access Toke （也可以同时生成新的 Refresh Token）

步骤 (C), (D), (E), (F) 关于 Resource Server 如何处理 request 、检查 Access Token 的机制，不在本 spec 的范围内，跟 Token 的格式有关。RFC 6750 的 Bearer Token 有定义，见系列文第 6 篇。

### Section 1.5 四种内建授权流程 (Grant Flows)

Spec 里面定义了四种流程，分别是:

-  Authorization Code Grant Type Flow
-  Implicit Grant Type Flow
-  Resource Owner Password Credentials Grant Type Flow
-  Client Credentials Grant Type Flow

此外还可以扩充。根据流程的不同，有不同的实现细节。Client 的类型也会限制可以实现的流程，例如 Native App 就不准使用 Client Credentials ，因为这些密码会外泄。

实务上不需要实现所有流程。我看了许多大网站的 OAuth 2 API，大部份会支援 Authorization Code Grant Flow，其他的则不一定。之后写一篇文章整理。

这里提一下 Clients 的类型，分成 Public 和 Confidential 两种，根据能不能保密 Client Credentials 来区分，可以的就是 Confidential （如 Server 上的程序），不行的就是 Public （如 Native App、In-Browser App）。详见[系列文第 2 篇]()。

(1) Authorization Code Grant Flow

-  要向 Authorization Server 先取得 Grant Code 再取得 Access Token （两步）。
-  适合 Confidential Clients ，如部署在 Server 上面的应用程序。
-  可以生成 Refresh Token。
-  需要 User-Agent Redirection。

(2) Implicit Grant Flow

-  Authorization Server 直接向 Client 生成 Access Token （一步）。
-  适合非常特定的 Public Clients ，例如跑在 Browser 里面的应用程序。
-  Authorization Server 不必（也无法）验证 Client 的身份。
-  禁止生成 Refresh Token。
-  需要 User-Agent Redirection。
-  有资料外泄风险。

(3) Resource Owner Password Credentials Grant Flow （使用者的帐号密码）

-  Resource Owner 的帐号密码直接拿来当做 Grant。
-  适用于 Resource Owner 高度信赖的 Client （像是 OS 内建的）或是官方应用程序。
-  其他流程不适用时才能用。
-  可以生成 Refresh Token。
-  没有 User-Agent Redirection。

(4) Client Credentials Grant Flow （Client 的帐号密码）

-  Client 的 ID 和 Secret 直接用来当做 Grant
-  适用于跑在 Server 上面的 Confidential Client
-  不建议生成 Refresh Token 。
-  没有 User-Agent Redirection。

**技术要求**: 必须全程使用 TLS (HTTPS)

因为资料在网路上面传递会被抓取或截获，所以 Spec 里面规定全程必须使用 TLS ，而因为 OAuth 是基于 HTTP 的，所以就是统统要使用 https 。实际上，定义在 Endpoints时，某些 Client 无法实现有 TLS 的 Endpoint ，则会适度放宽限制。所以虽然这段写的是「全程使用」，实际上是只有一些地方有规定需要经过 TLS ，但这个「一些」就包含了几乎所有经过网路的地方，所以我就直接写全程了。

至于 TLS 的版本，在 spec 写成的时候，最新版是 TLS 1.2 ，但实务上利用最广泛的却是 TLS 1.0 。所以在 Spec 里似乎没有明确定义 TLS 的版本。

### Section 1.6 User-Agent 要支援 HTTP Redirection

OAuth 2 用 HTTP 重定向 (Redirection) 极其频繁， Client 或 Authorization Server 用重定向来把 Resource Owner 的 User-Agent 转到别的地方。另外虽然 spec 里面的范例都是 302 重定向，若要用别的方式来转址也行，这属于实现细节。

### Section 1.7 存取 Protected Resource 的方式

关于 Client 如何利用 Access Token 存取 Protected Resource 的方式，在 OAuth 2.0 的 spec 里面只有定义概念，具体的机制没有定义：

-  Client 要出示 Access Token 来向 Resource Server 存取 Protected Resource。
-  具体出示机制不定义，通常是用 Authorization header 搭配该 Access Token 定义的 auth scheme ，如 Bearer Token (RFC 6750) ，见系列文第 6 篇。
-  Resource Server 必须验证 Access Token 并确认其尚未过期、确认其 scope 包含所要存取的 resource 。
-  具体验证机制不规定，通常是 Authorization Server 和 Resource Server 之间互相传输资料 (interaction) 以及同步化 (coordination)。

## Section 7 错误的回应方式

Spec 里面也不定义机制，只定义了概念以及基本的共用协定：

-  要是 Resource Request 失败，则 Server 最好要提示错误 。至于 error code ，登记的方式规定在 Section 11.4。
-  任何新定义的 Authentication Scheme （如 Bearer Token）都最好要定义一个机制来提示错误，其 value 要使用 OAuth 2.0 spec 里面规定的方式定义。
-  新定义的 Scheme 可能会只使用子集。
-  如果 error code 用具名参数（如 JSON 之类的 dictionary）回传，则其参数名称必须使用 error。
-  要是有个 Scheme 可以用在 OAuth 但不是专门设计给 OAuth ，则可以用一样的方式来把它里面的 error code 清单拿进来用 ※。
-  新定义的 Scheme 可以用 `error_description` 和 `error_uri` ，其意义要跟 OAuth 定义的一致。

※ MAY bind their error values to the registry in the same manner

Section 7.2

Section 11.4 里面有规定怎么提出新 error code 的 proposal ，有兴趣的同学就看一下吧

## 后记

感觉也没什么吗。OAuth，利用HTTP的请求头 以及 TLS。
