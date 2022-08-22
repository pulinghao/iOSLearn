//
//  ViewController.m
//  KC的考试6
//
//  Created by pulinghao on 2022/8/19.
//

#import "ViewController.h"



@interface ViewController ()


@property (nonatomic, strong) NSMutableArray *mArray;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mArray = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
//    [self demo3];
    
//    [self testBlock];
}

- (void)testBlock{
    
}



- (void)demo3{
//    dispatch_queue_t con = dispatch_get_global_queue(0, 0);
    dispatch_queue_t con = dispatch_queue_create("cooci", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 5000; i++) {
        dispatch_async(con, ^{
            NSString *name = [NSString stringWithFormat:@"%d.jpg",i % 10];
            NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:nil];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:data];
            dispatch_barrier_sync(con, ^{
                [self.mArray addObject:image];
            });
        });
        
    }
    NSLog(@"plh");
}

- (void)demo2{
//    dispatch_queue_t concurrentQueue = dispatch_queue_create("cooci", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(0, 0);
    /* 1.异步函数 */
    dispatch_async(concurrentQueue, ^{
        for (NSUInteger i = 0; i < 5; i++) {
            NSLog(@"download1-%zd-%@",i,[NSThread currentThread]);
        }
    });
    
    dispatch_async(concurrentQueue, ^{
        for (NSUInteger i = 0; i < 5; i++) {
            NSLog(@"download2-%zd-%@",i,[NSThread currentThread]);
        }
    });
    
    /* 2. 栅栏函数 */
    dispatch_barrier_sync(concurrentQueue, ^{
        NSLog(@"---------------------%@------------------------",[NSThread currentThread]);
    });
    NSLog(@"加载那么多,喘口气!!!");
    /* 3. 异步函数 */
    dispatch_async(concurrentQueue, ^{
        for (NSUInteger i = 0; i < 5; i++) {
            NSLog(@"日常处理3-%zd-%@",i,[NSThread currentThread]);
        }
    });
    NSLog(@"**********起来干!!");
    
    dispatch_async(concurrentQueue, ^{
        for (NSUInteger i = 0; i < 5; i++) {
            NSLog(@"日常处理4-%zd-%@",i,[NSThread currentThread]);
        }
    });
}

@end
