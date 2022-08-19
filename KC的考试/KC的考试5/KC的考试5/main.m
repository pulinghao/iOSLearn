//
//  main.m
//  KC的考试5
//
//  Created by pulinghao on 2022/8/19.
//

#import <Foundation/Foundation.h>

typedef void (^blk)(void);
@interface KCObject : NSObject

@property (nonatomic, strong) blk doWork;
@property (nonatomic, strong) blk doStudent;
@end

@implementation KCObject

- (void)test{
    __weak typeof(self) weakSelf = self;
    self.doWork = ^{
        __block typeof(self) strongSelf = weakSelf;
        weakSelf.doStudent = ^{
            NSLog(@"%@",strongSelf);
//            strongSelf = nil;
//            NSLog(@"strong self count %ld",CFGetRetainCount((__bridge CFTypeRef)(strongSelf)));
        };
        weakSelf.doStudent();
    };
    self.doWork();
}

- (void)dealloc{
    NSLog(@"dealloc");
}
@end
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        KCObject *o = [[KCObject alloc] init];
        [o test];
    }
    return 0;
}
