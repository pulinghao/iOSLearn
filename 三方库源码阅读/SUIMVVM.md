# [SUIMVVM](https://github.com/lovemo/MVVMFramework)

MVVM设计模式的一个三方框架



# Coding Tips

## 1. Block的使用

```objc
//声明一个返回值为NSArray *的匿名函数block
typedef NSArray *(^FirstModelArrayBlock)();

- (void)getDataWithModelArray:(FirstModelArrayBlock)modelArrayBlock completion:(void (^)())completion;

// 内部实现
- (void)getDataWithModelArray:(FirstModelArrayBlock)modelArrayBlock completion:(void (^)())completion {
    if (modelArrayBlock) {
        self.dataArrayList = modelArrayBlock();
        if (completion) {
            completion();
        }
    }
}

//接口调用
uWeakSelf
    self.hudView.hidden = NO;
   [self.viewModel smk_viewModelWithProgress:nil success:^(id responseObject) {
       self.hudView.hidden = YES;
       [weakSelf.firstTableViewModel getDataWithModelArray:^NSArray *{
           return responseObject;
       } completion:^{
            [weakSelf.table reloadData];
       }];
   } failure:^(NSError *error) {
       
   }];

```

这里，`getDataWithModelArray`接口需要的参数是一个数组，因为内部需要对`self.dataArrayList`赋值，赋值的方式是通过拿到Block的返回赋值的。因此Block内部直接`return responseObject`

