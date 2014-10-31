---
layout: post
title: OAuth 2.0 笔记 (4.3) Resource Owner Password Credentials Grant Flow 细节
---

在 Resource Owner Password Credentials Grant Flow 流程里， Resource Owner 自己的帐号密码会直接用来当做 Authorization Grant ，并传递给 Authorization Server 来取得 Access Token 。这种流程只有在以下情况才能使用：

    Resource Owner 高度信赖 Client ，例如作业系统内建的应用程式（好比说 OS X 的 Twitter 整合）或是官方应用程式。
    其他别的流程都不适用。

而就算 Client 可以直接拿到 Resource Owner 的帐号密码，也只会使用一次，用来取得 Access Token 。Spec 里面定义的流程，会要求 Client 不储存帐号密码，而是随后以长时效的 Access Token 或 Refresh Token 取代之。

Authorization Server 应该要特别小心开放这种流程，并且要在别的流程都行不通的时候才使用这种。

这种流程适用于可以取得 Resource Owner 帐号密码的 Client （通常是透过一个输入框）。也可以用来把以前的帐号密码认证，迁移到 OAuth 认证。

最后拿到的除了 Access Token 之外，还会拿到 Refresh Token （Authorization Server 有支援的话）。

这是 OAuth 2.0 内建的四个流程之一。本文整理自 Section 4.3。
流程图

+----------+
| Resource |
|  Owner   |
|          |
+----------+
     v
     |    Resource Owner
    (A) Password Credentials
     |
     v
+---------+                                  +---------------+
|         |>--(B)---- Resource Owner ------->|               |
|         |         Password Credentials     | Authorization |
| Client  |                                  |     Server    |
|         |<--(C)---- Access Token ---------<|               |
|         |    (w/ Optional Refresh Token)   |               |
+---------+                                  +---------------+

       Figure 5: Resource Owner Password Credentials Flow

(A) Resource Owner 向 Client 提供真正的帐号密码。

(B) Client 用 Resource Owner 的帐号密码，向 Authorization Server 的 Token Endpoint 申请 Access Token。这个时候 Client 还要向 Authorization Server 认证自己。

(C) Authorization Server 认证 Client 、验证 Resource Owner 的帐号密码，如果正确的话，核发 Access Token。
(A) Authorization Request & Response

在这个流程里面， Authorization Grant 就是 Resource Owner 的帐号密码，所以在 Step (A) 里面直接向 Resource Onwer 索取，没有经过网路来取得 Authorization。

Spec 不规定 Client 要怎么拿到帐号密码，但是 Client 取得 Access Token 之后，必须把 Resource Owner 的帐号密码给销毁掉。
(B) Access Token Request

【Client】POST ▶ 【Token Endpoint】
参数
参数名 	必/选 	填什么/意义
grant_type 	必 	password
username 	必 	Resource Owner 的帐号
password 	必 	Resource Owner 的密码
scope 	选 	申请的存取范围
Authorization Server 的处理程序

这个 Request 进来的时候， Authorization Server 要做这些事：

    要求 Client 认证自己（如果是 Confidential Client 或有拿到 Client Credentials）
    如果 Client 有出示认证资料，就认证它，细节见系列文第 2 篇
    验证 Resource Owner 的帐号密码（以既有的验证方式）

慎防暴力破解

因为牵涉到帐号密码，所以 Authorization Server 要可以防 Endpoint 被暴力破解，具体实施的方法像是 Rate Limiting 或是发出警告。
范例

POST /token HTTP/1.1
Host: server.example.com
Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
Content-Type: application/x-www-form-urlencoded

grant_type=password&username=johndoe&password=A3ddj3w

(C) Access Token Response

（同 Authorization Code Grant Flow。）

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

安全性问题 (Section 10.7)
帐号密码外泄

Resource Owner Password Credentials Grant Type 通常是用在老旧 Client ，或是迁移旧的认证机制到 OAuth。虽然这种流程降低了在 Client 里面储存帐号密码所引来的风险，但是没有消除把帐号密码给 Client 看的必要性。（编按：第一步还是需要 Resonrce Owner 提供帐号密码）

这个流程的风险比起其他流程还要高，因为它保留了使用密码的 anti-pattern，而这个却是 OAuth spec 致力避免的。Client 可能会滥用密码，或是密码会不经意地泄漏给坏人（例如 Log 或是其他 Client 保存的记录）。
Resource Owner 无法控制授权权限与存取范围

此外，因为 Resource Owner 没办法控制授权的流程（Resource Owner 只参与到输入帐号密码），Client 可以取得比 Resource Owner 期望的权限 (scopes) 还要更多的权限。Authorization Server 在透过这种流程合法 Access Token 的时候应该要慎重考虑 scope 和时效的问题。

Authorization Server 和 Client 应该要尽量不使用这种流程，改用其他流程
