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

#import "NSOperationQueueVC.h"
#import "RunLoopVC.h"
#import "MyProxy.h"
#import "YYWeakProxy.h"
#import "LinkPerson.h"
extern void instrumentObjcMessageSends(BOOL);
extern void _objc_autoreleasePoolPrint(void);

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

@property (nonatomic, assign) Person *person;

@property (weak, nonatomic) IBOutlet UIButton *runLoopBtn;
@property (nonatomic, copy) testBlock block;
@property (weak, nonatomic) IBOutlet UIButton *showOpQueueVC;


@property (nonatomic, strong) UIView* myView;

@property (nonatomic, strong) UILabel *myLabel;;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    instrumentObjcMessageSends(YES);
    
    Calculator *calc = [[Calculator alloc] init];
        BOOL isEqual = [[calc calculate:^int(int result) {
            NSLog(@"init result ->%d",result);
            result += 2;
            result *= 5;
            return result;
        }] equal:^BOOL(int result) {
            return result == 10;
        }];

        NSLog(@"isEqual:%d", isEqual);
//    RuntimeLearn *runteim = [[RuntimeLearn alloc] init];
    
    self.lockLearn = [[LockLearn alloc] init];
    self.runtimeLearn = [[RuntimeLearn alloc] init];
    
    MyDog *dog = [MyDog new];
//    id proxy = [MyProxy proxyWithObj:dog];
//    [proxy barking:4];
    
    id p = [YYWeakProxy proxyWithTarget:dog];
//    [p performSelector:@selector(doSomething)];
    [p barking:4];
    
//    _myLabel = [[UILabel alloc] init];
//    _myLabel.text = @"1000+kg";
//    _myLabel.font = [UIFont systemFontOfSize:10];
//    _myLabel.frame = CGRectMake(10, 120, 200, 50);
//    _myLabel.numberOfLines = 1;
//    _myLabel.adjustsFontSizeToFitWidth = YES;
//    _myLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
//    _myLabel.minimumScaleFactor = 1.0;
//    [self.view addSubview:_myLabel];
    
//    [self addLabelWithFrame: CGRectMake(0, 100, 320, 100)
//         baselineAdjustment: UIBaselineAdjustmentAlignCenters];
//
//    [self addLabelWithFrame: CGRectMake(0, 210, 320, 100)
//         baselineAdjustment: UIBaselineAdjustmentAlignBaselines];
    
    [self gcd_dispatch_semaphore];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"jack" forKey:@"name"];
    dict[@"name"] = @"jack"; //@{@"name":@"jack"},等效于[mutableDictionary setObject:value forKeyedSubscript:@"name"];
    dict[@"name"] = nil;     //@{}

    [dict setObject:nil forKeyedSubscript:@"sex"];
//    [dict setObject:nil forKey:@"sex"];   //崩溃
//    id value = @"someValue";
//    dict[@"someKey"] = value; //
    [self testMultiBlock];
//    _myView = [[UIView alloc] initWithFrame:CGRectMake(10, 120, 100, 50)];
//    _myView.backgroundColor = [UIColor blueColor];
//    [self.view addSubview:_myView];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(10, 200, 100, 50)];
//        view2.backgroundColor = [UIColor redColor];
//        [self.view addSubview:view2];
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//        });

    });
    
//    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(10, 200, 100, 50)];
//    view2.backgroundColor = [UIColor redColor];
//    [self.view addSubview:view2];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.view addSubview:view2];
//    });
    
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
    

    _poolearn = [[AutoReleasePoolLearn alloc] init];
   
   
    
//    
//    [runteim resolve];
    
    [[Person new] testKindOfClass];

    instrumentObjcMessageSends(NO);
    


    
//    self.taggerpointer = [[TaggerPointerLearn alloc] init];
//    [self.taggerpointer testTaggerPointer];

    GCDLearn *gcd = [[GCDLearn alloc] init];
//    [gcd test5];
    [gcd userDispatchTimer];
//    
//    NSOperationQueueLearn *quelearn = [[NSOperationQueueLearn alloc] init];
//    [quelearn testQueue];
    
//    NSLog(@"1");
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSLog(@"2");
//    });
//    NSLog(@"3");
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        id array = [NSMutableArray arrayWithCapacity:1];
        id __unsafe_unretained array_1 = [NSMutableArray array];
        id array_2 = [NSMutableArray array];
        id __weak weakArray = [NSMutableArray arrayWithCapacity:1];
        id __unsafe_unretained unsaferetainedArray = [NSMutableArray arrayWithCapacity:1];
        NSLog(@"array: %p", array);
        NSLog(@"array_1: %p", array_1);
        NSLog(@"array_2: %p", array_2);
        NSLog(@"weakArray: %p", weakArray);
        NSLog(@"unsaferetainedArray: %p", unsaferetainedArray);
        _objc_autoreleasePoolPrint();
    });
}

- (void)viewDidAppear:(BOOL)animated
{
//    NSLog(@"%p",&_person);
//    NSLog(@"%p",_person);
//    [self.person doSomeThing];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.taggerpointer touchBegin];
}

- (void) addLabelWithFrame: (CGRect) f baselineAdjustment: (UIBaselineAdjustment) bla
{
    UILabel* label = [[UILabel alloc] initWithFrame: f];
    label.baselineAdjustment = bla;
    label.adjustsFontSizeToFitWidth = YES;
    label.font = [UIFont fontWithName: @"Courier" size: 20];
    label.text = @"00";
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor lightGrayColor];
    label.userInteractionEnabled = YES;
    [self.view addSubview: label];

    UIView* centerline = [[UIView alloc] initWithFrame: CGRectMake(f.origin.x, f.origin.y+(f.size.height/2.0), f.size.width, 1)];
    centerline.backgroundColor = [UIColor redColor];
    [self.view addSubview: centerline];

    UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(onTap:)];
    [label addGestureRecognizer: tgr];
}


- (void) onTap: (UITapGestureRecognizer*) tgr
{
    UILabel* label = (UILabel*)tgr.view;
    NSString* t = [label.text stringByAppendingString: @":00"];
    label.text = t;
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


- (IBAction)showVC2:(id)sender {
   
    NSOperationQueueVC *vc = [NSOperationQueueVC new];
    [self.navigationController pushViewController:vc animated:YES];
    NSDictionary *userInfo = @{
        @"name":@"Notification",
        @"age":@"18",
        @"height":@"188cm"
    };
    
    // 不执行方法
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"kFirstToSecondNotification" object:nil userInfo:userInfo];
    
    // method1
    // 执行方法，执行通知
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSDictionary *userInfo = @{
                @"name":@"Notification",
                @"age":@"18",
                @"height":@"188cm"
            };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kFirstToSecondNotification" object:nil userInfo:userInfo];
        [vc doSomething];
    }];
    
    
    // method2
    dispatch_async(dispatch_get_main_queue(), ^{
//            NSDictionary *userInfo = @{@"name":@"Notification",@"age":@"18",@"height":@"188cm"};
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"kFirstToSecondNotification" object:nil userInfo:userInfo];
    [vc doSomething];
        });
    
}

#pragma mark dispatch_semaphore信号量
- (void)gcd_dispatch_semaphore {
    //打印当前线程
    NSLog(@"currentThread---%@",[NSThread currentThread]);
    NSLog(@"semaphore---begin");
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSInteger number = 0;
    dispatch_async(queue, ^{
        // 追加任务1
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        //打印当前线程
        NSLog(@"1---%@",[NSThread currentThread]);
        number = 100;
        dispatch_semaphore_signal(semaphore);
        [NSThread sleepForTimeInterval:0.01];
        NSLog(@"2---%@",[NSThread currentThread]);
        
        number = 200;
        NSLog(@"3---%@",[NSThread currentThread]);
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"semaphore---end,number = %ld",(long)number);
}


//输出结果：
//2020-07-06 15:28:49.979677+0800 GCD[2989:1190741] currentThread---<NSThread: 0x2804b4f80>{number = 1, name = main}
//2020-07-06 15:28:49.979764+0800 GCD[2989:1190741] semaphore---begin
//2020-07-06 15:28:51.984955+0800 GCD[2989:1190767] 1---<NSThread: 0x28048f400>{number = 3, name = (null)}
//2020-07-06 15:28:51.985111+0800 GCD[2989:1190741] semaphore---end,number = 100



- (void)testMultiBlock
{
    [self sendIntBlock:^(int x) {
        NSLog(@"x:%d",x);
    }];
    
    int c = [self returnIntBlock:^int(double x) {
        return x + 10;
    }];
    
    NSLog(@"mulitiBlock c:%d",c);
}

- (void)sendBlock:(void (^)(void))blk{
    blk();
}

- (void)sendIdBlock:(void (^)(id x))blk
{
    id obj = [[NSObject alloc] init];
    blk(obj);
}
- (void)sendIntBlock:(void (^)(int x))blk{
    int x = 10;
    blk(x);
}

- (int)returnIntBlock:(int (^)(double x))blk
{
    int a = 10;
    return blk(a);
}
@end
