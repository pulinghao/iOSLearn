//
//  ViewController.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/16.
//
/**
 Union的用法
 typedef union {
     int a;
     float b;
 }UnionType;
 UnionType type;
 type.a = 3;

 NSLog(@"a --> %p",&type.a);
 NSLog(@"b --> %p",&type.b);
 NSLog(@"zd --> %p",sizeof(UnionType));
 */

    
#import "ViewController.h"
#import <objc/runtime.h>
#import "KVOPerson.h"
#import "RuntimeLearn.h"
#import "MyCopy.h"
#import "Person.h"
#import "PLHThread.h"
#import "LockLearn.h"
#import "TaggerPointerLearn.h"
#import "GCDLearn.h"
#import "NSOperationQueueLearn.h"
#import "AutoReleasePoolLearn.h"
#import "HItTestView.h"
extern void instrumentObjcMessageSends(BOOL);

typedef void (^MyBlock)(void);
typedef void(^OtherBlk)(int a);

typedef void(^testBlock)();

@interface homeViewControler : UIViewController
{
    NSOperationQueueLearn *_manager;
}
@property (nonatomic, assign) NSNumber *flag;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, copy)   MyBlock blk;




@end

@implementation homeViewControler
- (void)viewDidLoad
{
    self.blk = ^(void){
        if (self.flag) {
            self.name = @"the name";
            [_manager reloadData:self.name];
        }
        else
        {
            self.name = nil;
            [_manager clearData];
        }
    };
    
    
//    self.button.onClick = ^{
//        if (self.flag) {
//            self.name = @"the name";
//            [_manager reloadData:self.name];
//        }
//        else
//        {
//            self.name = nil;
//            [_manager clearData];
//        }
//    };
}
@end

@interface ViewController ()

@property (nonatomic, strong) LockLearn *lockLearn;
@property (nonatomic, strong) TaggerPointerLearn *taggerpointer;
@property (nonatomic, strong) RuntimeLearn *runtimeLearn;

@property (nonatomic, strong) AutoReleasePoolLearn *poolearn;
@property (nonatomic, strong) HItTestView *hitTestView;
@property (nonatomic, assign) Person *person;

@property (nonatomic, copy) testBlock block;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    instrumentObjcMessageSends(YES);
//    RuntimeLearn *runteim = [[RuntimeLearn alloc] init];
    
    self.lockLearn = [[LockLearn alloc] init];
    self.runtimeLearn = [[RuntimeLearn alloc] init];
    
    
//
//
//    BOOL ok = YES;
//    BOOL not = YES;
//    ok = not ?:not;
    
//    [self testBlock];
//    self.block();
//
//    [runteim resolve];
    
//    Person *person = [[Person alloc] init];
//    [person performSelector:@selector(swim)];
//    _poolearn = [[AutoReleasePoolLearn alloc] init];
//
//    Person *a = [[Person alloc] init];
//    NSLog(@"%p",&a);
//    NSLog(@"%p",a);
//    self.person = a;
//    NSLog(@"%p",&_person);
//    NSLog(@"%p",_person);
//    [self.person doSomeThing];
//
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self performSelector:@selector(delayFunc) withObject:nil afterDelay:1.0];
//    });
    
//    
//    [runteim resolve];
    
    [[Person new] testKindOfClass];
    instrumentObjcMessageSends(NO);
    
    self.hitTestView = [[HItTestView alloc] initWithFrame:CGRectMake(50, 100, 100, 50)];
    self.hitTestView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.hitTestView];
    
//    PLHThread *thread = [[PLHThread alloc] initWithBlock:^{
//        [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//            NSLog(@"定时打招呼!!!");
//        }];
//        [[NSRunLoop currentRunLoop] run];
//    }];
    
//    [thread start];



    
//    self.taggerpointer = [[TaggerPointerLearn alloc] init];
//    [self.taggerpointer testTaggerPointer];

    GCDLearn *gcd = [[GCDLearn alloc] init];
    [gcd meituanInterview];
//    [gcd useTargetQueue2];
//    
//    NSOperationQueueLearn *quelearn = [[NSOperationQueueLearn alloc] init];
//    [quelearn testQueue];
    
    NSLog(@"1");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"2");
    });
    NSLog(@"3");
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%p",&_person);
    NSLog(@"%p",_person);
//    [self.person doSomeThing];
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
//    [self.lockLearn testRecursiveLock];
    [self.lockLearn testTwoThreadLock];
}

- (IBAction)autoReleasePoolClick:(id)sender {
    [_poolearn withoutAutoreleasepoolClick];
}

- (void)testBlock
{
    __block int a = 10;
    self.block = ^{
        NSLog(@"%s",__func__);
        NSLog(@"a = %d",a);
    };
    a = 20;
}

- (void)delayFunc
{
    NSLog(@"%s",__func__);
}
@end
