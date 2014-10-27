 OAuth 2.0 筆記 (5) 核發與換發 Access Token

本文整理核發 Access Token (issuing) 與換發 Access Token (refreshing) 的規格。本來 Spec 裡面是分別寫在 Section 5 和 Section 6 的，不過因為 Endpoint 都是 Token Endpoint （除了 Implicit Grant Type），而且 Response 的規格相同，可以說是 Token Endpoint 的規格，所以我把他們寫在一起。
Response 的規格

Status Code: 200 OK

Header 裡面一定要有這些：

    Pragma: no-cache
    Cache-Control: no-store （如果有 Token 、有 Credential 或是其他敏感資料）

回應的是 JSON，所以：

    參數要編碼成 JSON 格式
    編碼完成的 JSON 放在 Response Body 裡面
    字串 (String) 要符合 JSON String 格式（好比說有些字元要 escape）
    數字 (Number) 要符合 JSON Number 格式

每一個參數都放在 JSON 的第一層。
核發 Access Token

如果 Access Token Request 合法且經授權，則 Authorization Server 會核發 Access Token 以及 Refresh Token （不一定有，看 Access Token 支援以及流程允許與否，例如 Implicit Grant Type 就禁止核發 Refresh Token）。

如果 Access Token Request 失敗，像是 Client 認證不過，或是 Request 不正確，那麼 Authorization Server 會回傳 Error ，本文最末提及。

以下是核發 Access Token 驗證程序都正確、要核發的時候的規格。
參數

Client 收到不認識的參數必須忽略之。參數的長度（含 token）在 spec 裡面都不定義，Client 不可以自行瞎猜，Authorization Server 的文件裡面應該要提到。
參數名 	必/選 	填什麼/意義
access_token 	必 	由 Authorization Server 核發的 Access Token 。
token_type 	必 	Token 的類型，例如 Bearer （見系列文第 6 篇）。
expires_in 	建議有 	幾秒過期，如 3600 表示 1 小時。若要省略，最好在文件裡註明。
scope 	必* 	Access Token 的授權範圍 (scopes)。
refresh_token 	選 	就是 Refresh Token

其中 scope 如果和申請的不同則要附上，如果一樣的話就不必附上。

其中 refresh_token ，可以用來申請新的 Access Token。不一定會有，甚至 Client Credentials Grant Type 就建議不要發。
範例

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

換發 Access Token

換發 (Refreshing) Access Token ，指的是目前的 Access Token 過期、權限不足，而需要取得新的 Token 。可以換發的前提，的前提，是 Authorization Server 之前有核發 Refresh Token 。如果沒有，就不行。Client 可以自動做這件事（像是已知 Token 過期）。

Refresh Token 通常是會存在很久的 token ，且是用來拿取新的 Access Token 的，所以要綁定到被核發的 Client。

換發新的 Access Token 的時候，可以一併核發新的 Refresh Token ，這樣子的話 Client 必須把舊的 Refresh Token 丟掉，換成新的。同時， Authorization Server 也可以撤銷舊的 Refresh Token 。需注意新的 Refresh Token 其 scope 也要跟舊的 Refresh Token 一致。

換發 Access Token 的 Request 是發到 Token Endpoint ，用 POST。
參數
參數名 	必/選 	填什麼/意義
grant_type 	必 	refresh_token
refresh_token 	必 	就填 Refresh Token
scope 	選 	申請的存取範圍

其中 scope 絕對不可以包含之前 Resource Owner 沒有授權過的。如果沒給這個參數，則直接沿用之前授權過的那些。
Authorization Server 的處理程序

這個 Request 進來的時候， Authorization Server 要做這些事：

    要求 Client 認證自己（如果是 Confidential Client 或有拿到 Client Credentials）
    如果 Client 有出示認證資料，就認證它，細節見系列文第 2 篇
    確定 Refresh Token 是發給 Client 的
    驗證 Refresh Token 正確

如果都沒正確，就照核發 Access Token 的方式回 Response （本文「核發 Access Token」一段）。
範例

Client 向 Token Endpoint 換發新的 Access Token

POST /token HTTP/1.1
Host: server.example.com
Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token&refresh_token=tGzv3JOkF0XG5Qx2TlKWIA

發生錯誤時的回應方式

Status Code: 400 Bad Request （若無特別規定就用這個）

Header 和 Format (JSON) 跟核發的時候一樣。
參數

基本上跟 Authorization Code Grant Flow 裡面的 Authorization Endopint 的錯誤參數一樣，差別在於 error 的錯誤代碼可以用的不一樣。
參數名 	必/選 	填什麼/意義
error 	必 	錯誤代碼，其值後述。
error_description 	選 	人可讀的錯誤訊息，給 Client 開發者看的，不是給 End User 看的。ASCII 可見字元，除了雙引號和反斜線之外。
error_uri 	選 	一個 URI ，指向載有錯誤細節的網頁，要符合 URI 的格式。

而 error 的值是以下的其中一個：
值 	意義/用途
invalid_request 	欠缺必要的參數、有不正確的參數、有重複的參數、或其他原因導致無法解讀。
invalid_client 	Client 認證失敗，如 Client 未知、沒送出 Client 認證、使用了 Server 不支援的認證方式。
invalid_grant 	提出的 Grant 或是 Refresh Token 不正確、過期、被撤銷、Redirection URI 不符、不是給你這個 Client。
unauthorized_client 	Client 沒有被授權可以使用這種方法來取得 Authorization Code。
unsupported_grant_type 	Authorization Server 不支援使用這種 Grant Type （例如不支援 MAC）。
invalid_scope 	所要求的 scope 不正確、未知、無法解讀。

其中 invalid_client ：

    Status code 可以用 401 Unauthorized
    如果 Client 是用 Authorization header 來提交認證的，則回應必須用 401 加上 WWW-Authenticate ，其 value 要符合 Client 使用的 auth scheme （如 Bearer）

與 Authorization Endpoint 的差別：

    多了 invalid_client ，因為有 Client 認證這個動作，而 Authorization Endpoint 則沒有。
    多了 invalid_grant ，顯然，因為有傳 Grant 進來。
    沒有 unsupported_response_type ，多了 unsupported_grant_type ，顯然，理由同上。
    沒有 server_error 和 temporarily_unavailable ， Authorization Endpoint 會有，是因為 5xx 沒辦法轉址，而那個 Endpoint 需要轉址。在 Token Endpoint 沒有轉址的動作，所以不需要特別定義這兩個 error code 來提示伺服器錯誤，直接噴 5xx 就行了。（這是我個人的理解，不是寫在 spec 裡面）

範例

HTTP/1.1 400 Bad Request
Content-Type: application/json;charset=UTF-8
Cache-Control: no-store
Pragma: no-cache

{
  "error":"invalid_request"
}
 
