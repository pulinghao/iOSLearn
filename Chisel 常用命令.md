# Chisel 常用命令

Chisel 官方wiki：https://github.com/facebook/chisel/wiki

## bmessage

根据方法名设置断点

语法

```shell
(lldb)bmessage <expression>
(lldb)bmessage -[MyView setFrame:]
(lldb)bmessage +[MyView awesomeClassMethod]
(lldb)bmessage -[0xabcd1234 setFrame:]
```

说明：一般设置断点，如果这个方法本类没有实现，是父类实现的，断点是无效的。*bmessage有效避免了这种缺陷，即使本类没有实现，也能设置上断点*。

在类的方法或实例的方法上设置一个符号断点，而不用担心层次结构中的哪个类实际实现了这个方法。神器神器 我们自定义的方法中可以打断点。系统实现的方法就懵逼啊





## pclass

查看某个对象所属类的继承关系

```shell
(lldb)pclass 0xffffffff
```

