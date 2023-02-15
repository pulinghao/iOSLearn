> 细心的读者会发现，大前端依赖的不是前端语言或者前端的各种编程框架，而是虚拟机和渲染引擎。——戴铭

本节重点介绍Week，围绕Weex的

- 使用

- 渲染流程
- 通信接口
- 原理

## 使用Weex

使用CoacoPods集成

<img src="/Volumes/MacHD_M2/Users/pulinghao/Github/iOSLearn/动态化/动态化Weex.assets/image-20230213004151337.png" alt="image-20230213004151337" style="zoom:50%;" />

在ViewController中引入Weex实例

```
- (void)viewDidLoad{
	[super viewDidLoad];
	_instance = [[WXSDKInstance alloc]] init];
	_instance.onCreate = ^(UIView *view){
		// 拿到weex渲染的view
		[weakSelf.weexView removeFromSuperView]; //清理掉原来的weexView
		weakSelf.weexView = view;
		[weakSelf.view addSubView:weakSelf.weexView];
	};
	_instance.onFailed = ^(NSError *error){
		//渲染失败
	}
	_instance.renderFinish = ^(UIVew *view){
		//处理redner finish
	}
	
	// 从网络加载模板
	[_instance.renderURL:url options:@{//配置}];
}
```



## 通信

### JavaScript调端能力

<img src="/Volumes/MacHD_M2/Users/pulinghao/Github/iOSLearn/动态化/动态化Weex.assets/image-20230213004723386.png" alt="image-20230213004723386" style="zoom:50%;" />

- 首先，需要实现的方法的类Your Native Module，需要遵循WXModuleProtocol
- 然后将这个Module，注册到WeekSDKEngine中
- 最后在前端JS里，通过weex.require("Your Native Module").showSomething("name")来调用方法

那么WeekEngine是如何注册这个ShowSomething方法的

- 通过NSClassFromString()的反射方法，获取注册的类，也就是当weex.require("Your Native Module")中的部分
-  然后执行一个查找方法的循环
  - 从当前的类的methodList查找方法（这个方法是在注册的时候，由wx_eport_method_+行号+方法名组成的，被注册在全局的Config中）
  - 判断这个方法名是否有前缀，
    - 如果有前缀，通过NSSelectorFromString的反射方法，构造这个方法
    - 否则继续查找
  - 找到的这个方法，会被以{name : method}的方式，存到本地的方法列表中



## 从Vue 到 JS Bundle

Weex中的.we文件，使用自己设计的DSL模板语法，也支持样式和JS，最终会被解析成JS可识别的对象，也就是JS Bundle。在解析 HTML语言的标签时，使用的npm组件parse 5，会将HTML标签解析后生成JSON对象。

不同的标签由不同的weex组件处理：

- CSS样式：weex-styler
- template: weex-template

### 端内运行JS Bundle的原理

在端内，通过JS Framework来解析生成好的 JSBundle。解析的结果，是JSON格式的Virtual Dom。

JS Framework会在WeexSDK初始化的时候执行。

