---
layout: post
title: OAuth 2.0 笔记 (4.2) Implicit Grant Flow 细节
---

在 Implicit Grant Flow 里，Authorization Server 直接向 Client 核发 Access Token ，而不像 Authorization Code Grant Flow ，先核发 Grant ，再另外去拿 Access Token。

Authorization Server 核发 Access Token 的时候，不认证 Client （其实也无法认证），在某些情况下，可以用 Redirection URI 来确保 Access Token 只发给正确的 Client 。这种流程依赖 Resource Owner 本人的存在，以及事先设定的 Redirection URI。

这种流程是专门为特定的 Public Client 来优化的，例如跑在 Browser 里面的应用程式。但也因此有外泄风险，例如：

    Resource Owner 可以看到 Access Token
    其他可以存取 User-Agent 的应用程式，也可以看到 Access Token
    Access Token 传输时，会直接出现在 Redirection URI 里面，所以 Resource Owner 以及同一台设备的应用程式可以看到

因为需要实施转址，所以 Client 要可以跟 Resource Owner 的 User-Agent (Browser) 互动，也要可以接收从 Authorization Server 来的 Redirection Request。（同 Authorization Code Grant Flow）

最后拿到的只有 Access Token ，不会拿到 Refresh Token （禁止核发 Refresh Token）。

这是 OAuth 2.0 内建的四个流程之一。本文整理自 Section 4.2。
流程图

+----------+
| Resource |
|  Owner   |
|          |
+----------+
     ^
     |
    (B)
+----|-----+          Client Identifier     +---------------+
|         -+----(A)-- & Redirection URI --->|               |
|  User-   |                                | Authorization |
|  Agent  -|----(B)-- User authenticates -->|     Server    |
|          |                                |               |
|          |<---(C)--- Redirection URI ----<|               |
|          |          with Access Token     +---------------+
|          |            in Fragment
|          |                                +---------------+
|          |----(D)--- Redirection URI ---->|   Web-Hosted  |
|          |          without Fragment      |     Client    |
|          |                                |    Resource   |
|     (F)  |<---(E)------- Script ---------<|               |
|          |                                +---------------+
+-|--------+
  |    |
 (A)  (G) Access Token
  |    |
  ^    v
+---------+
|         |
|  Client |
|         |
+---------+

注: (A), (B) 这两步的线拆成两段，因为会经过 user-agent

                    Figure 4: Implicit Grant Flow

(A) Client 把 Resource Owner 的 User-Agent 转到 Authorization Endpoint 来启动流程。Client 会传送：

    Client ID
    申请的 scopes
    内部 state
    Redirection URI，申请结果下来之后 Authorization Server 要转址过去。

(B) Authorization Server 通过 User-Agent 认证 Resource Owner，并确定 Resource Onwer 许可或驳回Client 的存取申请。

(C) 假设 Resource Owner 许可了存取申请， Authorization Server 会把 User-Agent 转回去先前指定的 Redirection URI ，其中包含 Access Token ，放在 Fragment Component 里面。

(D) User-Agent 跟随转址的指示，发出 Request 到 Web-Hosted Client Resource ，这个 Request 里面不会有刚刚拿到的 Fragment ， User-Agent 自己保留 Fragment 。（注）

(E) Web-Hosted Client Resource 回传一个网页（HTML & JavaScript），这个网页可以拿到完整的 Redirection URI （含先前 User-Agent 保留的 Fragment）、把 Fragment 里面的 Access Token 和其他参数给解出来。（注）

(F) User-Agent 执行从 Web-Hosted Client Resource 来的 Script 把 Access Token 解出来。

(G) User-Agent 把 Access Token 传给 Client。

注： (D) 之后的有点抽象，我的理解是这样：

    Web-Hosted Client Resource 当作你自己架的 App Server ，在上面开 Redirection Endpoint ，所以这个流程其实 Client 本体 (JavaScript App) 没有 Endpoint ，Endpoint 是开在一个 HTTP(s) Server 上面。
    Browser 事实上在 Access http://example.com/cb#access_token =123 的时候，只会发送 http://example.com/cb 的 request ，在 Request 里面不会有 #access_token=123
    所以 (D) 所谓「Request 不含 Fragment，User-Agent 自己保留 Fragment」这一步是 User-Agent 自动做的， Client 开发者不需要用 JavaScript 特别处理，只要把 Redirection Endpoint 指定给自己的 App Server 就可以了。
    而 (E) 所谓「回传一个网页来解出 User-Agent 保留的 Fragment」，就是说 User-Agent 打 Request 到 Redirection URI （含 Fragment，但不会传送到 Server）的时候，他的 response 里面包含 JavaScript ，而上面说了，Fragment 是自动保留在 User-Agent 的，所以这个 Response 在 Server 那边不会知道有 Fragment 的存在，也就不会知道 Access Token 的存在，而是 User-Agent 才知道。
    所以 (F) 就是跑这个 script 解出 Access Token 和参数，(G) 把 (F) 的执行结果塞给 Client (JavaScript App)。

也就是说其实是设计给不能听 Redirection Endpoint 的 In-Browser JavaScript App 的解法。我看到的用法是 Google 的 OAuth 2.0 for Client-side JavaScript。
(A) Authorization Request

【User-Agent】GET ▶【Authorization Endpoint】

第一步是 Client 产生一个 URL 连到 Authorization Endpoint ，要 Resource Owner 打开（点击）这个 URL ，从而产生「向 Authorization Endpoint 发送 GET request」的操作。

把参数包在 URI 的 query component 里面。
参数
参数名 	必/选 	填什么/意义
response_type 	必 	token
client_id 	必 	自己的 Client ID
state 	建议有 	内部状态
redirect_uri 	选 	申请结果下来之后要转址去哪里
scope 	选 	申请的存取范围

其中的 state， Authorization Server 转回 Client 的时候会附上。可以防范 CSRF ，所以最好是加上这个值，详见系列文第 7 篇关于 CSRF 的安全性问题。
Authorization Server 的处理程序

因为 Implicit Grant Flow 是直接在 Authorization Endpoint 发 Access Token ，所以资料验证和授权都在这一步处理。所以这个 Request 进来的时候， Authorization Server 要做这些事：

    验证所有必须给的参数都有给且合法
    Redirection URI 与预先在 Authorization Server 设定的相符。

如果没问题，就询问 Resource Owner 是否授权，即 (B) 步骤。
(C) Authorization Response

【Client】 ◀ 302【Authorization Endpoint】

是 Resource Owner 在 (B) 决定授权与否之后回应的 Response。

在 (B) 里面， Resource Owner 若同意授权，这个「同意授权」的 request 会往 Authorization Endpoint 发送，接著会收到 302 的转址 response ，里面带有「前往 Client 的 Redirection Endpoint 的 URL」的转址 (Location header)，从而产生「向 Redirection URI 发送 GET Request」的操作。

参数要用 URL Encoding 编起来，放在 Fragment Component 里面。

若 Access Token Request 合法且有经过授权，则核发 Access Token。如果 Client 认证失败，或 Request 不合法，则依照 Section 5.2 的规定回复错误。

特别注意 Implicit Grant Type 禁止 核发 Refresh Token。

某些 User-Agent 不支援 Fragment Redirection ，这种情况可以使用间接转址，即是转到一个页面，放一个 "Continue" 的按钮，按下去连到真正的 Redirection URI 。
参数
参数名 	必/选 	填什么/意义
access_token 	必 	即 Access Token
expires_in 	建议有 	几秒过期，如 3600 表示 10 分钟。若要省略，最好在文件里注明效期。
scope 	必* 	Access Token 的授权范围 (scopes)。
state 	必* 	原内部状态。

其中 scope 如果和 (A) 申请的不同则要附上，如果一样的话就不必附上。

其中 state 如果 (A) 的时候有附上，则 Resopnse 里面必须有，完全一致的原值。如果原本就没有，就不需要回传。

Access Token 的长度由 Authorization Server 定义，应写在文件中， Client 不可以瞎猜。

Client 遇到不认识的参数必须忽略。
范例

HTTP/1.1 302 Found
Location: http://example.com/cb#access_token=2YotnFZFEjr1zCsicMWpAA
          &state=xyz&token_type=example&expires_in=3600

错误发生时的处理方式

跟 Authorization Code Grant Flow 相同，差别在于错误的内容是放在 Fragment Component 而不是 Query Component。请参考系列文第 4.1 篇关于 Authorization Code Grant Flow 的 Access Token Request 错误处理原则。

例如：

HTTP/1.1 302 Found
Location: https://client.example.com/cb#error=access_denied&state=xyz

安全性问题

在 spec 里面提及的安全性问题写在 Section 10.3 和 10.16 ，其中 10.3 只是特别提到 Implicit Grant Type 「透过 URI Fragment 来传 Access Token ，所以可能会外泄」，而 10.16 则是针对 Implicit Grant Type 可能会有伪造 Resource Owner 的安全性问题。其中 10.3 关于 Access Token 保密的问题，见系列文第 7 篇。
误用 Access Token 来在 Implicit Flow 里面伪装 Resource Owner (Section 10.16)

这个 Section 的原文我看不太懂，似乎是在说，这流程里面会有漏洞让坏人可以置换 Access Token ，原本是要给 A Client 的 Token 到了 B Client 的手上。Amazon 的文件 里面有提到，他的建议是，在真的拿 Token 来用之前，要去 Authorization Server 问一下是不是真是给这个 Client 用的，不是的话就不能用。

新浪微博 API 的「用户身份伪造」应该也是在讲类似的事。
xiajian@xiajian-Inspiron:~/works/test$ vi oa.txt 
xiajian@xiajian-Inspiron:~/works/test$ opencc -i oa.txt -c zht2zhs.ini
    =123 的时候，只会发送 http://example.com/cb 的 request ，在 Request 里面不会有 #access_token=123
    所以 (D) 所谓「Request 不含 Fragment，User-Agent 自己保留 Fragment」这一步是 User-Agent 自动做的， Client 开发者不需要用 JavaScript 特别处理，只要把 Redirection Endpoint 指定给自己的 App Server 就可以了。
    而 (E) 所谓「回传一个网页来解出 User-Agent 保留的 Fragment」，就是说 User-Agent 打 Request 到 Redirection URI （含 Fragment，但不会传送到 Server）的时候，他的 response 里面包含 JavaScript ，而上面说了，Fragment 是自动保留在 User-Agent 的，所以这个 Response 在 Server 那边不会知道有 Fragment 的存在，也就不会知道 Access Token 的存在，而是 User-Agent 才知道。
    所以 (F) 就是跑这个 script 解出 Access Token 和参数，(G) 把 (F) 的执行结果塞给 Client (JavaScript App)。

也就是说其实是设计给不能听 Redirection Endpoint 的 In-Browser JavaScript App 的解法。我看到的用法是 Google 的 OAuth 2.0 for Client-side JavaScript。
(A) Authorization Request

【User-Agent】GET ▶【Authorization Endpoint】

第一步是 Client 产生一个 URL 连到 Authorization Endpoint ，要 Resource Owner 打开（点击）这个 URL ，从而产生「向 Authorization Endpoint 发送 GET request」的操作。

把参数包在 URI 的 query component 里面。
参数
参数名 	必/选 	填什么/意义
response_type 	必 	token
client_id 	必 	自己的 Client ID
state 	建议有 	内部状态
redirect_uri 	选 	申请结果下来之后要转址去哪里
scope 	选 	申请的存取范围

其中的 state， Authorization Server 转回 Client 的时候会附上。可以防范 CSRF ，所以最好是加上这个值，详见系列文第 7 篇关于 CSRF 的安全性问题。
Authorization Server 的处理程序

因为 Implicit Grant Flow 是直接在 Authorization Endpoint 发 Access Token ，所以资料验证和授权都在这一步处理。所以这个 Request 进来的时候， Authorization Server 要做这些事：

    验证所有必须给的参数都有给且合法
    Redirection URI 与预先在 Authorization Server 设定的相符。

如果没问题，就询问 Resource Owner 是否授权，即 (B) 步骤。
(C) Authorization Response

【Client】 ◀ 302【Authorization Endpoint】

是 Resource Owner 在 (B) 决定授权与否之后回应的 Response。

在 (B) 里面， Resource Owner 若同意授权，这个「同意授权」的 request 会往 Authorization Endpoint 发送，接著会收到 302 的转址 response ，里面带有「前往 Client 的 Redirection Endpoint 的 URL」的转址 (Location header)，从而产生「向 Redirection URI 发送 GET Request」的操作。

参数要用 URL Encoding 编起来，放在 Fragment Component 里面。

若 Access Token Request 合法且有经过授权，则核发 Access Token。如果 Client 认证失败，或 Request 不合法，则依照 Section 5.2 的规定回复错误。

特别注意 Implicit Grant Type 禁止 核发 Refresh Token。

某些 User-Agent 不支援 Fragment Redirection ，这种情况可以使用间接转址，即是转到一个页面，放一个 "Continue" 的按钮，按下去连到真正的 Redirection URI 。
参数
参数名 	必/选 	填什么/意义
access_token 	必 	即 Access Token
expires_in 	建议有 	几秒过期，如 3600 表示 10 分钟。若要省略，最好在文件里注明效期。
scope 	必* 	Access Token 的授权范围 (scopes)。
state 	必* 	原内部状态。

其中 scope 如果和 (A) 申请的不同则要附上，如果一样的话就不必附上。

其中 state 如果 (A) 的时候有附上，则 Resopnse 里面必须有，完全一致的原值。如果原本就没有，就不需要回传。

Access Token 的长度由 Authorization Server 定义，应写在文件中， Client 不可以瞎猜。

Client 遇到不认识的参数必须忽略。
范例

HTTP/1.1 302 Found
Location: http://example.com/cb#access_token=2YotnFZFEjr1zCsicMWpAA
          &state=xyz&token_type=example&expires_in=3600

错误发生时的处理方式

跟 Authorization Code Grant Flow 相同，差别在于错误的内容是放在 Fragment Component 而不是 Query Component。请参考系列文第 4.1 篇关于 Authorization Code Grant Flow 的 Access Token Request 错误处理原则。

例如：

HTTP/1.1 302 Found
Location: https://client.example.com/cb#error=access_denied&state=xyz

安全性问题

在 spec 里面提及的安全性问题写在 Section 10.3 和 10.16 ，其中 10.3 只是特别提到 Implicit Grant Type 「透过 URI Fragment 来传 Access Token ，所以可能会外泄」，而 10.16 则是针对 Implicit Grant Type 可能会有伪造 Resource Owner 的安全性问题。其中 10.3 关于 Access Token 保密的问题，见系列文第 7 篇。
误用 Access Token 来在 Implicit Flow 里面伪装 Resource Owner (Section 10.16)

这个 Section 的原文我看不太懂，似乎是在说，这流程里面会有漏洞让坏人可以置换 Access Token ，原本是要给 A Client 的 Token 到了 B Client 的手上。Amazon 的文件 里面有提到，他的建议是，在真的拿 Token 来用之前，要去 Authorization Server 问一下是不是真是给这个 Client 用的，不是的话就不能用。

新浪微博 API 的「用户身份伪造」应该也是在讲类似的事。
