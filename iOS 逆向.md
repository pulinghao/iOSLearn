# iOS 逆向

## 常用命令

``MSHookIvar``获取成员变量

```objective-c
[MSHookIvar<UITableView *>(self,"_tableView") endEditing:YES];
```

