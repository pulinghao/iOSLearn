# HTTP

## 版本演进

| 版本号 | 特点                                                         | 缺点                                                         |
| ------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 0.9    | get                                                          |                                                              |
| 1.0    | post请求头，建立TCP                                          | <font color='red'>无状态</font>（服务器处理完后，断开连接）  |
| 1.1    | 1. 使用最广泛<br>2.<font color='red'>长连接（默认不关闭）</font>，被多个请求复用，基于TCP `Connection:keep alive`实现<br>3.管道机制，客户端能同时发多个请求，但是服务端还是**单管道**，队头堵塞(不允许两个并行的响应) | 不安全<br>高延迟<br>不支持推送                               |
| 2.0    | 1.多路复用，修复管道机制，避免队头阻塞（Socket半全工）<br>2.二进制分帧，传输<br>3.`Header`信息压缩，每次请求会携带很多信息，都是一模一样的相同内容<br>4.服务器自推送<br>5.无状态 节省依赖性<br>6.Cookie | 队头阻塞未解决（多个请求在第一个TCP管道中，一旦丢包，需要等待重传） |
| 3.0    | google提出                                                   |                                                              |

## 长连接

### keep-alive的限制

- 1.0中默认不打开，客户端必须发送一个Connection:keep-alive打开
- 实体主体，必须有准确的Content-Length，如果传错了，另一端就无法检测出报文的结束和另一条报文的开始

## 多路复用

多路复用：解决了浏览器限制同一个域名下的请求数量的问题，只通过**一个TCP链接**就可以传输所有的请求数据

HTTP 1.0 不能多路复用，它是基于文本分割的协议

HTTP 2.0 可以多路复用，它是基于二进制 帧的协议



## 结构

HTTP报文是由**一行一行的字符串**组成。

- 纯文本
- 非二进制代码

### 请求报文

| 说明   | 内容                                     |
| ------ | ---------------------------------------- |
| 起始行 | GET /test/hi-there.txt HTTP 1.0          |
| 首部   | Accept: text/*<br>Accept-Language: en,fr |

- 请求方式 POST or GET
- HTTP版本
- 接收的类型

### 响应报文

| 说明   | 内容                                          |
| ------ | --------------------------------------------- |
| 起始行 | HTTP 1.0 200 OK                               |
| 首部   | Content-type: text/plain<br>Content-length:19 |
| 主体   | Hi！this is  a test                           |

- HTTP版本
- 状态码
- 返回值类型
- 返回内容

## 缺点

明文通信：加密，通讯加密（SSL），对报文主体的内容加密（Base64，MD5）

没有身份验证，可以伪装攻击

- 无法确认服务端
- 无法确认客户端
- 是否有访问权限
- 证书 

无法验证报文的完整性：中间人攻击，HTTPS

# HTTPS

## SSL握手



![img](/Users/pulinghao/Github/iOSLearn/源码阅读/AFN/AFNetworking源码解读.assets/https-intro.png)

1. 客户端发送请求给服务端，服务端（有私钥和公钥，由自己或者CA机构生成）
2. 服务端返回**公钥**
3. 客户端（TLS完成）向CA机构验证**公钥**，如果没问题，生成随机Key
4. 使用**公钥**，加密传输随机Key
5. 服务端使用**私钥**解密（因为客户端使用服务端的公钥加密的），获取Key，使用Key 隐藏内容
6. 使用客户端Key响应加密内容，
7. 客户端使用Key解密内容（这里是对称加密，这个秘钥就是key）

> RSA主要是用于验证签名是否有效。公钥是公开的.所以我们不会用于私钥加密核心数据.但是利用私钥加密也会有应用场景.比如我们会用于签名.然后客户端利用公钥去验证签名.比如:App Store有一个私钥.iOS系统内置一个公钥.iOS系统如何知道APP是苹果发布的呢?利用公钥验证App Store的私钥签名.当然实际上苹果利用双向验证,更加复杂.但核心就是这个思路.



数字签名：在服务端下发公钥之前，服务端会找双方都可信赖的第三方CA（数字证书认证机构）。CA会对公钥做数字签名。

HTTPS 既使用到了RAS 加密 和 对称加密。

非对称加密：耗时，耗性能