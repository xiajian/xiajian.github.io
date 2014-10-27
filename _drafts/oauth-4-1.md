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
参数名 	必/选 	填什么/