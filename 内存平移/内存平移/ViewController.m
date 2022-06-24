//
//  ViewController.m
//  内存平移
//
//  Created by pulinghao on 2022/6/23.
// 参考：https://www.jianshu.com/p/ba622e3abe40

#import "ViewController.h"
#import "Person.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
//    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    Class cls = [Person class];
//    void *kc = &cls;
//    [(__bridge  id)kc saySomething];
    
    Person *person = [Person alloc];
    void *sp = (void *)&self;
    void *end = (void *)&person;
    long count = (sp - end) / 0x8;
    for (long i = 0; i < count;i++){
        void *address = sp - 0x8 * i;
        if(i == 1){
            NSLog(@"%p : %s",address,*(char **)address);
        } else {
            NSLog(@"%p : %@",address,*(void **)address);
        }
    }
}


@end
