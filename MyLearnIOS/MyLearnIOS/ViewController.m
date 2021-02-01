//
//  ViewController.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/16.
//

#import "ViewController.h"
#import "KVOPerson.h"
#import "RuntimeLearn.h"
#import "MyCopy.h"
#import <objc/runtime.h>
#import "Person.h"
#import "PLHThread.h"
#import "LockLearn.h"
#import "TaggerPointerLearn.h"
extern void instrumentObjcMessageSends(BOOL);
@interface ViewController ()

@property (nonatomic, strong) LockLearn *lockLearn;
@property (nonatomic, strong) TaggerPointerLearn *taggerpointer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    instrumentObjcMessageSends(YES);
//    RuntimeLearn *runteim = [[RuntimeLearn alloc] init];
//    
//    [runteim resolve];
    
//    [[Person new] walk];
    instrumentObjcMessageSends(NO);
    
//    PLHThread *thread = [[PLHThread alloc] initWithBlock:^{
//        [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//            NSLog(@"定时打招呼!!!");
//        }];
//        [[NSRunLoop currentRunLoop] run];
//    }];
    
//    [thread start];
    
//    typedef union {
//        int a;
//        float b;
//    }UnionType;
//    UnionType type;
//    type.a = 3;
//
//    NSLog(@"a --> %p",&type.a);
//    NSLog(@"b --> %p",&type.b);
//    NSLog(@"zd --> %p",sizeof(UnionType));
    
//    self.lockLearn = [[LockLearn alloc] init];
    self.taggerpointer = [[TaggerPointerLearn alloc] init];
    [self.taggerpointer testTaggerPointer];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.taggerpointer touchBegin];
}

- (void)learnRunloop
{
    CFRunLoopRef mainRunLoop = CFRunLoopGetMain();
    CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent();
    
    CFRunLoopMode mode = CFRunLoopCopyCurrentMode(mainRunLoop);
    
    CFArrayRef array = CFRunLoopCopyAllModes(mainRunLoop);
    
}

- (void)sourceTest
{
    CFRunLoopSourceContext context = {
           0,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
    };
    CFRunLoopSourceRef source0 = CFRunLoopSourceCreate(CFAllocatorGetDefault(), 0, &context);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source0, kCFRunLoopDefaultMode);
}

- (IBAction)testLock:(id)sender {
    [self.lockLearn POSIX_Codictions];
}


@end
