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

Redirection Endpoint 可以在 Client 注册的时候设定，或是在发出 Authorization Request 的时候指定。

以下这些类型的 Clients 必须设定 Redirection Endpoint：

    Public Client
    Confidential Client 且利用 Implicit Grant Type

Authorization Server 应该要要求所有 Clients 在使用 Authorization Endpoint 之前，都设定 Redirection Endpoint。会要求设定 Redirection Endpoint，是为了防止坏人利用 Authorization Endopint 做为 open redirector 。详见本文最末段，关于安全性的问题。
Authorize 时，Redirection URI 不正确的处理方式

如果 Authorization Server 验证 Redirection URI 失败（没注册、不相符等情况），则 Authorization Server 应该提示错误，并且 不可以自动转回 错误的 Redirection URI 。
URI 的要求

    必须是 Absolute URI （就是下图的 scheme + hierarchical + query (选用)）。定义在 RFC3986 的 Section 4.3。
    URI 里面可以有 Query Component（如 ?xxx=yyy），但是当要加入其他 parameter 的时候，必须保留既有的 parameters 。
    URI 里面不可以有 Fragment Component （#zzz）。

若无法指定完整的 URI （像是不能指定 Query Component），则应该要求指定 URI 的 scheme 、 authority 、 path 这三个部份（见下图）。

就我的理解可以给出以下范例：
OK? 	Example 	Reason
◯ 	https://www.example.com/oauth/callback 	
◯ 	https://www.example.com/oauth/callback?origin=facebook 	
✕ 	https://www.example.com 	没有 path part

根据维基百科的解释，即是 Query Component 之前的所有部份，亦即仅允许 Client 自订 Query Component：

  foo://username:password@example.com:8042/over/there/index.dtb?type=animal&name=narwhal#nose
  \_/   \_______________/ \_________/ \__/            \___/ \_/ \______________________/ \__/
   |           |               |       |                |    |            |                |
   |       userinfo         hostname  port              |    |          query          fragment
   |    \________________________________/\_____________|____|/ \__/        \__/
   |                    |                          |    |    |    |          |
scheme              authority                    path   |    |    interpretable as keys
 name   \_______________________________________________|____|/       \____/     \_____/
                             |                          |    |          |           |
                     hierarchical part                  |    |    interpretable as values
                                                        |    |
                                interpretable as filename    interpretable as extension

TLS (HTTPS) 的要求

Redirection Endpoint 在以下任一种情况，应该要有 TLS ：

    发出 Authorization Request 时的 Response Type 为 code 或 token （= 内建流程的每一种）。
    重新转向的时候会经由公开网路传递敏感资料。

然而这个并不强求，因为现阶段有些 Client 实作 TLS 有困难。因此，若重新转向的目标并不是 TLS (https) ，则 Authorization Server 应该要向 Resource Owner 提出警告。
关于 Redirection Endpoint 的内容的建议

所谓的内容，就是当 User-Agent 打开 Redirection Endpoint URI 的时候看到的内容，通常是 HTML ，所以如果 HTML 直接在 Redirection Request 输出的话，任何 script 都可以拿到 Redirection URI 及包含在其中的 credentials 。

因此有这些建议：

    Client 应该直接从 URI 里面解出 credentials ，并且马上 redirect 到别的地方以防外泄。
    Client 不应该在 Redirection Response 里面载入第三方 script （Analytics 、社交网站、广告等）。
    若第三方 script 无法避免，则 Client 必须确保自己的 script 先跑，先把 credentials 解出来，并且移除 credentials 。

从 Rails 的实作方式来说，就是直接在 Controller 里面解出 credentials ，存进 Model ，然后 redirect 到别的 path 就行了。

Section 3.1.2 - 3.1.2.5
Token Endpoint (Authorization Server)

Token Endpoint 是 Client 用来拿取 Access Token 的。拿取的时候，要出示 Authorization Grant （第一次拿 Access Token）或 Refresh Token （旧的 Access Token 不能用，要重新拿新的）。

在内建的四种流程里，只有 Implicit Grant Type 不使用之，因为这个流程的 Access Token 是直接在 Authorization Endpoint 那边就直接给了。

在 Token Endpoint 处理的流程中，有一步是认证 Client ，用来确认 Client 的身份。详见「关于认证 Client 的说明」一段。

Client 得知 Token Endpoint 的方法不定义，通常是直接写在服务的文件里面。（同 Authorization Endpoint）
HTTP Method

必须使用 POST。Client 在发送 Token Request 的时候，也必须使用 POST 。
URI 要求

（同 Authorization Endpoint）

    URI 里面可以有 Query Component（如 ?xxx=yyy），但是当要加入其他 parameter 的时候，必须保留既有的 parameters 。
    URI 里面不可以有 Fragment Component （#zzz）。

传递的参数

虽然在 Token Endpoint 的 Spec 里面没有写到必备的参数，但我整理了四种内建流程以及换发 Token 的流程之后，总结出「一定要有 Grant Type」这个事实，所以在这里写下来。还有其他参数，但是会根据流程的不同而不同。
参数名 	必/选 	意义
grant_type 	必 	会 switch 到不同的 flow ，见下文 Grant Type 段
state 	建议有 	通用参数，用来维持最初状态，见下文
scope 	选 	通用参数，用来指定存取范围，见下文
Grant Type

Grant Type 透过 grant_type 参数来指定，其值定义如下：
值 	意义
authorization_code 	用 Authorization Code 求 Access Token
(Authorization Code Grant Flow)。
password 	用 Resorce Owner Password Credentials 求 Access Token
(Resource Owner Password Credentials Grant Flow)。
client_credentials 	用 Client Credentials 求 Access Token
(Client Credentials Grant Flow)。
refresh_token 	用 Refresh Token 换发 Access Token。

至于更多 Grant Types 可以参考 Section 8.3。

Grant Type 没给，或不认得的时候，回应错误的方式见系列文第 5 篇。
参数解析原则

（同 Authorization Endpoint）
TLS (https) 要求

必须经过 TLS ，因为 request 和 response 里面都有 credentials 会被看到。
Response 的方式

由于这个 Endpoint 是专门用来核发 Access Token 的，其 Response 的方式以及错误回应方式，我写在系列文第 5 篇。
关于认证 Client 的说明

在 Token Endpoint 的流程里面，有一步是要认证 Client ，需要认证的 Clients 是 Confidential Clients 或是有发给 Client Credentials 的 Clients 。

实际认证的机制，规定在 Section 2.3 里面（系列文第 2 篇）。简单来说，要用 HTTP Basic Auth 来认证，设 Client Credential 为：ID s6BhdRkqt3 、 Secret 7Fjfp0ZBr1KtDRbnfVdmIw ，那么在 Client 往 Token Endpoint 发 Request 的时候， Request Header 里面要有这个：

Authorization: Basic czZCaGRSa3F0Mzo3RmpmcDBaQnIxS3REUmJuZlZkbUl3

认证 Client 是为了：

    强化「Refresh Token ↔ 核发的对象 Client」与「Authorization Code ↔ 授予的对象 Client」之间的关系。当 Authorization Code 要透过不安全通道传到 Redirection Endpoint 的时候，或是 Redirection URI 没有全部注册的时候（动态组态，本文略），Client 认证就显得很重要。
    用来复原被骇掉的 Client ，做法是禁用或更改它的 Credentials ，这样子可以防止坏人滥用被偷走的 Refresh Token。替换单独一组 client credential 比撤销整组 Refresh Tokens 还要来得快。
    实施认证管理的最佳实践 (Best Practice)，即是要求定期更换 credentials。更换所有的 Refresh Token 是很难做到的，而定期更换单独一组 credential 却很容易。

在某些流程里，Client 会用 client_id 参数来识别自己。像是在 Authorization Code Grant 流程里面，发 Request 到 Access Token 的时候，没有认证的 Client （如 Public Client）就必须用 client_id 来避免收到给别的 Client 的 Access Token，Authorization Server 也可以借此防止 Client 自己置换 Authorization Code。需注意这个方法并不会为 Proteected Resource 带来额外的保护。

Section 3.2 - 3.2.1
Endpoints 通用的参数
scope: 指定存取范围

Authorization Endpoint 和 Token Endpoint 允许 Client 指定申请 Access Token 的时候所要的 scopes （存取范围）。

参数名称是 scope。格式是一串 scopes 用空格 (U+0020) 分开，区分大小写。每一个 scope 的值是由 Authorization Server 定义的，格式是 ASCII 可见字元，排除双引号 " (U+0022) 和反斜线 \ (U+005C)。顺序不重要。每出现一个 scope 值，就代表要多加一个新的 scope。

根据 Authorization Server 制定的政策，以及 Resource Owner 的指示，可以完全或部份忽略某些 scopes。在这种情况下，scope 值也会在 Endpoint Response 里面回传，也就是当真正授予的 scopes 与原本要求的不同的时候告诉 Client。所以可能比原本要求的 scopes 还要少，也可能还要多。

假如 Client 在申请 Authorization 的时候，没有给 scope 值，则 Authorization Server 必须做以下之中的一件事：

    用预设值处理（若有）。
    回报错误，提示 scope 不合法。

处理方式、预设值、 scope 的要求，应该要写在 Authorization Server 文件里。
实务上的 scope

实务上大部份网站的 OAuth 2.0 实作方式， scope 都是用逗号 (,, U+002C) 分隔的，有的甚至不存在 scope 这种东西，一授权就是 full access。之后会写一篇文章来整理。

Section 3.3
state: 维持 Endpoint 之间的操作状态

Endpoint 之间可以用 state 参数来维持操作状态，例如这种情况：

    我打开 A 网站的 X 页面
    我按下「登入」按钮来登入 A 网站，用 Facebook 帐号来登入
    Facebook 完成登入流程之后，回到 A 网站
    我希望我看到的是 A 网站的 X 页面←【目标】

要达到这个目标，就可以用 state 参数来维持「使用者之前在看 X 页面」这个状态。

state 参数在传递的过程中会原封不动，所以 Client 最后一定会得到原本的 state 。

又，因为 state 可能会放在 URI 里面，所以如果里面有敏感资料，则可能会留下痕迹（像是 Log 、 Proxy 的 Log 等等），所以最好是 Client 有内建加解密机制，这样子在传递的过程就不会被抄走。

state 也可以应用在防止 CSRF ，见 Section 10.12 （系列文第 7 篇 ）。
安全性问题
Open Redirectors (Section 10.15)

Open Redirector 指的是 Endpoint 使用某参数来自动把 User-Agent 转向到该参数所指定的位置，而没有经过事先验证。Auothorization Server 、 Authorization Endpoint 、 Client Redirection Endpoint 可能会因为设定的不好所以变成 Open Redirector。

Open Redirectors 会被利用在钓鱼攻击，或是让坏人得以伪造 URI 的 authority part 让它看起来很像可信任的网站，引导使用者前往恶意网站。此外，如果 Authorization Server 允许 Client 只事先指定 Redirection URI 的一部分，那么坏人可以利用 Client 操作的 Open Redirector 来建立一个 Redirection URI ，这个 URI 跳过 Authorization Server 验证，但是会把 Authorization Code 或 Access Token 传送到坏人所控制的 endpoint。

在Amazon 的文件里面，提出了 Open Redirector 常有的 pattern ：

    example.com/go.php?url=
    example.com/search?q=user+search+keywords&url=
    example.com/coupon.jsp?code=ABCDEF&url=
    example.com/login?url=

这种「疑似可以手动指定之后要再转去别的地方」的参数容易变成 Open Redirector。
