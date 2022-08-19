//
//  main.m
//  KC的考试1
//
//  Created by pulinghao on 2022/8/19.
//

#import <Foundation/Foundation.h>

typedef void (^blk)(void);
@interface Person : NSObject
@property (nonatomic, strong) blk p_blk;
@property (nonatomic, strong) NSObject *obj;

@end

@implementation Person
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.obj = [[NSObject alloc] init];
    }
    return self;
}


/// 构造一个堆上对象，看下block修饰
- (void)testBlock{
    NSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)(self.obj)));
    __block NSObject *obj = self.obj; // 变量在堆上，产生强引用
    void(^block4)(void) = ^{
        NSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)(obj)));
    };
    block4();
    NSLog(@"%@",block4); //输出2
    
    __block NSObject *obj2 = [NSObject new]; // 变量在栈上，不产生强引用
    void(^block5)(void) = ^{
        NSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)(obj2)));
    };
    block5();
    NSLog(@"%@",block5); //输出1
    // arc下输出 2 2 1 都是堆block
    // mrc下输出 2 2 1 都是栈block
}


@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person *p = [[Person alloc] init];
        [p testBlock];
        // insert code here...
        NSObject *objc = [NSObject new];
        NSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)(objc)));
        
        void (^block1)(void) = ^{
            NSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)(objc)));
        };
        block1();
        
        void(^__weak block2)(void) = ^{
            NSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)(objc)));
        };
        block2();
        
        void(^block3)(void) = [block2 copy];
        block3();
        
        __block NSObject *obj = [NSObject new]; // 变量在栈上，不产生强引用
        void(^block4)(void) = ^{
            NSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)(obj)));
        };
        NSLog(@"%@",block4);
        block4();
        
        
        //mrc下输出 1 1 1 2 1
        //arc下输出 1 3 4 5 1
    }
    return 0;
}
