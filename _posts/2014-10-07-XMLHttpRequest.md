---
layout: post
title: XMLHttpRequest Level 1
---

[XMLHttpRequest Level 1](http://www.w3.org/TR/XMLHttpRequest/)是W3C的草案，个人在看《Web 性能》时看到，试着翻译一下。

## 摘要
----

XMLHttpRequest规范定义了在客户端和服务器端传递数据的API，其用提供客户端的脚本化的功能。

> 注： W3C网站上的只是[XMLHttpRequest Living Specification](https://xhr.spec.whatwg.org/)的一个快照。

##1 Introduction

> 本节是非规范的。

XMLHttpRequest对象是用来下载资源的API。 object is an API for fetching resources.

The name XMLHttpRequest is historical and has no bearing on its functionality.

Some simple code to do something with data from an XML document fetched over the network:

```javascript
function processData(data) {
  // taking care of data
}

function handler() {
  if(this.readyState == this.DONE) {
    if(this.status == 200 &&
       this.responseXML != null &&
       this.responseXML.getElementById('test').textContent) {
      // success!
      processData(this.responseXML.getElementById('test').textContent);
      return;
    }
    // something went wrong
    processData(null);
  }
}

var client = new XMLHttpRequest();
client.onreadystatechange = handler;
client.open("GET", "unicorn.xml");
client.send();
```

If you just want to log a message to the server:

```javascript
function log(message) {
  var client = new XMLHttpRequest();
  client.open("POST", "/log");
  client.setRequestHeader("Content-Type", "text/plain;charset=UTF-8");
  client.send(message);
}
```

Or if you want to check the status of a document on the server:

```javascript
function fetchStatus(address) {
  var client = new XMLHttpRequest();
  client.onreadystatechange = function() {
    // in case of network errors this might not give reliable results
    if(this.readyState == this.DONE)
      returnStatus(this.status);
  }
  client.open("HEAD", address);
  client.send();
}
```

### 1.1 Specification history

The XMLHttpRequest object was initially defined as part of the WHATWG's HTML effort. (Based on Microsoft's implementation many years prior.) It moved to the W3C in 2006. Extensions (e.g. progress events and cross-origin requests) to XMLHttpRequest were developed in a separate draft (XMLHttpRequest Level 2) until end of 2011, at which point the two drafts were merged and XMLHttpRequest became a single entity again from a standards perspective. End of 2012 it moved back to the WHATWG. 

## 2 Conformance

All diagrams, examples, and notes in this specification are non-normative, as are all sections explicitly marked non-normative. Everything else in this specification is normative.

The key words "MUST", "MUST NOT", "REQUIRED", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in the normative parts of this specification are to be interpreted as described in RFC2119. For readability, these words do not appear in all uppercase letters in this specification. [RFC2119]

2.1 Extensibility

User agents, Working Groups, and other interested parties are strongly encouraged to discuss new features with the WHATWG community.

## 3 Terminology

This specification uses terminology, cross-linked throughout, from DOM, DOM Parsing and Serialization, Encoding, Fetch, File API, HTML, HTTP, URL, Web IDL, and XML. [DOM] [DOMPS] [ENCODING] [FETCH] [FILEAPI] [HTML] [HTTP] [URL] [WEBIDL] [XML] [XMLNS]

It uses the typographic conventions from HTML. [HTML]

The term user credentials for the purposes of this specification means cookies, HTTP authentication, and client-side SSL certificates. Specifically it does not refer to proxy authentication or the Origin header. [COOKIES]


## 4 Interface XMLHttpRequest

```javascript
[NoInterfaceObject,
 Exposed=(Window,Worker)]
interface XMLHttpRequestEventTarget : EventTarget {
  // event handlers
  attribute EventHandler onloadstart;
  attribute EventHandler onprogress;
  attribute EventHandler onabort;
  attribute EventHandler onerror;
  attribute EventHandler onload;
  attribute EventHandler ontimeout;
  attribute EventHandler onloadend;
};

[Exposed=(Window,Worker)]
interface XMLHttpRequestUpload : XMLHttpRequestEventTarget {
};

enum XMLHttpRequestResponseType {
  "",
  "arraybuffer",
  "blob",
  "document",
  "json",
  "text"
};

[Constructor,
 Exposed=(Window,Worker)]
interface XMLHttpRequest : XMLHttpRequestEventTarget {
  // event handler
  attribute EventHandler onreadystatechange;

  // states
  const unsigned short UNSENT = 0;
  const unsigned short OPENED = 1;
  const unsigned short HEADERS_RECEIVED = 2;
  const unsigned short LOADING = 3;
  const unsigned short DONE = 4;
  readonly attribute unsigned short readyState;

  // request
  void open(ByteString method, USVString url);
  void open(ByteString method, USVString url, boolean async, optional USVString? username = null, optional USVString? password = null);
  void setRequestHeader(ByteString name, ByteString value);
           attribute unsigned long timeout;
           attribute boolean withCredentials;
  readonly attribute XMLHttpRequestUpload upload;
  void send(optional (Document or BodyInit)? body = null);
  void abort();

  // response
  readonly attribute USVString responseURL;
  readonly attribute unsigned short status;
  readonly attribute ByteString statusText;
  ByteString? getResponseHeader(ByteString name);
  ByteString getAllResponseHeaders();
  void overrideMimeType(DOMString mime);
           attribute XMLHttpRequestResponseType responseType;
  readonly attribute any response;
  readonly attribute USVString responseText;
  [Exposed=Window] readonly attribute Document? responseXML;
};
```

Each XMLHttpRequest object has a unique, associated XMLHttpRequestUpload object.

### 4.1 Constructors

The XMLHttpRequest object has an associated settings object.

client = new XMLHttpRequest()
    Returns a new XMLHttpRequest object. 

The XMLHttpRequest() constructor must run these steps:

- Let xhr be a new XMLHttpRequest object.
- Set xhr's settings object to the relevant settings object for the global object of xhr's interface object.
- Return xhr. 

### 4.2 Garbage collection

An XMLHttpRequest object must not be garbage collected if its state is OPENED and the send() flag is set, its state is HEADERS_RECEIVED, or its state is LOADING and it has one or more event listeners registered whose type is one of readystatechange, progress, abort, error, load, timeout, and loadend.

If an XMLHttpRequest object is garbage collected while its connection is still open, the user agent must terminate the request.

### 4.3 Event handlers

The following are the event handlers (and their corresponding event handler event types) that must be supported on objects implementing an interface that inherits from XMLHttpRequestEventTarget as attributes:
event handler 	event handler event type
onloadstart 	loadstart
onprogress 	progress
onabort 	abort
onerror 	error
onload 	load
ontimeout 	timeout
onloadend 	loadend

The following is the event handler (and its corresponding event handler event type) that must be supported as attribute solely by the XMLHttpRequest object:
event handler 	event handler event type
onreadystatechange 	readystatechange

### 4.4 States

client . readyState

    Returns the current state. 

The XMLHttpRequest object can be in several states. The readyState attribute must return the current state, which must be one of the following values:

UNSENT (numeric value 0)

    The object has been constructed.
OPENED (numeric value 1)

    The open() method has been successfully invoked. During this state request headers can be set using setRequestHeader() and the request can be made using the send() method.
HEADERS_RECEIVED (numeric value 2)

    All redirects (if any) have been followed and all HTTP headers of the response have been received. 
LOADING (numeric value 3)

    The response's body is being received. 
DONE (numeric value 4)

    The data transfer has been completed or something went wrong during the transfer (e.g. infinite redirects).

Initially the XMLHttpRequest object must be in the UNSENT state.

The send() flag indicates that the send() method has been invoked. It is initially unset and is used during the OPENED state.

### 4.5 Request

Each XMLHttpRequest object has the following request-associated concepts: request method, request URL, author request headers, request body, synchronous flag, upload complete flag, and upload events flag.

The author request headers is an initially empty header list.

The request body is initially null.

The synchronous flag, upload complete flag, and upload events flag are initially unset.

To terminate the request, terminate the fetch algorithm operated by the XMLHttpRequest object with reason fatal.

#### 4.5.1 The open() method

client . open(method, url [, async = true [, username = null [, password = null]]])

    Sets the request method, request URL, and synchronous flag.

    Throws a SyntaxError exception if either method is not a valid HTTP method or url cannot be parsed.

    Throws a SecurityError exception if method is a case-insensitive match for `CONNECT`, `TRACE` or `TRACK`.

    Throws an InvalidAccessError exception if async is false, the JavaScript global environment is a document environment, and either the timeout attribute is not zero, the withCredentials attribute is true, or the responseType attribute is not the empty string. 

Developers must not pass false for the async argument when the JavaScript global environment is a document environment as it has detrimental effects to the end user's experience. User agents are strongly encouraged to warn about such usage in developer tools and may experiment with throwing an InvalidAccessError exception when it occurs so the feature can eventually be removed from the platform.

The open(method, url, async, username, password) method must run these steps:

    If settings object's responsible document is not fully active, throw an InvalidStateError exception.

    Set base to settings object's API base URL.

    If method is not a method, throw a SyntaxError exception.

    If method is a forbidden method, throw a SecurityError exception.

    Normalize method.

    Let parsedURL be the result of parsing url with base.

    If parsedURL is failure, throw a SyntaxError exception.

    If the async argument is omitted, set async to true, and set username and password to null.

    Unfortunately legacy content prevents treating the async argument being undefined identical from it being omitted.

    If parsedURL's relative flag is set, run these substeps:

        If the username argument is not null, set parsedURL's username to username.

        If the password argument is not null, set parsedURL's password to password. 

    If async is false, the JavaScript global environment is a document environment, and either the timeout attribute value is not zero, the withCredentials attribute value is true, or the responseType attribute value is not the empty string, throw an InvalidAccessError exception.

    Terminate the request.

    A fetch can be ongoing at this point.

    Set variables associated with the object as follows:

        Set request method to method.

        Set request URL to parsedURL.

        Set the synchronous flag, if async is false, and unset the synchronous flag otherwise.

        Empty author request headers.

        Set response to a network error.

        Set response ArrayBuffer object to null.

        Set response Blob object to null.

        Set response Document object to null.

        Set response JSON object to null. 

    If the state is not OPENED, run these substeps:

        Change the state to OPENED.

        Fire an event named readystatechange. 

#### 4.5.2 The setRequestHeader() method

client . setRequestHeader(name, value)

    Combines a header in author request headers.

    Throws an InvalidStateError exception if the state is not OPENED or if the send() flag is set.

    Throws a SyntaxError exception if name is not a header name or if value is not a header value. 

As indicated in the algorithm below certain headers cannot be set and are left up to the user agent. In addition there are certain other headers the user agent will take control of if they are not set by the author as indicated at the end of the send() method section.

The setRequestHeader(name, value) method must run these steps:

    If the state is not OPENED, throw an InvalidStateError exception.

    If the send() flag is set, throw an InvalidStateError exception.

    If name is not a name or value is not a value, throw a SyntaxError exception.

    An empty byte sequence represents an empty header value.

    Terminate these steps if name is a forbidden header name.

    Combine name/value in author request headers. 

Some simple code demonstrating what happens when setting the same header twice:

```javascript
// The following script:
var client = new XMLHttpRequest();
client.open('GET', 'demo.cgi');
client.setRequestHeader('X-Test', 'one');
client.setRequestHeader('X-Test', 'two');
client.send();

// …results in the following header being sent:
X-Test: one, two
```

#### 4.5.3 The timeout attribute

client . timeout

    Can be set to a time in milliseconds. When set to a non-zero value will cause fetching to terminate after the given time has passed. When the time has passed, the request has not yet completed, and the synchronous flag is unset, a timeout event will then be dispatched, or a TimeoutError exception will be thrown otherwise (for the send() method).

    When set: throws an InvalidAccessError exception if the synchronous flag is set and the JavaScript global environment is a document environment. 

The timeout attribute must return its value. Initially its value must be zero.

Setting the timeout attribute must run these steps:

    If the JavaScript global environment is a document environment and the synchronous flag is set, throw an InvalidAccessError exception.

    Set its value to the new value. 

This implies that the timeout attribute can be set while fetching is in progress. If that occurs it will still be measured relative to the start of fetching.

#### 4.5.4 The withCredentials attribute

client . withCredentials

    True when user credentials are to be included in a cross-origin request. False when they are to be excluded in a cross-origin request and when cookies are to be ignored in its response. Initially false.

    When set: throws an InvalidStateError exception if the state is not UNSENT or OPENED, or if the send() flag is set.

    When set: throws an InvalidAccessError exception if either the synchronous flag is set and the JavaScript global environment is a document environment. 

The withCredentials attribute must return its value. Initially its value must be false.

Setting the withCredentials attribute must run these steps:

    If the state is not UNSENT or OPENED, throw an InvalidStateError exception.

    If the send() flag is set, throw an InvalidStateError exception.

    If the JavaScript global environment is a document environment and the synchronous flag is set, throw an InvalidAccessError exception.

    Set the withCredentials attribute's value to the given value. 

The withCredentials attribute has no effect when fetching same-origin resources.

#### 4.5.5 The upload attribute

client . upload

    Returns the associated XMLHttpRequestUpload object. It can be used to gather transmission information when data is transferred to a server. 

The upload attribute must return the associated XMLHttpRequestUpload object.

As indicated earlier, each XMLHttpRequest object has an associated XMLHttpRequestUpload object.

#### 4.5.6 The send() method

client . send([body = null])

    Initiates the request. The optional argument provides the request body. The argument is ignored if request method is GET or HEAD.

    Throws an InvalidStateError exception if the state is not OPENED or if the send() flag is set. 

The send(body) method must run these steps:

    If the state is not OPENED, throw an InvalidStateError exception.

    If the send() flag is set, throw an InvalidStateError exception.

    If the request method is GET or HEAD, set body to null.

    If body is null, go to the next step.

    Otherwise, let encoding be null, Content-Type be null, and then follow these rules, depending on body:

    Document

        Set encoding to `UTF-8`.

        If body is an HTML document, set Content-Type to `text/html`, and set Content-Type to `application/xml` otherwise. Then append `;charset=UTF-8` to Content-Type.

        Set request body to body, serialized, converted to Unicode, and utf-8 encoded. Re-throw any exception serializing throws.

        If body cannot be serialized, an InvalidStateError exception is thrown. 
    BodyInit

        If body is a string, set encoding to `UTF-8`.

        Set request body and Content-Type to the result of extracting body. 

    If Content-Type is non-null and author request headers contains no header named `Content-Type`, append `Content-Type`/Content-Type to author request headers.

    Otherwise, if the header named `Content-Type` in author request headers has a value that is a valid MIME type, which has a `charset` parameter whose value is not a case-insensitive match for encoding, and encoding is not null, set all the `charset` parameters of that `Content-Type` header's value to encoding.

    Let req be a new request, initialized as follows:

    method
        request method 
    url
        request URL 
    header list
        author request headers 
    unsafe request flag
        Set. 
    origin
        settings object's origin 
    force Origin header flag
        Set. 
    referrer
        settings object's API referrer source's URL if settings object's API referrer source is a document, and settings object's API referrer source otherwise 
    body
        request body 
    client
        settings object's global object 
    context
        xmlhttprequest 
    authentication flag
        Set. 
    synchronous flag
        Set if the synchronous flag is set. 
    mode
        CORS if the upload events flag is unset, and CORS-with-forced-preflight otherwise. 
    credentials mode
        If the withCredentials attribute value is true, include, and same-origin otherwise. 
    use URL credentials flag
        Set if either request URL's username is not the empty string or request URL's password is non-null. 

    If a header named `Accept-Language` is not in req's header list, append `Accept-Language`/an appropriate value to it.

    If a header named `Accept` is not in req's header list, append `Accept`/`*/*` to it.

    Unset the upload complete flag and upload events flag.

    If req's body is null, set the upload complete flag.

    Set the send() flag.

    If the synchronous flag is unset, run these substeps:

        If one or more event listeners are registered on the XMLHttpRequestUpload object, set the upload events flag.

        Fire a progress event named loadstart with 0 and 0.

        If the upload complete flag is unset, fire a progress event named loadstart on the XMLHttpRequestUpload object with 0 and req's body's length.

        Fetch req. Handle the tasks queued on the networking task source per below.

        If the timeout attribute value is not 0, terminate fetching after the amount of milliseconds specified by the timeout attribute value have passed with reason timeout.

        To process request body for request, run these subsubsteps:

            If not roughly 50ms have passed since these subsubsteps were last invoked, terminate these subsubsteps.

            Fire a progress event named progress on the XMLHttpRequestUpload object with request's body's transmitted and request's body's length. 

        To process request end-of-file for request, run these subsubsteps:

            Set the upload complete flag.

            Let transmitted be request's body's transmitted.

            Let length be request's body's length.

            Fire a progress event named progress on the XMLHttpRequestUpload object with transmitted and length.

            Fire a progress event named load on the XMLHttpRequestUpload object with transmitted and length.

            Fire a progress event named loadend on the XMLHttpRequestUpload object with transmitted and length. 

        To process response for response, run these subsubsteps:

            Set response to response.

            Handle errors for response.

            If response is a network error, return.

            Change the state to HEADERS_RECEIVED.

            Fire an event named readystatechange. 

        To process response body for response, run these subsubsteps:

            If not roughly 50ms have passed since these subsubsteps were last invoked, terminate these subsubsteps.

            Handle errors for response.

            If response is a network error, return.

            If state is HEADERS_RECEIVED, change the state to LOADING and fire an event named readystatechange.

            Fire a progress event named progress with response's body's transmitted and response's body's length. 

        To process response end-of-file for response, run handle response end-of-file for response. 

    Otherwise, if the synchronous flag is set, run these substeps:

        Release the storage mutex.

        Let response be the result of fetching req.

        Run handle response end-of-file for response. 

To handle response end-of-file for response, run these steps:

    If the synchronous flag is set, set response to response.

    Handle errors for response.

    If response is a network error, return.

    If the synchronous flag is unset, update response's body using response.

    Change the state to DONE.

    Unset the send() flag.

    Fire an event named readystatechange.

    Let transmitted be response's body's transmitted.

    Let length be response's body's length.

    Fire a progress event named progress with transmitted and length.

    Fire a progress event named load with transmitted and length.

    Fire a progress event named loadend with transmitted and length. 

To handle errors for response run these steps:

    If the send() flag is unset, return.

    If response is a network error, run the request error steps for event error and exception NetworkError.

    Otherwise, if response has a termination reason:

    end-user abort

        Run the request error steps for event abort and exception AbortError. 
    fatal

            Change the state to DONE.

            Unset the send() flag.

            Set response to a network error. 
    timeout

        Run the request error steps for event timeout and exception TimeoutError. 

The request error steps for event event and optionally an exception exception are:

    Change the state to DONE.

    Unset the send() flag.

    Set response to a network error.

    If the synchronous flag is set, throw an exception exception.

    Fire an event named readystatechange.

    At this point it is clear that the synchronous flag is unset.

    If the upload complete flag is unset, follow these substeps:

        Set the upload complete flag.

        Fire a progress event named progress on the XMLHttpRequestUpload object with 0 and 0.

        Fire a progress event named event on the XMLHttpRequestUpload object with 0 and 0.

        Fire a progress event named loadend on the XMLHttpRequestUpload object with 0 and 0. 

    Fire a progress event named progress with 0 and 0.

    Fire a progress event named event with 0 and 0.

    Fire a progress event named loadend with 0 and 0.

    4.5.7 The abort() method

client . abort()
    Cancels any network activity. 

The abort() method must run these steps:

    Terminate the request.

    If the state is OPENED with the send() flag set, HEADERS_RECEIVED, or LOADING, run the request error steps for event abort.

    Change the state to UNSENT.

    No readystatechange event is dispatched. 

### 4.6 Response

An XMLHttpRequest has an associated response. Unless stated otherwise it is a network error.
4.6.1 The responseURL attribute

The responseURL attribute must return the empty string if response's url is null and its serialization with the exclude fragment flag set otherwise.
4.6.2 The status attribute

The status attribute must return the response's status.
4.6.3 The statusText attribute

The statusText attribute must return the response's status message.
4.6.4 The getResponseHeader() method

The getResponseHeader(name) method must run these steps:

    If response's header list has multiple headers whose name is name, return their values in list order as a single byte sequence separated from each other by a 0x2C 0x20 byte pair.

    If response's header list has one header whose name is name, return its value.

    Return null. 

The Fetch Standard filters response's header list. [FETCH]

For the following script:

```javascript
var client = new XMLHttpRequest();
client.open("GET", "unicorns-are-teh-awesome.txt", true);
client.send();
client.onreadystatechange = function() {
  if(this.readyState == 2) {
    print(client.getResponseHeader("Content-Type"));
  }
}
```

The print() function will get to process something like:

text/plain; charset=UTF-8

4.6.5 The getAllResponseHeaders() method

The getAllResponseHeaders() method must return response's header list, in list order, as a single byte sequence with each header separated by a 0x0D 0x0A byte pair, and each name and value of a header separated by a 0x3A 0x20 byte pair.

The Fetch Standard filters response's header list. [FETCH]

For the following script:

var client = new XMLHttpRequest();
client.open("GET", "narwhals-too.txt", true);
client.send();
client.onreadystatechange = function() {
  if(this.readyState == 2) {
    print(this.getAllResponseHeaders());
  }
}

The print() function will get to process something like:

Date: Sun, 24 Oct 2004 04:58:38 GMT
Server: Apache/1.3.31 (Unix)
Keep-Alive: timeout=15, max=99
Connection: Keep-Alive
Transfer-Encoding: chunked
Content-Type: text/plain; charset=utf-8

4.6.6 Response body

The response MIME type is the MIME type the `Content-Type` header contains excluding any parameters and converted to ASCII lowercase, or null if the response header can not be parsed or was omitted. The override MIME type is initially null and can get a value if overrideMimeType() is invoked. Final MIME type is the override MIME type unless that is null in which case it is the response MIME type.

The response charset is the value of the charset parameter of the `Content-Type` header or null if there was no `charset` parameter or the header could not be parsed or was omitted. The override charset is initially null and can get a value if overrideMimeType() is invoked. Final charset is the override charset unless that is null in which case it is the response charset.

An XMLHttpRequest object has an associated response ArrayBuffer object, response Blob object, response Document object, and a response JSON object. Their shared initial value is null.

An arraybuffer response is the return value of these steps:

    If response ArrayBuffer object is non-null, return it.

    Let bytes be the empty byte sequence, if response's body is null, and response's body otherwise.

    Set response ArrayBuffer object to a new ArrayBuffer object representing bytes and return it. 

A blob response is the return value of these steps:

    If response Blob object is non-null, return it.

    Let type be the empty string, if final MIME type is null, and final MIME type otherwise.

    Let bytes be the empty byte sequence, if response's body is null, and response's body otherwise.

    Set response Blob object to a new Blob object representing bytes with type type and return it. 

A document response is the return value of these steps:

    If response Document object is non-null, return it.

    Let bytes be response's body.

    If bytes is null, return null.

    If final MIME type is not null, text/html, text/xml, application/xml, or does not end in +xml, return null.

    If responseType is the empty string and final MIME type is text/html, return null.

    This is restricted to responseType being "document" in order to prevent breaking legacy content.

    If final MIME type is text/html, run these substeps:

        Let charset be the final charset.

        If charset is null, prescan the first 1024 bytes of bytes and if that does not terminate unsuccessfully then let charset be the return value.

        If charset is null, set charset to utf-8.

        Let document be a document that represents the result parsing bytes following the rules set forth in the HTML Standard for an HTML parser with scripting disabled and a known definite encoding charset. [HTML]

        Flag document as an HTML document. 

    Otherwise, let document be a document that represents the result of running the XML parser with XML scripting support disabled on bytes. If that fails (unsupported character encoding, namespace well-formedness error, etc.), return null. [HTML]

    Resources referenced will not be loaded and no associated XSLT will be applied.

    If charset is null, set charset to utf-8.

    Set document's encoding to charset.

    Set document's content type to final MIME type.

    Set document's URL to response's url.

    Set document's origin to settings object's origin.

    Set response Document object to document and return it. 

A JSON response is the return value of these steps:

    If response JSON object is non-null, return it.

    Let bytes be response's body.

    If bytes is null, return null.

    Let JSON text be the result of running utf-8 decode on byte stream bytes.

    Let JSON object be the result of invoking the initial value of the parse property of the JSON object, with JSON text as its only argument. If that threw an exception, return null. [ECMASCRIPT]

    Set response JSON object to JSON object and return it. 

A text response is the return value of these steps:

    Let bytes be response's body.

    If bytes is null, return the empty string.

    Let charset be the final charset.

    If responseType is the empty string, charset is null, and final MIME type is either null, text/xml, application/xml or ends in +xml, use the rules set forth in the XML specifications to determine the encoding. Let charset be the determined encoding. [XML] [XMLNS]

    This is restricted to responseType being the empty string to keep the non-legacy responseType value "text" simple.

    If charset is null, set charset to utf-8.

    Return the result of running decode on byte stream bytes using fallback encoding charset. 

Authors are strongly encouraged to always encode their resources using utf-8.
4.6.7 The overrideMimeType() method

client . overrideMimeType(mime)

    Sets the `Content-Type` header for response to mime.

    Throws an InvalidStateError exception if the state is LOADING or DONE.

    Throws a SyntaxError exception if mime is not a valid MIME type. 

The overrideMimeType(mime) method must run these steps:

    If the state is LOADING or DONE, throw an InvalidStateError exception.

    If parsing mime analogously to the value of the `Content-Type` header fails, throw a SyntaxError exception.

    If mime is successfully parsed, set override MIME type to its MIME type, excluding any parameters, and converted to ASCII lowercase.

    If a `charset` parameter is successfully parsed, set override charset to its value. 

4.6.8 The responseType attribute

client . responseType [ = value ]

    Returns the response type.

    Can be set to change the response type. Values are: the empty string (default), "arraybuffer", "blob", "document", "json", and "text".

    When set: setting to "document" is ignored if the JavaScript global environment is a worker environment

    When set: throws an InvalidStateError exception if the state is LOADING or DONE.

    When set: throws an InvalidAccessError exception if the synchronous flag is set and the JavaScript global environment is a document environment. 

The responseType attribute must return its value. Initially its value must be the empty string.

Setting the responseType attribute must run these steps:

    If the JavaScript global environment is a worker environment and the given value is "document", terminate these steps.

    If the state is LOADING or DONE, throw an InvalidStateError exception.

    If the JavaScript global environment is a document environment and the synchronous flag is set, throw an InvalidAccessError exception.

    Set the responseType attribute's value to the given value. 

4.6.9 The response attribute

client . response

    Returns the response's body. 

The response attribute must return the result of running these steps:

If responseType is the empty string or "text"

        If the state is not LOADING or DONE, return the empty string.

        Return the text response. 

Otherwise

        If the state is not DONE, return null.

        If responseType is "arraybuffer"

            Return the arraybuffer response. 
        If responseType is "blob"

            Return the blob response. 
        If responseType is "document"

            Return the document response. 
        If responseType is "json"

            Return the JSON response. 

4.6.10 The responseText attribute

client . responseText

    Returns the text response.

    Throws an InvalidStateError exception if responseType is not the empty string or "text". 

The responseText attribute must return the result of running these steps:

    If responseType is not the empty string or "text", throw an InvalidStateError exception.

    If the state is not LOADING or DONE, return the empty string.

    Return the text response. 

4.6.11 The responseXML attribute

client . responseXML

    Returns the document response.

    Throws an InvalidStateError exception if responseType is not the empty string or "document". 

The responseXML attribute must return the result of running these steps:

    If responseType is not the empty string or "document", throw an InvalidStateError exception.

    If the state is not DONE, return null.

    Return the document response. 

The responseXML attribute has XML in its name for historical reasons. It also returns HTML resources as documents.
4.7 Events summary

This section is non-normative.

The following events are dispatched on XMLHttpRequest and/or XMLHttpRequestUpload objects:
Event name 	Interface 	Dispatched when…
readystatechange 	Event 	The readyState attribute changes value, except when it changes to UNSENT.
loadstart 	ProgressEvent 	The fetch initiates.
progress 	ProgressEvent 	Transmitting data.
abort 	ProgressEvent 	When the fetch has been aborted. For instance, by invoking the abort() method.
error 	ProgressEvent 	The fetch failed.
load 	ProgressEvent 	The fetch succeeded.
timeout 	ProgressEvent 	The author specified timeout has passed before the fetch completed.
loadend 	ProgressEvent 	The fetch completed (success or failure).

## 5 Interface FormData

typedef (File or USVString) FormDataEntryValue;

[Constructor(optional HTMLFormElement form),
 Exposed=(Window,Worker)]
interface FormData {
  void append(USVString name, Blob value, optional USVString filename);
  void append(USVString name, USVString value);
  void delete(USVString name);
  FormDataEntryValue? get(USVString name);
  sequence<FormDataEntryValue> getAll(USVString name);
  boolean has(USVString name);
  void set(USVString name, Blob value, optional USVString filename);
  void set(USVString name, USVString value);
  iterable<USVString, FormDataEntryValue>;
};

The FormData object represents an ordered list of entries. Each entry consists of a name and a value.

For the purposes of interaction with other algorithms, an entry's type is "string" if value is a string and "file" otherwise. If an entry's type is "file", its filename is the value of entry's value's name attribute.

To create an entry for name, value, and optionally a filename, run these steps:

    Let entry be a new entry.

    Set entry's name to name.

    If value is a Blob object and not a File object, set value to a new File object, representing the same bytes, whose name attribute value is "blob".

    If value is a File object and filename is given, set value to a new File object, representing the same bytes, whose name attribute value is filename.

    Set entry's value to value.

    Return entry. 

The FormData(form) constructor must run these steps:

    Let fd be a new FormData object.

    If form is given, set fd's entries to the result of constructing the form data set for form.

    Return fd. 

The append(name, value, filename) method must run these steps:

    Let entry be the result of create an entry with name, value, and filename if given.

    Append entry to FormData object's list of entries. 

The delete(name) method must remove all entries whose name is name.

The get(name) method must return the value of the first entry whose name is name, and null otherwise.

The getAll(name) method must return the values of all entries whose name is name, in list order, and the empty sequence otherwise.

The set(name, value) method must run these steps:

    Let entry be the result of create an entry with name, value, and filename if given.

    If there are any entries whose name is name, replace the first such entry with entry and remove the others.

    Otherwise, append entry to FormData object's list of entries. 

The has(name) method must return true if there is an entry whose name is name, and false otherwise.

The value pairs to iterate over are the entries with the key being the name and the value the value.

## 6 Interface ProgressEvent

```javascript
[Constructor(DOMString type, optional ProgressEventInit eventInitDict),
 Exposed=(Window,Worker)]
interface ProgressEvent : Event {
  readonly attribute boolean lengthComputable;
  readonly attribute unsigned long long loaded;
  readonly attribute unsigned long long total;
};

dictionary ProgressEventInit : EventInit {
  boolean lengthComputable = false;
  unsigned long long loaded = 0;
  unsigned long long total = 0;
}
```

Events using the ProgressEvent interface indicate some kind of progression.

The lengthComputable, loaded, and total attributes must return the value they were initialized to.

### 6.1 Firing events using the ProgressEvent interface

To fire an progress event named e given transmitted and length, fire an event named e with an event using the ProgressEvent interface that also meets these conditions:

    Set the loaded attribute value to transmitted.

    If length is not 0, set the lengthComputable attribute value to true and the total attribute value to length. 

### 6.2 Suggested names for events using the ProgressEvent interface

This section is non-normative.

The suggested type attribute values for use with events using the ProgressEvent interface are summarized in the table below. Specification editors are free to tune the details to their specific scenarios, though are strongly encouraged to discuss their usage with the WHATWG community to ensure input from people familiar with the subject.
type attribute value 	Description 	Times 	When
loadstart 	Progress has begun. 	Once. 	First.
progress 	In progress. 	Once or more. 	After loadstart has been dispatched.
error 	Progression failed. 	Zero or once (mutually exclusive). 	After the last progress has been dispatched.
abort 	Progression is terminated.
timeout 	Progression is terminated due to preset time expiring.
load 	Progression is successful.
loadend 	Progress has stopped. 	Once. 	After one of error, abort, timeout or load has been dispatched.

The error, abort, timeout, and load event types are mutually exclusive.

Throughout the web platform the error, abort, timeout and load event types have their bubbles and cancelable attributes initialized to false, so it is suggested that for consistency all events using the ProgressEvent interface do the same.

### 6.3 Security Considerations

For cross-origin requests some kind of opt-in, e.g. the CORS protocol defined in the Fetch Standard, has to be used before events using the ProgressEvent interface are dispatched as information (e.g. size) would be revealed that cannot be obtained otherwise. [FETCH]

### 6.4 Example

In this example XMLHttpRequest, combined with concepts defined in the sections before, and the HTML progress element are used together to display the process of fetching a resource.

```html
<!DOCTYPE html>
<title>Waiting for Magical Unicorns</title>
<progress id=p></progress>
<script>
  var progressBar = document.getElementById("p"),
      client = new XMLHttpRequest()
  client.open("GET", "magical-unicorns")
  client.onprogress = function(pe) {
    if(pe.lengthComputable) {
      progressBar.max = pe.total
      progressBar.value = pe.loaded
    }
  }
  client.onloadend = function(pe) {
    progressBar.value = pe.loaded
  }
  client.send()
</script>
```

Fully working code would of course be more elaborate and deal with more scenarios, such as network errors or the end user terminating the request.

## References

- [COOKIES] HTTP State Management Mechanism, Adam Barth. IETF. 
- [DOM] DOM, Anne van Kesteren, Aryeh Gregor and Ms2ger. WHATWG. 
- [DOMPS] DOM Parsing and Serialization, Travis Leithead. W3C. 
- [ECMASCRIPT] ECMAScript Language Specification. ECMA. 
- [ENCODING] Encoding, Anne van Kesteren. WHATWG. 
- [FETCH] Fetch, Anne van Kesteren. WHATWG. 
- [FILEAPI] File API, Arun Ranganathan and Jonas Sicking. W3C. 
- [HTML] HTML, Ian Hickson. WHATWG. 
- [HTTP] Hypertext Transfer Protocol -- HTTP/1.1, Roy Fielding, James Gettys, Jeffrey Mogul et al.. IETF. 
- [RFC2119]  Key words for use in RFCs to Indicate Requirement Levels, Scott Bradner. IETF. 
- [URL] URL, Anne van Kesteren. WHATWG. 
- [WEBIDL] Web IDL, Cameron McCormack. W3C. 
- [XML] Extensible Markup Language, Tim Bray, Jean Paoli, C. M. Sperberg-McQueen et al.. W3C. 
- [XMLNS]  Namespaces in XML, Tim Bray, Dave Hollander, Andrew Layman et al.. W3C. 
