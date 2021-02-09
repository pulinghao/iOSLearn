//
//  RuntimeVC.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/23.
//

#import "RuntimeVC.h"
#import <objc/runtime.h>
#import "RuntimeLearn.h"

@interface RuntimeVC ()

@property (nonatomic, strong) RuntimeLearn *learn;

@end

@implementation RuntimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self classTest];
    _learn = [[RuntimeLearn alloc] init];
    [_learn resolve];
    
}

void hunting(id self, SEL _cmd){
    NSLog(@"%s",__func__);
}
- (void)classTest
{
    // 创建一类对
    Class TZCat = objc_allocateClassPair([NSObject class], "TZCat", 0);

    // 添加实例变量
    NSString *name = @"name";
    class_addIvar(TZCat, name.UTF8String, sizeof(id),log2(sizeof(id)),@encode(id));
    
    // 添加方法
    class_addMethod(TZCat, @selector(hunting), (IMP)hunting, "v@:");

    objc_registerClassPair(TZCat);
    
    // 创建实例对象
    
    id cat = [[TZCat alloc] init];
    [cat setValue:@"Tom" forKey:@"name"];
    NSLog(@"name = %@",[cat valueForKey:@"name"]);
    
    // 方法调用
    [cat performSelector:@selector(hunting)];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
