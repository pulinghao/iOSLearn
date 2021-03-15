//
//  ViewController.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/16.
//

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
    
    BOOL ok = YES;
    BOOL not = YES;
    ok = not ?:not;
    
    
//    [runteim resolve];
    
    Person *person = [[Person alloc] init];
    [person performSelector:@selector(swim)];
    _poolearn = [[AutoReleasePoolLearn alloc] init];
   
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
    

    
//    self.taggerpointer = [[TaggerPointerLearn alloc] init];
//    [self.taggerpointer testTaggerPointer];

    GCDLearn *gcd = [[GCDLearn alloc] init];
    [gcd useTargetQueue2];
//    
//    NSOperationQueueLearn *quelearn = [[NSOperationQueueLearn alloc] init];
//    [quelearn testQueue];
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
    [self.lockLearn testRecursiveLock];
}

- (IBAction)autoReleasePoolClick:(id)sender {
    [_poolearn withoutAutoreleasepoolClick];
}

@end
