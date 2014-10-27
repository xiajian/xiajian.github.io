---
layout: post
title: OAuth 2.0 筆記 (3) Endpoints 的規格 
---


在 OAuth 2.0 裡面，Endpoints （資料傳輸接點）共有三種：

    Authorization Server 的 Authorization Endpoint
    Client 的 Redirection Endpoint
    Authorization Server 的 Token Endpoint

其規格如下文，不能只看名稱來判別其用途，像是 Authorization Endpoint 其實是一點多用，在某些流程裡會發 Authorization Grant Code ，有些流程會直接發 Access Token ，有些流程會略過之。

使用的順序大致上是 Authorization Endpoint → Redirection Endpoint → Token Endpoint 。

可以發現到 Resource Server 上面並沒有定義任何 Endpoints ，這是因為取得 Access Token 的流程與 Resource Server 無關， Resource Server 只需要認 Access Token 並且向 Authorization Server 驗證 Token 合法就行了。
Authorization Endpoint (Authorization Server)

Authorization Endpoint 主要是給 Client 從 Resource Owner 取得 Authorization Grant 用的，其過程會透過 User-Agent 轉向。

在內建的四種流程中，只有 Authorization Code Grant Flow 和 Implicit Grant Flow 才會使用到。

處理過程中，必須先認證 Resource Owner ，但認證方法在 spec 裡面不明確定義，或許是帳密、或許是 session cookie 。也就是說要登入這個使用者。

Client 得知 Authorization Endpoint 的方法不定義，通常是直接寫在服務的文件裡面。
URI 要求

    URI 裡面可以有 Query Component（如 ?xxx=yyy），但是當要加入其他 parameter 的時候，必須保留既有的 parameters 。
    URI 裡面不可以有 Fragment Component （#zzz）。

HTTP Method

必須支援 GET。可以支援 POST（非必備）。
傳遞的參數
參數名 	必/選 	意義
response_type 	必 	會 switch 到不同的 flow ，見下文 Response Type 段
state 	建議有 	通用參數，用來維持最初狀態，見下文
scope 	選 	通用參數，用來指定存取範圍，見下文
Response Type

Response Type 透過 response_type 參數來指定，其值定義如下：
值 	意義
code 	求 Authorization Code (Authorization Code Flow)
token 	求 Access Token (Implicit Flow)
（其他） 	為 extension ，若有多個，可以以空格分開

若 response_type 欠缺或認不得，必須回錯誤，見下文。
參數解析原則

    留空的參數要當做沒有提供 (omitted) 。例如 response_type=code&state= 要當做沒給 state 參數。
    認不得的參數必須忽略之。
    每個參數只能出現一次，不可重覆出現。若有重覆，則要回傳錯誤。

TLS (https) 要求

必須經過 TLS ，因為 response 裡面有 credentials 會被看到。
遇到錯誤的時候的處理方式

所謂錯誤，像是參數錯誤、Client 不被授權使用這種 Authorization 、Server 不支援這種 Authorization 等等。雖然 Spec 裡面的四種流程，有用到 Authorization Endpoint 的（其實就是 Authorization Code 和 Implicit），其處理方式都一樣，但是只使用於內建流程， Extension 可能會使用更多的，所以不寫在這篇裡面。

你只要知道 spec 裡面的內建流程，對於 Authorization Endpoint 的錯誤處理方式是一模一樣的就好了。

Section 3.1, 3.1.1
Redirection Endpoint (Client)

Authorization Server 在完成與 Resource Owner 的互動之後（認證 Resource Owner 、提示 Client 要請求授權之類的），會把 Resource Owner 的 User-Agent 轉回 Cilent ，這個轉回去的目標就是 Redirection Endopoint 。

在內建的四種流程中，只有 Authorization Code Flow 和 Implicit Flow 才會使用到。

註：本文省略關於多重 Redirection URI 和動態設置 (Dynamic Configuration) 的 spec 的解說，因為一來我看不懂，二來我沒用過要指定多個 Redirection URI 的 OAuth 服務，所以不清楚它的用途，我想對於入門來說應該是不需要說明（我也沒能力說明）。有興趣的同學可以看 spec 的 Section 3.1.2.3 。
Client 設定 Redirection Endpoint

Redirection Endpoint 可以在 Client 註冊的時候設定，或是在發出 Authorization Request 的時候指定。

以下這些類型的 Clients 必須設定 Redirection Endpoint：

    Public Client
    Confidential Client 且利用 Implicit Grant Type

Authorization Server 應該要要求所有 Clients 在使用 Authorization Endpoint 之前，都設定 Redirection Endpoint。會要求設定 Redirection Endpoint，是為了防止壞人利用 Authorization Endopint 做為 open redirector 。詳見本文最末段，關於安全性的問題。
Authorize 時，Redirection URI 不正確的處理方式

如果 Authorization Server 驗證 Redirection URI 失敗（沒註冊、不相符等情況），則 Authorization Server 應該提示錯誤，並且 不可以自動轉回 錯誤的 Redirection URI 。
URI 的要求

    必須是 Absolute URI （就是下圖的 scheme + hierarchical + query (選用)）。定義在 RFC3986 的 Section 4.3。
    URI 裡面可以有 Query Component（如 ?xxx=yyy），但是當要加入其他 parameter 的時候，必須保留既有的 parameters 。
    URI 裡面不可以有 Fragment Component （#zzz）。

若無法指定完整的 URI （像是不能指定 Query Component），則應該要求指定 URI 的 scheme 、 authority 、 path 這三個部份（見下圖）。

就我的理解可以給出以下範例：
OK? 	Example 	Reason
◯ 	https://www.example.com/oauth/callback 	
◯ 	https://www.example.com/oauth/callback?origin=facebook 	
✕ 	https://www.example.com 	沒有 path part

根據維基百科的解釋，即是 Query Component 之前的所有部份，亦即僅允許 Client 自訂 Query Component：

  foo://username:password@example.com:8042/over/there/index.dtb?type=animal&name=narwhal#nose
  \_/   \_______________/ \_________/ \__/            \___/ \_/ \______________________/ \__/
   |           |               |       |                |    |            |                |
   |       userinfo         hostname  port              |    |          query          fragment
   |    \________________________________/\_____________|____|/ \__/        \__/
   |                    |                          |    |    |    |          |
scheme              authority                    path   |    |    interpretable as keys
 name   \_______________________________________________|____|/       \____/     \_____/
                             |                          |    |          |           |
                     hierarchical part                  |    |    interpretable as values
                                                        |    |
                                interpretable as filename    interpretable as extension

TLS (HTTPS) 的要求

Redirection Endpoint 在以下任一種情況，應該要有 TLS ：

    發出 Authorization Request 時的 Response Type 為 code 或 token （= 內建流程的每一種）。
    重新轉向的時候會經由公開網路傳遞敏感資料。

然而這個並不強求，因為現階段有些 Client 實作 TLS 有困難。因此，若重新轉向的目標並不是 TLS (https) ，則 Authorization Server 應該要向 Resource Owner 提出警告。
關於 Redirection Endpoint 的內容的建議

所謂的內容，就是當 User-Agent 打開 Redirection Endpoint URI 的時候看到的內容，通常是 HTML ，所以如果 HTML 直接在 Redirection Request 輸出的話，任何 script 都可以拿到 Redirection URI 及包含在其中的 credentials 。

因此有這些建議：

    Client 應該直接從 URI 裡面解出 credentials ，並且馬上 redirect 到別的地方以防外洩。
    Client 不應該在 Redirection Response 裡面載入第三方 script （Analytics 、社交網站、廣告等）。
    若第三方 script 無法避免，則 Client 必須確保自己的 script 先跑，先把 credentials 解出來，並且移除 credentials 。

從 Rails 的實作方式來說，就是直接在 Controller 裡面解出 credentials ，存進 Model ，然後 redirect 到別的 path 就行了。

Section 3.1.2 - 3.1.2.5
Token Endpoint (Authorization Server)

Token Endpoint 是 Client 用來拿取 Access Token 的。拿取的時候，要出示 Authorization Grant （第一次拿 Access Token）或 Refresh Token （舊的 Access Token 不能用，要重新拿新的）。

在內建的四種流程裡，只有 Implicit Grant Type 不使用之，因為這個流程的 Access Token 是直接在 Authorization Endpoint 那邊就直接給了。

在 Token Endpoint 處理的流程中，有一步是認證 Client ，用來確認 Client 的身份。詳見「關於認證 Client 的說明」一段。

Client 得知 Token Endpoint 的方法不定義，通常是直接寫在服務的文件裡面。（同 Authorization Endpoint）
HTTP Method

必須使用 POST。Client 在發送 Token Request 的時候，也必須使用 POST 。
URI 要求

（同 Authorization Endpoint）

    URI 裡面可以有 Query Component（如 ?xxx=yyy），但是當要加入其他 parameter 的時候，必須保留既有的 parameters 。
    URI 裡面不可以有 Fragment Component （#zzz）。

傳遞的參數

雖然在 Token Endpoint 的 Spec 裡面沒有寫到必備的參數，但我整理了四種內建流程以及換發 Token 的流程之後，總結出「一定要有 Grant Type」這個事實，所以在這裡寫下來。還有其他參數，但是會根據流程的不同而不同。
參數名 	必/選 	意義
grant_type 	必 	會 switch 到不同的 flow ，見下文 Grant Type 段
state 	建議有 	通用參數，用來維持最初狀態，見下文
scope 	選 	通用參數，用來指定存取範圍，見下文
Grant Type

Grant Type 透過 grant_type 參數來指定，其值定義如下：
值 	意義
authorization_code 	用 Authorization Code 求 Access Token
(Authorization Code Grant Flow)。
password 	用 Resorce Owner Password Credentials 求 Access Token
(Resource Owner Password Credentials Grant Flow)。
client_credentials 	用 Client Credentials 求 Access Token
(Client Credentials Grant Flow)。
refresh_token 	用 Refresh Token 換發 Access Token。

至於更多 Grant Types 可以參考 Section 8.3。

Grant Type 沒給，或不認得的時候，回應錯誤的方式見系列文第 5 篇。
參數解析原則

（同 Authorization Endpoint）
TLS (https) 要求

必須經過 TLS ，因為 request 和 response 裡面都有 credentials 會被看到。
Response 的方式

由於這個 Endpoint 是專門用來核發 Access Token 的，其 Response 的方式以及錯誤回應方式，我寫在系列文第 5 篇。
關於認證 Client 的說明

在 Token Endpoint 的流程裡面，有一步是要認證 Client ，需要認證的 Clients 是 Confidential Clients 或是有發給 Client Credentials 的 Clients 。

實際認證的機制，規定在 Section 2.3 裡面（系列文第 2 篇）。簡單來說，要用 HTTP Basic Auth 來認證，設 Client Credential 為：ID s6BhdRkqt3 、 Secret 7Fjfp0ZBr1KtDRbnfVdmIw ，那麼在 Client 往 Token Endpoint 發 Request 的時候， Request Header 裡面要有這個：

Authorization: Basic czZCaGRSa3F0Mzo3RmpmcDBaQnIxS3REUmJuZlZkbUl3

認證 Client 是為了：

    強化「Refresh Token ↔ 核發的對象 Client」與「Authorization Code ↔ 授予的對象 Client」之間的關係。當 Authorization Code 要透過不安全通道傳到 Redirection Endpoint 的時候，或是 Redirection URI 沒有全部註冊的時候（動態組態，本文略），Client 認證就顯得很重要。
    用來復原被駭掉的 Client ，做法是禁用或更改它的 Credentials ，這樣子可以防止壞人濫用被偷走的 Refresh Token。替換單獨一組 client credential 比撤銷整組 Refresh Tokens 還要來得快。
    實施認證管理的最佳實踐 (Best Practice)，即是要求定期更換 credentials。更換所有的 Refresh Token 是很難做到的，而定期更換單獨一組 credential 卻很容易。

在某些流程裡，Client 會用 client_id 參數來識別自己。像是在 Authorization Code Grant 流程裡面，發 Request 到 Access Token 的時候，沒有認證的 Client （如 Public Client）就必須用 client_id 來避免收到給別的 Client 的 Access Token，Authorization Server 也可以藉此防止 Client 自己置換 Authorization Code。需注意這個方法並不會為 Proteected Resource 帶來額外的保護。

Section 3.2 - 3.2.1
Endpoints 通用的參數
scope: 指定存取範圍

Authorization Endpoint 和 Token Endpoint 允許 Client 指定申請 Access Token 的時候所要的 scopes （存取範圍）。

參數名稱是 scope。格式是一串 scopes 用空格 (U+0020) 分開，區分大小寫。每一個 scope 的值是由 Authorization Server 定義的，格式是 ASCII 可見字元，排除雙引號 " (U+0022) 和反斜線 \ (U+005C)。順序不重要。每出現一個 scope 值，就代表要多加一個新的 scope。

根據 Authorization Server 制定的政策，以及 Resource Owner 的指示，可以完全或部份忽略某些 scopes。在這種情況下，scope 值也會在 Endpoint Response 裡面回傳，也就是當真正授予的 scopes 與原本要求的不同的時候告訴 Client。所以可能比原本要求的 scopes 還要少，也可能還要多。

假如 Client 在申請 Authorization 的時候，沒有給 scope 值，則 Authorization Server 必須做以下之中的一件事：

    用預設值處理（若有）。
    回報錯誤，提示 scope 不合法。

處理方式、預設值、 scope 的要求，應該要寫在 Authorization Server 文件裡。
實務上的 scope

實務上大部份網站的 OAuth 2.0 實作方式， scope 都是用逗號 (,, U+002C) 分隔的，有的甚至不存在 scope 這種東西，一授權就是 full access。之後會寫一篇文章來整理。

Section 3.3
state: 維持 Endpoint 之間的操作狀態

Endpoint 之間可以用 state 參數來維持操作狀態，例如這種情況：

    我打開 A 網站的 X 頁面
    我按下「登入」按鈕來登入 A 網站，用 Facebook 帳號來登入
    Facebook 完成登入流程之後，回到 A 網站
    我希望我看到的是 A 網站的 X 頁面←【目標】

要達到這個目標，就可以用 state 參數來維持「使用者之前在看 X 頁面」這個狀態。

state 參數在傳遞的過程中會原封不動，所以 Client 最後一定會得到原本的 state 。

又，因為 state 可能會放在 URI 裡面，所以如果裡面有敏感資料，則可能會留下痕跡（像是 Log 、 Proxy 的 Log 等等），所以最好是 Client 有內建加解密機制，這樣子在傳遞的過程就不會被抄走。

state 也可以應用在防止 CSRF ，見 Section 10.12 （系列文第 7 篇 ）。
安全性問題
Open Redirectors (Section 10.15)

Open Redirector 指的是 Endpoint 使用某參數來自動把 User-Agent 轉向到該參數所指定的位置，而沒有經過事先驗證。Auothorization Server 、 Authorization Endpoint 、 Client Redirection Endpoint 可能會因為設定的不好所以變成 Open Redirector。

Open Redirectors 會被利用在釣魚攻擊，或是讓壞人得以偽造 URI 的 authority part 讓它看起來很像可信任的網站，引導使用者前往惡意網站。此外，如果 Authorization Server 允許 Client 只事先指定 Redirection URI 的一部分，那麼壞人可以利用 Client 操作的 Open Redirector 來建立一個 Redirection URI ，這個 URI 跳過 Authorization Server 驗證，但是會把 Authorization Code 或 Access Token 傳送到壞人所控制的 endpoint。

在Amazon 的文件裡面，提出了 Open Redirector 常有的 pattern ：

    example.com/go.php?url=
    example.com/search?q=user+search+keywords&url=
    example.com/coupon.jsp?code=ABCDEF&url=
    example.com/login?url=

這種「疑似可以手動指定之後要再轉去別的地方」的參數容易變成 Open Redirector。
