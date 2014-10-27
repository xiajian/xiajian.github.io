---
layout: post
title: OAuth 2.0 筆記 (4.1) Authorization Code Grant Flow 細節
---

在 Authorization Grant Code Flow 裡，Client 不直接向 Resource Owner 要求許可，而是把 Resource Owner 導去 Authorization Server 要求許可， Authorization Server 再透過轉址來告訴 Client 授權許可的代碼 (code) 。在轉址回去之前， Authorization Server 會先認證 Resource Owner 並取得授權。因為 Resource Owner 只跟 Authorization Server 認證，所以 Client 絕對不會拿到 Resource Owner 的帳號密碼。

在這種流程裡， Authorization Grant Code 會以一個字串 (string) 具體存在，並且傳遞給 Client ，做為 Authorization Grant （Resource Owner 的授權許可）。在取得 Grant 之後，還沒有取得 Access Token ，Client 要再自己去向 Authorization Server 取得 Access Token 。

這個流程是專門為在 Server 執行的 Confidential Client 優化的。

因為需要實施轉址，所以 Client 要可以跟 Resource Owner 的 User-Agent (Browser) 互動，也要可以接收從 Authorization Server 來的 Redirection Request。

最後拿到的除了 Access Token 之外，還會拿到 Refresh Token （Authorization Server 有支援的話）。

這是 OAuth 2.0 內建的四個流程之一。本文整理自 Section 4.1。
流程圖

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

註: (A), (B), (C) 這三步的線拆成兩段，因為會經過 user-agent

                  Figure 3: Authorization Code Flow

(A) Client 把 Resource Owner 的 User-Agent 轉到 Authorization Endpoint 來啟動流程。Client 會傳送：

    Client ID
    申請的 scopes
    內部 state
    Redirection URI，申請結果下來之後 Authorization Server 要轉址過去。

(B) Authorization Server 通過 User-Agent 認證 Resource Owner，並確定 Resource Onwer 許可或駁回Client 的存取申請。

(C) 假設 Resource Owner 許可了存取申請， Authorization Server 會把 User-Agent 轉回去先前指定的 Redirection URI ，其中包含了：

    Authorization Code
    許可的 scopes （如果跟申請的不一樣才會附上）
    先前提供的內部 state （原封不動，如果先前有提供才會附上）

(D) Client 向 Authorization Server 的 Token Endpoint 要求 Access Token，申請時會傳送：

    先前取得的 Authorization Code
    Redirection URI，用來驗證和之前 (C) 時的一致。
    Client 的認證資料

(E) Authorization Server 認證 Client 、驗證 Authorization Code、並確認 Redirection URI 和之前 (C) 轉址的一致。都符合的話，Authorization Server 會回傳 Access Token ，以及可選的 Refresh Token。
(A) Authorization Request

【User-Agent】GET ▶【Authorization Endpoint】

第一步是 Client 產生一個 URL 連到 Authorization Endpoint ，要 Resource Owner 打開（點擊）這個 URL ，從而產生「向 Authorization Endpoint 發送 GET request」的操作。

把參數包在 URI 的 query components 裡面。
參數
參數名 	必/選 	填什麼/意義
response_type 	必 	code
client_id 	必 	自己的 Client ID
state 	建議有 	內部狀態
redirect_uri 	選 	申請結果下來之後要轉址去哪裡
scope 	選 	申請的存取範圍

其中的 state， Authorization Server 轉回 Client 的時候會附上。可以防範 CSRF ，所以最好是加上這個值，詳見系列文第 7 篇關於 CSRF 的安全性問題。
範例

GET /authorize?response_type=code&client_id=s6BhdRkqt3&state=xyz
    &redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb HTTP/1.1
Host: server.example.com

(C) Authorization Response

【Authorization Endpoint】 302 Response ▷ 【User-Agent】▶ GET 【Client: Redirection Endpoint】

是 Resource Owner 在 (B) 決定授權與否之後回應的 Response。

在 (B) 裡面， Resource Owner 若同意授權，這個「同意授權」的 request 會往 Authorization Endpoint 發送，接著會收到 302 的轉址 response ，裡面帶有「前往 Client 的 Redirection Endpoint 的 URL」的轉址 (Location header)，從而產生「向 Redirection URI 發送 GET Request」的操作。
參數
參數名 	必/選 	填什麼/意義
code 	必 	Authorization Code
state 	必* 	原內部狀態

其中 state 如果 (A) 的時候有附上，則 Resopnse 裡面必須有，完全一致的原值。如果原本就沒有，就不需要回傳。

其中 Authorization Code：

    必須是短時效的，建議最長 10 分鐘。
    Client 只能使用一次，如果重複使用，Authorization Server 必須拒絕，並且建議撤銷之前透過這個 Grant 核發過的 Tokens
    要綁定 Code ↔ Client ID ↔ Redirection URI 的關係
    長度由 Authorization Server 定義，應寫在文件中， Client 不可以瞎猜。

Client 遇到不認識的參數必須忽略。
範例

HTTP/1.1 302 Found
Location: https://client.example.com/cb?code=SplxlOBeZQQYbYS6WxSbIA
          &state=xyz

錯誤發生時的回應方式

如果發生的錯誤是：

    Redirection URI 沒給、不正確、沒註冊過
    Client ID 沒給、不正確

則 Authorization Server 應該告知 Resource Owner 這個錯誤，並且絕對不可以自動轉址到錯誤的 Redirection URI。

如果發生的錯誤是因為 Resource Owner 拒絕授權或是因為除了 Redirection URI 不正確的原因，那麼 Authorization Server 要告知 Client ，方法是把錯誤內容放在 Redireciton URI 的 Query Component 裡面，用 URL Encoding 編碼過，可用的參數為：
參數名 	必/選 	填什麼/意義
error 	必 	錯誤代碼，其值後述。
error_description 	選 	人可讀的錯誤訊息，給 Client 開發者看的，不是給 End User 看的。
ASCII 可見字元，除了雙引號和反斜線之外。
error_uri 	選 	一個 URI ，指向載有錯誤細節的網頁，要符合 URI 的格式。
state 	必* 	原內部狀態

其中 state 如果 (A) 的時候有附上，則 Resopnse 裡面必須有，完全一致的原值。如果原本就沒有，就不需要回傳。

而 error 的值是以下的其中一個：
值 	意義/用途
invalid_request 	欠缺必要的參數、有不正確的參數、有重複的參數、或其他原因導致無法解讀。
unauthorized_client 	Client 沒有被授權可以使用這種方法來取得 Authorization Code。
access_denied 	Resource Owner 或 Authorization Owner 拒絕授權的申請。
unsupported_response_type 	Authorization Server 不支援使用這種方法取得 Authorization Code。
invalid_scope 	所要求的 scope 不正確、未知、無法解讀。
server_error 	Authorization Server 遇到意外的情況而無法處理請求。
temporarily_unavailable 	Authorization Server 因為過載或維修中而暫時無法處理請求。

其中 server_error 和 temporarily_unavailable 有必要，因為 5xx 系列的 status code 不能轉址。
(D) Access Token Request

【Client】POST ▶ 【Token Endpoint】
參數
參數名 	必/選 	填什麼/意義
grant_type 	必 	authorization_code
code 	必 	在 (C) 拿到的 Authorization Code
redirect_uri 	必 	如果 (A) 有提供，則必須提供一模一樣的。
client_id 	必* 	自己的 Client ID （Public Client 才要填）。

其中 client_id 只有 Public Client 才需要提供，如果是 Confidential Client 或有拿到 Client Credentials ，就必須進行 Client 認證，細節見系列文第 2 篇。
Authorization Server 的處理程序

這個 Request 進來的時候， Authorization Server 要做這些事：

    要求 Client 認證自己（如果是 Confidential Client 或有拿到 Client Credentials）
    如果 Client 有出示認證資料，就認證它，細節見系列文第 2 篇
    確定 Authorization Code 是發給 Client 的
        Confidential: 用 Client 的認證過程來證明
        Public: 用 Client ID 來證明
    驗證 Authorization Code 正確
    如果 (A) 有給 Redirection URI 的話，確定這次給的 Redirection URI 與 (A) 時的一模一樣。

範例

POST /token HTTP/1.1
Host: server.example.com
Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code&code=SplxlOBeZQQYbYS6WxSbIA
&redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb

(E) Access Token Response

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

安全性問題
Authorization Code 的安全性問題 (Section 10.5)
Authorization Code 被偷

Authorization Code 的傳輸應該要經由安全通道，特別是如果 Client 的 Redirection URI 是指向網路資源（根據 scheme），那麼應該要求其使用 TLS。

另外，因為 Authorization Code 是經由 User-Agent 的轉址來傳輸的，所以可能從 User-Agent 的歷史記錄和 Referrer header 裡面找到。
從 Authorization Code 來認證 Reosurce Owner

Authorization Code 做為一個純文字的 bearer credential （代表持有者的 credential）來運作，這個 credential 用來驗證：在 Authorization Server 上面授予權限的 Resource Owner = 返回 Client 要完成程序的 Resource Owner。所以，如果 Client 依賴予 Authorization Code 來認證 Resource Owner ，那麼 Client 端的 Redirection Endpoint 必須使用 TLS。
Authorization Code 被二度利用

Authorization Code 必須要是短時效、單次使用。如果 Authorization Server 檢測到多次的請求來把一個 Authorization Code 換成 Access Token ，那麼 Authorization Server 應該要試著撤銷所有之前使用該 Authrization Code 來取得的 Access Token 。
認證 Client 防止誤發 Authorization Code

如果對 Client 的認證可行，那麼 Authorization Server 必須認證該 Client ，並且確保 Authorization Code 核發給同一個 Client 。
竄改 Authorization Code 的 Redirection URI (Section 10.6)

使用 Authorization Code Grant Type 要求授權的時候，Client 可以用 "redirect_uri" 來指定 Redirection URI。如果壞人可以竄改 Redirection URI 的值，他就可以讓 Authorization Server 把 Resource Owner 轉向到壞人控制的 URI ，並且拿到 Authorization Code。

步驟如下：

    壞人在合法的 Client 建立一個帳號，並起始授權流程。
    當壞人的 User-Agent 被傳送到 Authorization Server 來取得存取權限的時候，壞人取得由 Client 提供的 Authorization URI 並且把 Client 的 Redirection URI 取代成壞人控制的 URI。
    壞人接著晃點 (trick) 受害者去跟隨修改過的連結來授權合法 Client 的存取權限。
    在 Authorization Server，受害者會得到一個正常的、正確的 Request ，其 Request 代表合法的、受信任的 Client，並且授權其存取。
    受害者接著會被轉向壞人控制的 Endpoint ，還附上 Authorization Code。
    壞人接著把 Authorization Code 送到原先 Client 提供的真正的 Redirection URI 來完成授權流程。
    Client 把 Authorization Code 換成 Access Token 並且連結到壞人的帳號，而這個 Access Token 可以用來透過 Client 存取受害者的 Protected Resource 。

防範方式：

確認 Redirection URI 一致 ：Authorization Server 必須確保之前用來拿取 Authorization Code 的 Redirection URI ，跟之後透過 Authorization Code 拿取 Access Token 時的 Redirection URI 一模一樣。

事先設定 Redirection URI 並驗證 ：Authorization Server 必須要求 Public Clients 並且最好要要求 Confidential Clients 事先指定 Redirection URIs。如果有一個 Redirection URI 附在 request 裡面，那麼 Authorization Server 必須驗證其符合事先指定的 URIs。
