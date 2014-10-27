---
layout: post
title: OAuth 2.0 笔记 (4.4) Client Credentials Grant Flow 细节 
---

即 Client ID + Client Secret 。适用于跑在 Server 的 Client 。

如果是以下情况的话，就可以使用这个流程：

    Client 自己就是 Resource Owner ，Client 取用的是自己拥有的 Protected Resources
    Client is requesting access to protected resources based on an authorization previously arranged with the authorization server. （这个我看不懂，所以保留原文，求解释…）

这个流程只能用在 Confidential Client 。

这是 OAuth 2.0 内建的四个流程之一。相对于别的流程来说简单很多。本文整理自 Section 4.4。
流程图

+---------+                                  +---------------+
|         |                                  |               |
|         |>--(A)- Client Authentication --->| Authorization |
| Client  |                                  |     Server    |
|         |<--(B)---- Access Token ---------<|               |
|         |                                  |               |
+---------+                                  +---------------+

                Figure 6: Client Credentials Flow

(A) Client 向 Authorization Server 认证自己，并且发 Request 到 Token Endpoint

(B) Authorization Server 认证 Client ，如果正确的话，核发 Access Token。
(A) Access Token Request

【Client】POST ▶ 【Token Endpoint】
参数
参数名 	必/选 	填什么/意义
grant_type 	必 	client_credentials
scope 	选 	申请的存取范围
Authorization Server 的处理程序

这个 Request 进来的时候， Authorization Server 必须认证 Client，细节见系列文第 2 篇。（跟 Authorization Code Grant Type / Resource Owner Credentials Grant Type 不同，这个强制要求认证）
范例

POST /token HTTP/1.1
Host: server.example.com
Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials

(B) Access Token Response

【Client】 ◀ 【Token Endpoint】

若 Access Token Request 合法且有经过授权，则核发 Access Token，但是最好不要核发 Refresh Token。如果 Client 认证失败，或 Request 不合法，则依照 Section 5.2 的规定回复错误。

详细核发 Access Token 的细节写在系列文第 5 篇。

（除了「建议不要发 Refresh Token」这一点之外，大致上同 Authorization Code Grant Flow。）
范例

HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8
Cache-Control: no-store
Pragma: no-cache

{
  "access_token":"2YotnFZFEjr1zCsicMWpAA",
  "token_type":"example",
  "expires_in":3600,
  "example_parameter":"example_value"
}


