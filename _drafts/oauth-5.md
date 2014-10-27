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

如果都没正确，就照核发 Access Token 的方式