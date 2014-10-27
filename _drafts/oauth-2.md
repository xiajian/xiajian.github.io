---
layout: post
title: OAuth 2.0 笔记 (2) Client 的注册与认证
---

在 OAuth 2.0 的 spec 里面，关于注册 Client (Registration) 这件事，只定义了抽象的概念、类型 (profiles) 与要求，以及基于保密能力把 Clients 分成两类： confidential 和 public。

而认证 (Authentication) 的流程则是有规定需要传送的资料。所谓的认证，就是 Client 要向 Authorization Server 证明自己的身份，若把 Client 比喻为人类使用者的话，就像是打帐号密码之类的动作。在 spec 内建的流程中，需要认证 Client 的地方只有 Token Endpoint，就是「发给你 Token 的时候」认证。其中 Implicit Flow 并没有认证 Client （也没有经过 Token Endpoint）。
Client 的注册

Spec 不规定 Client 如何向 Authorization Server 注册自己，通常是用 HTML 界面。注册时， Authorization Server 与 Client 之间不需要有直接互动，如果 Authorization Server 支援的话，注册的过程可以依赖其他的手段来建立互相的信任、取得 Client 的注册资料（Redirection URI 、Client Type 等）。例如，可以透过内部的通道来搜寻 Client 。

注册的时候， Client 的开发人员应该要做这些事：

    指定 Client Type （见下文）
    指定 Redirection URL （如 Section 3.1.2 所述）
    提供其他 Authorization Server 要求的资料（名称、网站、Logo 等）

Section 2
Client Types

在 spec 里面，根据有没有能力保密 client 的 credentials （帐号密码），定义了两种 Client Types：

confidential：Client 可以自我保密 client 的 credentials（例如跑在 Server 上面，且可以限制 credentials 的存取），或是可以用别的手段来确保认证过程的安全性。

public：Client 无法保密 credentials （Native App 或是跑在 Browser 里面的 App），或是无法用任何手段来保护 client 的认证。

Authorization Server 不应该自行猜测 Client 属于何种。（不过现实却不是这样，见下文。）

单一的 Client 可能会分离成不同的组件 (components) ，如一个跑在 Server 、一个跑在 Client 。若 Authorization Server 没有支援这种 Client ，或没有指南文件，则开发人员时必须为各个组件注册不同的 Clients。

Section 2.1
Client Profiles

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

虽然规定注册时要填