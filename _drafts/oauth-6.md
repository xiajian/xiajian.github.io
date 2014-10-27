 OAuth 2.0 笔记 (6) Bearer Token 的使用方法

September 30, 2013 · 0 Comments

这篇不属于 OAuth 2.0 规格书（RFC 6749）本身，而是属于另一份 spec RFC 6750: The OAuth 2.0 Authorization Framework: Bearer Token Usage 。我认为它存在的目的是「示范一下 Token 的用法，并且定义下来，让大家可以参考」，因为 OAuth 2.0 规格书没有明确规定「Token 长什么样子」，甚至「Resource Server 如何拒绝非法的 Token」（指 API）都没定义，只规定了怎么拿取、怎么撤销、怎么流通。

实际上，即使有定义这个 Bearer Token ，各大网站的 API 也并非都使用这种 Token ，我看到有明确说明使用 Bearer Token 的像是 Twitter API，其他的要不是非使用 "Bearer" 关键字，就是没有明确指出何种 Token （其实也不需要，因为在那些网站 Token 只有一种用途）。

不过即使如此，对于我打算实作的 API ，我也是准备使用 Bearer Token 的，因为够 naïve 。如果你跟我一样没有自己刻 Token 的能力，就用 Bearer Token 就好了。

当然， RFC 6750 我也有转成 Markdown 好读版。
Bearer Token 的用途

OAuth 2.0 (RFC 6749) 定义了 Client 如何取得 Access Token 的方法。Client 可以用 Access Token 以 Resource Owner 的名义来向 Resource Server 取得 Protected Resource ，例如我 (Resource Owner) 授权一个手机 App (Client) 以我 (Resource Owner) 的名义去 Facebook (Resource Server) 取得我的朋友名单 (Protected Resource)。OAuth 2.0 定义 Access Token 是 Resource Server 用来认证的唯一方式，有了这个， Resource Server 就不需要再提供其他认证方式，例如帐号密码。

然而在 RFC 6749 里面只定义抽象的概念，细节如 Access Token 格式、怎么传到 Resource Server ，以及 Access Token 无效时， Resource Server 怎么处理，都没有定义。所以在 RFC 6750 另外定义了 Bearer Token 的用法。Bearer Token 是一种 Access Token ，由 Authorization Server 在 Resource Owner 的允许下核发给 Client ，Resource Server 只要认这个 Token 就可以认定 Client 已经经由 Resource Owner 的许可，不需要用密码学的方式来验证这个 Token 的真伪。关于 Token 被偷走的安全性问题，此 Spec 里面也有提到。

本段参考 Abstract 及 Section 1
Bearer Token 的格式

Bearer XXXXXXXX

其中 XXXXXXXX 的格式为 b64token ，ABNF 的定义：

b64token = 1*( ALPHA / DIGIT / "-" / "." / "_" / "~" / "+" / "/" ) *"="

写成 Regular Expression 即是：

/[A-Za-z0-9\-\._~\+\/]+=*/

本段参考 Section 2.1
Client 向 Resource Server 出示 Access Token 的方式

三种
(1) 放在 HTTP Header 里面

GET /resource HTTP/1.1
Host: server.example.com
Authorization: Bearer mF_9.B5f-4.1JqM

Resource Server 必须支援这个方式。

本段参考 Section 2.2
(2) 放在 Request Body 里面（Form 之类的）

POST /resource HTTP/1.1
Host: server.example.com
Content-Type: application/x-www-form-urlencoded

access_token=mF_9.B5f-4.1JqM

前提：

    Header 要有 Content-Type: application/x-www-form-urlencoded。
    Body 格式要符合 W3C HTML 4.01 定义 application/x-www-form-urlencoded。
    Body 要只有一个 part （不可以是 multipart）。
    Body 要编码成只有 ASCII chars 的内容。
    Request method 必须是一种有使用 request-body 的，也就是说不能用 GET 。

就是送表单嘛，但不可以是 multipart/form-data 这种（通常用来上传档案）。

Resource Server 可以但不一定要支援这个方式。

本段参考 Section 2.3
(3) 放在 URI 里面的一个 Query Parameter （不建议）

规定要使用 access_token 这个 parameter ，例：

GET /resource?access_token=mF_9.B5f-4.1JqM HTTP/1.1
Host: server.example.com

然而因为 URL 可以被 proxy 抄走（如 log）或存在浏览器的历史记录里面，为了防 replay ，最好这样做：

    Client 送 Cache-Control: no-store header
    Server 回 2xx 的时候，送 Cache-Control: private header

Spec 不建议使用这种
