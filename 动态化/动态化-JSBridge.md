- 动态化介绍
- 主流的动态化技术
- 动态化框架的结构



# 动态化介绍

在前端越来越火的年代，逐渐衍生出类似React Native、Flutter等开发套件。所达到的目的挺简单的，达到在多个平台下共用一份代码，节省开发成本，提高开发效率。其次，由于JavaScript语言的特殊性，能动态更新页面而不需要发版。



市场上，主流的动态化框架

<img src="https://intranetproxy.alipay.com/skylark/lark/0/2023/jpeg/82756350/1679584372140-db4f78a0-d41c-46a7-85e5-6a004b8fe858.jpeg" alt="img" style="zoom:50%;" />

在这里，根据渲染方式的不同分为两大流派：RN方案和Flutter。二者最大的区别，在于渲染机制的不同，RN采用平台原生控件的渲染，而Flutter采用了自绘控件。另外，包括对脚本的编译与执行、渲染前的布局、以及线程管理等，也有区别。

# JSBridge

在JSCore 和 V8 面世之前，我们来看下 JavaScript 是如何与Native通信的。

JavaScript 是运行在一个单独的 JS Context 中（例如，WebView 的 Webkit 引擎、JSCore）。由于这些 Context 与原生运行环境的天然隔离，我们可以将这种情况与 RPC（Remote Procedure Call，远程过程调用）通信进行类比，将 Native 与 JavaScript 的每次互相调用看做一次 RPC 调用。



在 JSBridge 的设计中，可以把前端看做 RPC 的客户端，把 Native 端看做 RPC 的服务器端，从而 JSBridge 要实现的主要逻辑就出现了：通信调用（Native 与 JS 通信） 和句柄解析调用。类似于一种C/S的方式。

<img src="https://intranetproxy.alipay.com/skylark/lark/0/2023/png/82756350/1679324162027-96f2cb08-0e98-45e0-bd41-bb666890ff8e.png" alt="img" style="zoom:50%;" />

## **JavaScript 调用 Native的方式**

主要有两种：注入 API 和 拦截 URL SCHEME。

1. 注入API

注入 API 方式的主要原理是，通过 WebView 提供的接口，向JavaScript 的 Context（window）中注入对象或者方法，让 JavaScript 调用时，直接执行相应的 Native 代码逻辑，达到 JavaScript 调用 Native 的目的。

- iOS的WKWebView：WKScriptMessageHandler回调
- Android：addJavascriptInterface 注入

例如，在前端页面index.html中有个按钮，点击之后，给iOS端发消息。

```html
<script>
  function sendMessage() {
    window.webkit.messageHandlers.hello.postMessage("Hello from JavaScript!");
  }
</script>
<button onclick="sendMessage()">Send Message</button>
```

对于 iOS 的 WKWebView，实例如下：

```objectivec
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"hello"];
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    [self.view addSubview:self.webView];
    // 加载本地的html资源
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *htmlUrl = [NSURL fileURLWithPath:htmlPath];
    [self.webView loadRequest:[NSURLRequest requestWithURL:htmlUrl]];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"hello"]) {
        NSLog(@"%@", message.body);
    }
}
```

输出

![img](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/82756350/1679670436968-7a40d291-f63b-4a70-9f57-770612ef118b.png)



1. 拦截 URL SCHEME

先解释一下 URL SCHEME：URL SCHEME是一种类似于url的链接，是为了方便app直接互相调用设计的，形式和普通的 url 近似，主要区别是 protocol 和 host 一般是自定义的。

例如: jsbridge://showToast?text=hello。

```html
<script>
  function showToast() {
    var text = document.getElementById("text").value;
    var url = "jsbridge://showToast?text=" + text;
    window.location.href = url;
  }
</script>
<input type="text" id="text" placeholder="Input text here">
<button onclick="showToast()">Show Toast</button>
```


拦截 URL SCHEME 的主要流程是：Web 端通过某种方式（例如 iframe.src）发送 URL Scheme 请求，之后 Native 拦截到请求并根据 URL SCHEME（包括所带的参数）进行相关操作。

在时间过程中，这种方式有一定的缺陷：

1) 使用 iframe.src 发送 URL SCHEME 会有 url 长度的隐患。

2) 创建请求，需要一定的耗时，比注入 API 的方式调用同样的功能，耗时会较长。

这个demo中，前端的代码 `window.location.href = url;`会进行重定向，跳转到 `jsbridge://showToast?text=hello` 这个地址，此时会被当前的页面捕获这个动作。从中拿到URL。

以下为iOS WKWebView拦截到这个请求之后，解析其中的字符串并处理

```objectivec
- (BOOL)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    if ([url.scheme isEqualToString:@"jsbridge"]) {
        NSString *host = url.host;
        if ([host isEqualToString:@"showToast"]) {
            NSString *text = [self getParameterFromUrl:url.absoluteString paramName:@"text"];
            NSLog(@"%@", text);
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return YES;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
    return YES;
}
```

Web发送URL请求的方法有这么几种：

1. a标签
2. `location.href`
3. 使用`iframe.src`
4. 发送ajax请求

这些方法，a标签需要用户操作，location.href可能会引起页面的跳转丢失调用，发送ajax请求Android没有相应的拦截方法，所以使用iframe.src是经常会使用的方案。



## **Native 调用 JavaScript 的方式**

相比于 JavaScript 调用 Native， Native 调用 JavaScript 较为简单，直接执行拼接好的 JavaScript 代码即可。

从外部调用 JavaScript 中的方法，因此 JavaScript 的方法必须在全局的 window 上。

iOS代码如下：

```objectivec
[webView evaluateJavaScript:@"执行的JS代码" completionHandler:^(id _Nullable response, NSError * _Nullable error) {

}];
```

Android代码如下：

```java
String jsCode = String.format("window.showWebDialog('%s')", text);
webView.evaluateJavascript(jsCode, new ValueCallback<String>() {
    @Override
    public void onReceiveValue(String value) {

    }
});
```



## JavaScriptCore & V8

将Native方法直接暴露给JS，打通两端的数据通道。。

### 实现一个加法运算

1. 创建JSContext上下文环境

```objectivec
// Create a JSContext object
JSContext *context = [[JSContext alloc] init];

// Define a JavaScript function
NSString *jsFunction = @"function add(a, b) { return a + b; }";

// Evaluate the JavaScript function in the context
[context evaluateScript:jsFunction];

// Call the JavaScript function from Objective-C
JSValue *result = [context evaluateScript:@"add(2, 3)"];
```

1. 设置要执行的JS脚本
2. 执行JS脚本，第一次 evaluateScript ，定义了javaScript中的那个方法
3. 执行JS脚本`add(2, 3)`，第二次 evaluateScript ，执行了第一次定义的add方法

# 

# 类RN方案

## 从一个Demo说起





# JSBridge



## JavaScriptCore