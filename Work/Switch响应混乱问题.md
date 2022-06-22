# Switch响应混乱问题

在Cell中，使用UISwitch，记得先removeTarget，再添加target，否则点击单个Switch，会响应多个事件。

```objective-c
// add target/action for particular event. you can call this multiple times and you can specify multiple target/actions for a particular event.    // passing in nil as the target goes up the responder chain. The action may optionally include the sender and the event in that order    // the action cannot be NULL. Note that the target is not retained.    
 - (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
```



```objective-c
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   BMSystemConfigPageCell *cell = nil;
    static NSString *switchIdentifier = @"switchIdentifier";
     cell = [tableView dequeueReusableCellWithIdentifier:switchIdentifier];
      if (cell == nil) {
           cell = [[BMSystemConfigPageSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:switchIdentifier];
           cell.allowSelection = NO;
      }
      BMSystemConfigPageSwitchCell *switchCell = (BMSystemConfigPageSwitchCell *)cell;
      [switchCell.switchView setOn:[self.class getUserAddrSync]];
       // 重点看这里！！！
  	   // 必须先移除，再添加
       [switchCell.switchView removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
      [switchCell.switchView addTarget:self action:@selector(onSwitchUserAdrrSync:) forControlEvents:UIControlEventValueChanged];
      [dic setObject:@"同步至账号为你提供更便捷出行方式" forKey:@"subTitle"];
      [dic setObject:@"常用地址同步至账号" forKey:@"title"];
}
```

老系统中，cell没有超出一个屏幕时，reloadData时，每个cell的位置不变化，不会发生复用

原因是，在iOS 15.1.1系统中，整个页面的cell没有超出一屏，reloadData时，每个cell的位置会发生变化，导致cell复用，多次调用addTarget那个接口。添加多个action。