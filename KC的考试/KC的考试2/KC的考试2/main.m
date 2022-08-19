//
//  main.m
//  KC的考试2
//
//  Created by pulinghao on 2022/8/19.
//

#import <Foundation/Foundation.h>

@interface KCObject : NSObject

@property (nonatomic, strong) NSMutableArray *mArray;

@end

@implementation KCObject

- (NSMutableArray *)mArray{
    if (!_mArray) {
        _mArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _mArray;
}

- (void)test{
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"1",@"2", nil];
    self.mArray = arr;
    
    void(^kcBlock)(void) = ^{
        NSLog(@"%p",&arr);
        [arr addObject:@"3"];
        [self.mArray addObject:@"a"];
        NSLog(@"KC %@",arr);
        NSLog(@"Cooci: %@",self.mArray);
    };
    [arr addObject:@"4"];
    [self.mArray addObject:@"5"];
    
    NSLog(@"%p",&arr);
    arr = nil;
    self.mArray = nil;
    
    kcBlock();
}

@end

void testDemo(){
    dispatch_queue_t queue = dispatch_queue_create("cooci", NULL);
    
    NSLog(@"1");
    dispatch_async(queue, ^{
        NSLog(@"2");
        dispatch_sync(queue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
       
        KCObject *object = [[KCObject alloc] init];
        [object test];
        
    }
    return 0;
}
