---
layout: post
title: OAuth 2.0 筆記 (4.2) Implicit Grant Flow 細節
---

在 Implicit Grant Flow 裡，Authorization Server 直接向 Client 核發 Access Token ，而不像 Authorization Code Grant Flow ，先核發 Grant ，再另外去拿 Access Token。

Authorization Server 核發 Access Token 的時候，不認證 Client （其實也無法認證），在某些情況下，可以用 Redirection URI 來確保 Access Token 只發給正確的 Client 。這種流程依賴 Resource Owner 本人的存在，以及事先設定的 Redirection URI。

這種流程是專門為特定的 Public Client 來優化的，例如跑在 Browser 裡面的應用程式。但也因此有外洩風險，例如：

    Resource Owner 可以看到 Access Token
    其他可以存取 User-Agent 的應用程式，也可以看到 Access Token
    Access Token 傳輸時，會直接出現在 Redirection URI 裡面，所以 Resource Owner 以及同一台設備的應用程式可以看到

因為需要實施轉址，所以 Client 要可以跟 Resource Owner 的 User-Agent (Browser) 互動，也要可以接收從 Authorization Server 來的 Redirection Request。（同 Authorization Code Grant Flow）

最後拿到的只有 Access Token ，不會拿到 Refresh Token （禁止核發 Refresh Token）。

這是 OAuth 2.0 內建的四個流程之一。本文整理自 Section 4.2。
流程圖

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

註: (A), (B) 這兩步的線拆成兩段，因為會經過 user-agent

                    Figure 4: Implicit Grant Flow

(A) Client 把 Resource Owner 的 User-Agent 轉到 Authorization Endpoint 來啟動流程。Client 會傳送：

    Client ID
    申請的 scopes
    內部 state
    Redirection URI，申請結果下來之後 Authorization Server 要轉址過去。

(B) Authorization Server 通過 User-Agent 認證 Resource Owner，並確定 Resource Onwer 許可或駁回Client 的存取申請。

(C) 假設 Resource Owner 許可了存取申請， Authorization Server 會把 User-Agent 轉回去先前指定的 Redirection URI ，其中包含 Access Token ，放在 Fragment Component 裡面。

(D) User-Agent 跟隨轉址的指示，發出 Request 到 Web-Hosted Client Resource ，這個 Request 裡面不會有剛剛拿到的 Fragment ， User-Agent 自己保留 Fragment 。（註）

(E) Web-Hosted Client Resource 回傳一個網頁（HTML & JavaScript），這個網頁可以拿到完整的 Redirection URI （含先前 User-Agent 保留的 Fragment）、把 Fragment 裡面的 Access Token 和其他參數給解出來。（註）

(F) User-Agent 執行從 Web-Hosted Client Resource 來的 Script 把 Access Token 解出來。

(G) User-Agent 把 Access Token 傳給 Client。

註： (D) 之後的有點抽象，我的理解是這樣：

    Web-Hosted Client Resource 當作你自己架的 App Server ，在上面開 Redirection Endpoint ，所以這個流程其實 Client 本體 (JavaScript App) 沒有 Endpoint ，Endpoint 是開在一個 HTTP(s) Server 上面。
    Browser 事實上在 Access http://example.com/cb#access_token=123 的時候，只會發送 http://example.com/cb 的 request ，在 Request 裡面不會有 #access_token=123
    所以 (D) 所謂「Request 不含 Fragment，User-Agent 自己保留 Fragment」這一步是 User-Agent 自動做的， Client 開發者不需要用 JavaScript 特別處理，只要把 Redirection Endpoint 指定給自己的 App Server 就可以了。
    而 (E) 所謂「回傳一個網頁來解出 User-Agent 保留的 Fragment」，就是說 User-Agent 打 Request 到 Redirection URI （含 Fragment，但不會傳送到 Server）的時候，他的 response 裡面包含 JavaScript ，而上面說了，Fragment 是自動保留在 User-Agent 的，所以這個 Response 在 Server 那邊不會知道有 Fragment 的存在，也就不會知道 Access Token 的存在，而是 User-Agent 才知道。
    所以 (F) 就是跑這個 script 解出 Access Token 和參數，(G) 把 (F) 的執行結果塞給 Client (JavaScript App)。

也就是說其實是設計給不能聽 Redirection Endpoint 的 In-Browser JavaScript App 的解法。我看到的用法是 Google 的 OAuth 2.0 for Client-side JavaScript。
(A) Authorization Request

【User-Agent】GET ▶【Authorization Endpoint】

第一步是 Client 產生一個 URL 連到 Authorization Endpoint ，要 Resource Owner 打開（點擊）這個 URL ，從而產生「向 Authorization Endpoint 發送 GET request」的操作。

把參數包在 URI 的 query component 裡面。
參數
參數名 	必/選 	填什麼/意義
response_type 	必 	token
client_id 	必 	自己的 Client ID
state 	建議有 	內部狀態
redirect_uri 	選 	申請結果下來之後要轉址去哪裡
scope 	選 	申請的存取範圍

其中的 state， Authorization Server 轉回 Client 的時候會附上。可以防範 CSRF ，所以最好是加上這個值，詳見系列文第 7 篇關於 CSRF 的安全性問題。
Authorization Server 的處理程序

因為 Implicit Grant Flow 是直接在 Authorization Endpoint 發 Access Token ，所以資料驗證和授權都在這一步處理。所以這個 Request 進來的時候， Authorization Server 要做這些事：

    驗證所有必須給的參數都有給且合法
    Redirection URI 與預先在 Authorization Server 設定的相符。

如果沒問題，就詢問 Resource Owner 是否授權，即 (B) 步驟。
(C) Authorization Response

【Client】 ◀ 302【Authorization Endpoint】

是 Resource Owner 在 (B) 決定授權與否之後回應的 Response。

在 (B) 裡面， Resource Owner 若同意授權，這個「同意授權」的 request 會往 Authorization Endpoint 發送，接著會收到 302 的轉址 response ，裡面帶有「前往 Client 的 Redirection Endpoint 的 URL」的轉址 (Location header)，從而產生「向 Redirection URI 發送 GET Request」的操作。

參數要用 URL Encoding 編起來，放在 Fragment Component 裡面。

若 Access Token Request 合法且有經過授權，則核發 Access Token。如果 Client 認證失敗，或 Request 不合法，則依照 Section 5.2 的規定回覆錯誤。

特別注意 Implicit Grant Type 禁止 核發 Refresh Token。

某些 User-Agent 不支援 Fragment Redirection ，這種情況可以使用間接轉址，即是轉到一個頁面，放一個 "Continue" 的按鈕，按下去連到真正的 Redirection URI 。
參數
參數名 	必/選 	填什麼/意義
access_token 	必 	即 Access Token
expires_in 	建議有 	幾秒過期，如 3600 表示 10 分鐘。若要省略，最好在文件裡註明效期。
scope 	必* 	Access Token 的授權範圍 (scopes)。
state 	必* 	原內部狀態。

其中 scope 如果和 (A) 申請的不同則要附上，如果一樣的話就不必附上。

其中 state 如果 (A) 的時候有附上，則 Resopnse 裡面必須有，完全一致的原值。如果原本就沒有，就不需要回傳。

Access Token 的長度由 Authorization Server 定義，應寫在文件中， Client 不可以瞎猜。

Client 遇到不認識的參數必須忽略。
範例

HTTP/1.1 302 Found
Location: http://example.com/cb#access_token=2YotnFZFEjr1zCsicMWpAA
          &state=xyz&token_type=example&expires_in=3600

錯誤發生時的處理方式

跟 Authorization Code Grant Flow 相同，差別在於錯誤的內容是放在 Fragment Component 而不是 Query Component。請參考系列文第 4.1 篇關於 Authorization Code Grant Flow 的 Access Token Request 錯誤處理原則。

例如：

HTTP/1.1 302 Found
Location: https://client.example.com/cb#error=access_denied&state=xyz

安全性問題

在 spec 裡面提及的安全性問題寫在 Section 10.3 和 10.16 ，其中 10.3 只是特別提到 Implicit Grant Type 「透過 URI Fragment 來傳 Access Token ，所以可能會外洩」，而 10.16 則是針對 Implicit Grant Type 可能會有偽造 Resource Owner 的安全性問題。其中 10.3 關於 Access Token 保密的問題，見系列文第 7 篇。
誤用 Access Token 來在 Implicit Flow 裡面偽裝 Resource Owner (Section 10.16)

這個 Section 的原文我看不太懂，似乎是在說，這流程裡面會有漏洞讓壞人可以置換 Access Token ，原本是要給 A Client 的 Token 到了 B Client 的手上。Amazon 的文件 裡面有提到，他的建議是，在真的拿 Token 來用之前，要去 Authorization Server 問一下是不是真是給這個 Client 用的，不是的話就不能用。

新浪微博 API 的「用户身份伪造」應該也是在講類似的事。
