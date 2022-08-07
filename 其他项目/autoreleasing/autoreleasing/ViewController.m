//
//  ViewController.m
//  autoreleasing
//
//  Created by pulinghao on 2022/8/6.
//

#import "ViewController.h"

//在文件中引入以下声明即可使用这两个函数
extern void _objc_autoreleasePoolPrint();//打印注册到自动释放池中的对象
extern uintptr_t _objc_rootRetainCount(id obj);//获取对象的引用计数

@interface ViewController ()

@end

@implementation ViewController


- (void)testAutoRelease
{
    __autoreleasing UIView* myView;
    
    NSLog(@"str retain count: %@", [myView valueForKey:@"retainCount"]);
    @autoreleasepool {
        myView = [UIView new];
        NSLog(@"str retain count: %@", [myView valueForKey:@"retainCount"]);
    }
    NSLog(@"outside autoreleasepool myView:%@", myView);
}

- (void)testAutoRelease2
{
    __autoreleasing NSString* str;

    NSLog(@"str retain count: %@", [str valueForKey:@"retainCount"]);
    @autoreleasepool {
        str = [NSString stringWithFormat:@"%@", @"ssuuuuuuuuuuuuuuuuuuuu"];
        // 注意这里 用 -fno-objc-arc 编译和arc结果不一样
        // -fno-objc-arc  结果 为1
        // 默认 arc结果 2
//        [str autorelease];
        NSLog(@"str retain count: %@", [str valueForKey:@"retainCount"]);
    }
    NSLog(@"str retain count: %@", [str valueForKey:@"retainCount"]);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self testAutoRelease];
    
//    [self testAutoRelease2];
    
    
    @autoreleasepool {
//        id __strong obj = [NSArray array];
//        id __strong obj = [[NSObject alloc] init];
        id __strong obj = [[NSObject alloc] init];
        id __autoreleasing o = obj;
        NSLog(@"obj retain count = %d", _objc_rootRetainCount(obj));
    }
//    NSLog(@"obj retain count = %d", _objc_rootRetainCount(obj));
}


@end
