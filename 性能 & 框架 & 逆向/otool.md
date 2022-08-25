- 查看动态链接库

```shell
$ otool -L  /Applications/Pomotodo.app/Contents/MacOS/Pomotodo 
```

- 查看 Mach-O头结构等

```shell
$ otool -h 可执行文件
```

- 查看汇编码

```shell
$ otool -tV yourapp
```

- 逆向某个段

```shell
$ otool -v -s __DATA __objc_selrefs
```

逆向__DATA.__objc_selrefs段，提取可执行文件里引用到的方法名

通过otool命令逆向__DATA.__objc_classlist段和__DATA.__objc_classrefs段来获取当前所有oc类和被引用的oc类