//
//  main.m
//  KC的考试3
//
//  Created by pulinghao on 2022/8/19.
//

#import <Foundation/Foundation.h>

typedef void (^_LGBlock)(void);
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        int a = 0;
        void(^__weak weakBlock)(void) = ^{
            NSLog(@"-----%d",a);
        };
        
        struct _LGBlock *blc = (__bridge struct _LGBlock *)weakBlock;
        id __strong strongBlock = [weakBlock copy];
        
//        blc->invoke = nil;
        void(^strongBlock1)(void) = strongBlock;
        strongBlock1();
    }
    return 0;
}
