 OAuth 2.0 笔记 (5) 核发与换发 Access Token

本文整理核发 Access Token (issuing) 与换发 Access Token (refreshing) 的规格。本来 Spec 里面是分别写在 Section 5 和 Section 6 的，不过因为 Endpoint 都是 Token Endpoint （除了 Implicit Grant Type），而且 Response 的规格相同，可以说是 Token Endpoint 的规格，所以我把他们写在一起。
Response 的规格

Status Code: 200 OK

Header 里面一定要有这些：

    Pragma: no-cache
    Cache-Control: no-store （如果有 Token 、有 Credential 或是其他敏感资料）

回应的是 JSON，所以：

    参数要编码成 JSON 格式
    编码完成的 JSON 放在 Response Body 里面
    字串 (String) 要符合 JSON String 格式（好比说有些字元要 escape）
    数字 (Number) 要符合 JSON Number 格式

每一个参数都放在 JSON 的第一层。
核发 Access Token

如果 Access Token Request 合法且经授权，则 Authorization Server 会核发 Access Token 以及 Refresh Token （不一定有，看 Access Token 支援以及流程允许与否，例如 Implicit Grant Type 就禁止核发 Refresh Token）。

如果 Access Token Request 失败，像是 Client 认证不过，或是 Request 不正确，那么 Authorization Server 会回传 Error ，本文最末提及。

以下是核发 Access Token 验证程序都正确、要核发的时候的规格。
参数

Client 收到不认识的参数必须忽略之。参数的长度（含 token）在 spec 里面都不定义，Client 不可以自行瞎猜，Authorization Server 的文件里面应该要提到。
参数名 	必/选 	填什么/意义
access_token 	必 	由 Authorization Server 核发的 Access Token 。
token_type 	必 	Token 的类型，例如 Bearer （见系列文第 6 篇）。
expires_in 	建议有 	几秒过期，如 3600 表示 1 小时。若要省略，最好在文件里注明。
scope 	必* 	Access Token 的授权范围 (scopes)。
refresh_token 	选 	就是 Refresh Token

其中 scope 如果和申请的不同则要附上，如果一样的话就不必附上。

其中 refresh_token ，可以用来申请新的 Access Token。不一定会有，甚至 Client Credentials Grant Type 就建议不要发。
范例

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

换发 Access Token

换发 (Refreshing) Access Token ，指的是目前的 Access Token 过期、权限不足，而需要取得新的 Token 。可以换发的前提，的前提，是 Authorization Server 之前有核发 Refresh Token 。如果没有，就不行。Client 可以自动做这件事（像是已知 Token 过期）。

Refresh Token 通常是会存在很久的 token ，且是用来拿取新的 Access Token 的，所以要绑定到被核发的 Client。

换发新的 Access Token 的时候，可以一并核发新的 Refresh Token ，这样子的话 Client 必须把旧的 Refresh Token 丢掉，换成新的。同时， Authorization Server 也可以撤销旧的 Refresh Token 。需注意新的 Refresh Token 其 scope 也要跟旧的 Refresh Token 一致。

换发 Access Token 的 Request 是发到 Token Endpoint ，用 POST。
参数
参数名 	必/选 	填什么/意义
grant_type 	必 	refresh_token
refresh_token 	必 	就填 Refresh Token
scope 	选 	申请的存取范围

其中 scope 绝对不可以包含之前 Resource Owner 没有授权过的。如果没给这个参数，则直接沿用之前授权过的那些。
Authorization Server 的处理程序

这个 Request 进来的时候， Authorization Server 要做这些事：

    要求 Client 认证自己（如果是 Confidential Client 或有拿到 Client Credentials）
    如果 Client 有出示认证资料，就认证它，细节见系列文第 2 篇
    确定 Refresh Token 是发给 Client 的
    验证 Refresh Token 正确

如果都没正确，就照核发 Access Token 的方式回 Response （本文「核发 Access Token」一段）。
范例

Client 向 Token Endpoint 换发新的 Access Token

POST /token HTTP/1.1
Host: server.example.com
Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token&refresh_token=tGzv3JOkF0XG5Qx2TlKWIA

发生错误时的回应方式

Status Code: 400 Bad Request （若无特别规定就用这个）

Header 和 Format (JSON) 跟核发的时候一样。
参数

基本上跟 Authorization Code Grant Flow 里面的 Authorization Endopint 的错误参数一样，差别在于 error 的错误代码可以用的不一样。
参数名 	必/选 	填什么/意义
error 	必 	错误代码，其值后述。
error_description 	选 	人可读的错误讯息，给 Client 开发者看的，不是给 End User 看的。ASCII 可见字元，除了双引号和反斜线之外。
error_uri 	选 	一个 URI ，指向载有错误细节的网页，要符合 URI 的格式。

而 error 的值是以下的其中一个：
值 	意义/用途
invalid_request 	欠缺必要的参数、有不正确的参数、有重复的参数、或其他原因导致无法解读。
invalid_client 	Client 认证失败，如 Client 未知、没送出 Client 认证、使用了 Server 不支援的认证方式。
invalid_grant 	提出的 Grant 或是 Refresh Token 不正确、过期、被撤销、Redirection URI 不符、不是给你这个 Client。
unauthorized_client 	Client 没有被授权可以使用这种方法来取得 Authorization Code。
unsupported_grant_type 	Authorization Server 不支援使用这种 Grant Type （例如不支援 MAC）。
invalid_scope 	所要求的 scope 不正确、未知、无法解读。

其中 invalid_client ：

    Status code 可以用 401 Unauthorized
    如果 Client 是用 Authorization header 来提交认证的，则回应必须用 401 加上 WWW-Authenticate ，其 value 要符合 Client 使用的 auth scheme （如 Bearer）

与 Authorization Endpoint 的差别：

    多了 invalid_client ，因为有 Client 认证这个动作，而 Authorization Endpoint 则没有。
    多了 invalid_grant ，显然，因为有传 Grant 进来。
    没有 unsupported_response_type ，多了 unsupported_grant_type ，显然，理由同上。
    没有 server_error 和 temporarily_unavailable ， Authorization Endpoint 会有，是因为 5xx 没办法转址，而那个 Endpoint 需要转址。在 Token Endpoint 没有转址的动作，所以不需要特别定义这两个 error code 来提示伺服器错误，直接喷 5xx 就行了。（这是我个人的理解，不是写在 spec 里面）

范例

HTTP/1.1 400 Bad Request
Content-Type: application/json;charset=UTF-8
Cache-Control: no-store
Pragma: no-cache

{
  "error":"invalid_request"
}
