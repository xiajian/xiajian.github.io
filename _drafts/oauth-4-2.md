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
    Browser 事实上在 Access http://example.com/cb#access_token