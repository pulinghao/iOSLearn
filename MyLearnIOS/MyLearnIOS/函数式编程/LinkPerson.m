//
//  LinkPerson.m
//  MyLearnIOS
//
//  Created by pulinghao on 2022/3/11.
//

#import "LinkPerson.h"

/**
 链式编程
 
 1. 返回值  -(类型 * (^)(参数))
 2. 内部构造block，block构造实现体
 3. 实现体内部必须返回self
 4. 函数必须返回block
 */

@implementation LinkPerson

- (LinkPerson *)run{
    NSLog(@"run");
    return [[LinkPerson alloc] init];
}

- (LinkPerson *)study{
    NSLog(@"study");
    return [[LinkPerson alloc] init];
}

// 类型一定是 类 *(^)()
- (LinkPerson *(^)())runBlk{
    // 构造返回的Block
    LinkPerson * (^blk)() = ^(){
        NSLog(@"run");
        return self; //一定是返回self
    };
    return blk; //一定是blk
}

- (LinkPerson *(^)())studyBlk{
    LinkPerson * (^blk)() = ^(){
        NSLog(@"study");
        return self;
    };
    return blk;
}


@end


@implementation Calculator
- (Calculator *)calculate:(int (^)(int result))calculate {
    self.result = calculate(self.result);
    return self;
}
- (BOOL)equal:(BOOL (^)(int result))operation {
    return operation(self.result);
}
@end
