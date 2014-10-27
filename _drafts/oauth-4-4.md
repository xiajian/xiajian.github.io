---
layout: post
title: OAuth 2.0 筆記 (4.4) Client Credentials Grant Flow 細節 
---

即 Client ID + Client Secret 。適用於跑在 Server 的 Client 。

如果是以下情況的話，就可以使用這個流程：

    Client 自己就是 Resource Owner ，Client 取用的是自己擁有的 Protected Resources
    Client is requesting access to protected resources based on an authorization previously arranged with the authorization server. （這個我看不懂，所以保留原文，求解釋…）

這個流程只能用在 Confidential Client 。

這是 OAuth 2.0 內建的四個流程之一。相對於別的流程來說簡單很多。本文整理自 Section 4.4。
流程圖

+---------+                                  +---------------+
|         |                                  |               |
|         |>--(A)- Client Authentication --->| Authorization |
| Client  |                                  |     Server    |
|         |<--(B)---- Access Token ---------<|               |
|         |                                  |               |
+---------+                                  +---------------+

                Figure 6: Client Credentials Flow

(A) Client 向 Authorization Server 認證自己，並且發 Request 到 Token Endpoint

(B) Authorization Server 認證 Client ，如果正確的話，核發 Access Token。
(A) Access Token Request

【Client】POST ▶ 【Token Endpoint】
參數
參數名 	必/選 	填什麼/意義
grant_type 	必 	client_credentials
scope 	選 	申請的存取範圍
Authorization Server 的處理程序

這個 Request 進來的時候， Authorization Server 必須認證 Client，細節見系列文第 2 篇。（跟 Authorization Code Grant Type / Resource Owner Credentials Grant Type 不同，這個強制要求認證）
範例

POST /token HTTP/1.1
Host: server.example.com
Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials

(B) Access Token Response

【Client】 ◀ 【Token Endpoint】

若 Access Token Request 合法且有經過授權，則核發 Access Token，但是最好不要核發 Refresh Token。如果 Client 認證失敗，或 Request 不合法，則依照 Section 5.2 的規定回覆錯誤。

詳細核發 Access Token 的細節寫在系列文第 5 篇。

（除了「建議不要發 Refresh Token」這一點之外，大致上同 Authorization Code Grant Flow。）
範例

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


