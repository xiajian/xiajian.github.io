---
layout: post
title: OAuth 2.0 笔记 (2) Client 的注册与认证
---

在 OAuth 2.0 的 spec 里面，关于注册 Client (Registration) 这件事，只定义了抽象的概念、类型 (profiles) 与要求，以及基于保密能力把 Clients 分成两类： **confidential** 和 **public**。

而认证 (Authentication) 的流程则是有规定需要传送的资料。所谓的认证，就是 Client 要向 Authorization Server 证明自己的身份，若把 Client 比喻为人类使用者的话，就像是打帐号密码之类的动作。在 spec 内建的流程中，需要认证 Client 的地方只有 Token Endpoint，就是「发给你 Token 的时候」认证。其中 Implicit Flow 并没有认证 Client （也没有经过 Token Endpoint）。

## Client 的注册

Spec 不规定 Client 如何向 Authorization Server 注册自己，通常是用 HTML 界面。注册时， Authorization Server 与 Client 之间不需要有直接互动，如果 Authorization Server 支援的话，注册的过程可以依赖其他的手段来建立互相的信任、取得 Client 的注册资料（Redirection URI 、Client Type 等）。例如，可以透过内部的通道来搜寻 Client 。

注册的时候， Client 的开发人员应该要做这些事：

-  指定 Client Type （见下文）
-  指定 Redirection URL （如 Section 3.1.2 所述）
-  提供其他 Authorization Server 要求的资料（名称、网站、Logo 等）

### Section 2 Client Types

在 spec 里面，根据有没有能力保密 client 的 credentials （帐号密码），定义了两种 Client Types：

confidential：Client 可以自我保密 client 的 credentials（例如跑在 Server 上面，且可以限制 credentials 的存取），或是可以用别的手段来确保认证过程的安全性。

public：Client 无法保密 credentials （Native App 或是跑在 Browser 里面的 App），或是无法用任何手段来保护 client 的认证。

Authorization Server 不应该自行猜测 Client 属于何种。（不过现实却不是这样，见下文。）

单一的 Client 可能会分离成不同的组件 (components) ，如一个跑在 Server 、一个跑在 Client 。若 Authorization Server 没有支援这种 Client ，或没有指南文件，则开发人员时必须为各个组件注册不同的 Clients。

### Section 2.1 Client Profiles

OAuth 2.0 的 spec 是为以下这些类型的 Clients 来设计的：

Web Application：

    属于 confidential
    跑在 Web Server 上面。
    Client Credentials 及 Access Token 储存在 Server 上面，于 Resource Owner 不可见。

User-Agent-based Application

    属于 public
    Client 的程式是从 Web Server 下载到 Resource Owner 的 User-Agent 来执行的。
    通讯协定过程的数据以及 credentials 可以很容易被 Resource Owner 取得（而且通常看得到）。
    也因为这种 app 直接跑在 User-Agent 里面，所以可以在取得 Authorizations 的时候无缝接轨。

Native Application

    属于 public
    安装在 Resource Owner 的设备上，也在其上执行。
    通讯协定过程的数据与 credentials 可以被 Resource Owner 取得。
    任何包在 app 里面的 Client Credentials 都要假设可以被解出来。
    相对而言，动态取得的 credentials ，像是 Access Token 、 Refresh Token ，可以得到某种程度的保护。至少，如果把这些 credentials 存放在 Client 会使用的伺服器上，也可以得到保护。
    在某些平台上，这些 credentials 可能会被保护起来，从而不让其他在同一台设备上的其他 apps 取得。（OS X 的 Keychain Access 就是这种机制）
    关于 Native Application 有更多实作上的考量，请见后文。

举例：

应用程式 	Profile 	Type
自动抓 Facebook 照片的某个伺服器程式 	Web Application 	Confidential
可以连结 Facebook 帐号的 Firefox Add-On 	UA-based Application 	Public
iPhone 版的 Facebook 即时通讯程式 	Native App 	Public

出自 Section 2.1，范例除外

现实中的 Client Registration

虽然规定注册时要填 Client Type，实务上好像没什么网站会要求填写 Client Type 的，甚至 Client Profile，在整份 API 里面，即使会区分 client ，也是把 client 依其 Profiles 区分。
Client Identifier （识别号）

Client 的惟一识别号，注册时取得，对 Authorization Server 也是惟一的。

会被 Resource Owner 看到，所以绝对不可以在 Client Authentication 的时候单独使用。

其长度 spec 并不规定。Client 不可自己猜测。Authorization Server 应该要在文件里提及。

Section 2.2 认证 Client 的方式 (Authentication)

confidential：要有认证流程，其流程要符合 Authorization Server 的安全规范。通常是用事先核发的 credentials （如 Password 、非对称式金钥）。

public：可以有认证方式（不必备），但绝对不能以 Public Client 的认证方式来识别 (identify) 个别的 client 。

Client 每一次 request 只能用一种方式来认证。

Section 2.3 用 Client Password 来认证

方法 (1): HTTP Basic Auth

持有 Password 的 Client 可以用 HTTP Basic Auth 来认证（见 RFC 2617）。帐密要先用 urlencode 编过。

例如 ID 是 s6BhdRkqt3 、 Secret 是 7Fjfp0ZBr1KtDRbnfVdmIw ，则步骤如下：

Step 1: 根据 Basic Auth 的规则，把 ID 和 Secret 连起来，中间用冒号 : 分开，变成这样：

s6BhdRkqt3:7Fjfp0ZBr1KtDRbnfVdmIw

Step 2: 用 base64 编过，变成这样：

czZCaGRSa3F0Mzo3RmpmcDBaQnIxS3REUmJuZlZkbUl3

Step 3: 加上 Basic 前缀：

Basic czZCaGRSa3F0Mzo3RmpmcDBaQnIxS3REUmJuZlZkbUl3

Step 4: 最后得到的 HTTP Auth 的 header 就是：

Authorization: Basic czZCaGRSa3F0Mzo3RmpmcDBaQnIxS3REUmJuZlZkbUl3

方法 (2): POST

此外还有另一种方法（不建议使用）是使用 POST 发送以下资料：
参数名 	必/选 	注
client_id 	必 	
client_secret 	必 	若本来就是空白的密码，则可留空。

注意事项：

    这种方法不建议使用
    应该限制在无法使用 Basic Auth 或其他 HTTP Authentication 方式的 Client 来使用。
    不可以把参数放在 URI 里面。
    要经过 TLS (https) 。
    因为牵涉到密码，所以要防暴力破解。

范例：（换发 Access Token 时，Client 要认证自己）

POST /token HTTP/1.1
Host: server.example.com
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token&refresh_token=tGzv3JOkF0XG5Qx2TlKWIA
&client_id=s6BhdRkqt3&client_secret=7Fjfp0ZBr1KtDRbnfVdmIw

Section 2.3.1 其他认证方式

没规定不能有别的，只要 Authorization Server 没有安全上的疑虑就好了。

不过，如果要做别的认证方式，必须要建一张表记录认证方式跟 Client ID 。
实际上的利用方式

理想与现实总是有段差距。实务上，许多大网站只支援 POST ，Basic Auth 则不一定支援。而 Facebook 则是只支援 GET （不符合「不可以放在 URI 里面」的要求）。
未注册的 Clients

没规定不能有这种 Client 存在，spec 里面也不讨论。
关于 Native Application

Native Application 指的是在 Resource Owner 的设备上面安装、执行的 Client （即桌面应用程式、手机 App），需要特别考虑安全性、平台相容性、整体的 User Experience 。

Authorzation Endpoint 会要求 Client 和 Resource Owner 的 User-Agent 之间的互动。Native Application 可以调用外部的 User-Agent 或是内嵌一个在应用程式里面。用法如下。
外部 User-Agent：

    用 Redirection URI 捉到来自 Authorization Server 的 response ，这个 URI 的 Scheme 要事先向 OS 注册，才能让 Client 成为 Scheme 的处理程式（如 facebook:）。
    手动复制贴上 credentials 。
    跑在本机的 Web Server。
    安装一个 User-Agent 的扩充套件。
    提供一个 Redirection URI 来识别出一个放在 Server 上的、由 Client 控制的 resurce ，让 resource 可以被 Native Application 取得（例如 Facebook 有一个固定的 Redirection URI）。

内嵌 User-Agent:

    直接监视其状态变化来得到 response （例如看到网址变成事先指定的，就表示得到了 redirection）
    直接存取其 cookie。

外部或内嵌 User-Agent 的选择

在选择要用哪一种 User-Agent 的时候，请考虑以下这些事：

    外部的 User-Agent 会增加达成率 (completion rate) ，因为 Resource Owner 可能已经登入到 Authorization Server 了，如此就可以免去重新登入的麻烦，从而让使用者无缝接轨（不需要重新登入）。Resource Owner 也可能会依赖 User-Agent 特有的功能来协助登入（如自动填写密码、二步验证）。
    内嵌的 User-Agent 也许会增进使用的方便性，因为这样就不需要切换到另一个视窗。
    内嵌的 User-Agent 会导致安全上的挑战，因为 Resource Owner 要在一个来历不明的视窗里面填入帐号密码，如果是一般的外部 User-Egent，可以有别的视觉指引来辩认（如 URI、SSL Certificate）。内嵌的 User-Agent 会教育使用者去相信来历不明的认证请求，进而让钓鱼攻击更容易执行。

Grant Flow 的选择

Native Application 可以用的流程是 Implicit Grant 和 Authorization Code Grant 。在选择要用哪一种的时候，请考虑以下这些事：

    使用 Authorization Code Grant 的 Native Application 最好不要兼使用 client credentials ，因为 Native App 无法保密这些资料。
    使用 Implicit Grant 的时候，不会拿到 Refresh Token 不会，这样子一旦过期，就需要重复认证的流程。

Section 9 安全性问题

这里的安全性问题出自 Section 10 ，因为跟 Client Authentcation 有关，所以直接放进来。
Client 认证的安全性问题 (Section 10.1)

Authorization Server 设立 Client credentials 是为了认证 Client。建议 Authorization Server 考虑使用比 Client password 更强的认证方式。Web Application Clients 必须确保 Client password 和其他 credentaisl 的保密。

Authorization Server 不可以为了认证 Client 而核发 Client Passwords 或是其他 credentials 给 Native Application 或是 User-Agent-Based Application Clients ，但是可以核发给特定设备上面的 Native Applciation 。

如果 Client 认证无法实施，Authorization Server 应该使用别的方式来验证 Client 的身份。例如，要求 Client 预先设定 Redirection URI，或是让 Resource Owner 来确认 Client 的身份。虽然，在询问 Resource Owner 的授权的时候，即使有正确的 Redirection URI ，也不足以验证 Client 的身份， 但是可以防止 credentails 传递到假的 Client 。

对于未经认证的 Clients （如 Public Clients），Authorization Server 必须考虑与其互动时会引发的安全性冲击，且核发给这种 Clients 的其他 credentials 有外泄的可能（例如 Refresh Token），应致力降低其可能性。
伪装成别的 Client (Section 10.2)

Client 可能会被骇，像是 credentials 外泄。这种情况发生时，恶意的 Client 可以伪装成被骇的 Client 并取得存取 Protected Resource 的权限。

Authorization Server 必须尽可能认证 Client 。如果 Authorization Server 因为 Client 的性质而不能认证之（例如 In-Browser App 就不能认证），那么 Authorization Server 必须要求其预先设定 Redirection URI 来接收授权的 response，并且应该利用其他手段来保护 Resource Owner 使用这种潜在的恶意 Client 。

Authorizatino Server 应该要强化明确的 Resource Owner 授权流程，并且提供 Resource Owner 关于 Client 要求的授权范围 (scope) 以及时效。Resource Owner 在当下的 Client 的环境里面，要不要检阅这些资讯、要不要授权或拒绝请求，则是他的自由。

当 Authorization Server 收到重复的授权请求的时候，要是 Resource Owner 本人没有与 Authorization Server 互动、Client 没有认证自己、又没有其他方法可以确定重复的请求是来自真正的 Client 而不是伪装的，则 Authorization Server 不应该处理重复的授权请求。
Open Redirector

没要求 Client 事先指定 Redirection URI ，可能会使得 Authorization Endpoint 变成 Open Redirector 。详见系列文第 3 篇关于 Open Redirector 的安全性问题。
