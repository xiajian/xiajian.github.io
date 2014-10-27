---
layout: post
title: OAuth 2.0 筆記 (4.3) Resource Owner Password Credentials Grant Flow 細節
---

在 Resource Owner Password Credentials Grant Flow 流程裡， Resource Owner 自己的帳號密碼會直接用來當做 Authorization Grant ，並傳遞給 Authorization Server 來取得 Access Token 。這種流程只有在以下情況才能使用：

    Resource Owner 高度信賴 Client ，例如作業系統內建的應用程式（好比說 OS X 的 Twitter 整合）或是官方應用程式。
    其他別的流程都不適用。

而就算 Client 可以直接拿到 Resource Owner 的帳號密碼，也只會使用一次，用來取得 Access Token 。Spec 裡面定義的流程，會要求 Client 不儲存帳號密碼，而是隨後以長時效的 Access Token 或 Refresh Token 取代之。

Authorization Server 應該要特別小心開放這種流程，並且要在別的流程都行不通的時候才使用這種。

這種流程適用於可以取得 Resource Owner 帳號密碼的 Client （通常是透過一個輸入框）。也可以用來把以前的帳號密碼認證，遷移到 OAuth 認證。

最後拿到的除了 Access Token 之外，還會拿到 Refresh Token （Authorization Server 有支援的話）。

這是 OAuth 2.0 內建的四個流程之一。本文整理自 Section 4.3。
流程圖

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

(A) Resource Owner 向 Client 提供真正的帳號密碼。

(B) Client 用 Resource Owner 的帳號密碼，向 Authorization Server 的 Token Endpoint 申請 Access Token。這個時候 Client 還要向 Authorization Server 認證自己。

(C) Authorization Server 認證 Client 、驗證 Resource Owner 的帳號密碼，如果正確的話，核發 Access Token。
(A) Authorization Request & Response

在這個流程裡面， Authorization Grant 就是 Resource Owner 的帳號密碼，所以在 Step (A) 裡面直接向 Resource Onwer 索取，沒有經過網路來取得 Authorization。

Spec 不規定 Client 要怎麼拿到帳號密碼，但是 Client 取得 Access Token 之後，必須把 Resource Owner 的帳號密碼給銷毀掉。
(B) Access Token Request

【Client】POST ▶ 【Token Endpoint】
參數
參數名 	必/選 	填什麼/意義
grant_type 	必 	password
username 	必 	Resource Owner 的帳號
password 	必 	Resource Owner 的密碼
scope 	選 	申請的存取範圍
Authorization Server 的處理程序

這個 Request 進來的時候， Authorization Server 要做這些事：

    要求 Client 認證自己（如果是 Confidential Client 或有拿到 Client Credentials）
    如果 Client 有出示認證資料，就認證它，細節見系列文第 2 篇
    驗證 Resource Owner 的帳號密碼（以既有的驗證方式）

慎防暴力破解

因為牽涉到帳號密碼，所以 Authorization Server 要可以防 Endpoint 被暴力破解，具體實施的方法像是 Rate Limiting 或是發出警告。
範例

POST /token HTTP/1.1
Host: server.example.com
Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
Content-Type: application/x-www-form-urlencoded

grant_type=password&username=johndoe&password=A3ddj3w

(C) Access Token Response

（同 Authorization Code Grant Flow。）

【Client】 ◀ 【Token Endpoint】

若 Access Token Request 合法且有經過授權，則核發 Access Token，同時可以核發 Refresh Token （非必備）。如果 Client 認證失敗，或 Request 不合法，則依照 Section 5.2 的規定回覆錯誤。

詳細核發 Access Token 的細節寫在系列文第 5 篇。
範例

發給 Access Token：

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

安全性問題 (Section 10.7)
帳號密碼外洩

Resource Owner Password Credentials Grant Type 通常是用在老舊 Client ，或是遷移舊的認證機制到 OAuth。雖然這種流程降低了在 Client 裡面儲存帳號密碼所引來的風險，但是沒有消除把帳號密碼給 Client 看的必要性。（編按：第一步還是需要 Resonrce Owner 提供帳號密碼）

這個流程的風險比起其他流程還要高，因為它保留了使用密碼的 anti-pattern，而這個卻是 OAuth spec 致力避免的。Client 可能會濫用密碼，或是密碼會不經意地洩漏給壞人（例如 Log 或是其他 Client 保存的記錄）。
Resource Owner 無法控制授權權限與存取範圍

此外，因為 Resource Owner 沒辦法控制授權的流程（Resource Owner 只參與到輸入帳號密碼），Client 可以取得比 Resource Owner 期望的權限 (scopes) 還要更多的權限。Authorization Server 在透過這種流程合法 Access Token 的時候應該要慎重考慮 scope 和時效的問題。

Authorization Server 和 Client 應該要儘量不使用這種流程，改用其他流程。
