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

Spec 不建议使用这种方法，如果真的没办法送 header 也没办法透过 request-body 送，再来考虑这种。

Resource Server 可以但不一定要支援这个方式。

本段参考 Section 2.4
Resource Server 向 Client 提示「认证不过，拒绝存取」的方式

拒绝存取的情况，例如没给 Access Token 或是给了但不合法（如空号、过期、Resource Owner 没许可 Client 拿取此资料），则 Resource Server 必须在回应里包含 WWW-Authenticate 的 header 来提示错误。这个 header 定义在 RFC 2617 Section 3.2.1。WWW-Authenticate 的值，使用的 auth-scheme 是 Bearer ，随后一个空格，接著要有至少一个 auth-param 。

范例：

HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer realm="example",
                  error="invalid_token",
                  error_description="The access token expired"

以下这些 auth-params 是 WWW-Authenticate 会用到的：
参数名 	必/选 	填什么/意义
realm 	选用 	见下文
scope 	选用 	提示所需权限，见下文
error 	选用 	有出示 Access Token 则最好有这个
realm

用 realm 来指出需要授权才能存取的范围，意义跟 HTTP Authentication 的 realm 一样。realm 只能出现一次。
scope

用 scope 来指出「要拿这个 Resource 需要出示具有哪些 scope 的 Access Token 」：

    要区分大小写。
    要以空白分隔。
    可以用哪些 scope ，是看 Authorization Server 怎么定义，Spec 不定义，也没有登录中心。
    顺序不重要。
    是给程式看的，不是设计给使用者看的。

scope 还可以在向 Authorization Server 索取新 Access Token 的时候使用。

scope 值只能出现一次。实际写在 scope 里面的单一个 scope 必须只能用以下的字元，定义在 RFC 6749 附录 A.4 ：

\x21, \x23-\x5b, \x5d-\x7e

即可见的 US-ASCII 字元里面，除了双引号 " (\x22) 和反斜线 \ (\x5c) 以外。空格当然也不能用，因为是用来区分不同 scopes 的。
error

如果 Client 出示了 Access Token 但认证失败，则最好加上 error 这个 auth-param ，用来告诉 Client 为何认证失败。此外还可以加上 error_description 用自然语言来告诉开发者为什么错误，但这个不该给使用者看到。此外也可以加上 error_uri 用来提供一个网址，里面用自然语言解释错误讯息。这三个 auth-param 都只能最多出现一次。

如果 request 没有出示 Access Token （例如 Client 不知道需要认证，或是使用了不支援的认证方式（例如不支援 URI parameter）），则 response 不应该带 error 或任何错误讯息。

error 的值的意义以及推荐使用的 HTTP response code 如下：
值 	Status Code 	意义/用途
invalid_request 	400 Bad Request 	没提供必要的参数、提供了不支援的参数、提供了错误的参数值、同样的参数出现多次、使用一种以上的方法来出示 Access Token （如放在 header 里又放在 form 里）、或是其他无法解读 request 的情况。
invalid_token 	401 Unauthorized 	Access Token 过期、被收回授权、无法解读、或其他 Access Token 不合法的情况。这种情况下， Client 可以重新申请一个 Access Token 并且用新的 Access Token 来重试 request 。
insufficient_scope 	403 Forbidden 	这个 request 需要出示比 Client 出示的 Access Token 代表的 scopes 还要更多的 scopes 。这种情况下，可以另外提供 scope auth-param 来具体指出需要哪些 scopes 。

error 和 error_description 的值必须只能用以下的字元，定义在 RFC 6749 附录 A.7 和 RFC 6749 附录 A.8：

\x20-\x21, \x23-\x5b, \x5d-\x7e

即空格 (\x20) 再加上可见的 US-ASCII 字元里面，除了双引号 " (\x22) 和反斜线 \ (\x5c) 以外。

error_uri 的值必须符合 RFC 3986 的定义，即是只能用以下的字元（同 scope 里面的单一 scope）：

\x21, \x23-\x5b, \x5d-\x7e

即可见的 US-ASCII 字元里面，除了双引号 " (\x22) 和反斜线 \ (\x5c) 以外。

本段参考 Section 3 及 Section 3.1
Authorization Server 给 Client 核发 Access Token 的范例

既然是 OAuth 2.0 的 access token ，就通常是循 OAuth 2.0 的 spec 来核发，范例如下：

HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8
Cache-Control: no-store
Pragma: no-cache

{
  "access_token":"mF_9.B5f-4.1JqM",
  "token_type":"Bearer",
  "expires_in":3600,
  "refresh_token":"tGzv3JOkF0XG5Qx2TlKWIA"
}

本段参考 Section 4
安全性问题与对策

RFC 6750 是基于 OAuth 2.0 RFC 6749 来写的，所以在该 spec 里面提过的安全性问题就不再提及。

原文将问题与问题对策分开成 Section 5.1 和 Section 5.2 ，我为了方便笔记，所以合并在一起。以下「坏人」的原文是 attacker。
一般对策

大部份的安全性问题可以透过数位签章或是 MAC (Message Authentication Code) 来防护。

Authorization Server 必须有实作 TLS，版本则随时间推移而不同。 spec 作成的时候， TLS 最新版是 1.2 ，但实务上很少使用，1.0 才是最为广泛利用的。
伪造或窜改 Access Token 的问题

坏人可能会伪造或窜改既有的 Access Token （窜改指的是修改授权范围或授权参数），让 Resource Server 给予 Client 不适当的存取权。例如，坏人可能会延长 Token 的过期时间。或是恶意的 Client 变造声明来看到它不应该看到的东西，例如，告诉使用者只拿取公开的个人资料，却在取得授权时，另外拿了朋友名单。

Section 5.1 > Token manufacture/modification
对策

对于 Bearer Token ，可以只加一个参照用的 id 来间接指到真正的授权资讯，而不是直接烧在 Token 里面。这种间接参照用的 id ，必须要难以被猜到；但使用间接参照，因为要间接检查授权资讯，所以可能会导致 Resource Server 和 Authorization Server 之间有额外的动作※。这种机制的细节，spec 里面没有定义。

Spec 没有定义 token 的编码方式，所以不提及保护 Token 的完整性 (integrity) 的详细建议。若要实作保护完整性的措施，则该实作方式必须要可以防止 Token 被窜改。

※：原文是 "between a server and the token issuer"
Access Token 传输过程外泄、曝露敏感资料的问题

Token 传输过程可能被监听而外泄，或 Token 本身可能会包含敏感资料※。

※在 Section 5.1 原文提及 "token disclosure" 的时候，仅提及曝露敏感资料，没提及传输过程的外泄，然而 5.2 里面关于 "token disclosure" 的对策，有一并提及传输过程外泄（中间人攻击、监听等），所以我写这一段时，同时提及传输外泄以及曝露敏感资料。

Section 5.1 > Token disclosure
对策

为了防范 Token 在传输过程外泄，必须用 TLS 来实作机密防护，且该实作方式必须要使用有提供机密防护和完整性防护的加密方式，如此就能要求 Client 与 Authorization Server 和 Client 与 Resource Server 之间的通讯要有机密防护和完整性防护。因为 TLS 是这份 spec 里面规定一定要实作的，所以利用 TLS 来达成通讯过程的机密防护和完整性防护，是比较偏好的做法。

如果要防止 Client 取得 Token 的内容，那么除了 TLS 之外，还必须实作 Token 加密。

要进一步防范 Token 外泄，则 Client 在发 request 的时候，还必须要验证 TLS 的凭证链 (certificate chain) ，包括检查凭证有没有被撤销（Certificate Revocation List, RFC 5280）。

Cookie 通常是明文传输的 (in the clear)，所以任何写在里面的资讯都有外泄的风险。所以， Bearer Token 绝对不可以存放在明文传输 cookie 里面。详见 RFC 6265 (HTTP State Management Mechanism) 里面关于 cookie 的安全性问题。

某些部署方式，好比说利用 Load Balancer 的，TLS 传输在抵达 Resource Server 之前就结束了。这样子会导致 Token 在前端 Load Balaner 和后端实体 Resrouce Server 之间，没有加密保护。这种情况下，必须实作足够的手段※，来确保前端和后端 server 之间的资料保密。Token 加密也是一种方式。

※ 原文为 sufficient measures，我不会翻译…
挪用 Access Token 的问题

坏人可能会把某个专门给 Resource Server A 的 Access Token ，挪用到 Resource Server B ，使得 B 误信该 Access Token 可以拿来存取 B 的资料。

Section 5.1 > Token redirect
对策

要防止 Token 被挪用，则这件事很重要：Authorization Server 核发的 Token 里面要附上被核发人的资讯（通常是一或多部 Resource Server）。同时，也建议限制 Token 可以使用的 scope 范围。
二度利用 Access Token 的问题

坏人使用之前就存在的 Access Token 来存取 Reseouce Server （即：Token 被偷去用）。

Section 5.1 > Token replay
对策

要防止 Token 被偷走并且拿来二度利用，建议采用以下方案：

    Token 的存活时间必须被限制住。一种手段是在 Token 受保护的区段里面，设一个合法期间。使用短时效的 Token （如一小时以下）可以降低 Token 外泄的风险。
    Token 在 Client ↔ Authorization Server 、 Client ↔ Resource Server 之间交换的时候，必须要实作机密防护。如此一来，就算在传输途径上监听，也无法获得 Token ，也就无法二度利用。
    Client 要向 Resource Server 出示 Token 的时候，Client 必须验证 Resource Server 的真实身份，如 RFC 2818 (TLS) 的 Section 3.1 里面所述。注意，Client 必须要验证 TLS 凭证的凭证链 (certificate chain)。若 Resource Server 未经授权且未通过认证，或是凭证链验证失败，这时候向它出示 Token ，会导致敌手取得 Token 并且得到未经授权的权限来存取受保护的 resource。

安全性建议的总结

Section 5.3 Summary of Recommendations
要藏好 Bearer Token

Client 实作必须确保 Bearer Token 不会外泄给无关人士，因为他们可以以此来存取受保护的 resources。利用 Bearer Token 时，这是首要的安全性考量，且优先于其他更细节的建议。
要验证 TLS 的凭证链

当 Client 发 request 索取受保护的 resources 的时候，Client 必须验证 TLS 的凭证链。若做不到的话，可能会引发 DNS 劫持，导致 Token 被坏人偷走。
全程使用 TLS (https)

当 Clients 利用 Bearer Token 发 request 时，Client 必须一直使用 TLS (RFC5246) (https) 或同等的安全传输。若做不到的话， Token 会曝露在各种攻击方式，让坏人可以得到意料之外的存取权。
不要把 Bearer Token 存在 Cookie

绝对不可以把 Bearer Token 存在可以明文传输 (sent in the clear) 的 Cookie 里面（明文传输是 cookie 传输的预设方式）。若存在 Cookie 里面，必须要小心 Cross-Site Request Forgery 。
要核发短时效的 Bearer Token

核发 Token 的伺服器最好是核发短时效的 Bearer Token （一小时以内），尤其是发给跑在浏览器里面的 Client ，或是其他容易发生资讯外泄的场合。利用短时效的 Bearer Token 可以降低 Token 外泄时的冲击。
要核发有区分使用范围的 Bearer Token

Token 伺服器最好要核发包含 audience restriction, scoping their use to the intended replying party, or set of relying party 的 Token 。
不要用 Page URL 来传送 Bearer Token

Bearer Token 最好不要从 URL 来传送（例如 query parameter），而最好是从有保密措施的 HTTP header 或是 body 来传输※。浏览器、伺服器等软体可能不会把历史记录或资料结构给妥善加密。如果 Bearer Token 透过 URL 传输，则坏人就有可能可以从历史记录取得之。

※ "be passed in HTTP message headers or message bodies for which confidentiality measures are taken"
