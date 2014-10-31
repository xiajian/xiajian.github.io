---
layout: post
title: OAuth 2.0 笔记 (4.1) Authorization Code Grant Flow 细节
---

在 Authorization Grant Code Flow 里，Client 不直接向 Resource Owner 要求许可，而是把 Resource Owner 导去 Authorization Server 要求许可， Authorization Server 再透过转址来告诉 Client 授权许可的代码 (code) 。在转址回去之前， Authorization Server 会先认证 Resource Owner 并取得授权。因为 Resource Owner 只跟 Authorization Server 认证，所以 Client 绝对不会拿到 Resource Owner 的帐号密码。

在这种流程里， Authorization Grant Code 会以一个字串 (string) 具体存在，并且传递给 Client ，做为 Authorization Grant （Resource Owner 的授权许可）。在取得 Grant 之后，还没有取得 Access Token ，Client 要再自己去向 Authorization Server 取得 Access Token 。

这个流程是专门为在 Server 执行的 Confidential Client 优化的。

因为需要实施转址，所以 Client 要可以跟 Resource Owner 的 User-Agent (Browser) 互动，也要可以接收从 Authorization Server 来的 Redirection Request。

最后拿到的除了 Access Token 之外，还会拿到 Refresh Token （Authorization Server 有支援的话）。

这是 OAuth 2.0 内建的四个流程之一。本文整理自 Section 4.1。
流程图

+----------+
| Resource |
|   Owner  |
|          |
+----------+
     ^
     |
    (B)
+----|-----+          Client Identifier      +---------------+
|         -+----(A)-- & Redirection URI ---->|               |
|  User-   |                                 | Authorization |
|  Agent  -+----(B)-- User authenticates --->|     Server    |
|          |                                 |               |
|         -+----(C)-- Authorization Code ---<|               |
+-|----|---+                                 +---------------+
  |    |                                         ^      v
 (A)  (C)                                        |      |
  |    |                                         |      |
  ^    v                                         |      |
+---------+                                      |      |
|         |>---(D)-- Authorization Code ---------'      |
|  Client |          & Redirection URI                  |
|         |                                             |
|         |<---(E)----- Access Token -------------------'
+---------+       (w/ Optional Refresh Token)

注: (A), (B), (C) 这三步的线拆成两段，因为会经过 user-agent

                  Figure 3: Authorization Code Flow

(A) Client 把 Resource Owner 的 User-Agent 转到 Authorization Endpoint 来启动流程。Client 会传送：

    Client ID
    申请的 scopes
    内部 state
    Redirection URI，申请结果下来之后 Authorization Server 要转址过去。

(B) Authorization Server 通过 User-Agent 认证 Resource Owner，并确定 Resource Onwer 许可或驳回Client 的存取申请。

(C) 假设 Resource Owner 许可了存取申请， Authorization Server 会把 User-Agent 转回去先前指定的 Redirection URI ，其中包含了：

    Authorization Code
    许可的 scopes （如果跟申请的不一样才会附上）
    先前提供的内部 state （原封不动，如果先前有提供才会附上）

(D) Client 向 Authorization Server 的 Token Endpoint 要求 Access Token，申请时会传送：

    先前取得的 Authorization Code
    Redirection URI，用来验证和之前 (C) 时的一致。
    Client 的认证资料

(E) Authorization Server 认证 Client 、验证 Authorization Code、并确认 Redirection URI 和之前 (C) 转址的一致。都符合的话，Authorization Server 会回传 Access Token ，以及可选的 Refresh Token。
(A) Authorization Request

【User-Agent】GET ▶【Authorization Endpoint】

第一步是 Client 产生一个 URL 连到 Authorization Endpoint ，要 Resource Owner 打开（点击）这个 URL ，从而产生「向 Authorization Endpoint 发送 GET request」的操作。

把参数包在 URI 的 query components 里面。
参数
参数名 	必/选 	填什么/意义
response_type 	必 	code
client_id 	必 	自己的 Client ID
state 	建议有 	内部状态
redirect_uri 	选 	申请结果下来之后要转址去哪里
scope 	选 	申请的存取范围

其中的 state， Authorization Server 转回 Client 的时候会附上。可以防范 CSRF ，所以最好是加上这个值，详见系列文第 7 篇关于 CSRF 的安全性问题。
范例

GET /authorize?response_type=code&client_id=s6BhdRkqt3&state=xyz
    &redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb HTTP/1.1
Host: server.example.com

(C) Authorization Response

【Authorization Endpoint】 302 Response ▷ 【User-Agent】▶ GET 【Client: Redirection Endpoint】

是 Resource Owner 在 (B) 决定授权与否之后回应的 Response。

在 (B) 里面， Resource Owner 若同意授权，这个「同意授权」的 request 会往 Authorization Endpoint 发送，接著会收到 302 的转址 response ，里面带有「前往 Client 的 Redirection Endpoint 的 URL」的转址 (Location header)，从而产生「向 Redirection URI 发送 GET Request」的操作。
参数
参数名 	必/选 	填什么/意义
code 	必 	Authorization Code
state 	必* 	原内部状态

其中 state 如果 (A) 的时候有附上，则 Resopnse 里面必须有，完全一致的原值。如果原本就没有，就不需要回传。

其中 Authorization Code：

    必须是短时效的，建议最长 10 分钟。
    Client 只能使用一次，如果重复使用，Authorization Server 必须拒绝，并且建议撤销之前透过这个 Grant 核发过的 Tokens
    要绑定 Code ↔ Client ID ↔ Redirection URI 的关系
    长度由 Authorization Server 定义，应写在文件中， Client 不可以瞎猜。

Client 遇到不认识的参数必须忽略。
范例

HTTP/1.1 302 Found
Location: https://client.example.com/cb?code=SplxlOBeZQQYbYS6WxSbIA
          &state=xyz

错误发生时的回应方式

如果发生的错误是：

    Redirection URI 没给、不正确、没注册过
    Client ID 没给、不正确

则 Authorization Server 应该告知 Resource Owner 这个错误，并且绝对不可以自动转址到错误的 Redirection URI。

如果发生的错误是因为 Resource Owner 拒绝授权或是因为除了 Redirection URI 不正确的原因，那么 Authorization Server 要告知 Client ，方法是把错误内容放在 Redireciton URI 的 Query Component 里面，用 URL Encoding 编码过，可用的参数为：
参数名 	必/选 	填什么/意义
error 	必 	错误代码，其值后述。
error_description 	选 	人可读的错误讯息，给 Client 开发者看的，不是给 End User 看的。
ASCII 可见字元，除了双引号和反斜线之外。
error_uri 	选 	一个 URI ，指向载有错误细节的网页，要符合 URI 的格式。
state 	必* 	原内部状态

其中 state 如果 (A) 的时候有附上，则 Resopnse 里面必须有，完全一致的原值。如果原本就没有，就不需要回传。

而 error 的值是以下的其中一个：
值 	意义/用途
invalid_request 	欠缺必要的参数、有不正确的参数、有重复的参数、或其他原因导致无法解读。
unauthorized_client 	Client 没有被授权可以使用这种方法来取得 Authorization Code。
access_denied 	Resource Owner 或 Authorization Owner 拒绝授权的申请。
unsupported_response_type 	Authorization Server 不支援使用这种方法取得 Authorization Code。
invalid_scope 	所要求的 scope 不正确、未知、无法解读。
server_error 	Authorization Server 遇到意外的情况而无法处理请求。
temporarily_unavailable 	Authorization Server 因为过载或维修中而暂时无法处理请求。

其中 server_error 和 temporarily_unavailable 有必要，因为 5xx 系列的 status code 不能转址。
(D) Access Token Request

【Client】POST ▶ 【Token Endpoint】
参数
参数名 	必/选 	填什么/意义
grant_type 	必 	authorization_code
code 	必 	在 (C) 拿到的 Authorization Code
redirect_uri 	必 	如果 (A) 有提供，则必须提供一模一样的。
client_id 	必* 	自己的 Client ID （Public Client 才要填）。

其中 client_id 只有 Public Client 才需要提供，如果是 Confidential Client 或有拿到 Client Credentials ，就必须进行 Client 认证，细节见系列文第 2 篇。
Authorization Server 的处理程序

这个 Request 进来的时候， Authorization Server 要做这些事：

    要求 Client 认证自己（如果是 Confidential Client 或有拿到 Client Credentials）
    如果 Client 有出示认证资料，就认证它，细节见系列文第 2 篇
    确定 Authorization Code 是发给 Client 的
        Confidential: 用 Client 的认证过程来证明
        Public: 用 Client ID 来证明
    验证 Authorization Code 正确
    如果 (A) 有给 Redirection URI 的话，确定这次给的 Redirection URI 与 (A) 时的一模一样。

范例

POST /token HTTP/1.1
Host: server.example.com
Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code&code=SplxlOBeZQQYbYS6WxSbIA
&redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb

(E) Access Token Response

【Client】 ◀ 【Token Endpoint】

若 Access Token Request 合法且有经过授权，则核发 Access Token，同时可以核发 Refresh Token （非必备）。如果 Client 认证失败，或 Request 不合法，则依照 Section 5.2 的规定回复错误。

详细核发 Access Token 的细节写在系列文第 5 篇。
范例

发给 Access Token：

HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8
Cache-Control: no-store
Pragma: no-cache

{
  "access_token":"2YotnFZFEjr1zCsicMWpAA",
  "token_type":"example",
  "expires_in":3600,
  "refresh_token":"tGzv3JOkF0XG5Qx2TlKWIA",
  "example_parameter":"example_value"
}

安全性问题
Authorization Code 的安全性问题 (Section 10.5)
Authorization Code 被偷

Authorization Code 的传输应该要经由安全通道，特别是如果 Client 的 Redirection URI 是指向网路资源（根据 scheme），那么应该要求其使用 TLS。

另外，因为 Authorization Code 是经由 User-Agent 的转址来传输的，所以可能从 User-Agent 的历史记录和 Referrer header 里面找到。
从 Authorization Code 来认证 Reosurce Owner

Authorization Code 做为一个纯文字的 bearer credential （代表持有者的 credential）来运作，这个 credential 用来验证：在 Authorization Server 上面授予权限的 Resource Owner = 返回 Client 要完成程序的 Resource Owner。所以，如果 Client 依赖予 Authorization Code 来认证 Resource Owner ，那么 Client 端的 Redirection Endpoint 必须使用 TLS。
Authorization Code 被二度利用

Authorization Code 必须要是短时效、单次使用。如果 Authorization Server 检测到多次的请求来把一个 Authorization Code 换成 Access Token ，那么 Authorization Server 应该要试著撤销所有之前使用该 Authrization Code 来取得的 Access Token 。
认证 Client 防止误发 Authorization Code

如果对 Client 的认证可行，那么 Authorization Server 必须认证该 Client ，并且确保 Authorization Code 核发给同一个 Client 。
窜改 Authorization Code 的 Redirection URI (Section 10.6)

使用 Authorization Code Grant Type 要求授权的时候，Client 可以用 "redirect_uri" 来指定 Redirection URI。如果坏人可以窜改 Redirection URI 的值，他就可以让 Authorization Server 把 Resource Owner 转向到坏人控制的 URI ，并且拿到 Authorization Code。

步骤如下：

    坏人在合法的 Client 建立一个帐号，并起始授权流程。
    当坏人的 User-Agent 被传送到 Authorization Server 来取得存取权限的时候，坏人取得由 Client 提供的 Authorization URI 并且把 Client 的 Redirection URI 取代成坏人控制的 URI。
    坏人接著晃点 (trick) 受害者去跟随修改过的连结来授权合法 Client 的存取权限。
    在 Authorization Server，受害者会得到一个正常的、正确的 Request ，其 Request 代表合法的、受信任的 Client，并且授权其存取。
    受害者接著会被转向坏人控制的 Endpoint ，还附上 Authorization Code。
    坏人接著把 Authorization Code 送到原先 Client 提供的真正的 Redirection URI 来完成授权流程。
    Client 把 Authorization Code 换成 Access Token 并且连结到坏人的帐号，而这个 Access Token 可以用来透过 Client 存取受害者的 Protected Resource 。

防范方式：

确认 Redirection URI 一致 ：Authorization Server 必须确保之前用来拿取 Authorization Code 的 Redirection URI ，跟之后透过 Authorization Code 拿取 Access Token 时的 Redirection URI 一模一样。

事先设定 Redirection URI 并验证 ：Authorization Server 必须要求 Public Clients 并且最好要要求 Confidential Clients 事先指定 Redirection URIs。如果有一个 Redirection URI 附在 request 里面，那么 Authorization Server 必须验证其符合事先指定的 URIs。
